//
//  GKWYAlbumViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYAlbumViewCell.h"
#import "GKWYCoverView.h"

@interface GKWYAlbumItemView()

@property (nonatomic, strong) GKWYCoverView *coverView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *artistLabel;
@property (nonatomic, strong) UILabel       *timeLabel;

@end

@implementation GKWYAlbumItemView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.coverView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.artistLabel];
        [self addSubview:self.timeLabel];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(30.0f));
            make.centerY.equalTo(self);
            make.width.mas_equalTo(kAdaptive(94.0f));
            make.height.mas_equalTo(kAdaptive(102.0f));
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverView.mas_right).offset(kAdaptive(20.0f));
            make.right.equalTo(self).offset(-kAdaptive(20.0f));
            make.top.equalTo(self.coverView.mas_top).offset(kAdaptive(20.0f));
        }];
        
        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.bottom.equalTo(self.coverView.mas_bottom).offset(-kAdaptive(10.0f));
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.artistLabel.mas_right).offset(kAdaptive(6.0f));
            make.centerY.equalTo(self.artistLabel);
        }];
    }
    return self;
}

- (void)setModel:(GKWYAlbumModel *)model {
    _model = model;
    
    [self.coverView.imgView sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
    self.nameLabel.attributedText = model.nameAttr;
    self.artistLabel.attributedText = model.artistsAttr;
    self.timeLabel.text  = model.publishTimeStr;
    
    if (self.isArtist) {
        self.artistLabel.hidden = YES;
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.centerY.equalTo(self.artistLabel);
        }];
        
        self.timeLabel.text = [NSString stringWithFormat:@"%@  %@首", model.publishTimeStr, model.size];
    }
}

#pragma mark - 懒加载
- (GKWYCoverView *)coverView {
    if (!_coverView) {
        _coverView = [[GKWYCoverView alloc] init];
        _coverView.topView.image = [UIImage imageNamed:@"cm8_search_album_side28x4"];
        [_coverView setAlbumLayout:kAdaptive(8.0f)];
    }
    return _coverView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel           = [UILabel new];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font      = [UIFont systemFontOfSize:15.0f];
    }
    return _nameLabel;
}

- (UILabel *)artistLabel {
    if (!_artistLabel) {
        _artistLabel = [[UILabel alloc] init];
    }
    return _artistLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel            = [UILabel new];
        _timeLabel.textColor  = [UIColor grayColor];
        _timeLabel.font       = [UIFont systemFontOfSize:13.0f];
    }
    return _timeLabel;
}

@end

@interface GKWYAlbumViewCell()

@property (nonatomic, strong) GKWYAlbumItemView *itemView;

@end

@implementation GKWYAlbumViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.itemView];
        [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setModel:(GKWYAlbumModel *)model {
    _model = model;
    self.itemView.isArtist = self.isArtist;
    self.itemView.model = model;
}

#pragma mark - 懒加载
- (GKWYAlbumItemView *)itemView {
    if (!_itemView) {
        _itemView = [[GKWYAlbumItemView alloc] init];
    }
    return _itemView;
}

@end
