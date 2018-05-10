//
//  GKAudioPlayer.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/24.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FreeStreamer/FSAudioStream.h>

typedef NS_ENUM(NSUInteger, GKAudioPlayerState) {
    GKAudioPlayerStateLoading,          // 加载中
    GKAudioPlayerStateBuffering,        // 缓冲中
    GKAudioPlayerStatePlaying,          // 播放
    GKAudioPlayerStatePaused,           // 暂停
    GKAudioPlayerStateStopped,          // 停止（手动）
    GKAudioPlayerStateEnded,            // 结束（播放完成）
    GKAudioPlayerStateError             // 错误
};

#define kPlayer [GKAudioPlayer sharedInstance]

@class GKAudioPlayer;

@protocol GKAudioPlayerDelegate<NSObject>

// 播放器状态改变
- (void)gkPlayer:(GKAudioPlayer *)player statusChanged:(GKAudioPlayerState)status;

// 播放时间（单位：毫秒)、总时间（单位：毫秒）、进度（播放时间 / 总时间）
- (void)gkPlayer:(GKAudioPlayer *)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime progress:(float)progress;

// 总时间（单位：毫秒）
- (void)gkPlayer:(GKAudioPlayer *)player totalTime:(NSTimeInterval)totalTime;

// 缓冲进度
- (void)gkPlayer:(GKAudioPlayer *)player bufferProgress:(float)bufferProgress;

@end

@interface GKAudioPlayer : NSObject

/**
 代理
 */
@property (nonatomic, weak) id<GKAudioPlayerDelegate> delegate;

/**
 播放地址（网络或本地）
 */
@property (nonatomic, copy) NSString *playUrlStr;

/**
 播放状态
 */
@property (nonatomic, assign) GKAudioPlayerState state;

/**
 单例

 @return 播放器对象
 */
+ (instancetype)sharedInstance;

/**
 快进、快退

 @param progress 进度
 */
- (void)setPlayerProgress:(float)progress;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 恢复（暂停后再次播放使用）
 */
- (void)resume;

/**
 停止
 */
- (void)stop;

@end
