//
//  FHViewController.m
//  FHWebView
//
//  Created by zenghongfei on 03/10/2017.
//  Copyright (c) 2017 zenghongfei. All rights reserved.
//

#import "FHViewController.h"
#import "UIWebViewController.h"
#import "WKWebViewController.h"

@interface FHViewController ()<UIWebViewDelegate>

@end

@implementation FHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)wkWebViewClick:(id)sender {
    
    WKWebViewController *wkVC = [[WKWebViewController alloc] init];
    [self.navigationController pushViewController:wkVC animated:YES];
}

- (IBAction)uiWebViewClick:(id)sender {
    UIWebViewController *uiVC = [[UIWebViewController alloc] init];
    [self.navigationController pushViewController:uiVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
