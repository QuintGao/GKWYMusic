//
//  GKWYVideoViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/29.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYVideoViewController.h"
#import "GKWYVideoDetailModel.h"
#import "GKVideoPlayer.h"


@interface GKWYVideoViewController ()

@property (nonatomic, strong) GKVideoPlayer         *player;

@property (nonatomic, strong) GKWYVideoDetailModel  *videoModel;

@property (nonatomic, assign) BOOL                  isPausedMusic;

@end

@implementation GKWYVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.player];
    
    [self getVideoDetail];
}

- (void)getVideoDetail {
    NSString *api = nil;
    
    if (self.song_id) {
        api = [NSString stringWithFormat:@"baidu.ting.mv.playMV&song_id=%@", self.song_id];
    }else {
        api = [NSString stringWithFormat:@"baidu.ting.mv.playMV&mv_id=%@", self.mv_id];
    }
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.videoModel = [GKWYVideoDetailModel yy_modelWithDictionary:responseObject[@"result"]];
        
        [self.player prepareWithModel:self.videoModel.video_file];
        
        [self.player play];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GKWYMusicTool hidePlayBtn];
    
    if (kWYPlayerVC.isPlaying) {
        self.isPausedMusic = YES;
        [kWYPlayerVC pauseMusic];
    }
    
    self.gk_fullScreenPopDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!kWYPlayerVC.isPlaying && self.isPausedMusic) {
        [kWYPlayerVC playMusic];
    }
}

#pragma mark - 懒加载
- (GKVideoPlayer *)player {
    if (!_player) {
        _player = [[GKVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenW * 9 / 16)];
    }
    return _player;
}

@end
