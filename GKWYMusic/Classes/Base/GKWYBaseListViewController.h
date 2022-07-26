//
//  GKWYBaseListViewController.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/20.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYBaseViewController.h"
#import <JXCategoryViewExt/JXCategoryView.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKWYListType) {
    GKWYListType_TableView,
    GKWYListType_CollectionView,
    GKWYListType_ScrollView
};

@interface GKWYBaseListViewController : GKWYBaseViewController

- (instancetype)initWithType:(GKWYListType)type;

@property (nonatomic, assign) GKWYListType type;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@interface GKWYBaseListViewController (UITableView)<UITableViewDataSource, UITableViewDelegate>

@end

@interface GKWYBaseListViewController (UICollectionView)<UICollectionViewDataSource, UICollectionViewDelegate>

@end

@interface GKWYBaseListViewController (JXListContainerView)<JXCategoryListContentViewDelegate>

@end

NS_ASSUME_NONNULL_END
