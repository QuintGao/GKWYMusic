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

#pragma mark - artist
@implementation GKWYResultArtistInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"artist_list"  : [GKWYResultArtistModel class]};
}

@end
@implementation GKWYResultArtistModel
@end

#pragma mark - song
@implementation GKWYResultSongInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"song_list"  : [GKWYMusicModel class]};
}

@end

#pragma amrk - album
@implementation GKWYResultAlbumInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"album_list"  : [GKWYResultAlbumModel class]};
}

@end
@implementation GKWYResultAlbumModel
@end

#pragma mark - video
@implementation GKWYResultVideoInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"video_list"  : [GKWYResultVideoModel class]};
}

@end
@implementation GKWYResultVideoModel
@end

#pragma mark - playlist
@implementation GKWYResultPlayListInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"playlist_info"  : [GKWYResultPlayListModel class]};
}

@end
@implementation GKWYResultPlayListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"userinfo"  : [GKWYResultPlayListUserInfoModel class]};
}

@end
@implementation GKWYResultPlayListUserInfoModel
@end

#pragma mark - user
@implementation GKWYResultUserInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"user_list"  : [GKWYResultUserModel class]};
}

@end

@implementation GKWYResultUserModel
@end
