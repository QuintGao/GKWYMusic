//
//  GKWYResultListViewController.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/2.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYResultListViewController.h"
#import "GKWYSongViewCell.h"
#import "GKWYPlayListViewCell.h"
#import "GKRefreshFooter.h"
#import "GKWYPlayListViewController.h"

@interface GKWYResultListViewController ()

@end

@implementation GKWYResultListViewController

- (instancetype)init {
    return [self initWithType:GKWYListType_TableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestData];
}

- (void)initUI {
    [self.tableView registerClass:GKWYSongViewCell.class forCellReuseIdentifier:@"GKWYSongViewCell"];
    [self.tableView registerClass:GKWYPlayListViewCell.class forCellReuseIdentifier:@"GKWYPlayListViewCell"];
    
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_footer = [GKRefreshFooter footerWithRefreshingBlock:^{
        [weakSelf requestData];
    }];
}

- (void)requestData {
    // type 搜索类型
    // 默认1 即单曲 , 取值意义 : 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频, 1018:综合,
    NSInteger offset = self.dataSource.count > 0 ? self.dataSource.count - 1 : 0;
    
    NSString *api = [NSString stringWithFormat:@"cloudsearch?keywords=%@&type=%zd&offset=%zd", self.keyword, self.type, offset];
    
    [self.loadingView startAnimation];
    
    __weak __typeof(self) weakSelf = self;
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        __strong __typeof(weakSelf) self = weakSelf;
        
        [self.loadingView stopAnimation];
        if ([responseObject[@"code"] integerValue] == 200) {
            NSString *listKey = nil;
            NSString *countKey = nil;
            Class cls = nil;
            if (self.type == 1) {
                listKey = @"songs";
                countKey = @"songCount";
                cls = GKWYMusicModel.class;
            }else if (self.type == 1000) {
                listKey = @"playlists";
                countKey = @"playlistCount";
                cls = GKWYPlayListModel.class;
            }
            if (!listKey) return;

            NSArray *list = [NSArray yy_modelArrayWithClass:cls json:responseObject[@"result"][listKey]];
            
            [self.dataSource addObjectsFromArray:list];
            NSInteger count = [responseObject[@"result"][countKey] integerValue];
            
            if (self.dataSource.count >= count) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [self.tableView.mj_footer endRefreshing];
            }
            [self.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        __strong __typeof(weakSelf) self = weakSelf;
        
        [self.loadingView stopAnimation];
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"搜索失败==%@", error);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = self.dataSource[indexPath.row];
    [model setValue:self.keyword forKey:@"keyword"];
    
    if (self.type == 1) {
        GKWYSongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYSongViewCell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }else if (self.type == 1000) {
        GKWYPlayListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYPlayListViewCell" forIndexPath:indexPath];
        cell.model = model;
        return cell;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == 1) {
        [GKWYRoutes routeWithUrlString:@"gkwymusic://song" params:@{@"list": self.dataSource, @"index": @(indexPath.row)}];
    }else if (self.type == 1000) {
        GKWYPlayListModel *model = self.dataSource[indexPath.row];
        GKWYPlayListViewController *listVC = [[GKWYPlayListViewController alloc] init];
        listVC.list_id = model.list_id;
        [self.navigationController pushViewController:listVC animated:YES];
    }
}

@end
