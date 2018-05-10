//
//  GKWYMusicModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKWYMusicModel : NSObject<NSCoding>
// 歌曲id
@property (nonatomic, copy) NSString *song_id;
// 歌曲名称
@property (nonatomic, copy) NSString *song_name;
// 歌手id
@property (nonatomic, copy) NSString *artist_id;
// 歌手名称
@property (nonatomic, copy) NSString *artist_name;
// 专辑id
@property (nonatomic, copy) NSString *album_id;
// 专辑名称
@property (nonatomic, copy) NSString *album_title;

// 用于背景图
@property (nonatomic, copy) NSString *pic_huge;

// 用于锁屏图片
@property (nonatomic, copy) NSString *pic_radio;
// 是否有mv
@property (nonatomic, copy) NSString *has_mv;
// 歌词
@property (nonatomic, copy) NSString *lrclink;

// 声音时长
@property (nonatomic, copy) NSString *file_duration;
// 声音扩展名
@property (nonatomic, copy) NSString *file_extension;
// 声音速率
@property (nonatomic, copy) NSString *file_bitrate;
// 声音大小
@property (nonatomic, copy) NSString *file_size;
// 声音播放路径
@property (nonatomic, copy) NSString *file_link;

#pragma mark - 额外的扩展属性
/** 是否正在播放 */
@property (nonatomic, assign) BOOL isPlaying;

/** 是否喜欢 */
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, assign) BOOL isLove;

/** 是否下载 */
@property (nonatomic, assign) BOOL isDownload;

@property (nonatomic, assign) GKDownloadManagerState downloadState;

@property (nonatomic, copy) NSString *song_size;
@property (nonatomic, copy) NSString *completed_size;

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) NSInteger fileLength;
@property (nonatomic, assign) NSInteger currentLength;

// 歌曲的本地路径
@property (nonatomic, copy) NSString *song_localPath;

// 歌曲的本地歌词
@property (nonatomic, copy) NSString *song_lyricPath;

// 歌曲的本地图片
@property (nonatomic, copy) NSString *song_imagePath;

@end
