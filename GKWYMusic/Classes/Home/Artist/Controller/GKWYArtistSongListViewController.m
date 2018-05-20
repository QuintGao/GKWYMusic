//
//  GKWYArtistSongListViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/15.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistSongListViewController.h"
#import "GKWYListViewCell.h"
#import "GKActionSheet.h"
#import "GKWYAlbumViewController.h"

@interface GKWYArtistSongListViewController ()<GKDownloadManagerDelegate>

@property (nonatomic, strong) GKWYMusicModel *currentModel;

@end

@implementation GKWYArtistSongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GKWYListViewCell class] forCellReuseIdentifier:kGKWYListViewCell];
    self.tableView.rowHeight = 54.0f;
    
    KDownloadManager.delegate = self;
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
    
    NSString *api = [NSString stringWithFormat:@"baidu.ting.artist.getSongList&tinguid=%@&artistid=%@&limits=50&order=2&offset=%d", self.model.ting_uid, self.model.artist_id, self.page];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.isRequest = YES;
        
        NSArray *songList = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:responseObject[@"songlist"]];
        
        [self.dataList addObjectsFromArray:songList];
        
        BOOL havemore = [responseObject[@"havemore"] boolValue];
        
        if (havemore) {
            self.tableView.mj_footer.hidden = NO;
            [self.tableView.mj_footer endRefreshing];
        }else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        [self hideLoading];
        
        [self.tableView reloadData];
    } failureBlock:^(NSError *error) {
        [self hideLoading];
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKWYListViewCell forIndexPath:indexPath];
    cell.row   = indexPath.row;
    cell.model = self.dataList[indexPath.row];
//    cell.moreClicked = ^(GKWYMusicModel *model) {
//        [self showActionSheetWithModel:model];
//    };
    return cell;
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
    
    GKActionSheetItem *albumItem = [GKActionSheetItem new];
    albumItem.title = [NSString stringWithFormat:@"专辑：%@", model.album_title];
    albumItem.imgName = @"cm2_lay_icn_alb_new";
    
    [GKActionSheet showActionSheetWithTitle:[NSString stringWithFormat:@"歌曲:%@", model.song_name] itemInfos:@[shareItem, downloadItem, commentItem, loveItem, albumItem] selectedBlock:^(NSInteger idx) {
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
            case 4: {   // 专辑
                GKWYAlbumViewController *albumVC = [GKWYAlbumViewController new];
                albumVC.album_id = model.album_id;
                [self.navigationController pushViewController:albumVC animated:YES];
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

@end
