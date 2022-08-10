//
//  GKWYHomeViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/19.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYHomeViewController.h"
#import "GKWYListViewController.h"
#import "GKWYSearchViewController.h"
#import "GKSearchBar.h"
#import "GKWYListTagModel.h"

@interface GKWYHomeViewController ()<GKSearchBarDelegate, JXCategoryTitleViewDataSource>

@property (nonatomic, strong) GKSearchBar *searchBar;

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, copy) NSString *showKeyword;
@property (nonatomic, copy) NSString *keyword;

@end

@implementation GKWYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.gk_navigationBar addSubview:self.searchBar];
    self.gk_navLineHidden = YES;
    
    [self requestData];
    
    [self requestDefaultSearch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary *musicInfo = [GKWYMusicTool lastMusicInfo];
    
    if (musicInfo) {
        [GKWYMusicTool showPlayBtn];
    }else {
        [GKWYMusicTool hidePlayBtn];
    }
    
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gk_navigationBar).offset(15.0f);
        make.right.equalTo(self.gk_navigationBar).offset(musicInfo ? -52.0f : -15.0f);
        make.bottom.equalTo(self.gk_navigationBar.mas_bottom).offset(-44.0f);
        make.height.mas_equalTo(44.0f);
    }];
    [self.searchBar layoutIfNeeded];
}

- (void)initializeViews {
    self.categoryView.titleDataSource = self;
    
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = kAPPDefaultColor;
    lineView.indicatorWidthIncrement = 2;
    lineView.indicatorHeight = 8;
    lineView.indicatorCornerRadius = 4;
    self.indicatorView = lineView;
}

- (void)requestData {
    [kHttpManager get:@"playlist/highquality/tags" params:nil successBlock:^(id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            self.tags = [NSArray yy_modelArrayWithClass:[GKWYListTagModel class] json:responseObject[@"tags"]];
            [self reloadData];
        }else {
            [GKMessageTool showError:@"请求失败"];
        }
    } failureBlock:^(NSError *error) {
        [GKMessageTool showError:@"请求失败"];
    }];
}

- (void)requestDefaultSearch {
    [kHttpManager get:@"search/default" params:nil successBlock:^(id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            self.showKeyword = responseObject[@"data"][@"showKeyword"];
            self.keyword = responseObject[@"data"][@"realkeyword"];
            self.searchBar.placeholder = self.showKeyword;
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

#pragma mark - GKSearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(GKSearchBar *)searchBar {
    GKWYSearchViewController *searchVC = [GKWYSearchViewController new];
    searchVC.showKeyword = self.showKeyword;
    searchVC.keyword = self.keyword;
    [self.navigationController pushViewController:searchVC animated:NO];
    return NO;
}

#pragma mark - JXCategoryTitleViewDataSource
- (NSInteger)numberOfTitleView:(JXCategoryTitleView *)titleView {
    return self.tags.count;
}

- (NSString *)titleView:(JXCategoryTitleView *)titleView titleForIndex:(NSInteger)index {
    return [self.tags[index] name];
}

#pragma mark - JXCategoryListContainerViewDelegate
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    GKWYListViewController *listVC = [[GKWYListViewController alloc] initWithType:GKWYListType_CollectionView];
    listVC.tagModel = self.tags[index];
    return listVC;
}

#pragma mark - 懒加载
- (GKSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar              = [[GKSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH)];
        _searchBar.placeholder  = @"搜索";
        _searchBar.placeholderColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        _searchBar.iconAlign    = GKSearchBarIconAlignCenter;
        _searchBar.iconImage    = [[UIImage imageNamed:@"cm2_topbar_icn_search"] changeImageWithColor:UIColor.whiteColor];
        _searchBar.delegate     = self;
        _searchBar.textField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        _searchBar.textField.layer.cornerRadius = _searchBar.textField.frame.size.height / 2;
        
        if (@available(iOS 11.0, *)) {
            [_searchBar.heightAnchor constraintLessThanOrEqualToConstant:44].active = YES;
        }
    }
    return _searchBar;
}

@end
