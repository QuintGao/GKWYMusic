//
//  UIButton+GKWYCategory.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/25.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ButtonLayout) {
    ButtonLayout_ImageRight,
    ButtonLayout_ImageLeft,
    ButtonLayout_ImageTop,
    ButtonLayout_ImageBottom
};

@interface UIButton (GKWYCategory)

- (void)setLayout:(ButtonLayout)layout spacing:(CGFloat)spacing;

@end

NS_ASSUME_NONNULL_END
