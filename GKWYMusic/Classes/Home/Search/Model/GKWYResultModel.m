//
//  GKWYResultModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYResultModel.h"

@implementation GKWYResultModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"artist"  : [GKWYResultArtistModel class],
             @"song"    : [GKWYResultSongModel class],
             @"album"   : [GKWYResultAlbumModel class]};
}

@end

@implementation GKWYResultArtistModel
@end

@implementation GKWYResultSongModel
@end

@implementation GKWYResultAlbumModel
@end
