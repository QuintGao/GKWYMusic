//
//  GKWYArtistVideoListViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/16.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistVideoListViewController.h"
#import "GKWYVideoViewCell.h"
#import "GKWYVideoViewController.h"

@interface GKWYArtistVideoListViewController ()

@end

@implementation GKWYArtistVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GKWYVideoViewCell class] forCellReuseIdentifier:kWYVideoViewCellID];
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
    
    NSString *api = [NSString stringWithFormat:@"baidu.ting.artist.getArtistMVList&id=%@&page=%d&size=20&usetinguid=%@", self.model.artist_id, self.page, self.model.ting_uid];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.isRequest = YES;
        
        NSDictionary *data = responseObject[@"result"];
        
        NSArray *mvList = [NSArray yy_modelArrayWithClass:[GKWYVideoModel class] json:data[@"mvList"]];
        
        [self.dataList addObjectsFromArray:mvList];
        
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
    GKWYVideoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWYVideoViewCellID forIndexPath:indexPath];
    cell.model = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYVideoModel *model = self.dataList[indexPath.row];
    
    GKWYVideoViewController *videoVC = [GKWYVideoViewController new];
    videoVC.mv_id = model.mv_id;
    [self.navigationController pushViewController:videoVC animated:YES];
}

@end
