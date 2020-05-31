//
//  UINavigationItem+GKCategory.m
//  GKNavigationBarViewController
//
//  Created by QuintGao on 2017/10/13.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "UINavigationItem+GKCategory.h"
#import "GKCommon.h"
#import "GKNavigationBarConfigure.h"

@implementation UINavigationItem (GKCategory)

+ (void)load {
    if (@available(iOS 11.0, *)) {} else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSArray <NSString *>*oriSels = @[@"setLeftBarButtonItem:",
                                             @"setLeftBarButtonItem:animated:",
                                             @"setLeftBarButtonItems:",
                                             @"setLeftBarButtonItems:animated:",
                                             @"setRightBarButtonItem:",
                                             @"setRightBarButtonItem:animated:",
                                             @"setRightBarButtonItems:",
                                             @"setRightBarButtonItems:animated:"];
            
            [oriSels enumerateObjectsUsingBlock:^(NSString * _Nonnull oriSel, NSUInteger idx, BOOL * _Nonnull stop) {
                gk_swizzled_method(self, oriSel, self);
            }];
        });
    }
}

- (void)gk_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self setLeftBarButtonItem:leftBarButtonItem animated:NO];
}

- (void)gk_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem animated:(BOOL)animated {
    if (!GKConfigure.gk_disableFixSpace && leftBarButtonItem) {//存在按钮且需要调节
        [self setLeftBarButtonItems:@[leftBarButtonItem] animated:animated];
    } else {//不存在按钮,或者不需要调节
        [self setLeftBarButtonItems:nil];
        [self gk_setLeftBarButtonItem:leftBarButtonItem animated:animated];
    }
}

- (void)gk_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    [self setLeftBarButtonItems:leftBarButtonItems animated:NO];
}  

- (void)gk_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems animated:(BOOL)animated {
    if (!GKConfigure.gk_disableFixSpace && leftBarButtonItems.count) {//存在按钮且需要调节
        UIBarButtonItem *firstItem = leftBarButtonItems.firstObject;
        CGFloat width = GKConfigure.gk_navItemLeftSpace - GKConfigure.gk_fixedSpace;
        if (firstItem.width == width) {//已经存在space
            [self gk_setLeftBarButtonItems:leftBarButtonItems animated:animated];
        } else {
            NSMutableArray *items = [NSMutableArray arrayWithArray:leftBarButtonItems];
            [items insertObject:[self fixedSpaceWithWidth:width] atIndex:0];
            [self gk_setLeftBarButtonItems:items animated:animated];
        }
    } else {//不存在按钮,或者不需要调节
        [self gk_setLeftBarButtonItems:leftBarButtonItems animated:animated];
    }
}

- (void)gk_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    [self setRightBarButtonItem:rightBarButtonItem animated:NO];
}

- (void)gk_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem animated:(BOOL)animated {
    if (!GKConfigure.gk_disableFixSpace && rightBarButtonItem) {//存在按钮且需要调节
        [self setRightBarButtonItems:@[rightBarButtonItem] animated:animated];
    } else {//不存在按钮,或者不需要调节
        [self setRightBarButtonItems:nil];
        [self gk_setRightBarButtonItem:rightBarButtonItem animated:animated];
    }
}

- (void)gk_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems{
    [self setRightBarButtonItems:rightBarButtonItems animated:NO];
}

- (void)gk_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems animated:(BOOL)animated {
    if (!GKConfigure.gk_disableFixSpace && rightBarButtonItems.count) {//存在按钮且需要调节
        UIBarButtonItem *firstItem = rightBarButtonItems.firstObject;
        CGFloat width = GKConfigure.gk_navItemRightSpace - GKConfigure.gk_fixedSpace;
        if (firstItem.width == width) {//已经存在space
            [self gk_setRightBarButtonItems:rightBarButtonItems animated:animated];
        } else {
            NSMutableArray *items = [NSMutableArray arrayWithArray:rightBarButtonItems];
            [items insertObject:[self fixedSpaceWithWidth:width] atIndex:0];
            [self gk_setRightBarButtonItems:items animated:animated];
        }
    } else {//不存在按钮,或者不需要调节
        [self gk_setRightBarButtonItems:rightBarButtonItems animated:animated];
    }
}

- (UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end

@implementation NSObject (GKCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            NSDictionary *oriSels = @{@"_UINavigationBarContentView": @"layoutSubviews",
                                      @"_UINavigationBarContentViewLayout": @"_updateMarginConstraints"
                                    };
            // bug fixed：这里要用NSObject.class 不能用self，不然会导致crash
            // 具体可看 注意系统库的坑之load函数调用多次 http://satanwoo.github.io/2017/11/02/load-twice/
            [oriSels enumerateKeysAndObjectsUsingBlock:^(NSString *cls, NSString *oriSel, BOOL * _Nonnull stop) {
                gk_swizzled_method(NSClassFromString(cls), oriSel, NSObject.class);
            }];
        }
    });
}

- (void)gk_layoutSubviews {
    if (GKConfigure.gk_disableFixSpace) return;
    if (![self isMemberOfClass:NSClassFromString(@"_UINavigationBarContentView")]) return;
    id layout = [self valueForKey:@"_layout"];
    if (!layout) return;
    SEL selector = NSSelectorFromString(@"_updateMarginConstraints");
    IMP imp = [layout methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(layout, selector);
    [self gk_layoutSubviews];
}

- (void)gk__updateMarginConstraints {
    if (GKConfigure.gk_disableFixSpace) return;
    if (![self isMemberOfClass:NSClassFromString(@"_UINavigationBarContentViewLayout")]) return;
    [self gk_adjustLeadingBarConstraints];
    [self gk_adjustTrailingBarConstraints];
    [self gk__updateMarginConstraints];
}

- (void)gk_adjustLeadingBarConstraints {
    if (GKConfigure.gk_disableFixSpace) return;
    NSArray<NSLayoutConstraint *> *leadingBarConstraints = [self valueForKey:@"_leadingBarConstraints"];
    if (!leadingBarConstraints) return;
    CGFloat constant = GKConfigure.gk_navItemLeftSpace - GKConfigure.gk_fixedSpace;
    for (NSLayoutConstraint *constraint in leadingBarConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeLeading && constraint.secondAttribute == NSLayoutAttributeLeading) {
            constraint.constant = constant;
        }
    }
}

- (void)gk_adjustTrailingBarConstraints {
    if (GKConfigure.gk_disableFixSpace) return;
    NSArray<NSLayoutConstraint *> *trailingBarConstraints = [self valueForKey:@"_trailingBarConstraints"];
    if (!trailingBarConstraints) return;
    CGFloat constant = GKConfigure.gk_fixedSpace - GKConfigure.gk_navItemRightSpace;
    for (NSLayoutConstraint *constraint in trailingBarConstraints) {
        if (constraint.firstAttribute == NSLayoutAttributeTrailing && constraint.secondAttribute == NSLayoutAttributeTrailing) {
            constraint.constant = constant;
        }
    }
}

@end
