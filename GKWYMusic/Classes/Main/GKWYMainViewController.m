//
//  GKWYMainViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMainViewController.h"

#import "GKWYHomeViewController.h"
#import "GKWYMineViewController.h"

@interface GKWYMainViewController ()

@end

@implementation GKWYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.translucent = NO;
    self.tabBar.tintColor = kAPPDefaultColor;
    
    // 主页
    [self addChildVC:[GKWYHomeViewController new] title:@"发现" imgName:@"cm2_btm_icn_discovery" selImgName:@"cm2_btm_icn_discovery_prs"];
    // 我的
    [self addChildVC:[GKWYMineViewController new] title:@"我的" imgName:@"cm2_btm_icn_music" selImgName:@"cm2_btm_icn_music_prs"];
    
    [self setupTabBarAppearance];
}

- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title imgName:(NSString *)imgName selImgName:(NSString *)selImgName {
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = [[UIImage imageNamed:imgName] changeImageWithColor:UIColor.grayColor];
    childVC.tabBarItem.selectedImage = [[UIImage imageNamed:selImgName] changeImageWithColor:kAPPDefaultColor];
    
    [childVC.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]} forState:UIControlStateNormal];
    [childVC.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];
    
    UINavigationController *nav = [UINavigationController rootVC:childVC];
    [self addChildViewController:nav];
}

- (void)setupTabBarAppearance {
    NSDictionary *normalTitleAttr = @{NSForegroundColorAttributeName: UIColor.grayColor, NSFontAttributeName: [UIFont systemFontOfSize:13.0]};
    NSDictionary *selectTitleAttr = @{NSForegroundColorAttributeName: kAPPDefaultColor, NSFontAttributeName: [UIFont systemFontOfSize:13.0]};
    if (@available(iOS 13.0, * )) {
        UITabBarAppearance *appearance = self.tabBar.standardAppearance;
        appearance.backgroundColor = UIColor.whiteColor;
        appearance.backgroundImage = UIImage.new;
        appearance.shadowColor = UIColor.clearColor;
        appearance.shadowImage = UIImage.new;
        [appearance applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nullable itemAppearance) {
            itemAppearance.normal.titleTextAttributes = normalTitleAttr;
            itemAppearance.selected.titleTextAttributes = selectTitleAttr;
        }];
        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, * )) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }else {
        self.tabBar.backgroundImage = UIImage.new;
        self.tabBar.backgroundColor = UIColor.whiteColor;
        [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.tabBarItem setTitleTextAttributes:normalTitleAttr forState:UIControlStateNormal];
            [obj.tabBarItem setTitleTextAttributes:selectTitleAttr forState:UIControlStateSelected];
        }];
    }
}

@end
