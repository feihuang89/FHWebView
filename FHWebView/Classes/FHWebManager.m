//
//  PKWebManager.m
//  WKWebView
//
//  Created by Africa on 17/2/10.
//  Copyright © 2017年 Africa. All rights reserved.
//

#import "FHWebManager.h"
#import <objc/runtime.h>
#import "FHWebViewProgressView.h"
#import "FHFileTool.h"

@interface FHWebManager ()<WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, weak) UIViewController <FHWebManagerDelegate> *delegate;

@end

@implementation FHWebManager

-(void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    NSLog(@"页面销毁");
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        //默认添加other类型url
        self.addWKNavigationTypeOther = YES;
        //默认控制url堆栈
        self.controlUrlArray = YES;
    }
    return self;
}

#pragma mark - public function
- (void)loadHTMLWithResource:(NSString *)resource type:(NSString *)type inDirectory:(NSString *)directory
{
    if (resource.length <= 0) return;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:resource ofType:type inDirectory:directory.length?directory:nil]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }else
    {
        //iOS8以下拷贝html文件夹到tmp  不然无法加载 可以拷贝单个文件
        NSString *fromPath = [[NSBundle mainBundle] pathForResource:directory.length?directory:resource ofType:directory.length?@"":type];
        
        [FHFileTool copyFileToTempDirWithFilePath:fromPath completionHandle:^(NSError *error, NSString *toPath) {
            NSURL *url = [[NSURL fileURLWithPath:toPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",resource,type]];
            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        }];
    }
}

- (void)reloadWhenTitleNull
{
    if (!self.webView.title) {
        [self.webView reload];
    }
}

- (void)removeWebkitCache
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
        //WKWebsiteDataTypeCookies 不删除cookie
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                        WKWebsiteDataTypeDiskCache,
                                                        WKWebsiteDataTypeOfflineWebApplicationCache,
                                                        WKWebsiteDataTypeMemoryCache,
                                                        WKWebsiteDataTypeLocalStorage,
                                                        WKWebsiteDataTypeSessionStorage,
                                                        WKWebsiteDataTypeIndexedDBDatabases,
                                                        WKWebsiteDataTypeWebSQLDatabases
                                                        ]];
        //你可以选择性的删除一些你需要删除的文件 or 也可以直接全部删除所有缓存的type
        //        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                   modifiedSince:dateFrom completionHandler:^{
                                                       // code
                                                       NSLog(@"delete webkit cache success!");
                                                   }];
    }else
    {
        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                   NSUserDomainMask, YES)[0];
        NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleIdentifier"];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        NSString *webKitFolderInCaches = [NSString
                                          stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        
        NSError *error;
        /* iOS8.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
    }
}

- (void)removeAllScriptMessageHandler
{
    //移除注册的js方法
    [self enumerateProtocalMethod:^(NSString *methodName) {
        [self.webView.configuration.userContentController removeScriptMessageHandlerForName:methodName];
    }];
}

//遍历协议中要求实现的实例方法
- (void)enumerateProtocalMethod:(void(^)(NSString *methodName))ProtocalMethodBlock
{
    unsigned int count = 0;
    Protocol * __unsafe_unretained protocal = objc_getProtocol("FHWebManagerDelegate");
    NSLog(@"%@", @(protocol_getName(protocal)));
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocal, YES, YES, &count);
    for (int i = 0; i < count; ++i) {
        struct objc_method_description method = methods[i];
        NSLog(@"%@", NSStringFromSelector(method.name));
        NSString *methodName = [NSStringFromSelector(method.name) stringByReplacingOccurrencesOfString:@":" withString:@""];
        ProtocalMethodBlock(methodName);
    }
}

- (void)bindWKWebViewWithFrame:(CGRect)frame delegate:(UIViewController <FHWebManagerDelegate>*)delegate
{
    self.delegate = delegate;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    
    //注册js方法
    [self enumerateProtocalMethod:^(NSString *methodName) {
        [config.userContentController addScriptMessageHandler:self name:methodName];
    }];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:frame configuration:config];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    self.webView = webView;
    [self.delegate.view addSubview:webView];
    
    //进度条
    FHWebViewProgressView *progressView = [[FHWebViewProgressView alloc] initWithFrame:CGRectMake(0, frame.origin.y, [UIScreen mainScreen].bounds.size.width, 2)];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //进度条颜色
    progressView.progressBarView.backgroundColor = [UIColor greenColor];
    [progressView setProgress:0 animated:YES];
    self.progressView = progressView;
    [self.delegate.view addSubview:progressView];
    
    //监听加载进度
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - 监听进度条进度
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [change[@"new"] floatValue];
        if (progress < 0.75) {
            progress = 0.75;
        }
        [self.progressView setProgress:progress animated:YES];
    }
}

#pragma mark - JS交互
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"回调的JS方法:%@",message.body);
    
    NSError *error = nil;
    NSDictionary *resultDict = nil;
    if ([message.body isKindOfClass:[NSString class]]) {  //字典
       resultDict = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    }else
    {
        resultDict = @{@"result":message.body};  //原始数据
    }
    
    if ((!error && resultDict)|| [message.body isEqual:@""]) {
        if ([self.delegate respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"%@:",message.name])]) {
            [self.delegate performSelectorOnMainThread:NSSelectorFromString([NSString stringWithFormat:@"%@:",message.name]) withObject:resultDict waitUntilDone:NO];
        }
    }
}

#pragma mark - WKUIDelegate
//在JS端调用alert函数时(警告弹窗)，会触发此代理方法
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    [self alertWithTitles:@[@"好"] message:message completionHandle:^(BOOL completed) {
        completionHandler();
    }];
}

//JS端调用confirm函数时(确认、取消式弹窗)，会触发此代理方法
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    [self alertWithTitles:@[@"取消",@"好"] message:message completionHandle:completionHandler];
}

//_blank标签打开新的frame时，触发
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - WKNavigationDelegate
//发送请求之前决定是否跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL allow = NO;
    
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        allow = [self.delegate webView:webView shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    }
    
    if (self.controlUrlArray) {  //如果不需要控制url堆栈，跳过添加到backList中的逻辑
        //该逻辑只控制url堆栈
        if (![self isSameHTMLPage:self.urlArray.lastObject andRequestURL:navigationAction.request.URL]) {
            
            NSLog(@"urlStr:%@",navigationAction.request.URL.absoluteString);
            
            if (!self.urlArray.count) {
                [self.urlArray addObject:navigationAction.request.URL];
            }else
            {
                void(^addUrlBlock)() = ^(){
                    NSString *lastUrlStr = [[[self.urlArray.lastObject absoluteString] componentsSeparatedByString:@"?"] firstObject];
                    NSString *nowUrlStr = [[navigationAction.request.URL.absoluteString componentsSeparatedByString:@"?"] firstObject];
                    if (![lastUrlStr isEqualToString:nowUrlStr] && ![navigationAction.request.URL.absoluteString isEqualToString:@"about:blank"]) {
                        [self.urlArray addObject:navigationAction.request.URL];
                    }
                };
                
                if (self.addWKNavigationTypeOther) {  //需要添加other类型url
                    if (navigationAction.navigationType == WKNavigationTypeLinkActivated || navigationAction.navigationType == WKNavigationTypeOther) {
                        addUrlBlock();
                    }
                }else  //不添加other类型url
                {
                    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
                        addUrlBlock();
                    }
                }
            }
        }
    }
    
    //拦截商品详情和店铺页面跳转京东客户端  跳转淘宝、天猫
    [self openJdAppWithUrlStr:navigationAction.request.URL.absoluteString];
    
    if ([self openThirdAppWithUrlStr:navigationAction.request.URL.absoluteString]) {
        allow = NO;  //tao:// tmall:// 跳转的链接不需要再加载
    }
    
    if (allow) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

//类似 UIWebView 的- webView:didFailLoadWithError:  开始加载数据时发生的错误
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"加载失败error:%@",error);
    
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

//加载完数据准备渲染网页
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"开始加载网页");
    
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

//网页加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"加载完成");
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        //执行完js的回调
    }];
    
    [self.webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        //执行完js的回调
    }];
    
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

//didCommitNavigation已经开始网页内容 之后出现错误
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error:%@",error);
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

//重定向
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    [self.urlArray removeObject:webView.URL];
    NSLog(@"重定向");
}

// 对于HTTPS的都会触发此代理，如果不要求验证，传默认就行
// 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的
-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
}

//>=iOS9 当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用上面的回调函数
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    [webView reload];
}

#pragma mark - private function
//跳转京东
- (void)openJdAppWithUrlStr:(NSString *)urlStr
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([urlStr containsString:@"item.m.jd.com"]) {
        
        NSString *htmlStr = [[urlStr componentsSeparatedByString:@"?"] firstObject];
        NSString *uidStr = [[htmlStr componentsSeparatedByString:@"/"] lastObject];
        NSString *uid = [[uidStr componentsSeparatedByString:@"."] firstObject];
        dict = @{@"skuId":uid,@"des":@"productDetail"}.mutableCopy;
        
    }else if ([urlStr containsString:@"shop.m.jd.com"])
    {
        urlStr = [[urlStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]] lastObject];
        NSArray *arr = [urlStr componentsSeparatedByString:@"&"];
        for (NSString *str in arr) {
            NSArray *tmpArr = [str componentsSeparatedByString:@"="];
            [dict setValue:tmpArr[1] forKey:tmpArr[0]];
        }
        [dict setValue:@"jshopMain" forKey:@"des"];
    }else
    {
        return ;
    }
    
    //京东跳转协议
    NSString *tmpStr = @"openApp.jdMobile://virtual?params=";
    
    NSMutableDictionary *mutDict = @{@"category":@"jump",
                                     @"sourceType":@"JSHOP_SOURCE_TYPE",
                                     @"sourceValue":@"JSHOP_SOURCE_VALUE"
                                     }.mutableCopy;
    [mutDict addEntriesFromDictionary:dict];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDict options:kNilOptions error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    tmpStr = [tmpStr stringByAppendingString:[self encodeString:str]];
    
    NSURL *url = [NSURL URLWithString:tmpStr];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (BOOL)openThirdAppWithUrlStr:(NSString *)urlStr
{
    void(^openTirdAppBlock)(NSString *urlStr) = ^(NSString *urlStr){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }
    };
    
    if ([urlStr containsString:@"taobao://"]) {
        openTirdAppBlock(urlStr);
        return YES;
    }else if ([urlStr containsString:@"tmall://"])
    {
        openTirdAppBlock(urlStr);
        return YES;
    }
    return NO;
}

//字符串编码
- (NSString *)encodeString:(NSString *)unencodedString
{
    NSString *encodedString= (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                   (CFStringRef)unencodedString,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8));
    return encodedString;
}

- (void)alertWithTitles:(NSArray <NSString *>*)titles message:(NSString *)message completionHandle:(void(^)(BOOL))completionHandler
{
    //push或present动画尚未结束，alert框可能弹不出来，completionHandler 最后没有被执行，导致crash
    if ([self.delegate isMovingToParentViewController] || [self.delegate isBeingPresented]) {
        completionHandler(NO);
        return;
    }

    //alert
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        [alertVC addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([obj isEqualToString:@"取消"]) {
                completionHandler(NO);
            }else
            {
                completionHandler(YES);
            }
        }]];
    }];
    
    if (self.delegate.navigationController) { //push
        if ([self.delegate.navigationController.topViewController isKindOfClass:[self.delegate class]]) { //UIViewController of WKWebView is visible
            [self.delegate presentViewController:alertVC animated:YES completion:nil];
        }else
        {
            completionHandler(NO);
        }
    }else  //present
    {
        if (self.delegate) {
            [self.delegate presentViewController:alertVC animated:YES completion:nil];
        }else
        {
            completionHandler(NO);
        }
    }
}

#pragma mark - URL request Helper
//判断请求的页面与当前页面是否为同一页
- (BOOL)isSameHTMLPage:(NSURL *)lastURL andRequestURL:(NSURL *)requestURL
{
    BOOL isSame = NO;
    
    BOOL isFragment = [self isFragmentJump:lastURL andRequestURL:requestURL];
    
    if (isFragment) {
        isSame = YES;
    }else
    {
        isSame = [lastURL isEqual:requestURL];
    }
    return isSame;
}

//判断是否是页面内的链接跳转:#位置标识   链接一样，只是位置不一样
- (BOOL)isFragmentJump:(NSURL *)lastURL andRequestURL:(NSURL *)requestURL
{
    BOOL isFragmentJump = NO;
    
    //位置标识
    if (requestURL.fragment) {
        NSString *nonFragmentURL = [requestURL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:requestURL.fragment] withString:@""];
        
        NSString *lastURLStr;
        
        if (lastURL.fragment) {
            lastURLStr = [lastURL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:lastURL.fragment] withString:@""];
        }else{
            lastURLStr = lastURL.absoluteString;
        }
        
        isFragmentJump = [nonFragmentURL isEqualToString:lastURLStr];
    }
    
    return isFragmentJump;
}

#pragma mark - getter function
-(NSMutableArray *)urlArray
{
    if (!_urlArray) {
        _urlArray = [NSMutableArray array];
    }
    return _urlArray;
}

@end
