//
//  GKWYPlayListHeaderView.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/22.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYPlayListHeaderView.h"
#import "GKWYCoverView.h"
#import "UIButton+GKWYCategory.h"

@interface GKWYPlayListHeaderView()

@property (nonatomic, strong) GKWYCoverView *coverView;

@property (nonatomic, strong) UILabel *introLabel;

@property (nonatomic, strong) UIView *operationView;
@property (nonatomic, strong) UIButton *collectBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIView *collectLineView;
@property (nonatomic, strong) UIView *commentLineView;

@end

@implementation GKWYPlayListHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.coverView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.introLabel];
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
            make.height.mas_equalTo(kAdaptive(236.0f));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverView.mas_right).offset(kAdaptive(24.0f));
            make.right.equalTo(self).offset(-kAdaptive(128.0f));
            make.top.equalTo(self.coverView).offset(kAdaptive(12.0f));
        }];
        
        [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self).offset(-kAdaptive(110.0f));
            make.bottom.equalTo(self.coverView.mas_bottom).offset(-kAdaptive(6.0f));
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

- (void)setModel:(GKWYPlayListModel *)model {
    _model = model;
    
    [self.coverView.imgView sd_setImageWithURL:[NSURL URLWithString:model.coverImgUrl] placeholderImage:[UIImage imageNamed:@"cm2_default_cover_80"]];
    [self.coverView updateCount:model.formatPlayCount];
    
    self.titleLabel.text = model.name;
    self.introLabel.text = model.desc;
    
    [self.collectBtn setTitle:model.subscribedCount forState:UIControlStateNormal];
    [self.commentBtn setTitle:model.commentCount forState:UIControlStateNormal];
    [self.shareBtn setTitle:model.shareCount forState:UIControlStateNormal];
}

#pragma mark - 懒加载
- (GKWYCoverView *)coverView {
    if (!_coverView) {
        _coverView = [[GKWYCoverView alloc] init];
    }
    return _coverView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)introLabel {
    if (!_introLabel) {
        _introLabel = [[UILabel alloc] init];
        _introLabel.font = [UIFont systemFontOfSize:12];
        _introLabel.textColor = GKColorRGB(190, 180, 180);
    }
    return _introLabel;
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
