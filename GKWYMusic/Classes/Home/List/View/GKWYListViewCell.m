//
//  GKWYListViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/22.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYListViewCell.h"
#import "GKActionSheet.h"

@interface GKWYListViewCell()

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
 mv标志
 */
@property (nonatomic, strong) UIButton      *mvBtn;

/**
 更多按钮
 */
@property (nonatomic, strong) UIButton      *moreBtn;

@end

@implementation GKWYListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.numberBtn];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.downloadImgView];
        [self.contentView addSubview:self.artistLabel];
        [self.contentView addSubview:self.mvBtn];
        [self.contentView addSubview:self.moreBtn];
        [self.contentView addSubview:self.lineView];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(50);
            make.top.equalTo(self.contentView).offset(6);
        }];
        
        [self.downloadImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.bottom.equalTo(self.contentView).offset(-6);
            make.width.height.mas_equalTo(12.0f);
        }];
        
        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.centerY.equalTo(self.downloadImgView.mas_centerY);
        }];
        
        [self.numberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.centerX.equalTo(self.nameLabel.mas_left).offset(-25);
        }];
        
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kAdaptive(20.0f));
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.mvBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.moreBtn.mas_left).offset(-kAdaptive(20.0f));
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
    self.mvBtn.hidden     = !model.has_mv;
    
    if (model.has_mv) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(50);
            make.top.equalTo(self.contentView).offset(6);
            make.right.equalTo(self.contentView).offset(-kAdaptive(160.0f));
        }];
    }else {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(50);
            make.top.equalTo(self.contentView).offset(6);
            make.right.equalTo(self.contentView).offset(-kAdaptive(80.0f));
        }];
    }
    
    if (model.isDownload) {
        self.downloadImgView.hidden = NO;
        
        if (model.has_mv) {
            [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.downloadImgView.mas_right).offset(5.0f);
                make.centerY.equalTo(self.downloadImgView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-kAdaptive(160.0f));
            }];
        }else {
            [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.downloadImgView.mas_right).offset(5.0f);
                make.centerY.equalTo(self.downloadImgView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-kAdaptive(80.0f));
            }];
        }
    }else {
        self.downloadImgView.hidden = YES;
        if (model.has_mv) {
            [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.nameLabel.mas_left);
                make.centerY.equalTo(self.downloadImgView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-kAdaptive(160.0f));
            }];
        }else {
            [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.nameLabel.mas_left);
                make.centerY.equalTo(self.downloadImgView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-kAdaptive(80.0f));
            }];
        }
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

- (void)setSongModel:(GKWYMusicModel *)songModel {
    _songModel = songModel;
    
    self.numberBtn.hidden = YES;
    
    self.nameLabel.text   = songModel.song_name;
    self.artistLabel.text = [NSString stringWithFormat:@"%@ - %@", songModel.artist_name, songModel.album_title];
    self.mvBtn.hidden     = !songModel.has_mv;
    
    if (songModel.has_mv) {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(20.0f));
            make.top.equalTo(self.contentView).offset(6);
            make.right.equalTo(self.contentView).offset(-kAdaptive(160.0f));
        }];
    }else {
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(20.0f));
            make.top.equalTo(self.contentView).offset(6);
            make.right.equalTo(self.contentView).offset(-kAdaptive(80.0f));
        }];
    }
    
    if (songModel.isDownload) {
        self.downloadImgView.hidden = NO;
        
        if (songModel.has_mv) {
            [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.downloadImgView.mas_right).offset(5.0f);
                make.centerY.equalTo(self.downloadImgView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-kAdaptive(160.0f));
            }];
        }else {
            [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.downloadImgView.mas_right).offset(5.0f);
                make.centerY.equalTo(self.downloadImgView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-kAdaptive(80.0f));
            }];
        }
    }else {
        self.downloadImgView.hidden = YES;
        if (songModel.has_mv) {
            [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.nameLabel.mas_left);
                make.centerY.equalTo(self.downloadImgView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-kAdaptive(160.0f));
            }];
        }else {
            [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.nameLabel.mas_left);
                make.centerY.equalTo(self.downloadImgView.mas_centerY);
                make.right.equalTo(self.contentView).offset(-kAdaptive(80.0f));
            }];
        }
    }
}

- (void)moreBtnClick:(id)sender {
//    !self.moreClicked ? : self.moreClicked(self.model);
    
    [self showActionSheetWithModel:self.model ? self.model : self.songModel];
}

- (void)mvBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidClickMVBtn:model:)]) {
        [self.delegate cellDidClickMVBtn:self model:self.model];
    }
}

- (void)showActionSheetWithModel:(GKWYMusicModel *)model {
    NSMutableArray *items = [NSMutableArray new];
    
    __typeof(self) __weak weakSelf = self;
    
    GKActionSheetItem *nextItem = [GKActionSheetItem new];
    nextItem.imgName = @"cm2_lay_icn_next_new";
    nextItem.title   = @"下一首播放";
    nextItem.enabled = YES;
    nextItem.clickBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(cellDidClickNextItem:model:)]) {
            [weakSelf.delegate cellDidClickNextItem:weakSelf model:model];
        }
    };
    [items addObject:nextItem];
    
    GKActionSheetItem *shareItem = [GKActionSheetItem new];
    shareItem.imgName = @"cm2_lay_icn_share_new";
    shareItem.title   = @"分享";
    shareItem.enabled = YES;
    shareItem.clickBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(cellDidClickShareItem:model:)]) {
            [weakSelf.delegate cellDidClickShareItem:weakSelf model:model];
        }
    };
    [items addObject:shareItem];
    
    GKActionSheetItem *downloadItem = [GKActionSheetItem new];
    if (model.isDownload) {
        downloadItem.title      = @"删除下载";
        downloadItem.imgName    = @"cm2_lay_icn_dlded_new";
        downloadItem.tagImgName = @"cm2_lay_icn_dlded_check";
    }else {
        downloadItem.imgName    = @"cm2_lay_icn_dld_new";
        downloadItem.title      = @"下载";
    }
    downloadItem.enabled = YES;
    downloadItem.clickBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(cellDidClickDownloadItem:model:)]) {
            [weakSelf.delegate cellDidClickDownloadItem:weakSelf model:model];
        }
    };
    [items addObject:downloadItem];
    
    GKActionSheetItem *commentItem = [GKActionSheetItem new];
    commentItem.imgName = @"cm2_lay_icn_cmt_new";
    commentItem.title   = @"评论";
    commentItem.enabled = YES;
    commentItem.clickBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(cellDidClickCommentItem:model:)]) {
            [weakSelf.delegate cellDidClickCommentItem:weakSelf model:model];
        }
    };
    [items addObject:commentItem];
    
    GKActionSheetItem *loveItem = [GKActionSheetItem new];
    if (model.isLike) {
        loveItem.title = @"取消喜欢";
        loveItem.imgName = @"cm2_lay_icn_loved";
    }else {
        loveItem.title = @"喜欢";
        loveItem.image = [[UIImage imageNamed:@"cm2_lay_icn_love"] changeImageWithColor:kAPPDefaultColor];
    }
    loveItem.enabled = YES;
    loveItem.clickBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(cellDidClickLoveItem:model:)]) {
            [weakSelf.delegate cellDidClickLoveItem:weakSelf model:model];
        }
    };
    [items addObject:loveItem];
    
    GKActionSheetItem *artistItem = [GKActionSheetItem new];
    artistItem.title = [NSString stringWithFormat:@"歌手：%@", model.artist_name];
    artistItem.imgName = @"cm2_lay_icn_artist_new";
    artistItem.enabled = YES;
    artistItem.clickBlock = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(cellDidClickArtistItem:model:)]) {
            [weakSelf.delegate cellDidClickArtistItem:weakSelf model:model];
        }
    };
    [items addObject:artistItem];
    
    if (!self.isAlbum) {
        GKActionSheetItem *albumItem = [GKActionSheetItem new];
        albumItem.title = [NSString stringWithFormat:@"专辑：%@", model.album_title];
        albumItem.imgName = @"cm2_lay_icn_alb_new";
        albumItem.enabled = YES;
        albumItem.clickBlock = ^{
            if ([weakSelf.delegate respondsToSelector:@selector(cellDidClickAlbumItem:model:)]) {
                [weakSelf.delegate cellDidClickAlbumItem:weakSelf model:model];
            }
        };
        [items addObject:albumItem];
    }
    
    if (model.has_mv) {
        GKActionSheetItem *mvItem = [GKActionSheetItem new];
        mvItem.title = @"查看MV";
        mvItem.imgName = @"cm2_lay_icn_mv_new";
        mvItem.enabled = YES;
        mvItem.clickBlock = ^{
            if ([weakSelf.delegate respondsToSelector:@selector(cellDidClickMVItem:model:)]) {
                [weakSelf.delegate cellDidClickMVItem:weakSelf model:model];
            }
        };
        [items addObject:mvItem];
    }
    
    NSString *title = [NSString stringWithFormat:@"歌曲:%@", model.song_name];
    
    [GKActionSheet showActionSheetWithTitle:title itemInfos:items];
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

- (UIButton *)mvBtn {
    if (!_mvBtn) {
        _mvBtn = [UIButton new];
        [_mvBtn setImage:[UIImage imageNamed:@"cm4_list_tag_mv"] forState:UIControlStateNormal];
        [_mvBtn setImage:[UIImage imageNamed:@"cm4_list_tag_mv_prs"] forState:UIControlStateHighlighted];
        [_mvBtn setImage:[UIImage imageNamed:@"cm4_list_tag_mv_dis"] forState:UIControlStateDisabled];
        [_mvBtn addTarget:self action:@selector(mvBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mvBtn;
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
