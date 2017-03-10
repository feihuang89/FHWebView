//
//  UIViewController+NavgationBar.m
//  PicoocCoach
//
//  Created by Africa on 16/12/2.
//  Copyright © 2016年 Africa. All rights reserved.
//

#import "UIViewController+NavgationBar.h"
#import <objc/runtime.h>

/** 状态栏尺寸 */
#define kStatusBar 20.0
/** NavBar高度 */
#define kNavBarHeight 44.0
/** 获取屏幕宽度、高度 */
#define kScreenW MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define kScreenH MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)
#define UIColorFromRGB(rgbValue,alphaValue) [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0 green:((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0 blue:((CGFloat)(rgbValue & 0xFF))/255.0 alpha:alphaValue]
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
/** 图片 */
#define IMAGE(I) [UIImage imageNamed:(I)]

const char *leftBtnKey = "leftBtnKey";
const char *rightBtnKey = "rightBtnKey";
const char *leftTypeKey = "leftTypeKey";
const char *rightTypeKey = "rightTypeKey";
const char *navLineKey = "navLineKey";
const char *customNavBar = "customNavBar";
@implementation UIViewController (NavgationBar)

#pragma mark - setter getter
-(void)setNavBarColor:(UIColor *)navBarColor
{
    self.navigationController.navigationBar.barTintColor = navBarColor;
}

-(UIColor *)navBarColor
{
    return self.navigationController.navigationBar.barTintColor;
}

-(void)setLeftBtn:(UIButton *)leftBtn
{
    objc_setAssociatedObject(self, leftBtnKey, leftBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIButton *)leftBtn
{
    if (!objc_getAssociatedObject(self, leftBtnKey)) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.backgroundColor = [UIColor clearColor];
        leftBtn.frame = CGRectMake(14, kStatusBar, kNavBarHeight, kNavBarHeight);
        objc_setAssociatedObject(self, leftBtnKey, leftBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, leftBtnKey);
}

-(void)setRightBtn:(UIButton *)rightBtn
{
    objc_setAssociatedObject(self, rightBtnKey, rightBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIButton *)rightBtn
{
    if (!objc_getAssociatedObject(self, rightBtnKey)) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.backgroundColor = [UIColor clearColor];
        rightBtn.frame = CGRectMake(kScreenW - 46, kStatusBar, kNavBarHeight, kNavBarHeight);
        objc_setAssociatedObject(self, rightBtnKey, rightBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, rightBtnKey);
}

-(void)setLeftType:(NavLeftType)leftType
{
    objc_setAssociatedObject(self, leftTypeKey, @(leftType), OBJC_ASSOCIATION_ASSIGN);
}

-(NavLeftType)leftType
{
    return [objc_getAssociatedObject(self, leftTypeKey) integerValue];
}

-(void)setRightType:(NavRightType)rightType
{
    objc_setAssociatedObject(self, rightTypeKey, @(rightType), OBJC_ASSOCIATION_ASSIGN);
}

-(NavRightType)rightType
{
    return [objc_getAssociatedObject(self, rightTypeKey) integerValue];
}

-(UIView *)navLine
{
    if (!objc_getAssociatedObject(self, navLineKey)) {
        //灰色的下线   --- navbar 下面的线
        UIView *navLine = [[UIView alloc] initWithFrame:CGRectMake(0, 63, kScreenW, 1)];
        navLine.backgroundColor = UIColorFromRGB(0xD9D9D9, 1.f);
        navLine.hidden = YES;
        [self.customNavBar addSubview:navLine];
        objc_setAssociatedObject(self, navLineKey, navLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, navLineKey);
}

-(UIView *)customNavBar
{
    if (!objc_getAssociatedObject(self, customNavBar)) {
        UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kNavBarHeight+kStatusBar)];
        navBar.backgroundColor = [UIColor clearColor];
        navBar.userInteractionEnabled = YES;
        [self.view addSubview:navBar];
        objc_setAssociatedObject(self, customNavBar, navBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, customNavBar);
}

#pragma mark - private function
- (BOOL)isRootViewControllerForNav
{
    return self.navigationController.childViewControllers.count > 1;
}

#pragma mark - 设置导航栏样式
- (void)setNavBarType:(NavBarType)navBartype
{
    switch (navBartype) {
        case NavBarTypeDefault: //默认
        {
            if (self.navigationController) {
                //设置导航栏背景为nil
                [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                //设置导航栏底部阴影
//                [self.navigationController.navigationBar setShadowImage:[UIImage createImageWithColor:UIColorFromRGB(0xD9D9D9, 1.f) alpha:1]];
                [self.navigationController setNavigationBarHidden:NO];
                self.navBarColor = RGBCOLOR(238, 239, 243);
            }else
            {
                self.customNavBar.backgroundColor = RGBCOLOR(238, 239, 243);
                [self.customNavBar setHidden:NO];
                [self.navLine setHidden:NO];
            }
        }
            break;
            
        case NavBarTypeTransparent: //透明
        {
            if (self.navigationController) {
                [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsCompact];
                [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
            }else
            {
                self.customNavBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
                [self.navLine setHidden:YES];
            }
        }
            break;
            
        case NavBarTypeHidden:  //隐藏
        {
            if (self.navigationController) {
                [self.navigationController setNavigationBarHidden:YES];
            }else
            {
                [self.customNavBar setHidden:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 设置左右按钮样式
- (void)setNavLeftViewWithNavLeftType:(NavLeftType)leftType andCustomView:(UIView *)customView
{
    self.navigationItem.leftBarButtonItems = nil;
    
    self.leftType = leftType;
    
    if (leftType == NavLeftTypeUnknow) return;
    
    self.leftBtn.hidden = NO;
    if ([self isRootViewControllerForNav]) { //过滤根控制器
        
        [self leftBtnClickNameImageNameWithLeftType:leftType responseBlock:^(NSString *leftImageName, NSString *clickName) {
            if (leftType == NavLeftTypeNone) {
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIButton alloc] init]];
                return ;
            }
            
            if (!customView || ![customView isKindOfClass:[UIView class]]) {
                [self.leftBtn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                
                [self.leftBtn addTarget:self action:NSSelectorFromString([NSString stringWithFormat:@"leftBtn%@Click:",clickName]) forControlEvents:UIControlEventTouchUpInside];
                
                UIImage *leftImage = [UIImage imageNamed:leftImageName];
                self.leftBtn.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
                [self.leftBtn setImage:leftImage forState:UIControlStateNormal];
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
            }else
            {
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
            }
        }];
        
    }else  //导航栏根控制器 自定义左按钮
    {
        [self setRootVCNavLeftBtnWithLeftType:leftType customView:customView];
    }
}

- (void)setNavRightViewWithNavRightType:(NavRightType)rightType title:(NSString *)title andCustomView:(UIView *)customView
{
    self.navigationItem.rightBarButtonItems = nil;
    
    self.rightType = rightType;
    
    if (rightType == NavRightTypeUnknow) return;
    
    self.rightBtn.hidden = NO;
    if ([self isRootViewControllerForNav]) { //过滤根控制器

        [self rightBtnClickNameImageNameWithRightType:rightType ResponseBlock:^(NSString *rightImageName, NSString *clickName) {
            if (!customView || ![customView isKindOfClass:[UIView class]]) {
                if (rightType == NavRightTypeNone) {
                    self.rightBtn.hidden = YES;
                    return ;
                }
                [self.rightBtn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                [self.rightBtn addTarget:self action:NSSelectorFromString([NSString stringWithFormat:@"rightBtn%@Click:",clickName]) forControlEvents:UIControlEventTouchUpInside];
                
                if (rightType == NavRightTypeTitle) {
                    self.rightBtn.frame = CGRectMake(0, 0, 50, 40);
                    [self.rightBtn setTitle:title forState:UIControlStateNormal];
                    [self.rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                }else
                {
                    UIImage *rightImage = IMAGE(rightImageName);
                    self.rightBtn.frame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
                    [self.rightBtn setImage:rightImage forState:UIControlStateNormal];
                }
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
            }else
            {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
            }
        }];
        
    }else  //导航栏根控制器 自定义右按钮
    {
        [self setRootVCNavRightBtnWithRightType:rightType title:title customView:customView];
    }
}

#pragma mark  - 设置左右第二个按钮
- (void)setNavLeftSecondViewWithNavLeftType:(NavLeftType)leftType andCustomView:(UIView *)customView
{
    UIBarButtonItem *leftBarButtonItem = [self leftBarButtonItemWithLeftType:leftType andCustomView:customView];
    
    self.navigationItem.leftBarButtonItems = @[self.navigationItem.leftBarButtonItem? : [[UIBarButtonItem alloc] init],leftBarButtonItem];
}

- (void)setNavRightSecondViewWithNavRightType:(NavRightType)rightType andCustomView:(UIView *)customView
{
    UIBarButtonItem *rightBarButtonItem = [self rightBarButtonItemWithRightType:rightType title:nil andCustomView:customView];
    
    self.navigationItem.rightBarButtonItems = @[rightBarButtonItem,self.navigationItem.rightBarButtonItem? : [[UIBarButtonItem alloc]init]];
}

#pragma mark - 设置多个左右按钮
- (void)setNavLeftViewsWithNavLeftArray:(NSArray <NSDictionary *>*)navLeftArray
{
    if (navLeftArray.count < 2) return;
    
    NSMutableArray *mutArr = [NSMutableArray array];
    [navLeftArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count > 1) {  //字典只支持一个键值对，保证设置的左按钮是有序的
            return ;
        }
        NavLeftType leftType = [[obj allKeys][0] integerValue];
        
        UIBarButtonItem *leftBarButtonItem = [self leftBarButtonItemWithLeftType:leftType andCustomView:[obj allValues][0]];
        
        if (idx == 0) {
            self.leftType = leftType;
            self.leftBtn = leftBarButtonItem.customView;
        }
        
        [mutArr addObject:leftBarButtonItem];
    }];
    
    self.navigationItem.leftBarButtonItems = [mutArr copy];
}

- (void)setNavRightViewsWithNavRightArray:(NSArray<NSDictionary *> *)navRightArray
{
    if (navRightArray.count < 2) return;
    
    NSMutableArray *mutArr = [NSMutableArray array];
    [navRightArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count > 1) {  //字典只支持一个键值对，保证设置的左按钮是有序的
            return ;
        }
        NavRightType rightType = [[obj allKeys][0] integerValue];
        
        UIBarButtonItem *rightBarButtonItem = [self rightBarButtonItemWithRightType:rightType title:[obj allValues][0] andCustomView:[obj allValues][0]];
        
        if (idx == 0) {
            self.rightType = rightType;
            self.rightBtn = rightBarButtonItem.customView;
        }
        
        [mutArr addObject:rightBarButtonItem];
    }];
    
    self.navigationItem.rightBarButtonItems = [mutArr copy];
}

#pragma mark - 返回左右UIBarButtonItem
- (UIBarButtonItem *)leftBarButtonItemWithLeftType:(NavLeftType)leftType andCustomView:(UIView *)customView{
    
    __block UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [self leftBtnClickNameImageNameWithLeftType:leftType responseBlock:^(NSString *leftImageName, NSString *clickName) {
        if ((!customView || ![customView isKindOfClass:[UIView class]]) && leftType != NavLeftTypeNone) {
            
            UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftBtn addTarget:self action:NSSelectorFromString([NSString stringWithFormat:@"leftBtn%@Click:",clickName]) forControlEvents:UIControlEventTouchUpInside];
            
            UIImage *leftImage = IMAGE(leftImageName);
            leftBtn.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
            [leftBtn setImage:leftImage forState:UIControlStateNormal];
            leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        }else
        {
            leftItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
        }
    }];
    return leftItem;
}

- (UIBarButtonItem *)rightBarButtonItemWithRightType:(NavRightType)rightType title:(NSString *)title andCustomView:(UIView *)customView{
    
    __block UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
    [self rightBtnClickNameImageNameWithRightType:rightType ResponseBlock:^(NSString *rightImageName, NSString *clickName) {
        if ((!customView || ![customView isKindOfClass:[UIView class]]) && rightType != NavRightTypeNone) {
            UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightBtn addTarget:self action:NSSelectorFromString([NSString stringWithFormat:@"rightBtn%@Click:",clickName]) forControlEvents:UIControlEventTouchUpInside];
            
            if (rightType == NavRightTypeTitle) {
                rightBtn.frame = CGRectMake(0, 0, 50, 40);
                [rightBtn setTitle:title forState:UIControlStateNormal];
                [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            }else
            {
                UIImage *rightImage = IMAGE(rightImageName);
                rightBtn.frame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
                [rightBtn setImage:rightImage forState:UIControlStateNormal];
            }
            
            rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        }else
        {
            rightItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
        }
    }];
    
    return rightItem;
}

#pragma mark - 返回按钮图片名字、点击方法
- (void)leftBtnClickNameImageNameWithLeftType:(NavLeftType)leftType responseBlock:(void(^)(NSString *leftImageName,NSString *clickName))responseBlock
{
    NSString *leftImageName = nil;
    NSString *clickName = nil;
    switch (leftType) {
        case NavLeftTypeBack:
        {
            leftImageName = @"nav_back";
            clickName = @"NavLeftTypeBack";
        }
            break;
            
        case NavLeftTypeClose:
        {
            leftImageName = @"nav_close";
            clickName = @"NavLeftTypeClose";
        }
            break;
        case NavLeftTypeNone:
        case NavLeftTypeCustom:
        default:
            break;
    }
    
    if (responseBlock) {
        responseBlock(leftImageName,clickName);
    }
}

- (void)rightBtnClickNameImageNameWithRightType:(NavRightType)rightType ResponseBlock:(void(^)(NSString *rightImageName,NSString *clickName))responseBlock
{
    NSString *rightImageName = nil;
    NSString *clickName = nil;
    switch (rightType) {
        case NavRightTypeShare:
        {
            clickName = @"NavRightTypeShare";
            rightImageName = @"nav_share";
        }
            break;
            
        case NavRightTypeMessage:
        {
            clickName = @"NavRightTypeMessage";
            rightImageName = @"nav_message";
        }
            break;
            
        case NavRightTypeTitle:
            clickName = @"NavRightTypeTitle";
            break;
            
        case NavRightTypeCustom:
        case NavRightTypeNone:
            break;
        default:
            break;
    }
    
    if (responseBlock) {
        responseBlock(rightImageName,clickName);
    }
}

#pragma mark - 设置根控制器的左右按钮
- (void)setRootVCNavLeftBtnWithLeftType:(NavLeftType)leftType customView:(UIView *)customView
{
    //移除左按钮
    [self.leftBtn removeFromSuperview];
    
    NSString *leftImageName = nil;
    NSString *clickName = nil;
    switch (leftType) {
        case NavLeftTypeNone:
        {
            self.leftBtn.hidden = YES;
            [self.leftBtn removeFromSuperview];
        }
            break;
            
        case NavLeftTypeBack:
        {
            leftImageName = @"nav_back";
            clickName = @"NavLeftTypeBack";
        }
            break;
            
        case NavLeftTypeClose:
        {
            leftImageName = @"nav_close";
            clickName = @"NavLeftTypeClose";
        }
            break;
            
        case NavLeftTypeCustom:
        {
            [self.customNavBar addSubview:customView];
        }
            break;
        default:
            break;
    }
    
    if (!customView || ![customView isKindOfClass:[UIView class]]) {
        [self.leftBtn setImage:IMAGE(leftImageName) forState:UIControlStateNormal];
        [self.leftBtn addTarget:self action:NSSelectorFromString([NSString stringWithFormat:@"leftBtn%@Click:",clickName]) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBar addSubview:self.leftBtn];
    }
}

- (void)setRootVCNavRightBtnWithRightType:(NavRightType)rightType title:(NSString *)title customView:(UIView *)customView
{
    //移除右按钮
    [self.rightBtn removeFromSuperview];

    NSString *rightImageName = nil;
    NSString *clickName = nil;
    switch (rightType) {
        case NavRightTypeNone:
        {
            self.rightBtn.hidden = YES;
            [self.rightBtn removeFromSuperview];
        }
            break;
            
        case NavRightTypeShare:
        {
            clickName = @"NavRightTypeShare";
            rightImageName = @"nav_share";
        }
            break;
            
        case NavRightTypeMessage:
        {
            clickName = @"NavRightTypeMessage";
            rightImageName = @"nav_message";
        }
            break;
            
        case NavRightTypeTitle:
            clickName = @"NavRightTypeTitle";
            break;
            
        case NavRightTypeCustom:
        {
            [self.customNavBar addSubview:customView];
        }
            break;
        default:
            break;
    }
    
    if (!customView || ![customView isKindOfClass:[UIView class]]) {
        if (rightType == NavRightTypeTitle) {
            self.rightBtn.frame = CGRectMake(0, 0, 50, 40);
            [self.rightBtn setTitle:title forState:UIControlStateNormal];
            [self.rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        }else
        {
            [self.rightBtn setImage:IMAGE(rightImageName) forState:UIControlStateNormal];
        }
        [self.rightBtn addTarget:self action:NSSelectorFromString([NSString stringWithFormat:@"rightBtn%@Click:",clickName]) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavBar addSubview:self.rightBtn];
    }
}

#pragma mark - 点击事件
- (void)leftBtnNavLeftTypeBackClick:(UIButton *)btn
{
    NSLog(@"返回按钮点击");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftBtnNavLeftTypeCloseClick:(UIButton *)btn
{
    NSLog(@"关闭按钮点击");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBtnNavRightTypeShareClick:(UIButton *)btn
{
    NSLog(@"分享按钮点击");
}

- (void)rightBtnNavRightTypeMessageClick:(UIButton *)btn
{
    NSLog(@"消息按钮点击");
}

- (void)rightBtnNavRightTypeTitleClick:(UIButton *)btn
{
    NSLog(@"文字按钮点击");
}

@end
