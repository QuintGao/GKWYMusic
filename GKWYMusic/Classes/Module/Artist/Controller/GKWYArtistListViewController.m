//
//  GKWYArtistListViewController.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/5.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYArtistListViewController.h"
#import "GKWYListViewCell.h"
#import "GKWYAlbumViewCell.h"
#import "GKWYVideoViewCell.h"
#import "GKWYIntroViewCell.h"
#import "GKRefreshFooter.h"

@interface GKWYArtistListViewController ()

@property (nonatomic, assign) NSInteger index;

@end

@implementation GKWYArtistListViewController

- (instancetype)initWithIndex:(NSInteger)index {
    self.index = index;
    return [self initWithType:GKWYListType_TableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestData];
}

- (void)initUI {
    [self.tableView registerClass:GKWYListViewCell.class forCellReuseIdentifier:@"GKWYListViewCell"];
    [self.tableView registerClass:GKWYAlbumViewCell.class forCellReuseIdentifier:@"GKWYAlbumViewCell"];
    [self.tableView registerClass:GKWYVideoViewCell.class forCellReuseIdentifier:@"GKWYVideoViewCell"];
    [self.tableView registerClass:GKWYIntroViewCell.class forCellReuseIdentifier:@"GKWYIntroViewCell"];
    
    if (self.index == 1 || self.index == 2) {
        @weakify(self);
        self.tableView.mj_footer = [GKRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self);
            [self requestData];
        }];
        self.tableView.mj_footer.hidden = YES;
    }
}

- (void)requestData {
    @weakify(self);
    if (self.index == 0) {
        NSString *api = [NSString stringWithFormat:@"artist/top/song?id=%@", self.artist_id];
        
        [self.loadingView startAnimation];
        [kHttpManager get:api params:nil successBlock:^(id responseObject) {
            @strongify(self);
            [self.loadingView stopAnimation];
            if ([responseObject[@"code"] integerValue] == 200) {
                NSArray *list = [NSArray yy_modelArrayWithClass:GKWYMusicModel.class json:responseObject[@"songs"]];
                [self.dataSource addObjectsFromArray:list];
                [self.tableView reloadData];
            }
        } failureBlock:^(NSError *error) {
            @strongify(self);
            [self.loadingView stopAnimation];
            NSLog(@"%@", error);
        }];
    }else if (self.index == 1) {
        NSInteger offset = self.dataSource.count > 0 ? self.dataSource.count : 0;
        NSString *api = [NSString stringWithFormat:@"artist/album?id=%@&limit=10&offset=%zd", self.artist_id, offset];
        
        [self.loadingView startAnimation];
        [kHttpManager get:api params:nil successBlock:^(id responseObject) {
            @strongify(self);
            [self.loadingView stopAnimation];
            if ([responseObject[@"code"] integerValue] == 200) {
                NSArray *list = [NSArray yy_modelArrayWithClass:GKWYAlbumModel.class json:responseObject[@"hotAlbums"]];
                self.tableView.mj_footer.hidden = NO;
                if ([responseObject[@"more"] boolValue]) {
                    [self.tableView.mj_footer endRefreshing];
                }else {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                [self.dataSource addObjectsFromArray:list];
                [self.tableView reloadData];
            }
        } failureBlock:^(NSError *error) {
            @strongify(self);
            [self.tableView.mj_footer endRefreshing];
            [self.loadingView stopAnimation];
        }];
    }else if (self.index == 2) {
        NSInteger offset = self.dataSource.count > 0 ? self.dataSource.count : 0;
        NSString *api = [NSString stringWithFormat:@"artist/mv?id=%@&limit=10&offset=%zd", self.artist_id, offset];
        
        [self.loadingView startAnimation];
        [kHttpManager get:api params:nil successBlock:^(id responseObject) {
            @strongify(self);
            [self.loadingView stopAnimation];
            if ([responseObject[@"code"] integerValue] == 200) {
                NSArray *list = [NSArray yy_modelArrayWithClass:GKWYVideoModel.class json:responseObject[@"mvs"]];
                self.tableView.mj_footer.hidden = NO;
                if ([responseObject[@"hasMore"] boolValue]) {
                    [self.tableView.mj_footer endRefreshing];
                }else {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                [self.dataSource addObjectsFromArray:list];
                [self.tableView reloadData];
            }
        } failureBlock:^(NSError *error) {
            @strongify(self);
            [self.tableView.mj_footer endRefreshing];
            [self.loadingView stopAnimation];
        }];
    }else if (self.index == 3) {
        NSString *api = [NSString stringWithFormat:@"artist/desc?id=%@", self.artist_id];
        
        [self.loadingView startAnimation];
        [kHttpManager get:api params:nil successBlock:^(id responseObject) {
            @strongify(self);
            [self.loadingView stopAnimation];
            if ([responseObject[@"code"] integerValue] == 200) {
                GKWYArtistDescModel *model = [GKWYArtistDescModel new];
                model.title = [NSString stringWithFormat:@"%@简介", self.artist_name];
                model.desc = responseObject[@"briefDesc"];
                [self.dataSource addObject:model];
                
                NSArray *list = [NSArray yy_modelArrayWithClass:GKWYArtistDescModel.class json:responseObject[@"introduction"]];
                [self.dataSource addObjectsFromArray:list];
                [self.tableView reloadData];
            }
        } failureBlock:^(NSError *error) {
            @strongify(self);
            [self.loadingView stopAnimation];
        }];
    }
}

#pragma mark - 懒加载
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.index == 0) {
        GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYListViewCell" forIndexPath:indexPath];
        cell.row = indexPath.row;
        cell.model = self.dataSource[indexPath.row];
        return cell;
    }else if (self.index == 1) {
        GKWYAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYAlbumViewCell" forIndexPath:indexPath];
        cell.isArtist = YES;
        cell.model = self.dataSource[indexPath.row];
        return cell;
    }else if (self.index == 2) {
        GKWYVideoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYVideoViewCell" forIndexPath:indexPath];
        cell.model = self.dataSource[indexPath.row];
        return cell;
    }else if (self.index == 3) {
        GKWYIntroViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYIntroViewCell" forIndexPath:indexPath];
        cell.model = self.dataSource[indexPath.row];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource[indexPath.row] cellHeight];
}

@end
