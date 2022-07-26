//
//  UIButton+GKWYCategory.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/25.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "UIButton+GKWYCategory.h"

@implementation UIButton (GKWYCategory)

- (void)setLayout:(ButtonLayout)layout spacing:(CGFloat)spacing {
    switch (layout) {
        case ButtonLayout_ImageLeft:
            [self setAlignHorizontalWithSpacing:spacing isImageLeft:YES];
            break;
        case ButtonLayout_ImageRight:
            [self setAlignHorizontalWithSpacing:spacing isImageLeft:NO];
            break;
        case ButtonLayout_ImageTop:
            [self setAlignVerticalWithSpacing:spacing isImageTop:YES];
            break;
        case ButtonLayout_ImageBottom:
            [self setAlignVerticalWithSpacing:spacing isImageTop:NO];
            break;
            
        default:
            break;
    }
}

- (void)setAlignHorizontalWithSpacing:(CGFloat)spacing isImageLeft:(BOOL)imageLeft {
    CGFloat edgeOffset = spacing / 2;
    self.imageEdgeInsets = UIEdgeInsetsMake(0, -edgeOffset, 0, edgeOffset);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, edgeOffset, 0, -edgeOffset);
    if (!imageLeft) {
        self.transform = CGAffineTransformMakeScale(-1, 1);
        self.imageView.transform = CGAffineTransformMakeScale(-1, 1);
        self.titleLabel.transform = CGAffineTransformMakeScale(-1, 1);
    }
    self.contentEdgeInsets = UIEdgeInsetsMake(0, edgeOffset, 0, edgeOffset);
}

- (void)setAlignVerticalWithSpacing:(CGFloat)spacing isImageTop:(BOOL)imageTop {
    CGSize titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    CGSize imageSize = self.imageView.image.size;
    
    CGFloat imageVerticalOffset = (titleSize.height + spacing) / 2;
    CGFloat titleVerticalOffset = (imageSize.height + spacing) / 2;
    CGFloat imageHorizontalOffset = imageSize.width / 2;
    CGFloat titleHorizontalOffset = titleSize.width / 2;
    CGFloat sign = imageTop ? 1 : -1;
    
    self.imageEdgeInsets = UIEdgeInsetsMake(-imageVerticalOffset * sign, imageHorizontalOffset, imageVerticalOffset * sign, -imageHorizontalOffset);
    self.titleEdgeInsets = UIEdgeInsetsMake(titleVerticalOffset * sign, -titleHorizontalOffset, -titleVerticalOffset * sign, titleHorizontalOffset);
    
    CGFloat edgeOffset = (MIN(imageSize.height, titleSize.height) + spacing) / 2;
    self.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0, edgeOffset, 0);
 }

@end
