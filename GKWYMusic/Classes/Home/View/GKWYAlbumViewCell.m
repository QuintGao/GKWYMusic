//
//  GKWYAlbumViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYAlbumViewCell.h"

@interface GKWYAlbumViewCell()

@property (nonatomic, strong) UIImageView   *imgView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *artistLabel;
@property (nonatomic, strong) UIView        *lineView;

@end

@implementation GKWYAlbumViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.artistLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(5);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(50.0f);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(5);
            make.top.equalTo(self.imgView.mas_top);
        }];
        
        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.bottom.equalTo(self.imgView.mas_bottom);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setModel:(GKWYAlbumModel *)model {
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.artistpic]];
    self.nameLabel.text = model.albumname;
    self.artistLabel.text = model.artistname;
}

#pragma mark - 懒加载
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
    }
    return _imgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font     = [UIFont systemFontOfSize:15.0f];
    }
    return _nameLabel;
}

- (UILabel *)artistLabel {
    if (!_artistLabel) {
        _artistLabel = [UILabel new];
        _artistLabel.textColor = [UIColor grayColor];
        _artistLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _artistLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = kAppLineColor;
    }
    return _lineView;
}

@end
