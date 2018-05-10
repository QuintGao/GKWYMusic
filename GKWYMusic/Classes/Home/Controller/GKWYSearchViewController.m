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
#import "GKWYSongResultViewController.h"
#import "GKWYArtistResultViewController.h"
#import "GKWYAlbumResultViewController.h"

@interface GKWYSearchViewController ()<GKSearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) GKSearchBar *searchBar;

// 搜索历史table
@property (nonatomic, strong) UITableView *historyTableView;

@property (nonatomic, strong) GKWYResultModel *resultModel;

@property (nonatomic, strong) NSMutableArray *historys;

@end

@implementation GKWYSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.leftBarButtonItem = nil;
    
    [self.gk_navigationBar addSubview:self.searchBar];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gk_navigationBar).offset(10.0f);
        make.right.equalTo(self.gk_navigationBar);
        make.centerY.equalTo(self.gk_navigationBar.mas_bottom).offset(-44.0f);
        make.height.mas_equalTo(44.0f);
    }];
    
    [self.view addSubview:self.historyTableView];
    
    [self.historyTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
    }];
    
    self.historys = [NSMutableArray arrayWithArray:[GKWYMusicTool historys]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GKWYMusicTool hidePlayBtn];
    
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [GKWYMusicTool showPlayBtn];
}

#pragma mark - EVNCustomSearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(GKSearchBar *)searchBar {
    self.historyTableView.hidden = NO;
    
    return YES;
}

// 取消搜索
- (void)searchBarCancelBtnClicked:(GKSearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:YES];
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
    NSString *api = [NSString stringWithFormat:@"baidu.ting.search.catalogSug&query=%@", text];
    
    api = [api stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.resultModel = [GKWYResultModel yy_modelWithDictionary:responseObject];
        
        self.historyTableView.hidden = YES;
        [self.historyTableView reloadData];
        
        NSMutableArray *titles      = [NSMutableArray new];
        NSMutableArray *childVCs    = [NSMutableArray new];
        
        // 单曲
        [titles addObject:@"单曲"];
        GKWYSongResultViewController *songResultVC = [GKWYSongResultViewController new];
        songResultVC.songs = self.resultModel.song;
        [childVCs addObject:songResultVC];
        
        // 歌手
        [titles addObject:@"歌手"];
        GKWYArtistResultViewController *artistResultVC = [GKWYArtistResultViewController new];
        artistResultVC.artists = self.resultModel.artist;
        [childVCs addObject:artistResultVC];
        
        // 专辑
        [titles addObject:@"专辑"];
        GKWYAlbumResultViewController *albumResultVC = [GKWYAlbumResultViewController new];
        albumResultVC.albums = self.resultModel.album;
        [childVCs addObject:albumResultVC];
        
        self.titles     = titles;
        self.childVCs   = childVCs;
        
        [self reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"搜索失败==%@", error);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    cell.textLabel.text = self.historys[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.historys[indexPath.row];
    
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
        [_historyTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HistoryCell"];
    }
    return _historyTableView;
}

@end
