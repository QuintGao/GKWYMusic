//
//  GKWYSongListViewController.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/12.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYSongListViewController.h"
#import "GKWYListViewCell.h"

@interface GKWYSongListViewController ()

@end

@implementation GKWYSongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestData];
}

- (void)initUI {
    self.gk_navTitle = @"今日推荐";
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self.tableView registerClass:GKWYListViewCell.class forCellReuseIdentifier:@"GKWYListViewCell"];
}

- (void)requestData {
    NSString *api = @"recommend/songs";
    
    [self.loadingView startAnimation];
    @weakify(self);
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        @strongify(self);
        [self.loadingView stopAnimation];
        if ([responseObject[@"code"] integerValue] == 200) {
            NSArray *list = [NSArray yy_modelArrayWithClass:GKWYMusicModel.class json:responseObject[@"data"][@"dailySongs"]];
            [self.dataSource addObjectsFromArray:list];
            [self.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
        @strongify(self);
        [self.loadingView stopAnimation];
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYListViewCell" forIndexPath:indexPath];
    cell.row = indexPath.row;
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAdaptive(120.0f);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kAdaptive(88.0f))];
    view.backgroundColor = UIColor.whiteColor;
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = [[UIImage imageNamed:@"cm2_btn_play_full80x80"] changeImageWithColor:kAPPDefaultColor];
    [view addSubview:imgView];
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(kAdaptive(22.0f));
        make.centerY.equalTo(view);
        make.width.height.mas_equalTo(kAdaptive(48.0f));
    }];
    
    UILabel *playLabel = [[UILabel alloc] init];
    playLabel.textColor = UIColor.blackColor;
    playLabel.font = [UIFont systemFontOfSize:17.0f];
    playLabel.text = @"播放全部";
    [view addSubview:playLabel];
    [playLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(kAdaptive(22.0f));
        make.centerY.equalTo(imgView);
    }];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.textColor = GKColorGray(170.0f);
    countLabel.font = [UIFont systemFontOfSize:14.0f];
    countLabel.text = [NSString stringWithFormat:@"(%zd)", self.dataSource.count];
    [view addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(playLabel.mas_right);
        make.bottom.equalTo(playLabel.mas_bottom);
    }];
    
    return  self.dataSource.count > 0 ? view : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.dataSource.count > 0 ? kAdaptive(88.0) : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    [GKWYRoutes routeWithUrlString:@"gkwymusic://song" params:@{@"list": self.dataSource, @"index": @(indexPath.row)}];
}

@end
