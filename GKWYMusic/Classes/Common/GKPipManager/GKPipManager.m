//
//  GKPipManager.m
//  GKPictureInPictureDemo
//
//  Created by gaokun on 2021/4/8.
//

#import "GKPipManager.h"
#import <AVKit/AVKit.h>

@interface GKPipManager()<AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPictureInPictureController *pipVC;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, copy) void(^success)(void);
@property (nonatomic, copy) void(^failure)(NSError *error);

@property (nonatomic, assign) BOOL isHandleRestore;

@property (nonatomic, assign) BOOL stoppedWhenPlayEnd;

@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation GKPipManager

+ (instancetype)sharedManager {
    static GKPipManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GKPipManager alloc] init];
    });
    return instance;
}

- (UIWindow *)keyWindow {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
}

- (void)startPipWithUrl:(NSURL *)url time:(float)time stoppedWhenPlayEnd:(BOOL)stoppedWhenPlayEnd success:(nonnull void (^)(void))success failure:(nonnull void (^)(NSError * _Nonnull))failure {
    self.success = success;
    self.failure = failure;
    self.stoppedWhenPlayEnd = stoppedWhenPlayEnd;
    
    if (AVPictureInPictureController.isPictureInPictureSupported) {
        // 创建不可见的播放视图
        UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        playView.center = self.keyWindow.center;
        playView.hidden = YES;
        [self.keyWindow addSubview:playView];
        
        // 创建播放器
        self.player = [AVPlayer playerWithURL:url];
        [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        // 创建播放layer
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//        self.playerLayer.frame = playView.bounds;
        self.playerLayer.frame = CGRectMake(0, 0, kScreenW, 80);
        [playView.layer addSublayer:self.playerLayer];
        
        // 播放
        [self.player seekToTime:CMTimeMake(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.player play];
        
        if (stoppedWhenPlayEnd) {
            // 监听播放结束
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        }
    }else {
        NSError *error = [NSError errorWithDomain:@"com.test.pip" code:-1 userInfo:@{@"message": @"该系统不支持画中画功能"}];
        
        !self.failure ? : self.failure(error);
    }
}

- (void)startPipWithUrl:(NSURL *)url customView:(nonnull UIView *)customView success:(nonnull void (^)(void))success failure:(nonnull void (^)(NSError * _Nonnull))failure {
    self.success = success;
    self.failure = failure;
    self.customView = customView;
    
    if (AVPictureInPictureController.isPictureInPictureSupported) {
        // 创建不可见的播放视图
        UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        playView.center = self.keyWindow.center;
        playView.hidden = YES;
        [self.keyWindow addSubview:playView];
        
        // 创建播放器
        self.player = [AVPlayer playerWithURL:url];
        [self.player setMuted:YES];
        self.player.volume = 0;
        [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        // 创建播放layer
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = playView.bounds;
        [playView.layer addSublayer:self.playerLayer];
        
        // 播放
        [self.player play];
        
        // 监听播放结束
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }else {
        NSError *error = [NSError errorWithDomain:@"com.test.pip" code:-1 userInfo:@{@"message": @"该系统不支持画中画功能"}];
        
        !self.failure ? : self.failure(error);
    }
}

- (void)seekToTime:(float)time {
    if (self.player) {
        [self.player seekToTime:CMTimeMake(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        if (!self.isPlaying) {
            [self.player play];
        }
    }
}

- (void)startPlay {
    [self.player play];
}

- (void)stopPlay {
    [self.player pause];
}

- (void)playEnded:(NSNotification *)notify {
    NSLog(@"播放结束");
    self.isPlaying = NO;
    if (self.stoppedWhenPlayEnd) {
        [self.player pause];
        self.player = nil;
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
        
        [self.pipVC stopPictureInPicture];
        self.pipVC.delegate = nil;
        self.pipVC = nil;
    }
}

- (void)startPip {
    @try {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
    } @catch (NSException *exception) {
        NSLog(@"AVAudioSession发生错误");
    }
    
    self.pipVC = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
    self.pipVC.delegate = self;
    
    // 隐藏播放按钮、快进快退按钮
    [self.pipVC setValue:@1 forKey:@"controlsStyle"];
    
    // 延迟一下，否则可能开启失败
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.pipVC.isPictureInPictureActive) {
            [self.pipVC startPictureInPicture];
        }
    });
}

- (void)stopPip {
    [self.player pause];
    [self.player removeObserver:self forKeyPath:@"status"];
    self.player = nil;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    [self.pipVC stopPictureInPicture];
    self.pipVC.delegate = nil;
    self.pipVC = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    if (self.customView) {
        [self.customView removeFromSuperview];
        self.customView = nil;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusReadyToPlay: {
                self.isPlaying = YES;
                [self startPip];
            }
                break;
            case AVPlayerStatusFailed: {
                !self.failure ? : self.failure(self.player.error);
            }
                break;
            case AVPlayerStatusUnknown: {
                !self.failure ? : self.failure(self.player.error);
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"即将开启");
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"成功开启");
    if (self.customView) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        
        [window addSubview:self.customView];
        self.customView.frame = window.bounds;
    }
    !self.success ? : self.success();
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"即将关闭");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"成功关闭");
    [self stopPip];
    if (self.isHandleRestore) {
        self.isHandleRestore = NO;
    }
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"开启失败--%@", error);
    !self.failure ?: self.failure(error);
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"跳转");
    self.isHandleRestore = YES;
}

@end
