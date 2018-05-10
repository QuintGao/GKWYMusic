//
//  GKRefreshFooter.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKRefreshFooter.h"

@interface GKRefreshFooter()

@property (nonatomic, weak) UIImageView *loadingView;

@end

@implementation GKRefreshFooter

#pragma mark - 懒加载
- (UIImageView *)loadingView {
    if (!_loadingView) {
        NSMutableArray *images = [NSMutableArray new];
        for (NSInteger i = 0; i < 6; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%zd", i + 1];
            [images addObject:[[UIImage imageNamed:imageName] changeImageWithColor:kAPPDefaultColor]];
        }
        
        for (NSInteger i = 6; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%zd", i];
            [images addObject:[[UIImage imageNamed:imageName] changeImageWithColor:kAPPDefaultColor]];
        }
        
        UIImageView *loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
        loadingView.animationImages = images;
        loadingView.animationDuration = 0.75;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

#pragma mark - 重写父类方法
- (void)placeSubviews {
    [super placeSubviews];
    
    if (self.loadingView.constraints.count) return;
    
    CGFloat loadingCenterX = self.mj_w * 0.5;
    if (!self.isRefreshingTitleHidden) {
        loadingCenterX -= self.stateLabel.mj_textWith * 0.5 + self.labelLeftInset;
    }
    CGFloat loadingCenterY = self.mj_h * 0.5;
    self.loadingView.center = CGPointMake(loadingCenterX, loadingCenterY);
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle) {
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimating];
    } else if (state == MJRefreshStateRefreshing) {
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];
    }
}

@end
