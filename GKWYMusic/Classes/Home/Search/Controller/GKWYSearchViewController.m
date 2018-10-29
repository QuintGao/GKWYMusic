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

#import "GKWYPageViewController.h"

#import "GKWYSongResultViewController.h"
#import "GKWYVideoResultViewController.h"
#import "GKWYArtistResultViewController.h"
#import "GKWYAlbumResultViewController.h"

#import "GKWYSearchHeaderView.h"
#import "GKWYSearchViewCell.h"

#import "JXCategoryView.h"

@interface GKWYSearchViewController ()<GKSearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

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
    
    self.gk_navigationItem.leftBarButtonItem = nil;
    self.gk_navShadowColor = [UIColor clearColor];
    
    [self.gk_navigationBar addSubview:self.searchBar];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gk_navigationBar).offset(10.0f);
        make.right.equalTo(self.gk_navigationBar);
        make.bottom.equalTo(self.gk_navigationBar.mas_bottom).offset(-44.0f);
        make.height.mas_equalTo(44.0f);
    }];
    
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
    NSString *api = @"baidu.ting.search.hot&page_num=10";
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        NSArray *tags = [NSArray yy_modelArrayWithClass:[GKWYTagModel class] json:responseObject[@"result"]];
        
        self.headerView.tags = tags;
        
        self.historyTableView.tableHeaderView = self.headerView;
        
        self.historys = [NSMutableArray arrayWithArray:[GKWYMusicTool historys]];
        
        [self.historyTableView reloadData];
        
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
    [self.navigationController popViewControllerAnimated:NO];
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
    NSString *api = [NSString stringWithFormat:@"baidu.ting.search.merge&query=%@&page_size=30&page_no=1", text];
    
    api = [api stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.resultModel = [GKWYResultModel yy_modelWithDictionary:responseObject[@"result"]];
        
        self.historyTableView.hidden = YES;
        [self.historyTableView reloadData];

        NSMutableArray *titles      = [NSMutableArray new];
        NSMutableArray *childVCs    = [NSMutableArray new];

        // 单曲
        [titles addObject:@"单曲"];
        GKWYSongResultViewController *songResultVC = [GKWYSongResultViewController new];
        songResultVC.songInfo = self.resultModel.song_info;
        [childVCs addObject:songResultVC];

        // 视频
        [titles addObject:@"视频"];
        GKWYVideoResultViewController *videoResultVC = [GKWYVideoResultViewController new];
        videoResultVC.videoInfo = self.resultModel.video_info;
        [childVCs addObject:videoResultVC];
        // 歌手
        [titles addObject:@"歌手"];
        GKWYArtistResultViewController *artistResultVC = [GKWYArtistResultViewController new];
        artistResultVC.artistInfo = self.resultModel.artist_info;
        [childVCs addObject:artistResultVC];

        // 专辑
        [titles addObject:@"专辑"];
        GKWYAlbumResultViewController *albumResultVC = [GKWYAlbumResultViewController new];
        albumResultVC.albumInfo = self.resultModel.album_info;
        [childVCs addObject:albumResultVC];
        
        // 歌单
        [titles addObject:@"歌单"];
        
        // 用户
        [titles addObject:@"用户"];
        
        self.pageVC.titles = titles;
        self.pageVC.childVCs = childVCs;
        
        self.pageVC.view.hidden = NO;
        [self.pageVC reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"搜索失败==%@", error);
    }];
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
- (GKSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar              = [[GKSearchBar alloc] initWithFrame:CGRectMake(80, 0, KScreenW - 110, KScreenH)];
        _searchBar.placeholder  = @"请输入关键字";
        _searchBar.iconAlign    = GKSearchBarIconAlignLeft;
        _searchBar.iconImage    = [UIImage imageNamed:@"cm2_topbar_icn_search"];
        _searchBar.delegate     = self;
        _searchBar.showCancelButton = YES;
        [_searchBar.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        if (@available(iOS 11.0, *)) {
            [_searchBar.heightAnchor constraintLessThanOrEqualToConstant:44].active = YES;
        }
    }
    return _searchBar;
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
            [weakSelf searchResultWithText:model.word];
        };
    }
    return _headerView;
}

- (GKWYPageViewController *)pageVC {
    if (!_pageVC) {
        _pageVC = [GKWYPageViewController new];
        _pageVC.view.hidden = YES;
        _pageVC.hideNavBar  = YES;
    }
    return _pageVC;
}

@end
