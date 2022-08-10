//
//  GKWYPlayListCell.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/20.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYPlayListCell.h"
#import "GKWYCoverView.h"

@interface GKWYPlayListCell()

@property (nonatomic, strong) GKWYCoverView *coverView;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GKWYPlayListCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.coverView];
        [self.contentView addSubview:self.titleLabel];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-(kAdaptive(16.0) + self.titleLabel.font.lineHeight * 2));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.coverView.mas_bottom).offset(kAdaptive(10.0f));
        }];
    }
    return self;
}

- (void)setModel:(GKWYPlayListModel *)model {
    _model = model;
    
    [self.coverView.imgView sd_setImageWithURL:[NSURL URLWithString:model.coverImgUrl] placeholderImage:[UIImage imageNamed:@"cm2_default_cover_80"]];
    [self.coverView updateCount:model.formatPlayCount];
    
    self.titleLabel.text = model.name;
}

#pragma mark - 懒加载
- (GKWYCoverView *)coverView {
    if (!_coverView) {
        _coverView = [[GKWYCoverView alloc] init];
    }
    return _coverView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textColor = GKColorHEX(0x333333, 1.0f);
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

@end
