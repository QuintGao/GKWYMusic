//
//  GKWYDesktopView.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/27.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYDesktopView.h"
#import "GKWYDiskView.h"

@interface GKWYDesktopView()

@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic, strong) UIImageView *coverView;

@property (nonatomic, strong) GKWYDiskView *diskView;

@property (nonatomic, strong) UILabel *lyricLabel;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation GKWYDesktopView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.bgView];
        [self addSubview:self.coverView];
        [self addSubview:self.diskView];
        [self addSubview:self.lyricLabel];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.diskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(20.0));
            make.centerY.equalTo(self);
            make.width.height.mas_equalTo(kAdaptive(88.0));
        }];
        
        [self.lyricLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.diskView.mas_right).offset(kAdaptive(20.0f));
            make.right.equalTo(self).offset(-kAdaptive(20.0f));
            make.top.bottom.equalTo(self);
        }];
    }
    return self;
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
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(diskAnimation)];
    // 加入到主循环中
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)diskAnimation {
    self.diskView.diskImgView.transform = CGAffineTransformRotate(self.diskView.diskImgView.transform, M_PI_4 / 100.0f);
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

@end
