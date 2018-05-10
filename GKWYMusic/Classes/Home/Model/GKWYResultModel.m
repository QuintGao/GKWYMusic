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
    return @{@"artist"  : [GKWYArtistModel class],
             @"song"    : [GKWYSongModel class],
             @"album"   : [GKWYAlbumModel class]};
}

@end

@implementation GKWYArtistModel
@end

@implementation GKWYSongModel
@end

@implementation GKWYAlbumModel
@end
