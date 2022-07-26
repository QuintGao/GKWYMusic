//
//  GKLoadingView.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/25.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKLoadingView.h"

@interface GKLoadingView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *loadLabel;

@end

@implementation GKLoadingView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.imageView];
        [self addSubview:self.loadLabel];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(40.0f);
            make.centerX.equalTo(self);
        }];
        
        [self.loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(10.0f);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

- (void)startAnimation {
    self.imageView.hidden = NO;
    self.loadLabel.hidden = NO;
    [self.imageView startAnimating];
}

- (void)stopAnimation {
    self.imageView.hidden = YES;
    self.loadLabel.hidden = YES;
    [self.imageView stopAnimating];
    [self removeFromSuperview];
}

#pragma mark - 懒加载
- (UIImageView *)imageView {
    if (!_imageView) {
        NSMutableArray *images = [NSMutableArray new];
        for (NSInteger i = 0; i < 4; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i + 1];
            [images addObject:[[UIImage imageNamed:imageName] changeImageWithColor:kAPPDefaultColor]];
        }
        
        for (NSInteger i = 4; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i];
            [images addObject:[[UIImage imageNamed:imageName] changeImageWithColor:kAPPDefaultColor]];
        }
        
        UIImageView *loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
        loadingView.animationImages     = images;
        loadingView.animationDuration   = 0.75;
        loadingView.hidden              = YES;
        
        _imageView = loadingView;
    }
    return _imageView;
}

- (UILabel *)loadLabel {
    if (!_loadLabel) {
        _loadLabel              = [UILabel new];
        _loadLabel.font         = [UIFont systemFontOfSize:14.0f];
        _loadLabel.textColor    = [UIColor grayColor];
        _loadLabel.text         = @"正在加载...";
        _loadLabel.hidden       = YES;
    }
    return _loadLabel;
}

@end
