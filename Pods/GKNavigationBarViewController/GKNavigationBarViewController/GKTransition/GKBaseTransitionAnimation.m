//
//  GKBaseTransitionAnimation.m
//  GKNavigationBarViewController
//
//  Created by gaokun on 2019/1/15.
//  Copyright © 2019 gaokun. All rights reserved.
//

#import "GKBaseTransitionAnimation.h"

@interface GKBaseTransitionAnimation()

@end

@implementation GKBaseTransitionAnimation

+ (instancetype)transitionWithScale:(BOOL)scale {
    return [[self alloc] initWithScale:scale];
}

- (instancetype)initWithScale:(BOOL)scale {
    if (self = [super init]) {
        self.scale = scale;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

// 转场动画的时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return UINavigationControllerHideShowBarDuration;
}

// 转场动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 获取转场容器
    UIView *containerView = [transitionContext containerView];
    
    // 获取转场前后的控制器
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.containerView      = containerView;
    self.fromViewController = fromVC;
    self.toViewController   = toVC;
    self.transitionContext  = transitionContext;
    
    [self animateTransition];
}

// 子类重写
- (void)animateTransition{}

- (void)completeTransition {
    [self.transitionContext completeTransition:!self.transitionContext.transitionWasCancelled];
}

- (UIImage *)getCaptureWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

static const void* GKCaptureImageKey         = @"GKCaptureImage";

@implementation UIViewController (GKCapture)

- (void)setGk_captureImage:(UIImage *)gk_captureImage {
    objc_setAssociatedObject(self, &GKCaptureImageKey, gk_captureImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)gk_captureImage{
    return objc_getAssociatedObject(self, &GKCaptureImageKey);
}

@end
