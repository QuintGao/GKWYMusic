//
//  GKWYListViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYListViewController.h"
#import "GKWYRecommendViewCell.h"
#import "GKRefreshHeader.h"
#import "GKRefreshFooter.h"
#import "GKActionSheet.h"

@interface GKWYListViewController ()<GKDownloadManagerDelegate>

@property (nonatomic, strong) NSMutableArray *listArr;

@property (nonatomic, strong) GKWYMusicModel *currentModel;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger size;

@end

@implementation GKWYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.tableView registerClass:[GKWYRecommendViewCell class] forCellReuseIdentifier:kGKWYRecommendViewCell];
    self.tableView.rowHeight = 54.0f;
    
    // 初始化页码
    self.page = 0;
    // 初始化大小
    self.size = 20;
    
    self.tableView.mj_header = [GKRefreshHeader headerWithRefreshingBlock:^{
        self.page = 0;
        [self loadData];
    }];
    
    self.tableView.mj_footer = [GKRefreshFooter footerWithRefreshingBlock:^{
        self.page += self.size;
        [self loadData];
    }];
    
    [self.tableView.mj_header beginRefreshing];
    
    [kNotificationCenter addObserver:self selector:@selector(reloadMusic) name:GKWYMUSIC_LOVEMUSICNOTIFICATION object:nil];
    [kNotificationCenter addObserver:self selector:@selector(reloadMusic) name:GKWYMUSIC_PLAYMUSICCHANGENOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadMusic];
    
    KDownloadManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    KDownloadManager.delegate = nil;
}

- (void)reloadMusic {
    [self.tableView reloadData];
}

- (void)loadData {
    
    // 获取列表
    NSString *api = [NSString stringWithFormat:@"baidu.ting.billboard.billList&type=%zd&size=%zd&offset=%zd", self.type, self.size, self.page];
    
    if (self.page == 0) {
        [self.listArr removeAllObjects];
    }
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        NSArray *data = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:responseObject[@"song_list"]];
        
        [self.listArr addObjectsFromArray:data];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
        NSDictionary *billboard = responseObject[@"billboard"];
        
        // 是否有更多数据
        if ([billboard[@"havemore"] boolValue]) {
            [self.tableView.mj_footer endRefreshing];
        }else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    } failureBlock:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYRecommendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKWYRecommendViewCell forIndexPath:indexPath];
    cell.row   = indexPath.row;
    cell.model = self.listArr[indexPath.row];
    
    cell.moreClicked = ^(GKWYMusicModel *model) {
        self.currentModel = model;
        
        [self showActionSheetWithModel:model];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [kWYPlayerVC setPlayerList:self.listArr];
    
    [kWYPlayerVC playMusicWithIndex:indexPath.row];
    
    [self.navigationController pushViewController:kWYPlayerVC animated:YES];
}

#pragma mark - Private Methods
- (void)showActionSheetWithModel:(GKWYMusicModel *)model {
    GKActionSheetItem *shareItem = [GKActionSheetItem new];
    shareItem.imgName = @"cm2_lay_icn_share_new";
    shareItem.title   = @"分享";
    
    GKActionSheetItem *downloadItem = [GKActionSheetItem new];
    if (model.isDownload) {
        downloadItem.title      = @"删除下载";
        downloadItem.imgName    = @"cm2_lay_icn_dlded_new";
        downloadItem.tagImgName = @"cm2_lay_icn_dlded_check";
    }else {
        downloadItem.imgName    = @"cm2_lay_icn_dld_new";
        downloadItem.title      = @"下载";
    }
    
    GKActionSheetItem *commentItem = [GKActionSheetItem new];
    commentItem.imgName = @"cm2_lay_icn_cmt_new";
    commentItem.title   = @"评论";
    
    GKActionSheetItem *loveItem = [GKActionSheetItem new];
    if (model.isLike) {
        loveItem.title = @"取消喜欢";
        loveItem.imgName = @"cm2_lay_icn_loved";
    }else {
        loveItem.title = @"喜欢";
        loveItem.image = [[UIImage imageNamed:@"cm2_lay_icn_love"] changeImageWithColor:kAPPDefaultColor];
    }
    
    [GKActionSheet showActionSheetWithTitle:[NSString stringWithFormat:@"歌曲:%@", model.song_name] itemInfos:@[shareItem, downloadItem, commentItem, loveItem] selectedBlock:^(NSInteger idx) {
        switch (idx) {
            case 0: {   // 分享
                
            }
                break;
            case 1: {   // 下载
                [self downloadMusicWithModel:model];
            }
                break;
            case 2: {   // 评论
                
            }
                break;
            case 3: {   // 喜欢
                [self lovedMusicWithModel:model];
            }
                break;
                
            default:
                break;
        }
    }];
}

// 单个下载
- (void)downloadMusicWithModel:(GKWYMusicModel *)model {
    if (model.isDownload) {
        GKDownloadModel *dModel = [GKDownloadModel new];
        dModel.fileID = model.song_id;
        
        [KDownloadManager removeDownloadArr:@[dModel]];
    }else {
        [GKWYMusicTool downloadMusicWithSongId:model.song_id];
    }
}

- (void)lovedMusicWithModel:(GKWYMusicModel *)model {
    model.isLove = !model.isLove;
    
    [GKWYMusicTool loveMusic:model];
    
    if (model.isLike) {
        [GKMessageTool showSuccess:@"已添加到我喜欢的音乐" toView:self.view imageName:@"cm2_play_icn_loved" bgColor:[UIColor blackColor]];
    }else {
        [GKMessageTool showText:@"已取消喜欢" toView:self.view bgColor:[UIColor blackColor]];
    }
}

- (void)gkDownloadManager:(GKDownloadManager *)downloadManager downloadModel:(GKDownloadModel *)downloadModel stateChanged:(GKDownloadManagerState)state {
    if ([self.currentModel.song_id isEqualToString:downloadModel.fileID]) {
        
        GKActionSheetItem *downloadItem = [GKActionSheetItem new];
        
        if (state == GKDownloadManagerStateFinished) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 下载图片及歌词
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadModel.fileCover]];
                [imgData writeToFile:downloadModel.fileImagePath atomically:YES];
                
                // 歌词
                NSData *lrcData = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadModel.fileLyric]];
                [lrcData writeToFile:downloadModel.fileLyricPath atomically:YES];
                
                downloadItem.title      = @"删除下载";
                downloadItem.imgName    = @"cm2_lay_icn_dlded_new";
                downloadItem.tagImgName = @"cm2_lay_icn_dlded_check";
            });
        }else {
            downloadItem.imgName    = @"cm2_lay_icn_dld_new";
            downloadItem.title      = @"下载";
        }
        
        if ([GKActionSheet hasShow]) {
            [GKActionSheet updateActionSheetItemWithIndex:1 item:downloadItem];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - 懒加载
- (NSMutableArray *)listArr {
    if (!_listArr) {
        _listArr = [NSMutableArray new];
    }
    return _listArr;
}

@end
