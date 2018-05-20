//
//  GKWYListViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYListViewController.h"
#import "GKWYListViewCell.h"
#import "GKRefreshHeader.h"
#import "GKRefreshFooter.h"
#import "GKActionSheet.h"

#import "GKWYAlbumViewController.h"
#import "GKWYArtistViewController.h"

@interface GKWYListViewController ()<GKDownloadManagerDelegate, GKWYListViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *listArr;

@property (nonatomic, strong) GKWYMusicModel *currentModel;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger size;

@end

@implementation GKWYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.tableView registerClass:[GKWYListViewCell class] forCellReuseIdentifier:kGKWYListViewCell];
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
    self.tableView.mj_footer.hidden = YES;
    
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
        
        self.tableView.mj_footer.hidden = NO;
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
    GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKWYListViewCell forIndexPath:indexPath];
    cell.row      = indexPath.row;
    cell.model    = self.listArr[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [kWYPlayerVC setPlayerList:self.listArr];
    
    [kWYPlayerVC playMusicWithIndex:indexPath.row];
    
    [self.navigationController pushViewController:kWYPlayerVC animated:YES];
}

#pragma mark - GKWYListViewCellDelegate
- (void)cellDidClickMVBtn:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    
}

- (void)cellDidClickNextItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    
}

- (void)cellDidClickShareItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    
}

- (void)cellDidClickDownloadItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    
}

- (void)cellDidClickLoveItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    
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
            item.clickBlock = ^{
                GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
                artistVC.tinguid  = obj;
                artistVC.artistid = artists[idx];
                [weakSelf.navigationController pushViewController:artistVC animated:YES];
            };
            [items addObject:item];
        }];
        
        [GKActionSheet showActionSheetWithTitle:@"该歌曲有多个歌手"
                                      itemInfos:items
                                  selectedBlock:nil];
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
    
}

#pragma mark - Private Methods
- (void)showActionSheetWithModel:(GKWYMusicModel *)model {
    
    NSMutableArray *items = [NSMutableArray new];
    
    GKActionSheetItem *nextItem = [GKActionSheetItem new];
    nextItem.imgName = @"cm2_lay_icn_next_new";
    nextItem.title   = @"下一首播放";
    [items addObject:nextItem];
    
    GKActionSheetItem *shareItem = [GKActionSheetItem new];
    shareItem.imgName = @"cm2_lay_icn_share_new";
    shareItem.title   = @"分享";
    [items addObject:shareItem];
    
    GKActionSheetItem *downloadItem = [GKActionSheetItem new];
    if (model.isDownload) {
        downloadItem.title      = @"删除下载";
        downloadItem.imgName    = @"cm2_lay_icn_dlded_new";
        downloadItem.tagImgName = @"cm2_lay_icn_dlded_check";
    }else {
        downloadItem.imgName    = @"cm2_lay_icn_dld_new";
        downloadItem.title      = @"下载";
    }
    [items addObject:downloadItem];
    
    GKActionSheetItem *commentItem = [GKActionSheetItem new];
    commentItem.imgName = @"cm2_lay_icn_cmt_new";
    commentItem.title   = @"评论";
    [items addObject:commentItem];
    
    GKActionSheetItem *loveItem = [GKActionSheetItem new];
    if (model.isLike) {
        loveItem.title = @"取消喜欢";
        loveItem.imgName = @"cm2_lay_icn_loved";
    }else {
        loveItem.title = @"喜欢";
        loveItem.image = [[UIImage imageNamed:@"cm2_lay_icn_love"] changeImageWithColor:kAPPDefaultColor];
    }
    [items addObject:loveItem];
    
    GKActionSheetItem *artistItem = [GKActionSheetItem new];
    artistItem.title = [NSString stringWithFormat:@"歌手：%@", model.artist_name];
    artistItem.imgName = @"cm2_lay_icn_artist_new";
    [items addObject:artistItem];
    
    GKActionSheetItem *albumItem = [GKActionSheetItem new];
    albumItem.title = [NSString stringWithFormat:@"专辑：%@", model.album_title];
    albumItem.imgName = @"cm2_lay_icn_alb_new";
    [items addObject:albumItem];
    
    if (model.has_mv) {
        GKActionSheetItem *mvItem = [GKActionSheetItem new];
        mvItem.title = @"查看MV";
        mvItem.imgName = @"cm2_lay_icn_mv_new";
        [items addObject:mvItem];
    }
    
    [GKActionSheet showActionSheetWithTitle:[NSString stringWithFormat:@"歌曲:%@", model.song_name] itemInfos:items selectedBlock:^(NSInteger idx) {
        switch (idx) {
            case 0: {   // 下一首播放
                
            }
            case 1: {   // 分享
                
            }
                break;
            case 2: {   // 下载
                [self downloadMusicWithModel:model];
            }
                break;
            case 3: {   // 评论
                
            }
                break;
            case 4: {   // 喜欢
                [self lovedMusicWithModel:model];
            }
                break;
            case 5: {   // 歌手
                NSArray *arr = [model.all_artist_ting_uid componentsSeparatedByString:@","];
                if (arr.count > 1) {
                    
                }else {
                    GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
                    artistVC.tinguid  = arr.firstObject;
                    artistVC.artistid = model.artist_id;
                    [self.navigationController pushViewController:artistVC animated:YES];
                }
            }
                break;
            case 6: {   // 专辑
                GKWYAlbumViewController *albumVC = [GKWYAlbumViewController new];
                albumVC.album_id = model.album_id;
                [self.navigationController pushViewController:albumVC animated:YES];
            }
                break;
            case 7: {   // mv
                
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
