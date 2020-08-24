//
//  GKDelegateHandler.h
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/7/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKNavigationControllerDelegate;
// 此类用于处理UIGestureRecognizerDelegate的代理方法
@interface GKPopGestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

// 系统返回手势的target
@property (nonatomic, weak) id systemTarget;

@property (nonatomic, weak) GKNavigationControllerDelegate *customTarget;

@end

// 此类用于处理UINavigationControllerDelegate的代理方法
@interface GKNavigationControllerDelegate : NSObject<UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

// 手势Action
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture;

@end
