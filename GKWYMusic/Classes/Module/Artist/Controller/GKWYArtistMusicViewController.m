//
//  GKWYArtistMusicViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/15.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistSongViewController.h"
#import "GKWYRecommendViewCell.h"
#import "GKRefreshHeader.h"

@interface GKWYArtistSongViewController ()

@property (nonatomic, strong) NSArray *songList;

@end

@implementation GKWYArtistSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.tableView registerClass:[GKWYRecommendViewCell class] forCellReuseIdentifier:kGKWYRecommendViewCell];
    self.tableView.rowHeight = 54.0f;
    
    self.tableView.mj_header = [GKRefreshHeader headerWithRefreshingBlock:^{
        [self getSongList];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)getSongList {
    
    NSString *api = [NSString stringWithFormat:@"baidu.ting.artist.getSongList&tinguid=%@&limits=6&use_cluster=1&order=2", self.ting_uid];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.songList = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:responseObject[@"songlist"]];
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    } failureBlock:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYRecommendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKWYRecommendViewCell forIndexPath:indexPath];
    cell.model = self.songList[indexPath.row];
    return cell;
}

@end
