//
//  GKWYNavigationController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYNavigationController.h"

@interface GKWYNavigationController ()

@end

@implementation GKWYNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        UIViewController *root = self.childViewControllers.firstObject;
        
        if (viewController != root) {
            if ([viewController isKindOfClass:[GKNavigationBarViewController class]]) {
                GKNavigationBarViewController *vc = (GKNavigationBarViewController *)viewController;
                vc.gk_navLeftBarButtonItem = [UIBarButtonItem itemWithImageName:@"cm2_topbar_icn_back" target:self action:@selector(backAction)];
            }
            viewController.hidesBottomBarWhenPushed = YES;
        }
    }
    [super pushViewController:viewController animated:animated];
}

- (void)backAction {
    [self popViewControllerAnimated:YES];
}

@end
