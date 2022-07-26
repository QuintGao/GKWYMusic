//
//  UITabBarAppearance+GKCategory.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "UITabBarAppearance+GKCategory.h"

@implementation UITabBarAppearance (GKCategory)

- (void)applyItemAppearanceWithBlock:(void (^)(UITabBarItemAppearance * _Nullable))block {
    block(self.stackedLayoutAppearance);
    block(self.inlineLayoutAppearance);
    block(self.compactInlineLayoutAppearance);
}

@end
