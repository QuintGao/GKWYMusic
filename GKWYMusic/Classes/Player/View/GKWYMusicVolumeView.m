//
//  GKWYMusicVolumeView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMusicVolumeView.h"
#import "GKVolumeView.h"

@interface GKWYMusicVolumeView()

@property (nonatomic, strong) UIImageView   *volumeImgView;

@property (nonatomic, strong) GKVolumeView  *volumeView;

@end

@implementation GKWYMusicVolumeView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.volumeImgView];
        [self addSubview:self.volumeView];
        
        [self.volumeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10.0f);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.volumeView.gk_x        = self.volumeImgView.gk_right + 10;
    self.volumeView.gk_width    = self.gk_width - self.volumeView.gk_x - 5;
    self.volumeView.gk_height   = 36.0f;
    self.volumeView.gk_centerY  = self.gk_height * 0.5f;
}

- (void)hideSystemVolumeView {
    self.volumeView.hidden = NO;
    
    [self.volumeView getValue];
}

- (void)showSystemVolumeView {
    self.volumeView.hidden = YES;
}

#pragma mark - 懒加载
- (UIImageView *)volumeImgView {
    if (!_volumeImgView) {
        _volumeImgView = [UIImageView new];
        _volumeImgView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker_silent"];
    }
    return _volumeImgView;
}

- (GKVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [GKVolumeView new];
        
        __weak typeof(self) weakSelf = self;
        _volumeView.valueChanged = ^(float value) {
            if (value <= 0) {
                weakSelf.volumeImgView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker_silent"];
            }else {
                weakSelf.volumeImgView.image = [UIImage imageNamed:@"cm2_fm_vol_speaker"];
            }
        };
    }
    return _volumeView;
}

@end
