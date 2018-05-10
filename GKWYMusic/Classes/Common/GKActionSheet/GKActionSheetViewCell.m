//
//  GKActionSheetViewCell.m
//  GKAudioPlayerDemo
//
//  Created by gaokun on 2018/4/13.
//  Copyright © 2018年 高坤. All rights reserved.
//

#import "GKActionSheetViewCell.h"
#import "GKActionSheet.h"

@interface GKActionSheetViewCell()

@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UIImageView   *tagIconView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIView        *lineView;

@end

@implementation GKActionSheetViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.tagIconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(12.0f);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.tagIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.iconView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(12.0f);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setItem:(GKActionSheetItem *)item {
    _item = item;
    
    if (item.image) {
        self.iconView.image = item.image;
    }else {
        self.iconView.image = [UIImage imageNamed:item.imgName];
    }
    
    if (item.tagImgName) {
        self.tagIconView.image = [UIImage imageNamed:item.tagImgName];
    }
    
    self.titleLabel.text = item.title;
}

#pragma mark - 懒加载
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
    }
    return _iconView;
}

- (UIImageView *)tagIconView {
    if (!_tagIconView) {
        _tagIconView = [UIImageView new];
    }
    return _tagIconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = GKColorRGB(191, 187, 185);
    }
    return _lineView;
}

@end
