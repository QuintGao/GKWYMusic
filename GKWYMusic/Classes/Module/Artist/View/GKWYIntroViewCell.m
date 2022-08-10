//
//  GKWYIntroViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/18.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYIntroViewCell.h"

@interface GKWYIntroViewCell()

// 歌手简介
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation GKWYIntroViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self.contentView).offset(kAdaptive(32.0f));
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(32.0f));
            make.right.equalTo(self.contentView).offset(-kAdaptive(32.0f));
            make.top.equalTo(self.titleLabel.mas_bottom).offset(kAdaptive(20.0f));
        }];
    }
    return self;
}

- (void)setModel:(GKWYArtistDescModel *)model {
    _model = model;
    
    self.titleLabel.text = model.title;
    self.descLabel.text = model.desc;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = UIColor.blackColor;
    }
    return _titleLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:14.0f];
        _descLabel.textColor = GKColorGray(150);
        _descLabel.numberOfLines = 0;
    }
    return _descLabel;
}

@end
