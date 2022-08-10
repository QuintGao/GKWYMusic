//
//  GKWYArrowView.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/4.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYArrowView.h"

@implementation GKWYArrowView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.contentLabel];
        [self addSubview:self.arrowImgView];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.right.equalTo(self.arrowImgView.mas_left);
        }];
        
        [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.centerY.equalTo(self);
            make.width.height.mas_equalTo(kAdaptive(24.0f));
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:13.0f];
        _contentLabel.textColor = GKColorGray(160);
    }
    return _contentLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = [UIImage imageNamed:@"cm8_mlog_playlist_author_arrow12x12"];
    }
    return _arrowImgView;
}

@end
