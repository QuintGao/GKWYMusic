//
//  GKRefreshHeader.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/26.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKRefreshHeader.h"

@interface GKRefreshHeader(){
    __unsafe_unretained UIImageView *_arrowView;
}
@property (nonatomic, weak) UIImageView *loadingView;

@end

@implementation GKRefreshHeader

#pragma mark - 懒加载子控件
- (UIImageView *)arrowView
{
    if (!_arrowView) {
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[NSBundle mj_arrowImage]];
        [self addSubview:_arrowView = arrowView];
    }
    return _arrowView;
}

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

#pragma mark - 重写父类的方法
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.lastUpdatedTimeLabel.hidden = YES;
    
    // 箭头的中心点
    CGFloat arrowCenterX = self.mj_w * 0.5;
    if (!self.stateLabel.hidden) {
        CGFloat stateWidth = self.stateLabel.mj_textWith;
        CGFloat timeWidth = 0.0;
        if (!self.lastUpdatedTimeLabel.hidden) {
            timeWidth = self.lastUpdatedTimeLabel.mj_textWith;
        }
        CGFloat textWidth = MAX(stateWidth, timeWidth);
        arrowCenterX -= textWidth / 2 + self.labelLeftInset;
    }
    CGFloat arrowCenterY = self.mj_h * 0.5;
    CGPoint arrowCenter = CGPointMake(arrowCenterX, arrowCenterY);
    
    // 箭头
    if (self.arrowView.constraints.count == 0) {
        self.arrowView.mj_size = self.arrowView.image.size;
        self.arrowView.center = arrowCenter;
    }
    
    // 圈圈
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = arrowCenter;
    }
    
    self.arrowView.tintColor = self.stateLabel.textColor;
    
    [self setTitle:@"下拉更新" forState:MJRefreshStateIdle];
    [self setTitle:@"松开更新" forState:MJRefreshStatePulling];
    [self setTitle:@"更新中..." forState:MJRefreshStateRefreshing];
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        self.loadingView.hidden = YES;
        if (oldState == MJRefreshStateRefreshing) {
            self.arrowView.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                self.loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                
                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
                self.arrowView.hidden = NO;
            }];
        } else {
            [self.loadingView stopAnimating];
            self.arrowView.hidden = NO;
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }
    } else if (state == MJRefreshStatePulling) {
        [self.loadingView stopAnimating];
        self.loadingView.hidden = YES;
        self.arrowView.hidden = NO;
        [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
        }];
    } else if (state == MJRefreshStateRefreshing) {
        self.loadingView.hidden = NO;
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
        self.arrowView.hidden = YES;
    }
}

@end
