//
//  GKWYSongResultViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYSongResultViewController.h"
#import "GKWYAlbumViewController.h"
#import "GKWYArtistViewController.h"
#import "GKWYVideoViewController.h"
#import "GKWYListViewCell.h"
#import "GKActionSheet.h"

@interface GKWYSongResultViewController ()<GKWYListViewCellDelegate, GKDownloadManagerDelegate>

@property (nonatomic, strong) GKWYMusicModel *currentModel;

@end

@implementation GKWYSongResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    self.tableView.rowHeight = kAdaptive(110.0f);
    
    [self.tableView registerClass:[GKWYListViewCell class] forCellReuseIdentifier:kGKWYListViewCell];
    
    self.tipsLabel.text = @"无结果";
    
    KDownloadManager.delegate = self;
}

- (void)setSongInfo:(GKWYResultSongInfoModel *)songInfo {
    _songInfo = songInfo;

    [self gk_reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songInfo.song_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKWYListViewCell forIndexPath:indexPath];
    cell.songModel = self.songInfo.song_list[indexPath.row];
    cell.delegate  = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYMusicModel *model = self.songInfo.song_list[indexPath.row];
    [kWYPlayerVC playMusicWithModel:model];
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
    NSArray *tinguids = [model.all_artist_ting_uid componentsSeparatedByString:@","];
    NSArray *artists  = [model.all_artist_id componentsSeparatedByString:@","];
    if (tinguids.count == artists.count && tinguids.count > 1) {
        NSMutableArray *items = [NSMutableArray new];
        NSArray *titles = [model.artist_name componentsSeparatedByString:@","];
        
        __typeof(self) __weak weakSelf = self;
        [tinguids enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKActionSheetItem *item = [GKActionSheetItem new];
            item.title = titles[idx];
            item.enabled = YES;
            item.clickBlock = ^{
                GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
                artistVC.tinguid  = obj;
                artistVC.artistid = artists[idx];
                [weakSelf.navigationController pushViewController:artistVC animated:YES];
            };
            [items addObject:item];
        }];
        
        [GKActionSheet showActionSheetWithTitle:@"该歌曲有多个歌手" itemInfos:items];
    }else {
        GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
        artistVC.tinguid  = tinguids.firstObject;
        artistVC.artistid = artists.firstObject;
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
