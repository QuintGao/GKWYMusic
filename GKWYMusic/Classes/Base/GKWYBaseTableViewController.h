//
//  GKWYBaseTableViewController.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYBaseViewController.h"

@interface GKWYBaseTableViewController : GKWYBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *tipsLabel;

- (void)gk_reloadData;

@end
