//
//  GKVerticalButton.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/11.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKVerticalButton.h"

@implementation GKVerticalButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 调整frame
    [self.imageView sizeToFit];
    self.imageView.gk_centerX  = self.gk_width * 0.5f;
    self.imageView.gk_y        = 0;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.gk_centerX = self.gk_width * 0.5f;
    self.titleLabel.gk_y       = self.imageView.gk_bottom;
}

@end
