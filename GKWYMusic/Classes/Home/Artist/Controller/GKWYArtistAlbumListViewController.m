//
//  GKWYArtistAlbumListViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/16.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistAlbumListViewController.h"
#import "GKWYAlbumViewController.h"
#import "GKWYAlbumViewCell.h"

#import "GKRefreshHeader.h"
#import "GKRefreshFooter.h"

@interface GKWYArtistAlbumListViewController ()

@end

@implementation GKWYArtistAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GKWYAlbumViewCell class] forCellReuseIdentifier:kAlbumViewCellID];
    self.tableView.rowHeight = kAdaptive(120.0f);
}

- (void)loadData {
    if (!self.isRequest) {
        self.page = 0;
        
        [self showLoading];
        
        [self loadMoreData];
    }
}

- (void)loadMoreData {
    if (self.page == 0) {
        [self.dataList removeAllObjects];
    }else {
        self.page ++;
    }
    
    NSString *api = [NSString stringWithFormat:@"baidu.ting.artist.getAlbumList&format=json&tinguid=%@&artistid=%@&order=1&limits=30&offset=%d", self.model.ting_uid, self.model.artist_id, self.page];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.isRequest = YES;
        
        NSArray *albumList = [NSArray yy_modelArrayWithClass:[GKWYAlbumModel class] json:responseObject[@"albumlist"]];
        
        [self.dataList addObjectsFromArray:albumList];
        
        BOOL havmore = [responseObject[@"havemore"] boolValue];
        
        if (havmore) {
            self.tableView.mj_footer.hidden = NO;
            [self.tableView.mj_footer endRefreshing];
        }else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        [self hideLoading];
        
        [self.tableView reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
        
        [self hideLoading];
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GKWYAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumViewCellID forIndexPath:indexPath];
    cell.albumModel = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GKWYAlbumViewController *albumVC = [GKWYAlbumViewController new];
    albumVC.album_id = [self.dataList[indexPath.row] album_id];
    [self.navigationController pushViewController:albumVC animated:YES];
}

@end
