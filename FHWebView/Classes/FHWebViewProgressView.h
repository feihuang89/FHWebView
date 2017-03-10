//
//  PKWebViewProgressView.h
//  WKWebView
//
//  Created by Africa on 17/2/14.
//  Copyright © 2017年 Africa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHWebViewProgressView : UIView

@property (nonatomic) float progress;

@property (nonatomic) UIView *progressBarView;
@property (nonatomic) NSTimeInterval barAnimationDuration; // default 0.1
@property (nonatomic) NSTimeInterval fadeAnimationDuration; // default 0.27
@property (nonatomic) NSTimeInterval fadeOutDelay; // default 0.1

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
