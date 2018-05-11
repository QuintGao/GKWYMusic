//
//  GKAudioPlayer.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/24.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKAudioPlayer.h"
#import "GKTimer.h"

@interface GKAudioPlayer()

@property (nonatomic, strong) FSAudioStream *audioStream;

@property (nonatomic, strong) NSTimer       *playTimer;
@property (nonatomic, strong) NSTimer       *bufferTimer;

@end

@implementation GKAudioPlayer

+ (instancetype)sharedInstance {
    static GKAudioPlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [GKAudioPlayer new];
    });
    return player;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setPlayUrlStr:(NSString *)playUrlStr {
    if (![_playUrlStr isEqualToString:playUrlStr]) {
        
        // 切换数据，清除缓存
        [self removeCache];
        
        _playUrlStr = playUrlStr;
        
        if ([playUrlStr hasPrefix:@"http"] || [playUrlStr hasPrefix:@"https"]) {
            self.audioStream.url = [NSURL URLWithString:playUrlStr];
        }else {
            self.audioStream.url = [NSURL fileURLWithPath:playUrlStr];
        }
    }
}

- (void)setPlayerProgress:(float)progress {
    FSStreamPosition position = {0};
    position.position = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioStream seekToPosition:position];
    });
}

- (void)play {
    if (self.state == GKAudioPlayerStatePlaying) return;
    
    NSAssert(self.playUrlStr, @"url不能为空");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioStream play];
    });
    
    [self startTimer];
    
    [self startBufferTimer];
}

- (void)pause {
    if (self.state == GKAudioPlayerStatePaused) return;
    
    self.state = GKAudioPlayerStatePaused;
    [self setupPlayerState:self.state];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioStream pause];
    });
    
    [self stopTimer];
}

- (void)resume {
    if (self.state == GKAudioPlayerStatePlaying) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioStream pause];
    });
    
    [self startTimer];
}

- (void)stop {
    if (self.state == GKAudioPlayerStateStopped) return;
    
    self.state = GKAudioPlayerStateStopped;
    [self setupPlayerState:self.state];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioStream stop];
    });
    
    [self stopTimer];
}

- (void)startTimer {
    self.playTimer = [GKTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    [self.playTimer invalidate];
    self.playTimer = nil;
}

- (void)startBufferTimer {
    self.bufferTimer = [GKTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(bufferTimerAction:) userInfo:nil repeats:YES];
}

- (void)stopBufferTimer {
    [self.bufferTimer invalidate];
    self.bufferTimer = nil;
}

- (void)timerAction:(id)sender {
    FSStreamPosition cur = self.audioStream.currentTimePlayed;
    
    NSTimeInterval currentTime = cur.playbackTimeInSeconds * 1000;
    
    NSTimeInterval totalTime = self.audioStream.duration.playbackTimeInSeconds * 1000;
    
    NSTimeInterval progress = cur.position;
    
    if ([self.delegate respondsToSelector:@selector(gkPlayer:currentTime:totalTime:progress:)]) {
        [self.delegate gkPlayer:self currentTime:currentTime totalTime:totalTime progress:progress];
    }
    
    if ([self.delegate respondsToSelector:@selector(gkPlayer:totalTime:)]) {
        [self.delegate gkPlayer:self totalTime:totalTime];
    }
}

- (void)bufferTimerAction:(id)sender {
    float preBuffer      = (float)self.audioStream.prebufferedByteCount;
    float contentLength  = (float)self.audioStream.contentLength;
    
    // 这里获取的进度不能准确地获取到1
    float bufferProgress = contentLength > 0 ? preBuffer / contentLength : 0;
    
//    NSLog(@"缓冲进度%.2f", bufferProgress);
    
    // 为了能使进度准确的到1，这里做了一些处理
    int buffer = (int)(bufferProgress + 0.5);
    
    if (bufferProgress > 0.9 && buffer >= 1) {
        [self stopBufferTimer];
    }
    
    if ([self.delegate respondsToSelector:@selector(gkPlayer:bufferProgress:)]) {
        [self.delegate gkPlayer:self bufferProgress:bufferProgress];
    }
}

- (void)removeCache {
    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.audioStream.configuration.cacheDirectory error:nil];
    
    for (NSString *filePath in arr) {
        if ([filePath hasPrefix:@"FSCache-"]) {
            NSString *path = [NSString stringWithFormat:@"%@/%@", self.audioStream.configuration.cacheDirectory, filePath];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}

- (void)setupPlayerState:(GKAudioPlayerState)state {
    if ([self.delegate respondsToSelector:@selector(gkPlayer:statusChanged:)]) {
        [self.delegate gkPlayer:self statusChanged:state];
    }
}

#pragma mark - 懒加载
- (FSAudioStream *)audioStream {
    if (!_audioStream) {
        _audioStream = [[FSAudioStream alloc] init];
        
        __weak typeof(self) weakSelf = self;
        
        _audioStream.onCompletion = ^{
            NSLog(@"完成");
        };
        
        _audioStream.onStateChange = ^(FSAudioStreamState state) {
            switch (state) {
                case kFsAudioStreamRetrievingURL:       // 检索url
                    NSLog(@"检索url");
                    weakSelf.state = GKAudioPlayerStateLoading;
                    break;
                case kFsAudioStreamBuffering:           // 缓冲
                    NSLog(@"缓冲中。。");
                    weakSelf.state = GKAudioPlayerStateBuffering;
                    break;
                case kFsAudioStreamSeeking:             // seek
                    NSLog(@"seek中。。");
                    weakSelf.state = GKAudioPlayerStateLoading;
                    break;
                case kFsAudioStreamPlaying:             // 播放
                    NSLog(@"播放中。。");
                    weakSelf.state = GKAudioPlayerStatePlaying;
                    break;
                case kFsAudioStreamPaused:              // 暂停
                    NSLog(@"播放暂停");
                    weakSelf.state = GKAudioPlayerStatePaused;
                    break;
                case kFsAudioStreamStopped:              // 停止
                    NSLog(@"播放停止");
                    weakSelf.state = GKAudioPlayerStateStopped;
                    break;
                case kFsAudioStreamRetryingFailed:              // 检索失败
                    NSLog(@"检索失败");
                    weakSelf.state = GKAudioPlayerStateError;
                    break;
                case kFsAudioStreamRetryingStarted:             // 检索开始
                    NSLog(@"检索开始");
                    weakSelf.state = GKAudioPlayerStateLoading;
                    break;
                case kFsAudioStreamFailed:                      // 播放失败
                    NSLog(@"播放失败");
                    weakSelf.state = GKAudioPlayerStateError;
                    break;
                case kFsAudioStreamPlaybackCompleted:           // 播放完成
                    NSLog(@"播放完成");
                    weakSelf.state = GKAudioPlayerStateEnded;
                    break;
                case kFsAudioStreamRetryingSucceeded:           // 检索成功
                    NSLog(@"检索成功");
                    weakSelf.state = GKAudioPlayerStateLoading;
                    break;
                case kFsAudioStreamUnknownState:                // 未知状态
                    NSLog(@"未知状态");
                    weakSelf.state = GKAudioPlayerStateError;
                    break;
                case kFSAudioStreamEndOfFile:                   // 缓冲结束
                    NSLog(@"缓冲结束");
                    {
                        // 定时器停止后需要再次调用获取进度方法，防止出现进度不准确的情况
                        [weakSelf bufferTimerAction:nil];
                        
                        [weakSelf stopBufferTimer];
                    }
                    break;
                    
                default:
                    break;
            }
            [weakSelf setupPlayerState:weakSelf.state];
        };
    }
    return _audioStream;
}

@end
