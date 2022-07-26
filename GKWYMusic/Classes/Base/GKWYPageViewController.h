//
//  GKWYPageViewController.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYBaseViewController.h"
#import <JXCategoryViewExt/JXCategoryView.h>

@interface GKWYPageViewController : GKWYBaseViewController<JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

@property (nonatomic, strong) JXCategoryIndicatorComponentView *indicatorView;

@property (nonatomic, strong) JXCategoryListContainerView *containerView;

@property (nonatomic, assign) BOOL              hideNavBar;

- (void)initializeViews;

- (void)reloadData;

@end
