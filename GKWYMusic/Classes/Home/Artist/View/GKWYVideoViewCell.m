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
@property (nonatomic, strong) UIButton      *countBtn;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UIView        *lineView;

@end

@implementation GKWYVideoViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.countBtn];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(16.0f));
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(kAdaptive(195.0f));
            make.height.mas_equalTo(kAdaptive(110.0f));
        }];
        
        [self.countBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imgView).offset(kAdaptive(5.0f));
            make.right.equalTo(self.imgView).offset(-kAdaptive(5.0f));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(kAdaptive(20.0f));
            make.right.equalTo(self.contentView).offset(-kAdaptive(20.0f));
            make.top.equalTo(self.imgView.mas_top).offset(kAdaptive(16.0f));
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.titleLabel);
            make.bottom.equalTo(self.imgView.mas_bottom).offset(-kAdaptive(16.0f));
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setModel:(GKWYVideoModel *)model {
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail]];
    
    [self.countBtn setTitle:model.play_nums forState:UIControlStateNormal];
    
    self.titleLabel.text = model.title;
    
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [fmt dateFromString:model.publishtime];
    
    fmt.dateFormat = @"yyyy-MM-dd";
    
    self.timeLabel.text  = [fmt stringFromDate:date];
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

- (UIButton *)countBtn {
    if (!_countBtn) {
        _countBtn = [UIButton new];
        [_countBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _countBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _countBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _titleLabel.textColor = [UIColor blackColor];
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

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = kAppLineColor;
    }
    return _lineView;
}

@end
