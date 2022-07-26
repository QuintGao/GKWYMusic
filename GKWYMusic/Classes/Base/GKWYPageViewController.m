//
//  GKWYPageViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYPageViewController.h"

@interface GKWYPageViewController ()


@end

@implementation GKWYPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeViews];
    
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.containerView];
    
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.height.mas_equalTo(kAdaptive(80));
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.categoryView.mas_bottom);
    }];
}

- (void)initializeViews {
    // subclass implementation
}

- (void)reloadData {
    self.categoryView.indicators = @[self.indicatorView];
    self.categoryView.listContainer = self.containerView;
    
    [self.categoryView reloadData];
}

#pragma mark - JXCategoryListContainerViewDelegate
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    if (self.categoryView.titleDataSource && [self.categoryView.titleDataSource respondsToSelector:@selector(numberOfTitleView:)]) {
        return [self.categoryView.titleDataSource numberOfTitleView:self.categoryView];
    }
    return self.categoryView.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    return nil;
}

#pragma mark - 懒加载
- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.titleFont = [UIFont systemFontOfSize:15];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16];
        _categoryView.titleLabelStrokeWidthEnabled = YES;
        _categoryView.titleColor = UIColor.whiteColor;
        _categoryView.titleSelectedColor = UIColor.whiteColor;
        _categoryView.backgroundColor = kAPPDefaultColor;
    }
    return _categoryView;
}

- (JXCategoryListContainerView *)containerView {
    if (!_containerView) {
        _containerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_CollectionView delegate:self];
    }
    return _containerView;
}

@end
