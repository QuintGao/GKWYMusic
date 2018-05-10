//
//  GKWYSongViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYSongViewCell.h"

@interface GKWYSongViewCell()

@property (nonatomic, strong) UIButton  *playBtn;
@property (nonatomic, strong) UILabel   *nameLabel;
@property (nonatomic, strong) UILabel   *artistLabel;

@property (nonatomic, strong) UIView    *lineView;

@end

@implementation GKWYSongViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.playBtn];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.artistLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(5.0f);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playBtn.mas_right).offset(5.0f);
            make.top.equalTo(self.contentView).offset(8);
        }];
        
        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.bottom.equalTo(self.contentView).offset(-8);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setModel:(GKWYSongModel *)model {
    _model = model;
    
    self.nameLabel.text = model.songname;
    self.artistLabel.text = model.artistname;
    
    if ([model.songid isEqualToString:[GKWYMusicTool lastMusicId]]) {
        self.playBtn.selected = YES;
    }else {
        self.playBtn.selected = NO;
    }
}

#pragma mark - 懒加载
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton new];
        [_playBtn setImage:[[UIImage imageNamed:@"cm2_fm_btn_play"] changeImageWithColor:kAPPDefaultColor] forState:UIControlStateNormal];
        [_playBtn setImage:[[UIImage imageNamed:@"cm2_fm_btn_pause"] changeImageWithColor:kAPPDefaultColor] forState:UIControlStateSelected];
    }
    return _playBtn;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:15.0f];
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
