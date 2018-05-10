//
//  AppDelegate.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/19.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "AppDelegate.h"
#import "GKWYMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@", KDownloadManager.downloadDataDir);
    // 初始化导航栏style
    [self initNavStyle];
    
    // 初始化主窗口
    [self initWindow];
    
    // 初始化全局播放按钮
    [self initPlayBtn];
    
    // 初始化播放器
    [kWYPlayerVC initialData];
    
    // 网络监测
    [self networkStateCheck];

    return YES;
}

/**
 初始化导航栏style
 */
- (void)initNavStyle {
    [GKConfigure setupCustomConfigure:^(GKNavigationBarConfigure *configure) {
        // 导航栏背景色
        configure.backgroundColor = kAPPDefaultColor;
        configure.titleColor      = [UIColor whiteColor];
        configure.titleFont       = [UIFont systemFontOfSize:18.0f];
        configure.statusBarStyle  = UIStatusBarStyleLightContent;
        configure.backStyle       = GKNavigationBarBackStyleNone;
        configure.navItem_space   = 4.0f;
    }];
    
    // 适配iOS11
    if (@available(iOS 11.0, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
    }
}

/**
 初始化主窗口
 */
- (void)initWindow {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [GKWYMainViewController new];
    [self.window makeKeyAndVisible];
}

- (void)initPlayBtn {
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1"] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1_prs"] forState:UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(topbarPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:self.playBtn];
    
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.window).offset(statusBarFrame.size.height);
        make.right.equalTo(self.window).offset(-4);
        make.width.height.mas_equalTo(44.0f);
    }];
    
    [kNotificationCenter addObserver:self selector:@selector(playStatusChanged:) name:GKWYMUSIC_PLAYSTATECHANGENOTIFICATION object:nil];
}

/**
 网络监测
 */
- (void)networkStateCheck {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [GKWYMusicTool setNetworkState:@"wwan"];
                NSLog(@"4G");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [GKWYMusicTool setNetworkState:@"wifi"];
                NSLog(@"wifi");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [GKWYMusicTool setNetworkState:@"none"];
                NSLog(@"无网络");
                break;
            case AFNetworkReachabilityStatusUnknown:
                [GKWYMusicTool setNetworkState:@"none"];
                NSLog(@"无网络");
                break;
                
            default:
                break;
        }
        // 发送网络状态改变的通知
        [kNotificationCenter postNotificationName:GKWYMUSIC_NETWORKCHANGENOTIFICATION object:nil];
    }];
    [manager startMonitoring];
}

- (void)topbarPlayBtnClick:(id)sender {
    [[GKWYMusicTool visibleViewController].navigationController pushViewController:kWYPlayerVC animated:YES];
}

- (void)playStatusChanged:(NSNotification *)notify {
    if (kWYPlayerVC.isPlaying) {
        NSMutableArray *images = [NSMutableArray new];
        for (NSInteger i = 0; i < 6; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%zd", i + 1];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        
        for (NSInteger i = 6; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%zd", i];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        
        self.playBtn.imageView.animationImages   = images;
        self.playBtn.imageView.animationDuration = 0.75;
        [self.playBtn.imageView startAnimating];
    }else {
        if (self.playBtn.imageView.isAnimating) {
            [self.playBtn.imageView stopAnimating];
        }
        [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1"] forState:UIControlStateNormal];
        [self.playBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_playing1_prs"] forState:UIControlStateHighlighted];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
