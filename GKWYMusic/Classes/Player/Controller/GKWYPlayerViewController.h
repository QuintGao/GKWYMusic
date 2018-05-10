//
//  GKWYPlayerViewController.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/19.
//  Copyright © 2018年 gaokun. All rights reserved.
//  播放器页面

typedef NS_ENUM(NSUInteger, GKWYPlayerPlayStyle) {
    GKWYPlayerPlayStyleLoop,        // 循环播放
    GKWYPlayerPlayStyleOne,         // 单曲循环
    GKWYPlayerPlayStyleRandom       // 随机播放
};

#define kWYPlayerVC [GKWYPlayerViewController sharedInstance]

#import <GKNavigationBarViewController/GKNavigationBarViewController.h>

@interface GKWYPlayerViewController : GKNavigationBarViewController

@property (nonatomic, assign) GKWYPlayerPlayStyle   playStyle;      // 循环类型

/** 当前播放的音频的id */
@property (nonatomic, copy) NSString *currentPlayId;

/** 是否正在播放 */
@property (nonatomic, assign) BOOL isPlaying;

+ (instancetype)sharedInstance;

/**
 初始化播放器数据
 */
- (void)initialData;

/**
 重置播放器id列表

 @param playList 列表
 */
- (void)setPlayerList:(NSArray *)playList;

/**
 根据索引及列表播放音乐
 
 @param index 列表中的索引
 @param list 列表
 */
- (void)playMusicWithIndex:(NSInteger)index;

/**
 播放单个音频

 @param model 单个音频数据模型
 */
- (void)playMusicWithModel:(GKWYMusicModel *)model;

/**
 播放
 */
- (void)playMusic;

/**
 暂停
 */
- (void)pauseMusic;

/**
 停止
 */
- (void)stopMusic;

/**
 下一曲
 */
- (void)playNextMusic;

/**
 上一曲
 */
- (void)playPrevMusic;

@end
