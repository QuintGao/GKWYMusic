//
//  GKVideoPlayer.m
//  GKWYMusic
//
//  Created by gaokun on 2018/6/8.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "GKSliderView.h"

@interface GKVideoPlayer()<GKSliderViewDelegate>

@property (nonatomic, strong) AVPlayer      *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVURLAsset    *urlAsset;

@property (nonatomic, strong) UIImageView   *coverImgView;
@property (nonatomic, strong) UIView        *controlView;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIButton      *shareBtn;

@property (nonatomic, strong) UIButton      *playBtn;
@property (nonatomic, strong) UIButton      *fullScreenBtn;
@property (nonatomic, strong) UILabel       *timeLabel;

@property (nonatomic, strong) GKSliderView  *slider;

@property (nonatomic, assign) CGRect        originalFrame;          // 原始尺寸
@property (nonatomic, assign) CGRect        fullScreenFrame;        // 全屏尺寸

@property (nonatomic, copy) NSString        *playUrlStr;

// 重试次数
@property (nonatomic, assign) NSInteger     retryCount;

@property (nonatomic, assign) BOOL          isShow;

@end

@implementation GKVideoPlayer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.blackColor;
        
        [self addSubview:self.coverImgView];
        [self addSubview:self.controlView];
        [self.controlView addSubview:self.playBtn];
        [self.controlView addSubview:self.slider];
        [self.controlView addSubview:self.timeLabel];
        [self.controlView addSubview:self.fullScreenBtn];
        
        [self.controlView addSubview:self.activityView];
        
        self.originalFrame      = self.frame;
        
        self.coverImgView.frame = self.bounds;
        
        self.controlView.frame  = self.bounds;
        
        self.playBtn.center     = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
        
        self.activityView.center = self.playBtn.center;
        
        self.slider.frame   = CGRectMake(-2, self.frame.size.height - 15, self.frame.size.width + 4, 30);
        
        UITapGestureRecognizer *signalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signalTapAction:)];
        [self addGestureRecognizer:signalTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        [doubleTap requireGestureRecognizerToFail:signalTap];
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)dealloc {
    [self resetPlayer];
}

- (void)startDelay {
    [self stopDelay];
    
    // 设置3秒后隐藏控制层
    [self performSelector:@selector(delayAction) withObject:nil afterDelay:3.0f];
}

- (void)stopDelay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayAction) object:nil];
}

- (void)delayAction {
    self.controlView.hidden = YES;
    self.isShow = NO;
}

#pragma mark - Public Methods
- (void)prepareWithModel:(GKWYVideoFiles *)model {
    self.playUrlStr = model.file_link;
    
    self.status = GKVideoPlayerStatusUnload;
}

- (void)play {
    if (self.status == GKVideoPlayerStatusPlaying) return;
    
    // 主动调用点击播放按钮
    [self.playBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)pause {
    self.status = GKVideoPlayerStatusPaused;
    
    [self.player pause];
}

- (void)resume {
    if (self.status == GKVideoPlayerStatusPaused) {
        self.status = GKVideoPlayerStatusPlaying;
        
        [self.player play];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus itemStatus = [change[@"new"] intValue];
        switch (itemStatus) {
            case AVPlayerItemStatusReadyToPlay: {
                self.retryCount = 1;
                // 开始播放
                [self.player play];
                self.status = GKVideoPlayerStatusPlaying;
                
                [self stopLoading];
                
                self.playBtn.hidden = NO;
                
                // 延迟隐藏
                [self startDelay];
            }
                break;
            case AVPlayerItemStatusFailed:{
                [self stopLoading];
                if (self.retryCount == 3) { // 加载超过3次，不再加载
                    [self.activityView stopAnimating];
                    
                    self.status = GKVideoPlayerStatusError;
                }else {
                    self.retryCount ++;
                    // 重新加载
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self startLoading];
                        
                        [self loadCurrentAVPlayer];
                    });
                }
            }
                break;
            case AVPlayerItemStatusUnknown: {
                self.status = GKVideoPlayerStatusError;
            }
                break;
                
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) { // 监听缓冲进度
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        
        NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
        CMTime duration = playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        
        CGFloat bufferProgress = timeInterval / totalDuration;
        self.slider.bufferValue = bufferProgress;
    }
}

#pragma mark - Notification
- (void)playerItemPlayEnded:(NSNotification *)notify {
    self.status = GKVideoPlayerStatusEnded;
    
    [self setupPlayReplay];
}

#pragma mark - Private Methods
- (void)loadCurrentAVPlayer {
    [self resetPlayer];
    
    NSURL *videoURL = nil;
    if ([self.playUrlStr hasPrefix:@"http"]) {
        videoURL = [NSURL URLWithString:self.playUrlStr];
    }else {
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", self.playUrlStr]];
    }
    
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:videoURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self.coverImgView.layer addSublayer:self.playerLayer];
    self.playerLayer.frame = self.bounds;
    
    // 添加进度监听
    [self addPlayerrProgressObserver];
    
    // 添加状态监听
    [self addPlayerItemObserver:playerItem];
    
    // 添加通知
    [self addPlayerNotification];
    
}

- (void)resetPlayer {
    [self removePlayerNotification];
    [self removePlayerItemObserver:self.player.currentItem];
    
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.status = GKVideoPlayerStatusUnload;
}

- (void)setPlayerProgress:(float)progress {
    // 将进度转换成播放时间（不能直接将进度条快进到播放结束）
    if (progress == CMTimeGetSeconds(self.player.currentItem.duration)) {
        progress -= 0.5;
    }
    
    // 跳转到指定时间
    [self.player seekToTime:CMTimeMakeWithSeconds(progress, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (self.status == GKVideoPlayerStatusPlaying) {
            [self.player play];
        }else if (self.status == GKVideoPlayerStatusPaused) {
            [self.player pause];
        }
    }];
}

- (void)addPlayerNotification {
    // 播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlayEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)removePlayerNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)addPlayerItemObserver:(AVPlayerItem *)playerItem {
    // 监听加载状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓冲进度
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removePlayerItemObserver:(AVPlayerItem *)playerItem {
    // 移除加载状态监听
    [playerItem removeObserver:self forKeyPath:@"status"];
    // 移除缓冲进度监听
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

- (void)addPlayerrProgressObserver {
    __weak __typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 当前时间
        float currentTime = CMTimeGetSeconds(time);
        // 总时间
        float totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        // 进度
        float progress = totalTime == 0 ? 0 : (currentTime / totalTime);
        
        if (progress >= 0) {
            weakSelf.slider.value = progress;
        }
    }];
}

- (void)startLoading {
    if (!self.activityView.isAnimating) {
        [self.activityView startAnimating];
    }
}

- (void)stopLoading {
    if (self.activityView.isAnimating) {
        [self.activityView stopAnimating];
    }
}

- (void)setupPlayPaused {
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_mv_btn_play"] forState:UIControlStateNormal];
}

- (void)setupPlayPlaying {
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_mv_btn_pause"] forState:UIControlStateNormal];
}

- (void)setupPlayReplay {
    [self.playBtn setImage:[UIImage imageNamed:@"cm2_mv_btn_replay "] forState:UIControlStateNormal];
}

#pragma mark - Action
- (void)playBtnClick:(UIButton *)playBtn {
    if (self.status == GKVideoPlayerStatusUnload || self.status == GKVideoPlayerStatusError) {
        [self loadCurrentAVPlayer];
        
        self.activityView.hidden = NO;
        self.playBtn.hidden      = YES;
        
        [self startLoading];
    }else {
        if (self.status == GKVideoPlayerStatusPaused) {
            [self.player play];
            self.status = GKVideoPlayerStatusPlaying;
            [self setupPlayPlaying];
        }else if (self.status == GKVideoPlayerStatusPlaying) {
            [self.player pause];
            self.status = GKVideoPlayerStatusPaused;
            [self setupPlayPaused];
        }else if (self.status == GKVideoPlayerStatusEnded) {
            [self setPlayerProgress:0];
            self.status = GKVideoPlayerStatusPlaying;
            [self setupPlayPaused];
        }
    }
}

- (void)signalTapAction:(UITapGestureRecognizer *)tap {
    if (self.isShow) {
        self.controlView.hidden = YES;
        self.isShow = NO;
    }else {
        self.controlView.hidden = NO;
        self.isShow = YES;
        
        [self startDelay];
    }
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap {
    
}

#pragma mark - 懒加载
- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer new];
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        // 充满屏幕，保持宽高比
        [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _playerLayer;
}

- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
    }
    return _coverImgView;
}

- (UIView *)controlView {
    if (!_controlView) {
        _controlView = [UIView new];
        _controlView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cm2_mv_mask"]];
    }
    return _controlView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton new];
        [_playBtn setImage:[UIImage imageNamed:@"cm2_mv_btn_pause"] forState:UIControlStateNormal];
        [_playBtn sizeToFit];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.hidesWhenStopped  = YES;
        _activityView.hidden            = YES;
    }
    return _activityView;
}

- (GKSliderView *)slider {
    if (!_slider) {
        _slider = [GKSliderView new];
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_mv_playbar_btn_ver"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_mv_playbar_btn_ver"] forState:UIControlStateSelected];
        [_slider setThumbImage:[UIImage imageNamed:@"cm2_mv_playbar_btn_ver"] forState:UIControlStateHighlighted];
        _slider.maximumTrackImage = [UIImage imageNamed:@"cm2_mv_playbar_bg_ver"];
        _slider.minimumTrackImage = [UIImage imageNamed:@"cm2_mv_playbar_curr"];
        _slider.bufferTrackImage  = [UIImage imageNamed:@"cm2_mv_playbar_ready_ver"];
        _slider.sliderHeight      = 2;
        _slider.delegate          = self;
    }
    return _slider;
}

@end
