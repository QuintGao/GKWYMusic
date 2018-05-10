//
//  GKWYArtistViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistViewCell.h"

@interface GKWYArtistViewCell()

@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UILabel       *nameLabel;

@property (nonatomic, strong) UIView        *lineView;

@end

@implementation GKWYArtistViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(12.0f);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(50.0f);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(10.0f);
            make.centerY.equalTo(self.iconView);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setModel:(GKWYArtistModel *)model {
    _model = model;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.artistpic]];
    self.nameLabel.text = model.artistname;
}

#pragma mark - 懒加载
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.layer.cornerRadius = 25.0f;
        _iconView.layer.masksToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel              = [UILabel new];
        _nameLabel.textColor    = [UIColor blackColor];
        _nameLabel.font         = [UIFont systemFontOfSize:16.0f];
    }
    return _nameLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = kAppLineColor;
    }
    return _lineView;
}

@end
