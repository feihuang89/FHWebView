//
//  UIWebViewController.m
//  WKWebView
//
//  Created by Africa on 17/2/8.
//  Copyright © 2017年 Africa. All rights reserved.
//

#import "UIWebViewController.h"
#import "UIViewController+NavgationBar.h"

@interface UIWebViewController ()<UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *urlArray;

@end

@implementation UIWebViewController

-(NSMutableArray *)urlArray
{
    if (!_urlArray) {
        _urlArray = [NSMutableArray array];
    }
    return _urlArray;
}

-(void)dealloc
{
    NSLog(@"页面销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavBarType:NavBarTypeDefault];
    [self setNavLeftViewWithNavLeftType:NavLeftTypeBack andCustomView:nil];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.backgroundColor = [UIColor orangeColor];
    webView.delegate = self;
    
    self.webView = webView;
    [self.view addSubview:webView];
    
    NSURL *url = [NSURL URLWithString:@"http://www.soku.com/m/y/video?q=%E9%98%BF%E5%87%A1%E8%BE%BE%20%E7%89%87%E6%AE%B5#loaded"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    [webView loadRequest:request];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSDate *date = [NSDate date];
    NSLog(@"date begin:%@",date);
    
    NSString *urlStr = [request.URL absoluteString];
    NSLog(@"urlStr:%@",urlStr);
    if (![[self.urlArray.lastObject absoluteString] isEqualToString:urlStr]) {
        [self.urlArray addObject:request.URL];
    }
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"%s",__func__);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSDate *date = [NSDate date];
    NSLog(@"date finish:%@",date);
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"网页加载失败");
}

- (void)leftBtnNavLeftTypeBackClick:(UIButton *)btn
{
    if (self.urlArray.count > 1) {
        
        [self setNavLeftSecondViewWithNavLeftType:NavLeftTypeClose andCustomView:nil];
        
        [self.urlArray removeLastObject];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.urlArray.lastObject cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [self.webView loadRequest:request];
    }else
    {
        [self setNavLeftSecondViewWithNavLeftType:NavLeftTypeNone andCustomView:nil];

        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)leftBtnNavLeftTypeCloseClick:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
