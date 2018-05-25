//
//  GKWYAlbumViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYAlbumViewCell.h"

@interface GKWYAlbumViewCell()

@property (nonatomic, strong) UIImageView   *coverImgView;
@property (nonatomic, strong) UIImageView   *imgView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UIView        *lineView;

@end

@implementation GKWYAlbumViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.coverImgView];
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(16.0f));
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(kAdaptive(108.0f));
            make.width.mas_equalTo(kAdaptive(108.0f) * 220.0f / 200.0f);
        }];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverImgView);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(kAdaptive(108.0f));
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(kAdaptive(30.0f));
            make.right.equalTo(self.contentView).offset(-kAdaptive(20.0f));
            make.top.equalTo(self.imgView.mas_top).offset(kAdaptive(15.0f));
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.nameLabel);
            make.bottom.equalTo(self.imgView.mas_bottom).offset(-kAdaptive(14.0f));
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setModel:(GKWYResultAlbumModel *)model {
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.pic_small]];
    
    self.nameLabel.text = model.title;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@", model.author, model.publishtime];
}

- (void)setAlbumModel:(GKWYAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:albumModel.pic_small]];
    
    self.nameLabel.text   = albumModel.title;
    self.timeLabel.text  = [NSString stringWithFormat:@"%@ %@首", albumModel.publishtime, albumModel.songs_total];
}

#pragma mark - 懒加载
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
        _coverImgView.image = [UIImage imageNamed:@"cm2_list_detail_alb_cover"];
    }
    return _coverImgView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.layer.cornerRadius = 4.0f;
        _imgView.layer.masksToBounds = YES;
    }
    return _imgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel           = [UILabel new];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font      = [UIFont systemFontOfSize:15.0f];
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel            = [UILabel new];
        _timeLabel.textColor  = [UIColor grayColor];
        _timeLabel.font       = [UIFont systemFontOfSize:13.0f];
    }
    return _timeLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = kAppLineColor;
    }
    return _lineView;
}

@end
