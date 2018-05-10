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

- (void)setSongs:(NSArray *)songs {
    _songs = songs;
    
    [self gk_reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYSongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSongViewCellID forIndexPath:indexPath];
    cell.model = self.songs[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYSongModel *songModel = self.songs[indexPath.row];
    
    GKWYMusicModel *model = [GKWYMusicModel new];
    model.song_id       = songModel.songid;
    model.song_name     = songModel.songname;
    model.artist_name   = songModel.artistname;
    
    [kWYPlayerVC playMusicWithModel:model];
}

@end
