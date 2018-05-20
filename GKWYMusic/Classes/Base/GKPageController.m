//
//  GKPageController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKPageController.h"

@interface GKPageController ()

@end

@implementation GKPageController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.menuView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.menuView);
        make.height.mas_equalTo(0.5f);
    }];
}

#pragma mark - UIScrollViewDelegate
// 解决左右滑动与上下滑动的冲突
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    
    [kNotificationCenter postNotificationName:@"HorizontalScroll" object:@{@"canScroll":@"0"}];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    [kNotificationCenter postNotificationName:@"HorizontalScroll" object:@{@"canScroll":@"1"}];
}

#pragma mark - 懒加载
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = kAppLineColor;
    }
    return _lineView;
}

@end
