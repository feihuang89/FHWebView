//
//  WKWebViewController.m
//  WKWebView
//
//  Created by Africa on 17/2/10.
//  Copyright © 2017年 Africa. All rights reserved.
//

#import "WKWebViewController.h"
#import "UIViewController+NavgationBar.h"
#import "FHWebManager.h"

@interface WKWebViewController ()<FHWebManagerDelegate>

@property (nonatomic, strong) FHWebManager *webManager;

@end

@implementation WKWebViewController

-(void)dealloc
{
    [self.webManager removeAllScriptMessageHandler];
    NSLog(@"WKWebViewController页面销毁");
}

-(FHWebManager *)webManager
{
    if (!_webManager) {
        _webManager = [[FHWebManager alloc] init];
    }
    return _webManager;
}

-(WKWebView *)webView
{
    return self.webManager.webView;
}

-(NSMutableArray *)urlArray
{
    return self.webManager.urlArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //设置导航栏
    [self setNavBarType:NavBarTypeDefault];
    [self setNavLeftViewWithNavLeftType:NavLeftTypeBack andCustomView:nil];
    
    [self.webManager bindWKWebViewWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64) delegate:self];
    
    //不添加other类型url
//    self.webManager.addWKNavigationTypeOther = NO;
    
    [self sendRequest];
}

-(void)sendRequest
{
    NSURL *url = [NSURL URLWithString:@"http://www.soku.com/m/y/video?q=%E9%98%BF%E5%87%A1%E8%BE%BE%20%E7%89%87%E6%AE%B5#loaded"]; //http://people.mozilla.org/~rnewman/fennec/mem.html  http://shop.m.jd.com/?shopId=1000000829&skuId=2248768&categoryId=652_12345_12351
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    [self.webView loadRequest:request];
}

#pragma mark - FHWebManagerDelegate
-(BOOL)webView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType
{
    return YES;
}

-(void)webViewDidStartLoad:(WKWebView *)webView
{
    NSLog(@"%s",__func__);
}

-(void)webViewDidFinishLoad:(WKWebView *)webView
{
    NSLog(@"%s",__func__);
}

-(void)webView:(WKWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%s:%@",__func__,error.description);
}

#pragma mark - private function
-(void)leftBtnNavLeftTypeBackClick:(UIButton *)btn
{
    if (self.urlArray.count > 1) {
        
        //显示关闭按钮
        [self setNavLeftSecondViewWithNavLeftType:NavLeftTypeClose andCustomView:nil];
        
        [self.urlArray removeLastObject];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.urlArray.lastObject cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        [self.webView loadRequest:request];
    }else
    {
        //隐藏关闭按钮
        [self setNavLeftSecondViewWithNavLeftType:NavLeftTypeNone andCustomView:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)leftBtnNavLeftTypeCloseClick:(UIButton *)btn
{
    //隐藏关闭按钮
    [self setNavLeftSecondViewWithNavLeftType:NavLeftTypeNone andCustomView:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - JS交互
- (void)controlLeft:(NSDictionary *)dict
{
    NSLog(@"%@",dict);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
