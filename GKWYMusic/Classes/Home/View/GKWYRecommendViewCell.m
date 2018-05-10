//
//  GKWYRecommendViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/22.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYRecommendViewCell.h"

@interface GKWYRecommendViewCell()

/**
 序号
 */
@property (nonatomic, strong) UIButton      *numberBtn;

/**
 名称
 */
@property (nonatomic, strong) UILabel       *nameLabel;

/**
 下载图片
 */
@property (nonatomic, strong) UIImageView   *downloadImgView;

/**
 作者
 */
@property (nonatomic, strong) UILabel       *artistLabel;

/**
 分割线
 */
@property (nonatomic, strong) UIView        *lineView;

/**
 更多按钮
 */
@property (nonatomic, strong) UIButton      *moreBtn;

@end

@implementation GKWYRecommendViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.numberBtn];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.downloadImgView];
        [self.contentView addSubview:self.artistLabel];
        [self.contentView addSubview:self.moreBtn];
        [self.contentView addSubview:self.lineView];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(50);
            make.top.equalTo(self.contentView).offset(6);
            make.right.equalTo(self.contentView).offset(-60.0f);
        }];
        
        [self.downloadImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.bottom.equalTo(self.contentView).offset(-6);
            make.width.height.mas_equalTo(12.0f);
        }];
        
        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.right.equalTo(self.contentView).offset(-60.0f);
            make.centerY.equalTo(self.downloadImgView.mas_centerY);
        }];
        
        [self.numberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.centerX.equalTo(self.nameLabel.mas_left).offset(-25);
        }];
        
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0.5);
        }];
        
    }
    return self;
}

- (void)setModel:(GKWYMusicModel *)model {
    _model = model;
    
    self.nameLabel.text   = model.song_name;
    self.artistLabel.text = [NSString stringWithFormat:@"%@ - %@", model.artist_name, model.album_title];
    
    if (model.isDownload) {
        self.downloadImgView.hidden = NO;
        
        [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.downloadImgView.mas_right).offset(5.0f);
            make.centerY.equalTo(self.downloadImgView.mas_centerY);
            make.right.equalTo(self.contentView).offset(-60.0f);
        }];
    }else {
        self.downloadImgView.hidden = YES;
        
        [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.centerY.equalTo(self.downloadImgView.mas_centerY);
            make.right.equalTo(self.contentView).offset(-60.0f);
        }];
    }
    
    if (model.isPlaying) {
        [self.numberBtn setImage:[UIImage imageNamed:@"cm2_icn_volume"] forState:UIControlStateNormal];
        [self.numberBtn setTitle:nil forState:UIControlStateNormal];
        
        self.nameLabel.textColor   = GKColorRGB(200, 38, 39);
        self.artistLabel.textColor = GKColorRGB(200, 38, 39);
    }else {
        NSString *num = [NSString stringWithFormat:@"%02zd", self.row + 1];
        
        [self.numberBtn setTitle:num forState:UIControlStateNormal];
        [self.numberBtn setImage:nil forState:UIControlStateNormal];
        
        self.nameLabel.textColor   = [UIColor blackColor];
        self.artistLabel.textColor = [UIColor grayColor];
    }
}

- (void)moreBtnClick:(id)sender {
    !self.moreClicked ? : self.moreClicked(self.model);
}

#pragma mark - 懒加载
- (UIButton *)numberBtn {
    if (!_numberBtn) {
        _numberBtn = [UIButton new];
        [_numberBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _numberBtn.userInteractionEnabled = NO;
    }
    return _numberBtn;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel              = [UILabel new];
        _nameLabel.textColor    = [UIColor blackColor];
        _nameLabel.font         = [UIFont systemFontOfSize:16];
    }
    return _nameLabel;
}

- (UIImageView *)downloadImgView {
    if (!_downloadImgView) {
        _downloadImgView        = [UIImageView new];
        _downloadImgView.image  = [UIImage imageNamed:@"cm2_list_icn_dld_ok"];
        _downloadImgView.hidden = YES;
    }
    return _downloadImgView;
}

- (UILabel *)artistLabel {
    if (!_artistLabel) {
        _artistLabel            = [UILabel new];
        _artistLabel.textColor  = [UIColor grayColor];
        _artistLabel.font       = [UIFont systemFontOfSize:13];
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

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton new];
        [_moreBtn setImage:[UIImage imageNamed:@"cm4_list_icn_more"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"cm4_list_icn_more_prs"] forState:UIControlStateHighlighted];
        [_moreBtn setImage:[UIImage imageNamed:@"cm4_list_icn_more_dis"] forState:UIControlStateDisabled];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

@end
