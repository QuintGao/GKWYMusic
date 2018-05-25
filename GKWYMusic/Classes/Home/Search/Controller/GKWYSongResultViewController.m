//
//  GKWYSongResultViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYSongResultViewController.h"
#import "GKWYSongViewCell.h"

@interface GKWYSongResultViewController ()

@end

@implementation GKWYSongResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    self.tableView.rowHeight = 60.0f;
    
    [self.tableView registerClass:[GKWYSongViewCell class] forCellReuseIdentifier:kSongViewCellID];
    
    self.tipsLabel.text = @"无结果";
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
    GKWYSongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSongViewCellID forIndexPath:indexPath];
    cell.model = self.songInfo.song_list[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYResultSongModel *songModel = self.songInfo.song_list[indexPath.row];
    
    GKWYMusicModel *model = [GKWYMusicModel new];
    model.song_id       = songModel.song_id;
    model.song_name     = songModel.title;
    model.song_name     = songModel.title;
    model.album_id      = songModel.album_id;
    model.album_title   = songModel.album_title;
    model.artist_id     = songModel.artist_id;
    model.artist_name   = songModel.author;
    model.all_artist_id = songModel.all_artist_id;
    model.ting_uid      = songModel.ting_uid;
    model.pic_small     = songModel.pic_small;
    
    [kWYPlayerVC playMusicWithModel:model];
}

@end
