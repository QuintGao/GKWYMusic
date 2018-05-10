//
//  GKWYMainViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMainViewController.h"
#import "GKWYNavigationController.h"

#import "GKWYHomeViewController.h"
#import "GKWYMineViewController.h"

@interface GKWYMainViewController ()

@end

@implementation GKWYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.translucent = NO;
    
    self.tabBar.backgroundImage = [UIImage imageNamed:@"cm2_btm_bg"];
    // 主页
    [self addChildVC:[GKWYHomeViewController new] title:@"发现" imgName:@"cm2_btm_icn_discovery" selImgName:@"cm2_btm_icn_discovery_prs"];
    // 我的
    [self addChildVC:[GKWYMineViewController new] title:@"我的" imgName:@"cm2_btm_icn_music" selImgName:@"cm2_btm_icn_music_prs"];
}

- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title imgName:(NSString *)imgName selImgName:(NSString *)selImgName {
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = [UIImage imageNamed:imgName];
    childVC.tabBarItem.selectedImage = [UIImage imageNamed:selImgName];
    
    [childVC.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];
    
    GKWYNavigationController *nav = [GKWYNavigationController rootVC:childVC translationScale:NO];
    [self addChildViewController:nav];
}

@end
