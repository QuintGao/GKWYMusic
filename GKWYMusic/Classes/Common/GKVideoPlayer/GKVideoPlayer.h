//
//  GKVideoPlayer.h
//  GKWYMusic
//
//  Created by gaokun on 2018/6/8.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYVideoDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKVideoPlayerStatus) {
    GKVideoPlayerStatusUnload   = -1,   // 未加载
    GKVideoPlayerStatusLoaded   = 0,    // 加载完成
    GKVideoPlayerStatusPlaying  = 1,    // 播放中
    GKVideoPlayerStatusPaused   = 2,    // 暂停
    GKVideoPlayerStatusEnded    = 3,    // 播放结束
    GKVideoPlayerStatusError    = 4     // 错误
};

@interface GKVideoPlayer : UIView

@property (nonatomic, assign) GKVideoPlayerStatus status;

- (void)prepareWithModel:(GKWYVideoFiles *)model;

/**
 开始播放
 */
- (void)play;

/**
 暂停播放
 */
- (void)pause;

/**
 恢复播放
 */
- (void)resume;

@end

NS_ASSUME_NONNULL_END
