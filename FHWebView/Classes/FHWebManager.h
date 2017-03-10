//
//  PKWebManager.h
//  WKWebView
//
//  Created by Africa on 17/2/10.
//  Copyright © 2017年 Africa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol FHWebManagerDelegate <NSObject>

@optional

/**
 发送请求之前决定是否跳转,可实现此代理方法进行导航栏相关UI设置

 @param webView WKWebView
 @param url 需要跳转的链接
 */
- (BOOL)webView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType;

/**
 已经开始加载网页

 @param webView WKWebView
 */
- (void)webViewDidStartLoad:(WKWebView *)webView;

/**
 webView加载完成回调

 @param webView WKWebView
 */
- (void)webViewDidFinishLoad:(WKWebView *)webView;

/**
 webView加载失败

 @param webView WKWebView
 @param error 错误信息
 */
-(void)webView:(WKWebView *)webView didFailLoadWithError:(NSError *)error;

@required
/*--------------------web JS交互方法-------------------------*/
//导航栏标题
- (void)controlTitle:(NSDictionary *)dict;

//左上角规范
- (void)controlLeft:(NSDictionary *)dict;

//右上角规范
- (void)controlRight:(NSDictionary *)dict;

//点击右上角按钮之后回调：修改右上角状态
- (void)controlRightInfo:(NSDictionary *)dict;

@end

@class FHWebViewProgressView;
@interface FHWebManager : NSObject

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSMutableArray *urlArray;

@property (nonatomic, weak) FHWebViewProgressView *progressView;

/** 添加other类型的进入urlArray:H5采用window.location.href进行跳转链接的时候，会是WKNavigationTypeOther;而加载一个链接跳转多个iframe的时候，也是other，比如"淘宝、天猫"  default:YES*/
@property (nonatomic, assign) BOOL addWKNavigationTypeOther;

/** 控制url堆栈，默认控制；加载的url添加到backList中 */
@property (nonatomic, assign) BOOL controlUrlArray;

/**
 绑定webView

 @param frame frame
 @param delegate WKWebView的delegate
 */
- (void)bindWKWebViewWithFrame:(CGRect)frame delegate:(UIViewController <FHWebManagerDelegate>*)delegate;

/**
 删除注册的JS交互方法 PS：这一个方法必须在delegate销毁的时候调用，不然导致崩溃
 */
- (void)removeAllScriptMessageHandler;

/**
 判断是否是页面内的链接跳转:#位置标识 
 
 @param lastURL 上一个链接
 @param requestURL 请求链接
 @return 是/否
 */
- (BOOL)isFragmentJump:(NSURL *)lastURL andRequestURL:(NSURL *)requestURL;

/**
 删除webKit缓存，不包含cookie
 */
- (void)removeWebkitCache;

/**
 在viewWillAppear中调用该方法：判断webView.title是否为空，刷新当前页面，解决WKWebView白屏的问题
 */
- (void)reloadWhenTitleNull;

/**
 加载本地html

 @param resource 文件名
 @param type 文件类型
 @param directory 文件所在文件夹
 */
- (void)loadHTMLWithResource:(NSString *)resource type:(NSString *)type inDirectory:(NSString *)directory;

@end
