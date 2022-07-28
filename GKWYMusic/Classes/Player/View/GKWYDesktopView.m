//
//  GKWYDesktopView.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/27.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYDesktopView.h"
#import "GKWYDiskView.h"
#import "GKSliderView.h"

@interface GKWYDesktopView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic, strong) UIImageView *coverView;

@property (nonatomic, strong) GKWYDiskView *diskView;

@property (nonatomic, strong) UILabel *lyricLabel;

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *prevBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) GKSliderView *sliderView;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation GKWYDesktopView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.bgView];
        [self addSubview:self.diskView];
        [self addSubview:self.lyricLabel];
        [self addSubview:self.coverView];
        [self.coverView addSubview:self.playBtn];
        [self.coverView addSubview:self.prevBtn];
        [self.coverView addSubview:self.nextBtn];
        [self.coverView addSubview:self.sliderView];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.diskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(24.0));
            make.centerY.equalTo(self);
            make.width.height.mas_equalTo(kAdaptive(88.0));
        }];
        
        [self.lyricLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.diskView.mas_right).offset(kAdaptive(20.0f));
            make.right.equalTo(self).offset(-kAdaptive(20.0f));
            make.top.bottom.equalTo(self);
        }];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        [self.prevBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.playBtn.mas_left).offset(-15);
            make.centerY.equalTo(self.playBtn);
        }];
        
        [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playBtn.mas_right).offset(15);
            make.centerY.equalTo(self.playBtn);
        }];
        
        [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(20.0f));
            make.right.equalTo(self).offset(-kAdaptive(20.0f));
            make.bottom.equalTo(self).offset(-5);
            make.height.mas_equalTo(@3);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHide:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)showOrHide:(UITapGestureRecognizer *)tap {
    if (self.coverView.isHidden) {
        [UIView animateWithDuration:0.15 animations:^{
            self.coverView.hidden = NO;
        }];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCover) object:nil];
        [self performSelector:@selector(hideCover) withObject:nil afterDelay:3.0f];
    }else {
        [UIView animateWithDuration:0.15 animations:^{
            self.coverView.hidden = YES;
        }];
    }
}

- (void)hideCover {
    self.coverView.hidden = YES;
}

- (void)setDiskImageUrl:(NSString *)diskImageUrl {
    _diskImageUrl = diskImageUrl;
    
    [self.bgView sd_setImageWithURL:[NSURL URLWithString:diskImageUrl]];
    
    self.diskView.imgUrl = diskImageUrl;
}

- (void)setLyric:(NSString *)lyric {
    _lyric = lyric;
    
    self.lyricLabel.text = lyric;
}

- (void)startPlay {
    [self stopPlay];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(diskAnimation)];
    // 加入到主循环中
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.playBtn.selected = YES;
}

- (void)stopPlay {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.playBtn.selected = NO;
}

- (void)updateProgress:(CGFloat)progress {
    self.sliderView.value = progress;
}

- (void)diskAnimation {
    self.diskView.diskImgView.transform = CGAffineTransformRotate(self.diskView.diskImgView.transform, M_PI_4 / 100.0f);
}

- (void)playBtnClick {
    !self.playBtnClickBlock ?: self.playBtnClickBlock();
}

- (void)prevBtnClick {
    !self.prevBtnClickBlock ?: self.prevBtnClickBlock();
}

- (void)nextBtnClick {
    !self.nextBtnClickBlock ?: self.nextBtnClickBlock();
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:UIButton.class]) {
        return NO;
    }
    return YES;
}

#pragma mark - 懒加载
- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [_bgView addSubview:effectView];
        [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self->_bgView);
        }];
    }
    return _bgView;
}

- (UIImageView *)coverView {
    if (!_coverView) {
        _coverView = [[UIImageView alloc] init];
        _coverView.image = [UIImage imageNamed:@"nm_desktop_lyrics_cover355x71"];
        _coverView.hidden = YES;
        _coverView.userInteractionEnabled = YES;
    }
    return _coverView;
}

- (GKWYDiskView *)diskView {
    if (!_diskView) {
        _diskView = [[GKWYDiskView alloc] initDesktopView];
    }
    return _diskView;
}

- (UILabel *)lyricLabel {
    if (!_lyricLabel) {
        _lyricLabel = [[UILabel alloc] init];
        _lyricLabel.font = [UIFont systemFontOfSize:18];
        _lyricLabel.textColor = UIColor.whiteColor;
    }
    return _lyricLabel;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"nm_desktop_lyrics_play32x32"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"nm_desktop_lyrics_pause32x32"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)prevBtn {
    if (!_prevBtn) {
        _prevBtn = [[UIButton alloc] init];
        [_prevBtn setImage:[UIImage imageNamed:@"nm_desktop_lyrics_left34x21"] forState:UIControlStateNormal];
        [_prevBtn addTarget:self action:@selector(prevBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] init];
        [_nextBtn setImage:[UIImage imageNamed:@"nm_desktop_lyrics_right34x21"] forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[GKSliderView alloc] init];
        _sliderView.maximumTrackTintColor = UIColor.grayColor;
        _sliderView.minimumTrackTintColor = UIColor.whiteColor;
        _sliderView.sliderHeight = kAdaptive(2.0f);
        [_sliderView hideSliderBlock];
    }
    return _sliderView;
}

@end
