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
    return @{@"artist_info"  : [GKWYResultArtistInfoModel class],
             @"song_info"    : [GKWYResultSongInfoModel class],
             @"album_info"   : [GKWYResultAlbumInfoModel class],
             @"video_info"   : [GKWYResultVideoInfoModel class]};
}

@end

@implementation GKWYResultArtistInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"artist_list"  : [GKWYResultArtistModel class]};
}

@end
@implementation GKWYResultArtistModel
@end
@implementation GKWYResultSongInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"song_list"  : [GKWYResultSongModel class]};
}

@end
@implementation GKWYResultSongModel
@end
@implementation GKWYResultAlbumInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"album_list"  : [GKWYResultAlbumModel class]};
}

@end
@implementation GKWYResultAlbumModel
@end
@implementation GKWYResultVideoInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"video_list"  : [GKWYResultVideoModel class]};
}

@end
@implementation GKWYResultVideoModel
@end
