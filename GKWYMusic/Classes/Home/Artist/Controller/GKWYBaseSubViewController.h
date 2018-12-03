//
//  GKWYBaseSubViewController.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/18.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYBaseTableViewController.h"
#import "GKWYArtistModel.h"
#import <GKPageScrollView/GKPageScrollView.h>

@interface GKWYBaseSubViewController : GKWYBaseTableViewController<GKPageListViewDelegate>

@property (nonatomic, strong) UIScrollView      *mainScrollView;

@property (nonatomic, assign) BOOL isRequest;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) GKWYArtistModel *model;

@property (nonatomic, strong) NSMutableArray    *dataList;

// 请求数据
- (void)loadData;
- (void)loadMoreData;

// 显示、隐藏加载动画
- (void)showLoading;
- (void)hideLoading;

@end
