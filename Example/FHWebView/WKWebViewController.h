//
//  WKWebViewController.h
//  WKWebView
//
//  Created by Africa on 17/2/10.
//  Copyright © 2017年 Africa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKWebView;
@interface WKWebViewController : UIViewController

@property (nonatomic, weak) WKWebView *webView;

@property (nonatomic, strong) NSMutableArray *urlArray;

@end
