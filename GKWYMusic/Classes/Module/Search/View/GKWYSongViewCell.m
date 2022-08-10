//
//  GKWYSongViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYSongViewCell.h"

@interface GKWYSongItemView()

@property (nonatomic, strong) UIButton  *playBtn;
@property (nonatomic, strong) UILabel   *nameLabel;
@property (nonatomic, strong) UILabel   *artistLabel;
@property (nonatomic, strong) UIButton  *moreBtn;

@property (nonatomic, strong) UIView    *lineView;

@end

@implementation GKWYSongItemView

- (instancetype)init {
    if (self = [super init]) {
        
//        [self.contentView addSubview:self.playBtn];
        [self addSubview:self.nameLabel];
        [self addSubview:self.artistLabel];
        [self addSubview:self.lineView];
        [self addSubview:self.moreBtn];
        
//        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView).offset(5.0f);
//            make.centerY.equalTo(self.contentView);
//        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(30.0f));
            make.top.equalTo(self).offset(kAdaptive(24.0f));
        }];
        
        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.bottom.equalTo(self).offset(-kAdaptive(16.0f));
        }];
        
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-kAdaptive(30.0f));
            make.centerY.equalTo(self);
            make.width.height.mas_equalTo(kAdaptive(44.0f));
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(30.0f));
            make.right.equalTo(self).offset(-kAdaptive(30.0f));
            make.bottom.equalTo(self);
            make.height.mas_equalTo(LINE_HEIGHT);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setModel:(GKWYMusicModel *)model {
    _model = model;
    
    self.nameLabel.text = model.song_name;
    self.artistLabel.attributedText = model.artistAttr;
}

- (void)itemClick {
    !self.itemClickBlock ?: self.itemClickBlock(self.model);
}

- (void)moreBtnClick:(id)sender {
//    !self.moreClickBlock ?: self.moreClickBlock(self.model);
    [self showActionSheetWithModel:self.model];
}

- (void)showActionSheetWithModel:(GKWYMusicModel *)model {
    NSMutableArray *items = [NSMutableArray new];
    
    __typeof(self) __weak weakSelf = self;
    
    GKActionSheetItem *nextItem = [GKActionSheetItem new];
    nextItem.imgName = @"cm2_lay_icn_next_new";
    nextItem.title   = @"下一首播放";
    nextItem.enabled = YES;
    nextItem.clickBlock = ^{
        [GKMessageTool showText:@"下一首播放"];
    };
    [items addObject:nextItem];
    
    GKActionSheetItem *shareItem = [GKActionSheetItem new];
    shareItem.imgName = @"cm2_lay_icn_share_new";
    shareItem.title   = @"分享";
    shareItem.enabled = YES;
    shareItem.clickBlock = ^{
        [GKMessageTool showText:@"分享"];
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
        
    };
    [items addObject:downloadItem];
    
    GKActionSheetItem *commentItem = [GKActionSheetItem new];
    commentItem.imgName = @"cm2_lay_icn_cmt_new";
    commentItem.title   = @"评论";
    commentItem.enabled = YES;
    commentItem.clickBlock = ^{
        [GKMessageTool showText:@"评论"];
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
        
    };
    [items addObject:loveItem];
    
    GKActionSheetItem *artistItem = [GKActionSheetItem new];
    artistItem.title = [NSString stringWithFormat:@"歌手：%@", model.artists_name];
    artistItem.imgName = @"cm2_lay_icn_artist_new";
    artistItem.enabled = YES;
    artistItem.clickBlock = ^{
        [weakSelf showArtists];
    };
    [items addObject:artistItem];
    
    GKActionSheetItem *albumItem = [GKActionSheetItem new];
    albumItem.title = [NSString stringWithFormat:@"专辑：%@", model.al.name];
    albumItem.imgName = @"cm2_lay_icn_alb_new";
    albumItem.enabled = YES;
    albumItem.clickBlock = ^{
        [GKWYRoutes routeWithUrlString:model.al.route_url];
    };
    [items addObject:albumItem];
    
    if (model.has_mv) {
        GKActionSheetItem *mvItem = [GKActionSheetItem new];
        mvItem.title = @"查看MV";
        mvItem.imgName = @"cm2_lay_icn_mv_new";
        mvItem.enabled = YES;
        mvItem.clickBlock = ^{
            [GKMessageTool showText:@"查看MV"];
        };
        [items addObject:mvItem];
    }
    
    NSString *title = [NSString stringWithFormat:@"歌曲:%@", model.song_name];
    
    [GKActionSheet showActionSheetWithTitle:title itemInfos:items];
}

- (void)showArtists {
    if (self.model.ar.count > 1) {
        NSMutableArray *items = [NSMutableArray array];
        
        [self.model.ar enumerateObjectsUsingBlock:^(GKWYArtistModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKActionSheetItem *item = [GKActionSheetItem new];
            item.title = obj.name;
            item.enabled = YES;
            item.clickBlock = ^{
                [GKWYRoutes routeWithUrlString:obj.route_url];
            };
            [items addObject:item];
        }];
        
        [GKActionSheet showActionSheetWithTitle:@"该歌曲有多个歌手" itemInfos:items];
    }else {
        [GKWYRoutes routeWithUrlString:self.model.ar.firstObject.route_url];
    }
}

#pragma mark - 懒加载
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton new];
        [_playBtn setImage:[[UIImage imageNamed:@"cm2_fm_btn_play"] changeImageWithColor:kAPPDefaultColor] forState:UIControlStateNormal];
        [_playBtn setImage:[[UIImage imageNamed:@"cm2_fm_btn_pause"] changeImageWithColor:kAPPDefaultColor] forState:UIControlStateSelected];
        _playBtn.hidden = YES;
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
        _artistLabel.textColor = KAPPSearchColor;
        _artistLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _artistLabel;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton new];
        [_moreBtn setImage:[UIImage imageNamed:@"cm6_list_icn_more22x22"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"cm6_list_icn_more22x22"] forState:UIControlStateHighlighted];
        [_moreBtn setImage:[UIImage imageNamed:@"cm6_list_icn_more22x22"] forState:UIControlStateDisabled];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = kAppLineColor;
    }
    return _lineView;
}

@end

@interface GKWYSongViewCell()

@property (nonatomic, strong) GKWYSongItemView *itemView;

@end

@implementation GKWYSongViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.itemView];
        [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setModel:(GKWYMusicModel *)model {
    _model = model;
    
    self.itemView.model = model;
}

#pragma mark - 懒加载
- (GKWYSongItemView *)itemView {
    if (!_itemView) {
        _itemView = [[GKWYSongItemView alloc] init];
    }
    return _itemView;
}

@end
