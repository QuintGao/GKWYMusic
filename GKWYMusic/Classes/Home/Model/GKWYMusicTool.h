//
//  GKWYMusicTool.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKWYMusicModel.h"

@interface GKWYMusicTool : NSObject

/**
 此方法用于保存当前正在播放的音乐列表

 @param musicList 当前正在播放的音乐列表
 */
+ (void)saveMusicList:(NSArray *)musicList;

/**
 此方法用于获取本地保存的播放器正在播放的音乐列表

 @return 音乐列表
 */
+ (NSArray *)musicList;


#pragma mark - Loved
+ (NSArray *)lovedMusicList;
+ (void)loveMusic:(GKWYMusicModel *)model;

+ (NSInteger)indexFromID:(NSString *)musicID;

+ (void)saveModel:(GKWYMusicModel *)model;

#pragma mark - history
+ (NSArray *)historys;
+ (void)saveHistory:(NSArray *)historys;

#pragma mark - 历史播放信息
+ (NSString *)lastMusicId;
+ (NSInteger)playStyle;

#pragma mark - 其他
+ (UIViewController *)visibleViewController;

+ (void)showPlayBtn;
+ (void)hidePlayBtn;

+ (NSString *)networkState;
+ (void)setNetworkState:(NSString *)state;

// 时间转字符串：毫秒-> string
+ (NSString *)timeStrWithMsTime:(NSTimeInterval)msTime;
// 时间转字符串：秒 -> string
+ (NSString *)timeStrWithSecTime:(NSTimeInterval)secTime;


// 下载
+ (void)downloadMusicWithIds:(NSArray *)ids;

+ (void)downloadMusicWithSongId:(NSString *)songId;

@end
