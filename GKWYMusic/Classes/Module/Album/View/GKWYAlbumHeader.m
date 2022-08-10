//
//  GKWYAlbumHeader.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/11.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYAlbumHeader.h"
#import "GKVerticalButton.h"
#import "GKWYCoverView.h"
#import "UIButton+GKWYCategory.h"
#import "GKWYArrowView.h"

@interface GKWYAlbumHeader()

@property (nonatomic, strong) GKWYCoverView         *coverView;

@property (nonatomic, strong) GKWYArrowView *artistView;  // 歌手
@property (nonatomic, strong) UILabel *publishLabel;      // 发行时间
@property (nonatomic, strong) GKWYArrowView *descView;    // 专辑简介

@property (nonatomic, strong) UIView *operationView;
@property (nonatomic, strong) UIButton *collectBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIView *collectLineView;
@property (nonatomic, strong) UIView *commentLineView;

@end

@implementation GKWYAlbumHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.coverView];
        
        [self addSubview:self.albumNameLabel];
        [self addSubview:self.artistView];
        [self addSubview:self.publishLabel];
        [self addSubview:self.descView];
        [self addSubview:self.operationView];
        [self.operationView addSubview:self.collectBtn];
        [self.operationView addSubview:self.commentBtn];
        [self.operationView addSubview:self.shareBtn];
        [self.operationView addSubview:self.collectLineView];
        [self.operationView addSubview:self.commentLineView];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(30.0f));
            make.top.equalTo(self).offset(kAdaptive(30.0));
            make.width.mas_offset(kAdaptive(230));
            make.height.mas_equalTo(kAdaptive(260.0f));
        }];
        
        [self.albumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverView.mas_right).offset(kAdaptive(30.0f));
            make.right.equalTo(self).offset(-kAdaptive(50.0f));
            make.top.equalTo(self.coverView).offset(kAdaptive(40.0f));
        }];
        
        [self.artistView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.albumNameLabel);
            make.top.equalTo(self.albumNameLabel.mas_bottom).offset(kAdaptive(20.0f));
        }];
        
        [self.publishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.albumNameLabel);
            make.bottom.equalTo(self.descView.mas_top).offset(-kAdaptive(10.0f));
        }];
        
        [self.descView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.albumNameLabel);
            make.bottom.equalTo(self.coverView.mas_bottom);
            make.right.equalTo(self).offset(-kAdaptive(50.0f));
        }];
        
        [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-kAdaptive(28.0f));
            make.centerX.equalTo(self);
            make.width.mas_equalTo(kAdaptive(554.0f));
            make.height.mas_equalTo(kAdaptive(84.0f));
        }];
        
        CGFloat width = kAdaptive(554.0) / 3;
        [self.collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self.operationView);
            make.width.mas_equalTo(width);
        }];
        
        [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.width.equalTo(self.collectBtn);
            make.left.equalTo(self.collectBtn.mas_right);
        }];
        
        [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.width.equalTo(self.collectBtn);
            make.left.equalTo(self.commentBtn.mas_right);
        }];
        
        [self.collectLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.collectBtn.mas_right);
            make.centerY.equalTo(self.operationView);
            make.width.mas_equalTo(kAdaptive(2.0f));
            make.height.mas_equalTo(kAdaptive(40.0f));
        }];
        
        [self.commentLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.commentBtn.mas_right);
            make.centerY.equalTo(self.operationView);
            make.width.mas_equalTo(kAdaptive(2.0f));
            make.height.mas_equalTo(kAdaptive(40.0f));
        }];
    }
    return self;
}

- (void)setModel:(GKWYAlbumModel *)model {
    _model = model;
    
    [self.coverView.imgView sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
    
    self.albumNameLabel.text  = model.name;
    
    self.artistView.contentLabel.attributedText = model.artistAttr;
    
    self.publishLabel.text = [NSString stringWithFormat:@"发行时间：%@", model.publishTimeStr];
    
    self.descView.contentLabel.text = [model.desc stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    [self.collectBtn setTitle:model.collectCount forState:UIControlStateNormal];
    [self.commentBtn setTitle:model.commentCount forState:UIControlStateNormal];
    [self.shareBtn setTitle:model.shareCount forState:UIControlStateNormal];
}

#pragma mark - 懒加载
- (GKWYCoverView *)coverView {
    if (!_coverView) {
        _coverView = [[GKWYCoverView alloc] init];
        _coverView.topView.image = [UIImage imageNamed:@"cm8_my_music_relation_album60x10"];
        [_coverView setAlbumLayout:kAdaptive(16.0f)];
    }
    return _coverView;
}

- (UILabel *)albumNameLabel {
    if (!_albumNameLabel) {
        _albumNameLabel = [UILabel new];
        _albumNameLabel.textColor = [UIColor whiteColor];
        _albumNameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    }
    return _albumNameLabel;
}

- (GKWYArrowView *)artistView {
    if (!_artistView) {
        _artistView = [[GKWYArrowView alloc] init];
    }
    return _artistView;
}

- (UILabel *)publishLabel {
    if (!_publishLabel) {
        _publishLabel = [UILabel new];
        _publishLabel.textColor = GKColorRGB(211, 215, 218);
        _publishLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _publishLabel;
}

- (GKWYArrowView *)descView {
    if (!_descView) {
        _descView = [[GKWYArrowView alloc] init];
    }
    return _descView;
}

- (UIView *)operationView {
    if (!_operationView) {
        _operationView = [[UIView alloc] init];
        _operationView.backgroundColor = UIColor.whiteColor;
        _operationView.layer.cornerRadius = kAdaptive(42.0f);
        _operationView.layer.masksToBounds = YES;
        _operationView.layer.shadowColor = UIColor.blackColor.CGColor;
        _operationView.layer.shadowOffset = CGSizeMake(0, 1);
    }
    return _operationView;
}

- (UIButton *)collectBtn {
    if (!_collectBtn) {
        _collectBtn = [[UIButton alloc] init];
        [_collectBtn setImage:[UIImage imageNamed:@"cm8_mlog_playlist_collection_normal24x24"] forState:UIControlStateNormal];
        [_collectBtn setImage:[UIImage imageNamed:@"cm8_mlog_playlist_collection_selected24x24"] forState:UIControlStateSelected];
        [_collectBtn setTitleColor:GKColorHEX(0x333333, 1.0f) forState:UIControlStateNormal];
        _collectBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_collectBtn setLayout:ButtonLayout_ImageLeft spacing:kAdaptive(16.0f)];
    }
    return _collectBtn;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] init];
        [_commentBtn setImage:[UIImage imageNamed:@"cm8_mlog_playlist_comment24x24"] forState:UIControlStateNormal];
        [_commentBtn setTitleColor:GKColorHEX(0x333333, 1.0f) forState:UIControlStateNormal];
        _commentBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_commentBtn setLayout:ButtonLayout_ImageLeft spacing:kAdaptive(16.0f)];
    }
    return _commentBtn;
}

- (UIButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [[UIButton alloc] init];
        [_shareBtn setImage:[UIImage imageNamed:@"cm8_mlog_playlist_share24x24"] forState:UIControlStateNormal];
        [_shareBtn setTitleColor:GKColorHEX(0x333333, 1.0f) forState:UIControlStateNormal];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_shareBtn setLayout:ButtonLayout_ImageLeft spacing:kAdaptive(16.0f)];
    }
    return _shareBtn;
}

- (UIView *)collectLineView {
    if (!_collectLineView) {
        _collectLineView = [[UIView alloc] init];
        _collectLineView.backgroundColor = GKColorGray(218);
    }
    return _collectLineView;
}

- (UIView *)commentLineView {
    if (!_commentLineView) {
        _commentLineView = [[UIView alloc] init];
        _commentLineView.backgroundColor = GKColorGray(218);
    }
    return _commentLineView;
}

@end
