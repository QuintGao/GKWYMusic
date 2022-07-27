//
//  GKWYDiskView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYDiskView.h"

@interface GKWYDiskView()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation GKWYDiskView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.diskImgView];
        [self.diskImgView addSubview:self.imgView];
        
        [self.diskImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(66.0f);
            make.width.height.mas_equalTo(KScreenW - 80.0f);
        }];
        
        CGFloat imgWH = KScreenW - 80.0f - 100.0f;
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.diskImgView);
            make.width.height.mas_equalTo(imgWH);
        }];
        
        self.imgView.layer.cornerRadius  = imgWH * 0.5;
        self.imgView.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)initDesktopView {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.diskImgView];
        [self.diskImgView addSubview:self.imgView];
        
        [self.diskImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.diskImgView);
            make.width.height.mas_equalTo(kAdaptive(60.0f));
        }];
        
        self.imgView.layer.cornerRadius  = kAdaptive(60.0f) * 0.5;
        self.imgView.layer.masksToBounds = YES;
    }
    return self;
}

#pragma mark - Setter
- (void)setImgUrl:(NSString *)imgUrl {
    _imgUrl = imgUrl;
    
    if (imgUrl) {
        if ([imgUrl hasPrefix:@"http"] || [imgUrl hasPrefix:@"https"]) { // 网络图片
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"cm2_default_cover_fm"]];
        }else { // 本地图片
            NSData *data = [NSData dataWithContentsOfFile:imgUrl];
            if (data) {
                self.imgView.image = [UIImage imageWithData:data];
            }else {
                self.imgView.image = [UIImage imageNamed:@"cm2_default_cover_fm"];
            }
        }
    }else {
        self.imgView.image = [UIImage imageNamed:@"cm2_default_cover_fm"];
    }
}

- (void)setModel:(GKWYMusicModel *)model {
    _model = model;
    
    NSString *imgUrl = model.album_pic;
    
    if (imgUrl) {
        if ([imgUrl hasPrefix:@"http"] || [imgUrl hasPrefix:@"https"]) { // 网络图片
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"cm2_default_cover_fm"]];
        }else { // 本地图片
            NSData *data = [NSData dataWithContentsOfFile:imgUrl];
            if (data) {
                self.imgView.image = [UIImage imageWithData:data];
            }else {
                self.imgView.image = [UIImage imageNamed:@"cm2_default_cover_fm"];
            }
        }
    }else {
        self.imgView.image = [UIImage imageNamed:@"cm2_default_cover_fm"];
    }
}

#pragma mark - 懒加载
- (UIImageView *)diskImgView {
    if (!_diskImgView) {
        _diskImgView = [UIImageView new];
        _diskImgView.image = [UIImage imageNamed:@"cm2_play_disc-ip6"];
        _diskImgView.contentMode = UIViewContentModeScaleAspectFit;
        _diskImgView.clipsToBounds = YES;
    }
    return _diskImgView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
    }
    return _imgView;
}

@end
