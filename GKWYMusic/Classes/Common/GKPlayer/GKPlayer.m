////
////  GKPlayer.m
////  GKWYMusic
////
////  Created by gaokun on 2018/4/19.
////  Copyright © 2018年 gaokun. All rights reserved.
////
//
//#import "GKPlayer.h"
//#import <TXLiteAVSDK_Player/TXLiveBase.h>
//#import <TXLiteAVSDK_Player/TXLivePlayer.h>
//#import <TXLiteAVSDK_Player/TXLivePlayListener.h>
//
//@interface GKPlayer()<TXLivePlayListener>
//
//@property (nonatomic, strong) TXLivePlayer  *txLivePlayer;
//
//@property (nonatomic, assign) NSTimeInterval duration;
//
//@end
//
//@implementation GKPlayer
//
//+ (instancetype)sharedInstance {
//    static GKPlayer *player = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        player = [GKPlayer new];
//    });
//    return player;
//}
//
//- (instancetype)init {
//    if (self = [super init]) {
//        // 禁止打印
//        [TXLiveBase setLogLevel:LOGLEVEL_NULL];
//        [TXLiveBase setConsoleEnabled:NO];
//
//        self.status = GKPlayerStatusStopped;
//
//        // 开启后台播放
//        [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    }
//    return self;
//}
//
//#pragma mark - Public Methods
//- (void)setPlayUrlStr:(NSString *)playUrlStr {
//    _playUrlStr = playUrlStr;
//}
//
//- (void)setPlayerProgress:(float)progress {
//    [self.txLivePlayer seek:(self.duration * progress)];
//}
//
//- (void)play {
//    if (self.status == GKPlayerStatusBuffering) {
//        return;
//    }
//
//    if (self.status != GKPlayerStatusStopped) {
//        [self stop];
//    }
//
//    if ([self.txLivePlayer startPlay:self.playUrlStr type:PLAY_TYPE_VOD_HLS] != 0) {
//        [self setPlayerStatus:GKPlayerStatusError];
//    }
//
//    [self setPlayerStatus:GKPlayerStatusBuffering];
//}
//
//- (void)pause {
//    [self.txLivePlayer pause];
//    [self setPlayerStatus:GKPlayerStatusPaused];
//}
//
//- (void)resume {
//    if (self.status == GKPlayerStatusPaused) {
//        [self setPlayerStatus:GKPlayerStatusPlaying];
//
//        [self.txLivePlayer resume];
//    }
//}
//
//- (void)stop {
//    if (self.status != GKPlayerStatusStopped) {
//        [self.txLivePlayer stopPlay];
//
//        [self setPlayerStatus:GKPlayerStatusStopped];
//    }
//}
//
//#pragma mark - Private Methods
//- (void)setPlayerStatus:(GKPlayerStatus)status {
//    self.status = status;
//
//    if ([self.delegate respondsToSelector:@selector(gkPlayer:statusChanged:)]) {
//        [self.delegate gkPlayer:self statusChanged:self.status];
//    }
//}
//
//#pragma mark - TXLivePlayListener
//- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {
//    switch (EvtID) {
//        case PLAY_EVT_PLAY_LOADING: // 加载中
//            [self setPlayerStatus:GKPlayerStatusBuffering];
//            break;
//        case PLAY_EVT_PLAY_BEGIN: // 播放中
//            [self setPlayerStatus:GKPlayerStatusPlaying];
//            break;
//        case PLAY_EVT_PLAY_END: // 播放结束
//            [self setPlayerStatus:GKPlayerStatusEnded];
//            break;
//        case PLAY_EVT_PLAY_PROGRESS: { // 进度
//            self.duration     = [param[EVT_PLAY_DURATION] floatValue];
//
//            float currentTime = [param[EVT_PLAY_PROGRESS] floatValue] * 1000;   // 当前时间
//            float totalTime   = self.duration * 1000;                           // 总时间
//
//            if ([self.delegate respondsToSelector:@selector(gkPlayer:totalTime:)]) {
//                [self.delegate gkPlayer:self totalTime:totalTime];
//            }
//
//            float progress    = totalTime == 0 ? 0 : (currentTime / totalTime);
//            if ([self.delegate respondsToSelector:@selector(gkPlayer:currentTime:totalTime:progress:)]) {
//                [self.delegate gkPlayer:self currentTime:currentTime totalTime:totalTime progress:progress];
//            }
//        }
//            break;
//
//        default:
//            break;
//    }
//}
//
//- (void)onNetStatus:(NSDictionary *)param {
//
//}
//
//#pragma mark - 懒加载
//- (TXLivePlayer *)txLivePlayer {
//    if (!_txLivePlayer) {
//        _txLivePlayer               = [[TXLivePlayer alloc] init];
//        _txLivePlayer.delegate      = self;
//
//        TXLivePlayConfig *config    = [[TXLivePlayConfig alloc] init];
//        config.enableAEC            = YES;
//        config.cacheTime            = 0.1f;
//        _txLivePlayer.config        = config;
//    }
//    return _txLivePlayer;
//}
//
//@end
