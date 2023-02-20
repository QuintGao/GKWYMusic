//
//  GKWYVideoDetailModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/29.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYVideoDetailModel.h"

@implementation GKWYVideoDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"mv_id": @"id"};
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
