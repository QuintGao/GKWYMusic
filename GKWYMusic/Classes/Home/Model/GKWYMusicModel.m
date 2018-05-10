//
//  GKWYMusicModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMusicModel.h"

@implementation GKWYMusicModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"song_name"       : @"title",
             @"artist_name"     : @"author"
             };
}

- (BOOL)isPlaying {
    return [self.song_id isEqualToString:[kUserDefaults objectForKey:GKWYMUSIC_USERDEFAULTSKEY_LASTPLAYID]];
}

- (BOOL)isLike {
    __block BOOL exist = NO;
    
    [[GKWYMusicTool lovedMusicList] enumerateObjectsUsingBlock:^(GKWYMusicModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.song_id isEqualToString:self.song_id]) {
            exist = YES;
        }
    }];
    return exist;
}

- (BOOL)isDownload {
    return [KDownloadManager checkDownloadWithID:self.song_id];
}

- (NSString *)song_localPath {
    if (self.isDownload) {
        return [KDownloadManager modelWithID:self.song_id].fileLocalPath;
    }
    return nil;
}

- (NSString *)song_lyricPath {
    if (self.isDownload) {
        return [KDownloadManager modelWithID:self.song_id].fileLyricPath;
    }
    return nil;
}

- (NSString *)song_imagePath {
    if (self.isDownload) {
        return [KDownloadManager modelWithID:self.song_id].fileImagePath;
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

@end
