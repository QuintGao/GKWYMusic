//
//  GKWYResultTitleView.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/2.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYResultTitleView.h"
#import "GKWYSongViewCell.h"
#import "GKWYPlayListViewCell.h"
#import "GKWYAlbumViewCell.h"

@interface GKWYResultTitleView()

@end

@implementation GKWYResultTitleView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = kAdaptive(20.0f);
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(30.0f));
            make.top.equalTo(self).offset(kAdaptive(40.0f));
        }];
    }
    return self;
}

- (CGFloat)heightWithModel:(id)model { return 0; }

- (void)moreAction {
    !self.showMoreBlock ?: self.showMoreBlock();
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        _titleLabel.textColor = UIColor.blackColor;
    }
    return _titleLabel;
}

@end

@implementation GKWYResultSongView

- (CGFloat)heightWithModel:(id)model {
    self.titleLabel.text = @"单曲";
    
    GKWYResultSongInfoModel *songModel = (GKWYResultSongInfoModel *)model;
    
    __block CGFloat height = kAdaptive(94.0f);
    __block UIView *lastView = nil;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = kAppLineColor;
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kAdaptive(30.0f));
        make.right.equalTo(self).offset(-kAdaptive(30.0f));
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kAdaptive(19.0f));
        make.height.mas_equalTo(LINE_HEIGHT);
    }];
    
    [songModel.songs enumerateObjectsUsingBlock:^(GKWYMusicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.keyword = songModel.keyword;
        
        GKWYSongItemView *itemView = [[GKWYSongItemView alloc] init];
        itemView.model = obj;
        [self addSubview:itemView];
        itemView.itemClickBlock = ^(id model) {
            [GKWYRoutes routeWithUrlString:@"gkwymusic://song" params:@{@"list": songModel.songs, @"index": @(idx)}];
        };
        
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom);
            }else {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(kAdaptive(20.0f));
            }
            make.left.right.equalTo(self);
            make.height.mas_equalTo(kAdaptive(114.0f));
        }];
        
        height += kAdaptive(114.0f);
        lastView = itemView;
    }];
    
    UILabel *moreLabel = [[UILabel alloc] init];
    moreLabel.attributedText = songModel.moreAttr;
    moreLabel.userInteractionEnabled = YES;
    [self addSubview:moreLabel];
    [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(lastView.mas_bottom).offset(kAdaptive(24.0f));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreAction)];
    [moreLabel addGestureRecognizer:tap];
    
    height += kAdaptive(80.0f);
    
    return height;
}

@end

@implementation GKWYResultPlayListView

- (CGFloat)heightWithModel:(id)model {
    self.titleLabel.text = @"歌单";
    
    GKWYResultPlayListInfoModel *infoModel = (GKWYResultPlayListInfoModel *)model;
    
    __block CGFloat height = kAdaptive(94.0f);
    __block UIView *lastView = nil;
    
    [infoModel.playLists enumerateObjectsUsingBlock:^(GKWYPlayListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.keyword = infoModel.keyword;
        
        GKWYPlayListItemView *itemView = [[GKWYPlayListItemView alloc] init];
        itemView.model = obj;
        [self addSubview:itemView];
        
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom);
            }else {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(kAdaptive(20.0f));
            }
            make.left.right.equalTo(self);
            make.height.mas_equalTo(kAdaptive(114.0f));
        }];
        
        height += kAdaptive(114.0f);
        lastView = itemView;
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = kAppLineColor;
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(lastView.mas_bottom).offset(kAdaptive(30.0f));
        make.height.mas_equalTo(LINE_HEIGHT);
    }];
    
    UILabel *moreLabel = [[UILabel alloc] init];
    moreLabel.attributedText = infoModel.moreAttr;
    moreLabel.userInteractionEnabled = YES;
    [self addSubview:moreLabel];
    [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(lineView.mas_bottom).offset(kAdaptive(24.0f));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreAction)];
    [moreLabel addGestureRecognizer:tap];
    
    height += kAdaptive(110.0f);
    
    return height;
}

@end

@implementation GKWYResultAlbumView

- (CGFloat)heightWithModel:(GKWYResultAlbumInfoModel *)model {
    self.titleLabel.text = @"专辑";
    
    __block CGFloat height = kAdaptive(94.0f);
    __block UIView *lastView = nil;
    
    [model.albums enumerateObjectsUsingBlock:^(GKWYAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.keyword = model.keyword;
        
        GKWYAlbumItemView *itemView = [[GKWYAlbumItemView alloc] init];
        itemView.model = obj;
        [self addSubview:itemView];
        
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom);
            }else {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(kAdaptive(20.0f));
            }
            make.left.right.equalTo(self);
            make.height.mas_equalTo(kAdaptive(120.0f));
        }];
        
        height += kAdaptive(120.0f);
        lastView = itemView;
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = kAppLineColor;
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(lastView.mas_bottom).offset(kAdaptive(30.0f));
        make.height.mas_equalTo(LINE_HEIGHT);
    }];
    
    UILabel *moreLabel = [[UILabel alloc] init];
    moreLabel.text = [NSString stringWithFormat:@"%@ >", model.moreText];
    moreLabel.userInteractionEnabled = YES;
    moreLabel.font = [UIFont systemFontOfSize:13.0f];
    moreLabel.textColor = GKColorGray(135);
    [self addSubview:moreLabel];
    [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(lineView.mas_bottom).offset(kAdaptive(24.0f));
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreAction)];
    [moreLabel addGestureRecognizer:tap];
    
    height += kAdaptive(110.0f);
    
    return height;
}

@end
