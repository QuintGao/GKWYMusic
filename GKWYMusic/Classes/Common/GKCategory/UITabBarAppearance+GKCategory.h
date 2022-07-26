//
//  UITabBarAppearance+GKCategory.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBarAppearance (GKCategory)

/**
 同时设置 stackedLayoutAppearance、inlineLayoutAppearance、compactInlineLayoutAppearance 三个状态下的 itemAppearance
 */
- (void)applyItemAppearanceWithBlock:(void (^ _Nullable)(UITabBarItemAppearance * _Nullable itemAppearance))block;

@end

NS_ASSUME_NONNULL_END
