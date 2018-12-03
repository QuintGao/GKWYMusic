//
//  GKWYIntroDetailViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYIntroDetailViewController.h"

@interface GKWYIntroDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation GKWYIntroDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"歌手介绍";
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(NAVBAR_HEIGHT, 0, 0, 0));
    }];
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.font = [UIFont systemFontOfSize:16.0f];
    contentLabel.numberOfLines = 0;
    contentLabel.text = self.intro;
    [self.scrollView addSubview:contentLabel];
    
    contentLabel.frame = CGRectMake(kAdaptive(20.0f), kAdaptive(20.0f), KScreenW - kAdaptive(40.0f), 0);
    [contentLabel sizeToFit];
    
    self.scrollView.contentSize = CGSizeMake(0, contentLabel.frame.size.height + kAdaptive(40.0f));
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
    }
    return _scrollView;
}

@end
