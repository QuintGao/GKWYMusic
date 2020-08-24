//
//  GKNavigationBarViewController.h
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//  所有需要显示导航条的基类，可根据自己的需求设置导航栏
//  基本原理就是为每一个控制器添加自定义导航条，做到导航条与控制器相连的效果

#import <UIKit/UIKit.h>
#import "GKCategory.h"
#import "GKNavigationBar.h"
#import "GKNavigationBarConfigure.h"

@interface GKNavigationBarViewController : UIViewController

/// 自定义导航条
@property (nonatomic, strong, readonly) GKNavigationBar     *gk_navigationBar;

/// 自定义导航条栏目
@property (nonatomic, strong, readonly) UINavigationItem    *gk_navigationItem;

#pragma mark - 额外的快速设置导航栏的属性
@property (nonatomic, strong) UIColor                       *gk_navBarTintColor;
@property (nonatomic, strong) UIColor                       *gk_navBackgroundColor;
@property (nonatomic, strong) UIImage                       *gk_navBackgroundImage;
/** 设置导航栏分割线颜色或图片 */
@property (nonatomic, strong) UIColor                       *gk_navShadowColor;
@property (nonatomic, strong) UIImage                       *gk_navShadowImage;

@property (nonatomic, strong) UIColor                       *gk_navTintColor;
@property (nonatomic, strong) UIView                        *gk_navTitleView;
@property (nonatomic, strong) UIColor                       *gk_navTitleColor;
@property (nonatomic, strong) UIFont                        *gk_navTitleFont;

@property (nonatomic, strong) UIBarButtonItem               *gk_navLeftBarButtonItem;
@property (nonatomic, strong) NSArray<UIBarButtonItem *>    *gk_navLeftBarButtonItems;

@property (nonatomic, strong) UIBarButtonItem               *gk_navRightBarButtonItem;
@property (nonatomic, strong) NSArray<UIBarButtonItem *>    *gk_navRightBarButtonItems;

/** 页面标题-快速设置 */
@property (nonatomic, copy) NSString                        *gk_navTitle;

/// 是否隐藏导航栏分割线，默认为NO
@property (nonatomic, assign) BOOL                          gk_navLineHidden;

/// 显示导航栏分割线
- (void)showNavLine;

/// 隐藏导航栏分割线
- (void)hideNavLine;

/// 刷新导航栏frame
- (void)refreshNavBarFrame;

@end
