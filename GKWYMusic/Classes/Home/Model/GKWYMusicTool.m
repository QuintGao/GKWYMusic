//
//  GKWYMusicTool.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMusicTool.h"
#import "AppDelegate.h"

#define kDataPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"audio.json"]

#define kLovedDataPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"audio_love.json"]

#define kHistoryDataPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"search_history.json"]

@implementation GKWYMusicTool

+ (void)saveMusicList:(NSArray *)musicList {
    [NSKeyedArchiver archiveRootObject:musicList toFile:kDataPath];
}

+ (NSArray *)musicList {
    NSArray *musics = [NSKeyedUnarchiver unarchiveObjectWithFile:kDataPath];
    
    return musics;
}

+ (NSArray *)lovedMusicList {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:kLovedDataPath];
}

+ (void)loveMusic:(GKWYMusicModel *)model {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self lovedMusicList]];
    
    if (model.isLove) {
        __block BOOL exist = NO;
        [arr enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.song_id isEqualToString:model.song_id]) {
                exist = YES;
                *stop = YES;
            }
        }];
        
        if (!exist) {
            [arr addObject:model];
        }
    }else {
        __block NSInteger index = 0;
        __block BOOL exist      = NO;
        [arr enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.song_id isEqualToString:model.song_id]) {
                index = idx;
                exist = YES;
                *stop = YES;
            }
        }];
        
        if (exist) {
            [arr removeObjectAtIndex:index];
        }
    }
    [NSKeyedArchiver archiveRootObject:arr toFile:kLovedDataPath];
}

+ (NSInteger)indexFromID:(NSString *)musicID {
    __block NSInteger index = 0;
    
    [[self musicList] enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.song_id isEqualToString:musicID]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

+ (void)saveModel:(GKWYMusicModel *)model {
    NSMutableArray *musics = [NSMutableArray arrayWithArray:[self musicList]];
    
    [musics enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.song_id isEqualToString:obj.song_id]) {
            [musics replaceObjectAtIndex:idx withObject:model];
            *stop = YES;
        }
    }];
    
    [self saveMusicList:musics];
}

#pragma mark - history
+ (NSArray *)historys {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:kHistoryDataPath];
}

+ (void)saveHistory:(NSArray *)historys {
    [NSKeyedArchiver archiveRootObject:historys toFile:kHistoryDataPath];
}

+ (NSString *)lastMusicId {
    return [kUserDefaults objectForKey:GKWYMUSIC_USERDEFAULTSKEY_LASTPLAYID];
}

+ (NSInteger)playStyle {
    return [kUserDefaults integerForKey:GKWYMUSIC_USERDEFAULTSKEY_PLAYSTYLE];
}

+ (UIViewController *)visibleViewController {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [rootVC visibleViewControllerIfExist];
}

+ (void)showPlayBtn {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate.playBtn setHidden:NO];
}

+ (void)hidePlayBtn {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate.playBtn setHidden:YES];
}

+ (NSString *)networkState {
    return [kUserDefaults objectForKey:GKWYMUSIC_USERDEFAULTSKEY_NETWORKSTATE];
}

+ (void)setNetworkState:(NSString *)state {
    NSUserDefaults *defaults = kUserDefaults;
    [defaults setObject:state forKey:GKWYMUSIC_USERDEFAULTSKEY_NETWORKSTATE];
    [defaults synchronize];
}

+ (NSString *)timeStrWithMsTime:(NSTimeInterval)msTime {
    return [self timeStrWithSecTime:msTime / 1000];
}

+ (NSString *)timeStrWithSecTime:(NSTimeInterval)secTime {
    NSInteger time = (NSInteger)secTime;
    
    if (time / 3600 > 0) { // 时分秒
        NSInteger hour   = time / 3600;
        NSInteger minute = (time % 3600) / 60;
        NSInteger second = (time % 3600) % 60;
        
        return [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hour, minute, second];
    }else { // 分秒
        NSInteger minute = time / 60;
        NSInteger second = time % 60;
        
        return [NSString stringWithFormat:@"%02zd:%02zd", minute, second];
    }
}

+ (void)downloadMusicWithIds:(NSArray *)ids {
    // 多个id用,隔开
    NSString *idStr = [ids componentsJoinedByString:@","];
    
    // url
    NSString *url = [NSString stringWithFormat:@"http://ting.baidu.com/data/music/links?songIds=%@", idStr];
    
    [kHttpManager getWithURL:url params:nil successBlock:^(id responseObject) {
        
        if ([responseObject[@"errorCode"] integerValue] == 22000) {
            NSDictionary *data = responseObject[@"data"];
            
            NSDictionary *songInfo = data[@"songList"][0];
            
            GKDownloadModel *dModel = [GKDownloadModel new];
            dModel.fileID           = songInfo[@"songId"];
            dModel.fileName         = songInfo[@"songName"];
            dModel.fileArtistId     = songInfo[@"artistId"];
            dModel.fileArtistName   = songInfo[@"artistName"];
            dModel.fileAlbumId      = songInfo[@"albumId"];
            dModel.fileAlbumName    = songInfo[@"albumName"];
            dModel.fileCover        = songInfo[@"songPicRadio"];
            dModel.fileUrl          = songInfo[@"songLink"];
            dModel.fileDuration     = songInfo[@"time"];
            dModel.fileFormat       = songInfo[@"format"];
            dModel.fileRate         = songInfo[@"rate"];
            dModel.fileSize         = songInfo[@"size"];
            dModel.fileLyric        = songInfo[@"lrcLink"];
            
            [KDownloadManager addDownloadArr:@[dModel]];
            
            [GKMessageTool showText:@"已加入到下载队列"];
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

+ (void)downloadMusicWithSongId:(NSString *)songId {
    NSString *api = [NSString stringWithFormat:@"baidu.ting.song.play&songid=%@", songId];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        GKWYMusicModel *model = [GKWYMusicModel yy_modelWithDictionary:responseObject[@"songinfo"]];
        
        NSDictionary *bitrate = responseObject[@"bitrate"];
        model.file_link        = bitrate[@"file_link"];
        model.file_duration    = bitrate[@"file_duration"];
        model.file_bitrate     = bitrate[@"file_bitrate"];
        model.file_size        = bitrate[@"file_size"];
        model.file_extension   = bitrate[@"file_extension"];
        
        GKDownloadModel *dModel = [GKDownloadModel new];
        dModel.fileID           = model.song_id;
        dModel.fileName         = model.song_name;
        dModel.fileArtistId     = model.artist_id;
        dModel.fileArtistName   = model.artist_name;
        dModel.fileAlbumId      = model.album_id;
        dModel.fileAlbumName    = model.album_title;
        dModel.fileCover        = model.pic_radio;
        dModel.fileUrl          = model.file_link;
        dModel.fileDuration     = model.file_duration;
        dModel.fileFormat       = model.file_extension;
        dModel.fileRate         = model.file_bitrate;
        dModel.fileSize         = model.file_size;
        dModel.fileLyric        = model.lrclink;
        
        [KDownloadManager addDownloadArr:@[dModel]];
        
        [GKMessageTool showText:@"已加入到下载队列"];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"获取详情失败==%@", error);
        [GKMessageTool showError:@"加入下载失败"];
    }];
}

@end
