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
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <ZFPlayer/ZFAVPlayerManager.h>

@interface GKWYVideoViewController ()

//@property (nonatomic, strong) GKVideoPlayer         *player;

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) UIImageView *containerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic, strong) GKWYVideoDetailModel  *videoModel;

@property (nonatomic, assign) BOOL                  isPausedMusic;

@end

@implementation GKWYVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.containerView];
    
    [self getVideoDetail];
    [self setupPlayer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.containerView.frame = self.view.bounds;
}

- (void)getVideoDetail {
    NSString *api = [NSString stringWithFormat:@"mv/url?id=%@", self.mv_id];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            self.videoModel = [GKWYVideoDetailModel yy_modelWithDictionary:responseObject[@"data"]];
            self.model.playUrl = self.videoModel.url;
            [self.containerView sd_setImageWithURL:[NSURL URLWithString:self.model.imgurl16v9]];
            self.player.assetURL = [NSURL URLWithString:self.model.playUrl];
        }
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

- (void)setupPlayer {
    ZFAVPlayerManager *manager = [[ZFAVPlayerManager alloc] init];
    manager.shouldAutoPlay = YES;
    
    /// 播放器相关
    self.player = [ZFPlayerController playerWithPlayerManager:manager containerView:self.containerView];
    self.player.controlView = self.controlView;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 懒加载
- (UIImageView *)containerView {
    if (!_containerView) {
        _containerView = [[UIImageView alloc] init];
    }
    return _containerView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ZFPlayerControlView alloc] init];
        _controlView.showCustomStatusBar = YES;
    }
    return _controlView;
}

@end
