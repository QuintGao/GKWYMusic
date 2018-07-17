//
//  GKWYSearchHeaderView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/24.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYSearchHeaderView.h"

// 标签间距
#define kTagMargin      kAdaptive(20.0f)
// 标签内边距
#define kTagPadding     kAdaptive(24.0f)

@interface GKWYSearchHeaderView()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GKWYSearchHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(20.0f));
            make.top.equalTo(self).offset(kAdaptive(36.0f));
        }];
    }
    return self;
}

- (void)setTags:(NSArray *)tags {
    _tags = tags;
    
    __block CGFloat x = kTagMargin;
    __block CGFloat y = kAdaptive(80.0f);
    __block CGFloat w = 0;
    CGFloat h = kAdaptive(64.0f);
    
    [tags enumerateObjectsUsingBlock:^(GKWYTagModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *tag = [obj.word componentsSeparatedByString:@"-"].firstObject;
        
        UIButton *btn = [UIButton new];
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [btn setTitle:tag forState:UIControlStateNormal];
        [btn setTitleColor:GKColorRGB(44, 45, 47) forState:UIControlStateNormal];
        btn.layer.cornerRadius = kAdaptive(32.0f);
        btn.layer.borderColor = GKColorRGB(210.0f, 211.0f, 213.0f).CGColor;
        btn.layer.borderWidth = 0.5f;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(tagBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = idx + 999;
        [self addSubview:btn];
        
        w = [tag sizeWithAttributes:@{NSFontAttributeName : btn.titleLabel.font}].width + 2 * kTagPadding;
        
        if (x + w > KScreenW) {
            y += (h + kTagMargin);
            x = kTagMargin;
        }
        
        btn.frame = CGRectMake(x, y, w, h);
        
        x += (w + kTagMargin);
    }];
    
    self.gk_size = CGSizeMake(KScreenW, y + h + kTagMargin + kAdaptive(20.0f));
}

- (void)tagBtnClick:(UIButton *)sender {
    NSInteger index = sender.tag - 999;
    
    GKWYTagModel *tagM = self.tags[index];
    
    !self.tagBtnClickBlock ? : self.tagBtnClickBlock(tagM);
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel             = [UILabel new];
        _titleLabel.text        = @"热门搜索";
        _titleLabel.font        = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor   = GKColorGray(110.0f);
    }
    return _titleLabel;
}

@end
