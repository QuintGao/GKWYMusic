//
//  GKWYPlayListViewCell.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/3.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYPlayListViewCell.h"
#import "GKWYCoverView.h"

@interface GKWYPlayListItemView()

@property (nonatomic, strong) GKWYCoverView *coverView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation GKWYPlayListItemView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.coverView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descLabel];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(30.0f));
            make.centerY.equalTo(self);
            make.width.mas_equalTo(kAdaptive(96.0f));
            make.height.mas_equalTo(kAdaptive(104.0f));
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverView.mas_right).offset(kAdaptive(20.0f));
            make.top.equalTo(self.coverView).offset(kAdaptive(18.0f));
            make.right.equalTo(self).offset(-kAdaptive(20.0f));
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.nameLabel);
            make.bottom.equalTo(self.coverView.mas_bottom).offset(-kAdaptive(16.0f));
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setModel:(GKWYPlayListModel *)model {
    _model = model;
    
    [self.coverView.imgView sd_setImageWithURL:[NSURL URLWithString:model.coverImgUrl]];
    self.nameLabel.attributedText = model.nameAttr;
    self.descLabel.text = model.content;
}

- (void)itemClick {
    [GKWYRoutes routeWithUrlString:self.model.route_url];
}

#pragma mark - 懒加载
- (GKWYCoverView *)coverView {
    if (!_coverView) {
        _coverView = [[GKWYCoverView alloc] init];
        _coverView.bgView.hidden = YES;
    }
    return _coverView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:13.0f];
        _descLabel.textColor = GKColorGray(190);
    }
    return _descLabel;
}

@end

@interface GKWYPlayListViewCell()

@property (nonatomic, strong) GKWYPlayListItemView *itemView;

@end

@implementation GKWYPlayListViewCell

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

- (void)setModel:(GKWYPlayListModel *)model {
    _model = model;
    
    self.itemView.model = model;
}

#pragma mark - 懒加载
- (GKWYPlayListItemView *)itemView {
    if (!_itemView) {
        _itemView = [[GKWYPlayListItemView alloc] init];
    }
    return _itemView;
}

@end
