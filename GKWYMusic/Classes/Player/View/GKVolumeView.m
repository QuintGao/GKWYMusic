//
//  GKVolumeView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//  自定义音量控件试图

#import "GKVolumeView.h"

@implementation GKVolumeView

- (instancetype)init {
    if (self = [super init]) {
        // 设置自定义音量控件图片
        // 滑杆
        [self setMaximumVolumeSliderImage:[UIImage imageNamed:@"cm2_fm_vol_bg"] forState:UIControlStateNormal];
        [self setMinimumVolumeSliderImage:[UIImage imageNamed:@"cm2_fm_vol_cur"] forState:UIControlStateNormal];
        [self setVolumeThumbImage:[UIImage imageNamed:@"cm2_fm_vol_btn"] forState:UIControlStateNormal];
        
        // 按钮（airplay）
        [self setRouteButtonImage:[UIImage imageNamed:@"cm2_play_icn_airplay"] forState:UIControlStateNormal];
        [self setRouteButtonImage:[UIImage imageNamed:@"cm2_play_icn_airplay_prs"] forState:UIControlStateHighlighted];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)getValue {
    !self.valueChanged ? : self.valueChanged(self.volumeValue);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置子控件居竖直居中
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint center = obj.center;
        
        center.y = self.frame.size.height * 0.5;
        
        obj.center = center;
    }];
}

- (void)systemVolumeChanged:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    
    float value = [[userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    
    !self.valueChanged ? : self.valueChanged(value);
}

- (float)volumeValue {
    UISlider *slider = nil;
    
    for (UIView *view in self.subviews) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            slider = (UISlider *)view;
            break;
        }
    }
    return slider.value;
}

@end
