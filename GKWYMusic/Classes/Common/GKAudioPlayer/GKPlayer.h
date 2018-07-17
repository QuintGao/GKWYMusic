////
////  GKPlayer.h
////  GKWYMusic
////
////  Created by gaokun on 2018/4/19.
////  Copyright © 2018年 gaokun. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//
////#define kPlayer [GKPlayer sharedInstance]
//
//typedef NS_ENUM(NSUInteger, GKPlayerStatus) {
//    GKPlayerStatusBuffering = 0,    // 缓冲中
//    GKPlayerStatusPlaying   = 1,    // 播放中
//    GKPlayerStatusPaused    = 2,    // 暂停
//    GKPlayerStatusStopped   = 3,    // 手动停止
//    GKPlayerStatusEnded     = 4,    // 播放结束
//    GKPlayerStatusError     = 5     // 播放出错
//};
//
//@class GKPlayer;
//
//@protocol GKPlayerDelegate <NSObject>
//
//@optional
//
//// 播放器状态改变
//- (void)gkPlayer:(GKPlayer *)player statusChanged:(GKPlayerStatus)status;
//
//// 播放时间（单位：毫秒)、总时间（单位：毫秒）、进度（播放时间 / 总时间）
//- (void)gkPlayer:(GKPlayer *)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime progress:(float)progress;
//
//// 总时间（单位：毫秒）
//- (void)gkPlayer:(GKPlayer *)player totalTime:(NSTimeInterval)totalTime;
//
//@end
//
//@interface GKPlayer : NSObject
//
///** 代理 */
//@property (nonatomic, weak) id<GKPlayerDelegate> delegate;
///** 播放地址 */
//@property (nonatomic, copy) NSString *playUrlStr;
///** 播放状态 */
//@property (nonatomic, assign) GKPlayerStatus status;
//
///**
// 单例方法
// */
//+ (instancetype)sharedInstance;
//
//- (void)setPlayerProgress:(float)progress;
//
//- (void)play;
//- (void)pause;
//- (void)resume;
//- (void)stop;
//
//@end
