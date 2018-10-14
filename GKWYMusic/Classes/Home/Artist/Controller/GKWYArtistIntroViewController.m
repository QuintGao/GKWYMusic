//
//  GKWYArtistIntroViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/16.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistIntroViewController.h"
#import "GKWYArtistViewController.h"
#import "GKWYIntroViewCell.h"
#import "GKWYIntroDetailViewController.h"

@interface GKWYArtistIntroViewController ()

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@end

@implementation GKWYArtistIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GKWYIntroViewCell class] forCellReuseIdentifier:kWYIntroViewCellID];
    
    self.tableView.mj_footer = nil;
}

- (void)loadData {
    if (self.isRequest) return;
    
    self.page = 0;
    [self showLoading];
    [self loadMoreData];
}

- (void)loadMoreData {
    if (self.page == 0) {
        [self.dataList removeAllObjects];
    }else {
        self.page ++;
    }
    
    NSString *api = [NSString stringWithFormat:@"baidu.ting.artist.recommendArtist&ting_uid=%@", self.model.ting_uid];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.isRequest = YES;
        
        NSDictionary *data = responseObject[@"result"];
        
        NSArray *list = [NSArray yy_modelArrayWithClass:[GKWYArtistRecModel class] json:data[@"list"]];
        
        [self.dataList addObjectsFromArray:list];
        
        [self hideLoading];
        
        self.cellHeight = kAdaptive(90.0f) + self.model.introHeight + kAdaptive(60.0f) + kAdaptive(280.0f);
        
        [self.tableView reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
        [self hideLoading];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isRequest ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYIntroViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWYIntroViewCellID];
    cell.artistModel = self.model;
    cell.dataList    = self.dataList;
    cell.introBtnClickBlock = ^{
        GKWYIntroDetailViewController *detailVC = [GKWYIntroDetailViewController new];
        detailVC.intro = self.model.intro;
        [self.navigationController pushViewController:detailVC animated:YES];
    };
    
    cell.recArtistClickBlock = ^(GKWYArtistRecModel *model) {
        GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
        artistVC.tinguid  = model.ting_uid;
        artistVC.artistid = model.artist_id;
        [self.navigationController pushViewController:artistVC animated:YES];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

@end
