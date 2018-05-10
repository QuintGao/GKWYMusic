//
//  UIViewController+GKWYCategory.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "UIViewController+GKWYCategory.h"

@implementation UIViewController (GKWYCategory)

- (UIViewController *)visibleViewControllerIfExist {
    if (self.presentedViewController) {
        return [self.presentedViewController visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).topViewController visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController visibleViewControllerIfExist];
    }
    
    if ([self isViewLoaded] && self.view.window) {
        return self;
    } else {
        NSLog(@"visibleViewControllerIfExist:，找不到可见的viewController。self = %@, self.view.window = %@", self, self.view.window);
        return nil;
    }
}

@end
