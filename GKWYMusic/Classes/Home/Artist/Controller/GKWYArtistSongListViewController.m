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
#import "GKWYArtistViewController.h"
#import "GKWYVideoViewController.h"

@interface GKWYArtistSongListViewController ()<GKDownloadManagerDelegate, GKWYListViewCellDelegate>

@property (nonatomic, strong) GKWYMusicModel *currentModel;

@end

@implementation GKWYArtistSongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GKWYListViewCell class] forCellReuseIdentifier:kGKWYListViewCell];
    self.tableView.rowHeight = kAdaptive(110.0f);
    
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
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [kWYPlayerVC playMusicWithModel:self.dataList[indexPath.row]];
    [self.navigationController pushViewController:kWYPlayerVC animated:YES];
}

#pragma mark - GKWYListViewCellDelegate
- (void)cellDidClickMVBtn:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    GKWYVideoViewController *videoVC = [GKWYVideoViewController new];
    videoVC.song_id = model.song_id;
    [self.navigationController pushViewController:videoVC animated:YES];
}

- (void)cellDidClickNextItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [GKMessageTool showText:@"下一首播放"];
}

- (void)cellDidClickShareItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [GKMessageTool showText:@"分享"];
}

- (void)cellDidClickDownloadItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [self downloadMusicWithModel:model];
}

- (void)cellDidClickCommentItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [GKMessageTool showText:@"评论"];
}

- (void)cellDidClickLoveItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [self lovedMusicWithModel:model];
}

- (void)cellDidClickArtistItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    if (model.ar.count > 1) {
        NSMutableArray *items = [NSMutableArray new];
        
        __typeof(self) __weak weakSelf = self;
        [model.ar enumerateObjectsUsingBlock:^(GKWYMusicArModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKActionSheetItem *item = [GKActionSheetItem new];
            item.title = obj.name;
            item.enabled = YES;
            item.clickBlock = ^{
                GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
                artistVC.artistid = obj.ar_id;
                [weakSelf.navigationController pushViewController:artistVC animated:YES];
            };
            [items addObject:item];
        }];
        
        [GKActionSheet showActionSheetWithTitle:@"该歌曲有多个歌手" itemInfos:items];
    }else {
        GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
        artistVC.artistid = model.ar.firstObject.ar_id;
        [self.navigationController pushViewController:artistVC animated:YES];
    }
}

- (void)cellDidClickAlbumItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    GKWYAlbumViewController *albumVC = [GKWYAlbumViewController new];
    albumVC.album_id = model.album_id;
    [self.navigationController pushViewController:albumVC animated:YES];
}

- (void)cellDidClickMVItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    GKWYVideoViewController *videoVC = [GKWYVideoViewController new];
    videoVC.song_id = model.song_id;
    [self.navigationController pushViewController:videoVC animated:YES];
}

// 单个下载
- (void)downloadMusicWithModel:(GKWYMusicModel *)model {
    self.currentModel = model;
    
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

#pragma mark - GKDownloadManagerDelegate
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
