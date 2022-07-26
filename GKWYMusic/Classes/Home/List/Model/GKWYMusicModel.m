//
//  GKWYMusicModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMusicModel.h"

@implementation GKWYMusicArModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ar_id"       : @"id"};
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

@end

@implementation GKWYMusicModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"song_id"     : @"id",
             @"song_name"   : @"name",
             @"album_id"    : @"al.id",
             @"album_title" : @"al.name",
             @"album_pic"   : @"al.picUrl"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"ar"  : [GKWYMusicArModel class]};
}

- (NSString *)artists_name {
    if (!_artists_name) {
        [self.ar enumerateObjectsUsingBlock:^(GKWYMusicArModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (_artists_name == nil) {
                _artists_name = obj.name;
            }else {
                _artists_name = [NSString stringWithFormat:@"%@/%@", _artists_name, obj.name];
            }
        }];
    }
    return _artists_name;
}

- (NSString *)alia_name {
    if (!_alia_name) {
        if (self.alia.count > 0) {
            _alia_name = [NSString stringWithFormat:@"(%@)", self.alia.firstObject];
        }else {
            _alia_name = @"";
        }
    }
    return _alia_name;
}

- (BOOL)isPlaying {
    NSDictionary *musicInfo = [GKWYMusicTool lastMusicInfo];

    return [self.song_id isEqualToString:musicInfo[@"play_id"]];
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

//- (NSString *)pic_radio {
//    if (!_pic_radio || [_pic_radio isEqualToString:@""]) {
//        _pic_radio = self.pic_big;
//    }                                                                                  
//    return _pic_radio;
//}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

@end
