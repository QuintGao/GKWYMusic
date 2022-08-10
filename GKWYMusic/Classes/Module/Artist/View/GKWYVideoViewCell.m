//
//  GKWYVideoViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/17.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYVideoViewCell.h"

@interface GKWYVideoViewCell()

@property (nonatomic, strong) UIImageView   *imgView;
@property (nonatomic, strong) UILabel       *durationLabel;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UILabel       *countLabel;
@property (nonatomic, strong) UIView        *lineView;

@end

@implementation GKWYVideoViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.durationLabel];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.countLabel];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(32.0f));
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(kAdaptive(300.0f));
            make.height.mas_equalTo(kAdaptive(168.0f));
        }];
        
        [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.imgView).offset(-kAdaptive(12.0f));
            make.right.equalTo(self.imgView).offset(-kAdaptive(12.0f));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(kAdaptive(20.0f));
            make.right.equalTo(self.contentView).offset(-kAdaptive(20.0f));
            make.top.equalTo(self.imgView.mas_top).offset(kAdaptive(6.0f));
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(kAdaptive(22.0f));
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.top.equalTo(self.timeLabel.mas_bottom).offset(kAdaptive(10.0f));
        }];
    }
    return self;
}

- (void)setModel:(GKWYVideoModel *)model {
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.imgurl16v9] placeholderImage:[UIImage imageNamed:@"cm2_default_activity_18090x60"]];
    self.durationLabel.text = model.durationStr;
    self.titleLabel.text = model.name;
    self.timeLabel.text = model.publishTime;
    self.countLabel.text = model.playCountStr;
}

#pragma mark - 懒加载
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.layer.cornerRadius = 5;
        _imgView.layer.masksToBounds = YES;
    }
    return _imgView;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:13.0f];
        _durationLabel.textColor = UIColor.whiteColor;
    }
    return _durationLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel              = [UILabel new];
        _timeLabel.font         = [UIFont systemFontOfSize:13.0f];
        _timeLabel.textColor    = [UIColor grayColor];
    }
    return _timeLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel              = [UILabel new];
        _countLabel.font         = [UIFont systemFontOfSize:13.0f];
        _countLabel.textColor    = [UIColor grayColor];
    }
    return _countLabel;
}

@end
