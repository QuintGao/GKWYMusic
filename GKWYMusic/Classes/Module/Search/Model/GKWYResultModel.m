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
    return @{@"artist"  : [GKWYResultArtistInfoModel class],
             @"song"    : [GKWYResultSongInfoModel class],
             @"album"   : [GKWYResultAlbumInfoModel class],
             @"video"   : [GKWYResultVideoInfoModel class]};
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
    return @{@"songs"  : [GKWYMusicModel class]};
}

- (NSAttributedString *)moreAttr {
    if (!_moreAttr) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ >", self.moreText]];
        [attr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.0f], NSForegroundColorAttributeName: GKColorGray(135)} range:NSMakeRange(0, attr.length)];
        
        if (self.highText && [self.moreText containsString:self.highText]) {
            NSRange range = [self.moreText rangeOfString:self.highText];
            [attr addAttributes:@{NSForegroundColorAttributeName: KAPPSearchColor} range:range];
        }
        
        _moreAttr = attr;
    }
    return _moreAttr;
}

@end

#pragma amrk - album
@implementation GKWYResultAlbumInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"albums"  : [GKWYAlbumModel class]};
}

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
    return @{@"playLists"  : [GKWYPlayListModel class]};
}

- (NSAttributedString *)moreAttr {
    if (!_moreAttr) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ >", self.moreText]];
        [attr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.0f], NSForegroundColorAttributeName: GKColorGray(135)} range:NSMakeRange(0, attr.length)];
        
        if (self.highText && [self.moreText containsString:self.highText]) {
            NSRange range = [self.moreText rangeOfString:self.highText];
            [attr addAttributes:@{NSForegroundColorAttributeName: KAPPSearchColor} range:range];
        }
        
        _moreAttr = attr;
    }
    return _moreAttr;
}

@end

#pragma mark - user
@implementation GKWYResultUserInfoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"user_list"  : [GKWYResultUserModel class]};
}

@end

@implementation GKWYResultUserModel
@end
