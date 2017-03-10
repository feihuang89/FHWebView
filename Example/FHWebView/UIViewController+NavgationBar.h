//
//  UIViewController+NavgationBar.h
//  PicoocCoach
//
//  Created by Africa on 16/12/2.
//  Copyright © 2016年 Africa. All rights reserved.
//

/** 设置导航栏左右按钮、titleView相关分类 */

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    NavBarTypeDefault,  //默认灰
    NavBarTypeTransparent, //透明
    NavBarTypeHidden, //隐藏
} NavBarType;

typedef enum : NSUInteger {
    NavLeftTypeUnknow, //未知类型
    NavLeftTypeNone, //隐藏
    NavLeftTypeBack,  //返回
    NavLeftTypeClose, //关闭
    NavLeftTypeCustom, //自定义
} NavLeftType;

typedef enum : NSUInteger {
    NavRightTypeUnknow, //未知类型
    NavRightTypeNone, //设nil
    NavRightTypeShare, //分享图片
    NavRightTypeMessage, //消息图片
    NavRightTypeTitle, //文字
    NavRightTypeCustom, //自定义
} NavRightType;

@interface UIViewController (NavgationBar)

/** 导航栏背景颜色 */
@property (nonatomic, strong) UIColor *navBarColor;
/** 左按钮 */
@property (nonatomic, weak) UIButton *leftBtn;
/** 右按钮 */
@property (nonatomic, weak) UIButton *rightBtn;
/** 左按钮类型 */
@property (nonatomic, assign) NavLeftType leftType;
/** 右按钮类型 */  
@property (nonatomic, assign) NavRightType rightType;
/** 灰线 */
@property (nonatomic, strong, readonly) UIView *navLine;
/** 没有导航栏的Bar */
@property (nonatomic, strong, readonly) UIView *customNavBar;

/**
 设置导航栏样式

 @param navBartype 样式
 */
- (void)setNavBarType:(NavBarType)navBartype;

/**
 设置导航栏左按钮

 @param leftType 左按钮样式
 @param customView 如果需要自定义左按钮，传入自定义View
 */
- (void)setNavLeftViewWithNavLeftType:(NavLeftType)leftType andCustomView:(UIView *)customView;

/**
 设置导航栏右按钮

 @param rightType 右按钮样式
 @param title 右按钮文字
 @param customView 如果需要自定义右按钮，传入自定义View
 */
- (void)setNavRightViewWithNavRightType:(NavRightType)rightType title:(NSString *)title andCustomView:(UIView *)customView;

/**
 设置导航栏左边第二个按钮

 @param leftType 左按钮样式
 @param customView 自定义view
 */
- (void)setNavLeftSecondViewWithNavLeftType:(NavLeftType)leftType andCustomView:(UIView *)customView;

/**
 设置导航栏右边第二个按钮

 @param rightType 右按钮样式
 @param customView 自定义view
 */
- (void)setNavRightSecondViewWithNavRightType:(NavRightType)rightType andCustomView:(UIView *)customView;

/**
 设置导航栏左边多个视图

 @param navLeftArray 每个字典只有一个键值对(key:NavLeftType  value:customView)
 */
- (void)setNavLeftViewsWithNavLeftArray:(NSArray <NSDictionary *>*)navLeftArray;

/**
 设置导航栏右边多个视图

 @param navRightArray 每个字典只有一个键值对(key:NavRightType  value:customView)
 */
- (void)setNavRightViewsWithNavRightArray:(NSArray <NSDictionary *>*)navRightArray;

/**
 左按钮返回点击事件

 @param btn 返回按钮
 */
- (void)leftBtnNavLeftTypeBackClick:(UIButton *)btn;

/**
 左按钮关闭点击事件

 @param btn 关闭按钮
 */
- (void)leftBtnNavLeftTypeCloseClick:(UIButton *)btn;

/**
 右按钮分享点击事情

 @param btn 分享按钮
 */
- (void)rightBtnNavRightTypeShareClick:(UIButton *)btn;

/**
 右按钮消息点击事件

 @param btn 消息按钮
 */
- (void)rightBtnNavRightTypeMessageClick:(UIButton *)btn;

/**
 右按钮文字点击事件

 @param btn 文字按钮
 */
- (void)rightBtnNavRightTypeTitleClick:(UIButton *)btn;

@end
