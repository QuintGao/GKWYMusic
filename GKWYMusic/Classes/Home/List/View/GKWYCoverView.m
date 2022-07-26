//
//  GKWYCoverView.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYCoverView.h"

@interface GKWYCoverView()

@property (nonatomic, strong) UIView *topView;

@end

@implementation GKWYCoverView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.topView];
        [self addSubview:self.imgView];
        [self addSubview:self.bgView];
        [self.bgView addSubview:self.playImgView];
        [self.bgView addSubview:self.countLabel];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(kAdaptive(22.0));
            make.right.equalTo(self).offset(-kAdaptive(22.0));
            make.height.mas_equalTo(50);
        }];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self).offset(kAdaptive(6.0f));
        }];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.width.mas_equalTo(kAdaptive(100));
            make.height.mas_equalTo(kAdaptive(30));
        }];
        
        [self.playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView).offset(10);
            make.centerY.equalTo(self.bgView);
            make.width.height.mas_equalTo(kAdaptive(20));
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playImgView.mas_right).offset(2);
            make.centerY.equalTo(self.bgView);
        }];
    }
    return self;
}

- (void)updateCount:(NSString *)count {
    self.countLabel.text = count;
    
    CGFloat countW = [count sizeWithAttributes:@{NSFontAttributeName: self.countLabel.font}].width;
    CGFloat maxW = 10 + kAdaptive(20.0) + 2 + countW + 10;
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(maxW);
    }];
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = GKColorRGB(234, 237, 230);
        _topView.layer.cornerRadius = 10;
        _topView.layer.masksToBounds = YES;
    }
    return _topView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.layer.cornerRadius = 10;
        _imgView.layer.masksToBounds = YES;
        _imgView.backgroundColor = UIColor.whiteColor;
    }
    return _imgView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _bgView.layer.cornerRadius = kAdaptive(10.0);
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIImageView *)playImgView {
    if (!_playImgView) {
        _playImgView = [[UIImageView alloc] init];
        _playImgView.image = [UIImage imageNamed:@"fs_ic_play2"];
    }
    return _playImgView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:13.0];
        _countLabel.textColor = UIColor.whiteColor;
    }
    return _countLabel;
}

@end
