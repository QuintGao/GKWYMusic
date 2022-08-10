//
//  GKWYVideoDetailModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/29.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYVideoDetailModel.h"

@implementation GKWYVideoDetailModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"video_info"  : [GKWYVideoInfo class],
             @"mv_info"     : [GKWYVideoMVInfo class]};
}

- (GKWYVideoFiles *)video_file {
    if (!_video_file) {
        // 获取高清晰度的
        _video_file = [GKWYVideoFiles yy_modelWithDictionary:self.files[self.max_definition]];
    }
    return _video_file;
}

@end

@implementation GKWYVideoInfo

@end

@implementation GKWYVideoFiles

@end

@implementation GKWYVideoMVInfo

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"artist_list"  : [GKWYVideoArtist class]};
}

@end

@implementation GKWYVideoArtist

@end
