//
//  GKLyricModel.m
//  GKAudioPlayerDemo
//
//  Created by QuintGao on 2017/9/7.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKLyricModel.h"

@implementation GKLyricModel

- (CGFloat)cellHeight {
    if (!_cellHeight) {
        _cellHeight = [GKWYMusicTool sizeWithText:self.content font:[UIFont systemFontOfSize:15.0] maxW:kScreenW - kAdaptive(160)].height;
        _cellHeight += kAdaptive(30.0f);
    }
    return _cellHeight;
}

@end
