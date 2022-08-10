//
//  GKWYSearchViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYSearchViewController.h"
#import "GKSearchBar.h"
#import "GKWYResultModel.h"
#import "GKWYSearchResultViewController.h"

#import "GKWYPageViewController.h"

#import "GKWYSearchHeaderView.h"
#import "GKWYSearchViewCell.h"

#import "JXCategoryView.h"

@interface GKWYSearchViewController ()<GKSearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) GKSearchBar *searchBar;

// 搜索历史table
@property (nonatomic, strong) UITableView *historyTableView;

@property (nonatomic, strong) GKWYSearchHeaderView *headerView;

@property (nonatomic, strong) GKWYResultModel *resultModel;

@property (nonatomic, strong) NSMutableArray *historys;

@property (nonatomic, strong) GKWYPageViewController *pageVC;


@end

@implementation GKWYSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_backImage = nil;
    self.gk_backStyle = GKNavigationBarBackStyleNone;
    self.gk_navLeftBarButtonItem = nil;
    self.gk_navLineHidden = YES;
    
    self.gk_navItemLeftSpace = 0;
    [self.gk_navigationBar addSubview:self.searchView];
    self.searchBar.placeholder = self.showKeyword;
    
    [self.view addSubview:self.historyTableView];
    
    [self.historyTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
    }];
    
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.pageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
    }];
    
    [self loadHotSearch];
    
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GKWYMusicTool hidePlayBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [GKWYMusicTool showPlayBtn];
}

- (void)loadHotSearch {
    NSString *api = @"search/hot/detail";
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            NSArray *tags = [NSArray yy_modelArrayWithClass:[GKWYTagModel class] json:responseObject[@"data"]];
            self.headerView.tags = tags;
            
            self.historyTableView.tableHeaderView = self.headerView;
            
            self.historys = [NSMutableArray arrayWithArray:[GKWYMusicTool historys]];
            
            [self.historyTableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - EVNCustomSearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(GKSearchBar *)searchBar {
    self.historyTableView.hidden = NO;
    self.pageVC.view.hidden = YES;
    
    return YES;
}

// 取消搜索
- (void)searchBarCancelBtnClicked:(GKSearchBar *)searchBar {
    if (searchBar.text.length <= 0) {
        searchBar.text = self.keyword;
        
        [self.historys addObject:searchBar.text];
        
        [GKWYMusicTool saveHistory:self.historys];
        
        [self searchResultWithText:searchBar.text];
    }
}

// 搜索按钮点击
- (void)searchBarSearchBtnClicked:(GKSearchBar *)searchBar {
    if (!searchBar.text || [searchBar.text isEqualToString:@""]) {
        [GKMessageTool showTips:@"请输入搜索关键字"];
        return;
    }
    // 记录历史搜索
    [self.historys addObject:searchBar.text];
    
    [GKWYMusicTool saveHistory:self.historys];
    
    [self searchResultWithText:searchBar.text];
}

- (void)searchResultWithText:(NSString *)text {
    
    GKWYSearchResultViewController *resultVC = [[GKWYSearchResultViewController alloc] init];
    resultVC.keyword = text;
    [self.navigationController pushViewController:resultVC animated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYSearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKWYSearchViewCellID];
    cell.text = self.historys[indexPath.row];
    
    __typeof(self) __weak weakSelf = self;
    cell.deleteClickBlock = ^{
        [weakSelf.historys removeObjectAtIndex:indexPath.row];
        [weakSelf.historyTableView reloadData];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.historys[indexPath.row];
    
    [self.searchBar resignFirstResponder];
    
    [self searchResultWithText:text];
}

#pragma mark - 懒加载
- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 44)];
        
        UIButton *backBtn = [[UIButton alloc] init];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [_searchView addSubview:backBtn];
        [_searchView addSubview:self.searchBar];
    }
    return _searchView;
}

- (GKSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar              = [[GKSearchBar alloc] initWithFrame:CGRectMake(40, 0, KScreenW - 40, 44)];
        _searchBar.placeholderColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        _searchBar.iconImage    = [[UIImage imageNamed:@"cm2_topbar_icn_search"] changeImageWithColor:UIColor.whiteColor];
        _searchBar.iconAlign    = GKSearchBarIconAlignLeft;
        _searchBar.delegate     = self;
        _searchBar.textField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        _searchBar.textField.layer.cornerRadius = _searchBar.textField.frame.size.height / 2;
        _searchBar.showCancelButton = YES;
        [_searchBar.cancelBtn setTitle:@"搜索" forState:UIControlStateNormal];
        [_searchBar.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _searchBar.textField.textColor = UIColor.whiteColor;
        
        if (@available(iOS 11.0, *)) {
            [_searchBar.heightAnchor constraintLessThanOrEqualToConstant:44].active = YES;
        }
    }
    return _searchBar;
}

- (GKWYPageViewController *)pageVC {
    if (!_pageVC) {
        _pageVC = [[GKWYPageViewController alloc] init];
    }
    return _pageVC;
}

- (UITableView *)historyTableView {
    if (!_historyTableView) {
        _historyTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _historyTableView.dataSource = self;
        _historyTableView.delegate   = self;
        _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _historyTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_historyTableView registerClass:[GKWYSearchViewCell class] forCellReuseIdentifier:kGKWYSearchViewCellID];
    }
    return _historyTableView;
}

- (GKWYSearchHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [GKWYSearchHeaderView new];
        
        __typeof(self) __weak weakSelf = self;
        
        _headerView.tagBtnClickBlock = ^(GKWYTagModel *model) {
            
            [weakSelf.searchBar resignFirstResponder];
            [weakSelf searchResultWithText:model.searchWord];
        };
    }
    return _headerView;
}

@end
