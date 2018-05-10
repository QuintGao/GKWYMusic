//
//  GKWYMineViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMineViewController.h"
#import "GKWYMyListViewController.h"

@interface GKWYMineViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation GKWYMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationItem.title = @"我的音乐";
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [cell.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView).offset(10);
            make.centerY.equalTo(cell.contentView);
            make.width.height.mas_equalTo(40.0f);
        }];
        [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.imageView.mas_right).offset(10.0f);
            make.centerY.equalTo(cell.imageView);
        }];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = kAppLineColor;
        [cell addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(cell);
            make.left.equalTo(cell.textLabel.mas_left);
            make.height.mas_equalTo(0.5f);
        }];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"我喜欢的";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%zd", [GKWYMusicTool lovedMusicList].count];
        cell.imageView.image = [[UIImage imageNamed:@"cm2_play_icn_love"] changeImageWithColor:kAPPDefaultColor];
    }else {
        cell.textLabel.text = @"我下载的";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%zd", [KDownloadManager downloadedFileList].count];
        cell.imageView.image = [[UIImage imageNamed:@"cm2_icn_dld"] changeImageWithColor:kAPPDefaultColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYMyListViewController *listVC = [GKWYMyListViewController new];
    listVC.type = indexPath.row;
    
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        _tableView.rowHeight  = 50.0f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
