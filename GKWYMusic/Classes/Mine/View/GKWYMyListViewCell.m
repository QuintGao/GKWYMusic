//
//  GKWYMyListViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMyListViewCell.h"

@interface GKWYMyListViewCell()

@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *descLabel;
@property (nonatomic, strong) UIImageView   *tagImgView; // 是否下载标识
@property (nonatomic, strong) UILabel       *sizeLabel;
@property (nonatomic, strong) UIView        *lineView;

@end

@implementation GKWYMyListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.tagImgView];
        [self.contentView addSubview:self.sizeLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.top.equalTo(self.contentView).offset(10);
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
        
        [self.tagImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.centerY.equalTo(self.descLabel.mas_centerY);
        }];
        
        [self.sizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tagImgView.mas_right).offset(5);
            make.centerY.equalTo(self.descLabel.mas_centerY);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setModel:(GKWYMusicModel *)model {
    _model = model;
    
    self.nameLabel.text = model.song_name;
    self.descLabel.text = [NSString stringWithFormat:@"%@ - %@", model.artist_name, model.album_title];
    
    if (model.isDownload) {
        self.tagImgView.hidden = NO;
        self.sizeLabel.hidden  = NO;
        
        self.sizeLabel.text = model.song_size;
        
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sizeLabel.mas_right).offset(5.0f);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
        
        
    }else {
        self.tagImgView.hidden = YES;
        self.sizeLabel.hidden  = YES;
        
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
    }
}

#pragma mark - 懒加载
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _nameLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [UILabel new];
        _descLabel.textColor = [UIColor grayColor];
        _descLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _descLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = kAppLineColor;
    }
    return _lineView;
}

- (UIImageView *)tagImgView {
    if (!_tagImgView) {
        _tagImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm2_list_icn_dld_ok"]];
    }
    return _tagImgView;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [UILabel new];
        _sizeLabel.textColor = [UIColor grayColor];
        _sizeLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _sizeLabel;
}

@end
