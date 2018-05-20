//
//  GKWYAlbumHeader.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/11.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYAlbumHeader.h"
#import "GKVerticalButton.h"

@interface GKWYAlbumHeader()

@property (nonatomic, strong) UIImageView           *albumImgCoverView; // 专辑背景图
@property (nonatomic, strong) UIView                *albumImgBgView;    // 专辑图片背景
@property (nonatomic, strong) UIImageView           *albumImgView;      // 专辑图片
@property (nonatomic, strong) UIImageView           *tipImgView;

@property (nonatomic, strong) UILabel               *artistLabel;       // 歌手
@property (nonatomic, strong) UILabel               *artistNameLabel;   // 歌手名称
@property (nonatomic, strong) UILabel               *publishLabel;      // 发行时间

@property (nonatomic, strong) GKVerticalButton      *cmtButton;         // 评论按钮
@property (nonatomic, strong) GKVerticalButton      *shareButton;       // 分享按钮
@property (nonatomic, strong) GKVerticalButton      *downloadButton;    // 下载按钮
@property (nonatomic, strong) GKVerticalButton      *collectButton;     // 收藏按钮

@end

@implementation GKWYAlbumHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.gk_height = kAdaptive(540.0f);
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.albumImgCoverView];
        [self addSubview:self.albumImgBgView];
        [self.albumImgBgView addSubview:self.albumImgView];
        [self.albumImgBgView addSubview:self.tipImgView];
        
        [self addSubview:self.albumNameLabel];
        [self addSubview:self.artistLabel];
        [self addSubview:self.artistNameLabel];
        [self addSubview:self.publishLabel];
        
        [self addSubview:self.cmtButton];
        [self addSubview:self.shareButton];
        [self addSubview:self.downloadButton];
        [self addSubview:self.collectButton];
        
        [self.albumImgCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(35.0f));
            make.top.equalTo(self).offset(kAdaptive(30.0f));
            make.height.mas_equalTo(kAdaptive(280.0f));
            make.width.mas_equalTo(kAdaptive(280.0f) * 222.0f / 200.0f);
        }];
        
        [self.albumImgBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.albumImgCoverView);
            make.width.height.mas_equalTo(kAdaptive(280.0f));
        }];
        
        [self.albumImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.albumImgBgView);
        }];
        
        [self.tipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.albumImgView.mas_right).offset(-kAdaptive(10.0f));
            make.bottom.equalTo(self.albumImgView.mas_bottom).offset(-kAdaptive(10.0f));
        }];
        
        [self.albumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.albumImgBgView.mas_right).offset(kAdaptive(60.0f));
            make.top.equalTo(self.albumImgBgView.mas_top).offset(kAdaptive(30.0f));
            make.right.equalTo(self).offset(-ADAPTATIONRATIO * 20.0f);
        }];
        
        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.albumNameLabel);
            make.top.equalTo(self.albumNameLabel.mas_bottom).offset(kAdaptive(70.0f));
        }];
        
        [self.artistNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.artistLabel.mas_right);
            make.centerY.equalTo(self.artistLabel);
        }];
        
        [self.publishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.albumNameLabel);
            make.top.equalTo(self.artistLabel.mas_bottom).offset(kAdaptive(20.0f));
        }];
        
        CGFloat width = KScreenW / 4;
        
        [self.cmtButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.albumImgView.mas_bottom).offset(kAdaptive(40.0f));
            make.left.equalTo(self);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(kAdaptive(70.0f));
        }];
        
        [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cmtButton);
            make.left.equalTo(self.cmtButton.mas_right);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(kAdaptive(70.0f));
        }];
        
        [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cmtButton);
            make.left.equalTo(self.shareButton.mas_right);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(kAdaptive(70.0f));
        }];
        
        [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cmtButton);
            make.left.equalTo(self.downloadButton.mas_right);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(kAdaptive(70.0f));
        }];
    }
    return self;
}

- (void)setModel:(GKWYAlbumModel *)model {
    _model = model;
    
    [self.albumImgView sd_setImageWithURL:[NSURL URLWithString:model.pic_radio] placeholderImage:[UIImage imageNamed:@"cm2_default_cover_80"]];
    
    self.albumNameLabel.text  = model.title;
    
    self.artistNameLabel.text = model.author;
    
    self.publishLabel.text    = [NSString stringWithFormat:@"发行时间：%@", model.publishtime];
}

#pragma mark - 懒加载
- (UIImageView *)albumImgCoverView {
    if (!_albumImgCoverView) {
        _albumImgCoverView = [UIImageView new];
        _albumImgCoverView.image = [UIImage imageNamed:@"cm2_list_detail_alb_cover"];
    }
    return _albumImgCoverView;
}

- (UIView *)albumImgBgView {
    if (!_albumImgBgView) {
        _albumImgBgView = [UIImageView new];
        _albumImgBgView.clipsToBounds = NO;
        _albumImgBgView.layer.shadowRadius = kAdaptive(12.0f);
        _albumImgBgView.layer.shadowColor  = GKColorHEX(0x00000, 0.8f).CGColor;
        _albumImgBgView.layer.shadowOpacity = 1.0f;
        _albumImgBgView.layer.shadowOffset = CGSizeMake(0, kAdaptive(6.0f));
    }
    return _albumImgBgView;
}

- (UIImageView *)albumImgView {
    if (!_albumImgView) {
        _albumImgView = [UIImageView new];
        _albumImgView.contentMode = UIViewContentModeScaleAspectFit;
        _albumImgView.layer.cornerRadius = 5.0f;
        _albumImgView.layer.masksToBounds = YES;
        _albumImgView.userInteractionEnabled = YES;
    }
    return _albumImgView;
}

- (UIImageView *)tipImgView {
    if (!_tipImgView) {
        _tipImgView = [UIImageView new];
        _tipImgView.image = [UIImage imageNamed:@"cm2_list_detail_icn_infor"];
    }
    return _tipImgView;
}

- (UILabel *)albumNameLabel {
    if (!_albumNameLabel) {
        _albumNameLabel = [UILabel new];
        _albumNameLabel.textColor = [UIColor whiteColor];
        _albumNameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    }
    return _albumNameLabel;
}

- (UILabel *)artistLabel {
    if (!_artistLabel) {
        _artistLabel = [UILabel new];
        _artistLabel.textColor = GKColorRGB(211, 215, 218);
        _artistLabel.font = [UIFont systemFontOfSize:14.0f];
        _artistLabel.text = @"歌手：";
    }
    return _artistLabel;
}

- (UILabel *)artistNameLabel {
    if (!_artistNameLabel) {
        _artistNameLabel = [UILabel new];
        _artistNameLabel.textColor = GKColorRGB(248, 249, 250);
        _artistNameLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _artistNameLabel;
}

- (UILabel *)publishLabel {
    if (!_publishLabel) {
        _publishLabel = [UILabel new];
        _publishLabel.textColor = GKColorRGB(211, 215, 218);
        _publishLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _publishLabel;
}

- (GKVerticalButton *)cmtButton {
    if (!_cmtButton) {
        _cmtButton = [GKVerticalButton new];
        [_cmtButton setImage:[UIImage imageNamed:@"cm2_list_detail_icn_cmt"] forState:UIControlStateNormal];
        [_cmtButton setImage:[UIImage imageNamed:@"cm2_list_detail_icn_cmt_prs"] forState:UIControlStateHighlighted];
        _cmtButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_cmtButton setTitle:@"评论" forState:UIControlStateNormal];
        [_cmtButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _cmtButton;
}

- (GKVerticalButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [GKVerticalButton new];
        [_shareButton setImage:[UIImage imageNamed:@"cm2_list_detail_icn_share"] forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"cm2_list_detail_icn_share_prs"] forState:UIControlStateHighlighted];
        _shareButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _shareButton;
}

- (GKVerticalButton *)downloadButton {
    if (!_downloadButton) {
        _downloadButton = [GKVerticalButton new];
        [_downloadButton setImage:[UIImage imageNamed:@"cm2_list_detail_icn_dld"] forState:UIControlStateNormal];
        [_downloadButton setImage:[UIImage imageNamed:@"cm2_list_detail_icn_dld_prs"] forState:UIControlStateHighlighted];
        _downloadButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _downloadButton;
}

- (GKVerticalButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [GKVerticalButton new];
        [_collectButton setImage:[UIImage imageNamed:@"cm2_list_detail_icn_fav_new"] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"cm2_list_detail_icn_fav_new_prs"] forState:UIControlStateHighlighted];
        _collectButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_collectButton setTitle:@"收藏" forState:UIControlStateNormal];
        [_collectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _collectButton;
}

@end
