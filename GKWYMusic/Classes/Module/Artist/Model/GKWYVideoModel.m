//
//  GKWYVideoModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/17.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYVideoModel.h"

@implementation GKWYVideoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"video_id"        : @"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"artist"  : [GKWYArtistModel class]};
}

- (NSString *)durationStr {
    if (!_durationStr) {
        _durationStr = [GKWYMusicTool timeStrWithMsTime:self.duration.intValue];
    }
    return _durationStr;
}

- (NSString *)playCountStr {
    if (!_playCountStr) {
        if (self.playCount.intValue > 10000) {
            _playCountStr = [NSString stringWithFormat:@"%.1f万播放", self.playCount.intValue / 10000.0];
        }else {
            _playCountStr = [NSString stringWithFormat:@"%@播放", self.playCount];
        }
    }
    return _playCountStr;
}

- (CGFloat)cellHeight {
    if (!_cellHeight) {
        _cellHeight = kAdaptive(190.0f);
    }
    return _cellHeight;
}

@end
