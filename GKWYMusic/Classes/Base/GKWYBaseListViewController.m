//
//  GKWYBaseListViewController.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/20.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYBaseListViewController.h"

@interface GKWYBaseListViewController ()

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@end

@implementation GKWYBaseListViewController

- (instancetype)initWithType:(GKWYListType)type {
    if (self = [super init]) {
        self.listType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.listType == GKWYListType_TableView) {
        self.scrollView = self.tableView;
    }else if (self.listType == GKWYListType_CollectionView) {
        self.scrollView = self.collectionView;
    }
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.scrollView addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView);
        make.centerX.equalTo(self.scrollView);
        make.width.mas_equalTo(kScreenW);
        make.height.mas_equalTo(80);
    }];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _layout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (GKLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[GKLoadingView alloc] init];
    }
    return _loadingView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end

@implementation GKWYBaseListViewController (UIScrollView)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.scrollCallback ?: self.scrollCallback(scrollView);
}

@end

@implementation GKWYBaseListViewController (UITableView)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end

@implementation GKWYBaseListViewController (UICollectionView)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end

@implementation GKWYBaseListViewController (JXListContainerView)

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.scrollView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.scrollCallback = callback;
}

@end
