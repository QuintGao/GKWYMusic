//
//  GKWYPlayerViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/19.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYPlayerViewController.h"
#import "GKWYMusicCoverView.h"
#import "GKWYMusicLyricView.h"
#import "GKWYMusicControlView.h"
#import "GKWYMusicListView.h"
#import "CBAutoScrollLabel.h"
#import "GKTimer.h"
#import "GKWYArtistViewController.h"
#import "GKWYAlbumViewController.h"
#import "GKWYVideoViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface GKWYPlayerViewController ()<GKWYMusicCoverViewDelegate, GKWYMusicControlViewDelegate, GKWYMusicListViewDelegate, GKAudioPlayerDelegate, GKDownloadManagerDelegate>

/*****************UI**********************/
@property (nonatomic, strong) UIView                *titleView;
@property (nonatomic, strong) CBAutoScrollLabel     *nameLabel;
@property (nonatomic, strong) UILabel               *artistLabel;

@property (nonatomic, strong) UIImageView           *bgImageView;

@property (nonatomic, strong) GKWYMusicCoverView    *coverView;

/** 歌词视图 */
@property (nonatomic, strong) GKWYMusicLyricView    *lyricView;

@property (nonatomic, strong) GKWYMusicControlView  *controlView;

@property (nonatomic, strong) GKWYMusicListView     *listView; // 列表页

/**********************data*************************/

@property (nonatomic, strong) UIImage               *coverImage;
/** 音乐原始播放列表 */
@property (nonatomic, strong) NSArray               *musicList;
/** 当前播放的列表,包括乱序后的列表 */
@property (nonatomic, strong) NSArray               *playList;

@property (nonatomic, strong) GKWYMusicModel        *model;

@property (nonatomic, assign) BOOL                  isAutoPlay;     // 是否自动播放，用于切换歌曲
@property (nonatomic, assign) BOOL                  isDraging;      // 是否正在拖拽进度条
@property (nonatomic, assign) BOOL                  isSeeking;      // 是否在快进快退，锁屏时操作
@property (nonatomic, assign) BOOL                  isChanged;      // 是否正在切换歌曲，点击上一曲下一曲按钮
@property (nonatomic, assign) BOOL                  isCoverScroll;  // 是否转盘在滑动
@property (nonatomic, assign) BOOL                  isPaused;       // 是否点击暂停

@property (nonatomic, assign) BOOL                  isAppear;       // 是否显示播放器页
@property (nonatomic, assign) BOOL                  isInterrupt;    // 是否被打断

@property (nonatomic, assign) NSTimeInterval        duration;       // 总时间
@property (nonatomic, assign) NSTimeInterval        currentTime;    // 当前时间
@property (nonatomic, assign) NSTimeInterval        positionTime;   // 锁屏时的滑杆时间

@property (nonatomic, strong) NSTimer               *seekTimer;     // 快进、快退定时器

@property (nonatomic, assign) BOOL                  ifNowPlay;      // 是否立即播放

@property (nonatomic, assign) float                 toSeekProgress; // seek进度

@end

@implementation GKWYPlayerViewController

+ (instancetype)sharedInstance {
    static GKWYPlayerViewController *playerVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerVC = [GKWYPlayerViewController new];
    });
    return playerVC;
}

#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        [self.view addSubview:self.bgImageView];
        [self.view addSubview:self.coverView];
        [self.view addSubview:self.lyricView];
        [self.view addSubview:self.controlView];
        
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(170);
        }];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.gk_navigationBar.mas_bottom);
            make.bottom.equalTo(self.controlView.mas_top).offset(20);
        }];
        
        [self.lyricView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.gk_navigationBar.mas_bottom);
            make.bottom.equalTo(self.controlView.mas_top).offset(20);
        }];
        
        [self.coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLyricView)]];
        [self.lyricView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCoverView)]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    // 添加通知
    [self addNotifications];
    // 设置播放器的代理
    kPlayer.delegate                = self;
    // 禁用全屏滑动返回手势
    self.gk_fullScreenPopDisabled   = YES;
    
    // 锁屏控制(这里只能设置一次，多次设置事件也会调用多次)
    [self setupLockScreenControlInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    KDownloadManager.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [GKWYMusicTool hidePlayBtn];
    
    // 解决边缘滑动手势与UIScrollView滑动的冲突
    NSArray *gestures = self.navigationController.view.gestureRecognizers;
    
    for (UIGestureRecognizer *gesture in gestures) {
        if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [self.coverView.diskScrollView.panGestureRecognizer requireGestureRecognizerToFail:gesture];
        }
    }
    
    self.isAppear = YES;
    
    if (self.isPlaying) {
        [self.coverView playedWithAnimated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.nameLabel scrollLabelIfNeeded];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [GKWYMusicTool showPlayBtn];
    
    KDownloadManager.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.isAppear = NO;
    
    [self.nameLabel pausedScroll];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning");
}

#pragma mark - Public Methods
- (void)initialData {
    NSArray *musics = [GKWYMusicTool musicList];
    
    // 获取历史播放内容及进度
    NSDictionary *playInfo = [GKWYMusicTool lastMusicInfo];
    
    if (playInfo) { // 如果有播放记录列表肯定不会为空
        // 播放状态
        self.playStyle = [GKWYMusicTool playStyle];
        // 设置播放器列表
        [self setPlayerList:musics];
        
        // 获取索引，加载数据
        NSInteger index = [GKWYMusicTool indexFromID:playInfo[@"play_id"]];
        [self loadMusicWithIndex:index];
        
        self.toSeekProgress = [playInfo[@"play_progress"] floatValue];
    }else {
        [GKWYMusicTool hidePlayBtn];
    }
}

- (void)setPlayerList:(NSArray *)playList {
    self.musicList = playList;
    
    // 保存列表
    [GKWYMusicTool saveMusicList:playList];
    
    switch (self.playStyle) {
        case GKWYPlayerPlayStyleLoop:
        {
            self.playList = playList;
            [self setCoverList];
        }
            break;
        case GKWYPlayerPlayStyleOne:
        {
            self.playList = playList;
            [self setCoverList];
        }
            break;
        case GKWYPlayerPlayStyleRandom:
        {
            self.playList = [self randomArray:playList];
            [self setCoverList];
        }
            break;
            
        default:
            break;
    }
}

/**
 播放指定位置的音乐

 @param index 指定位置的索引
 @param isSetList 是否需要设置列表
 */
- (void)playMusicWithIndex:(NSInteger)index isSetList:(BOOL)isSetList {
    GKWYMusicModel *model = self.playList[index];
    
    if (![model.song_id isEqualToString:self.currentPlayId]) {
        self.currentPlayId = model.song_id;
        
        self.toSeekProgress = 0;
        
        self.ifNowPlay = YES;
        
        if (isSetList) {
            [self.coverView setMusicList:self.playList idx:index];
        }
        
        [kNotificationCenter postNotificationName:GKWYMUSIC_PLAYMUSICCHANGENOTIFICATION object:nil];
        
        self.model = model;
        
        [self getMusicInfo];
    }else {
        self.ifNowPlay = YES;
        
        if (self.isPlaying) return;
        
        if (model) {
            self.model = model;
            
            // 已下载，直接用下载数据播放
            if (self.model.isDownload) {
                [self getMusicInfo];
                return;
            }
            
            // 播放
            [self playMusic];
        }
    }
}

- (void)playMusicWithModel:(GKWYMusicModel *)model {
    NSMutableArray *playList = [NSMutableArray arrayWithArray:self.playList];
    
    __block NSInteger   index = 0;
    __block BOOL        exist = NO;
    
    [playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.song_id isEqualToString:model.song_id]) {
            index = idx;
            exist = YES;
            *stop = YES;
        }
    }];
    
    if (exist) {
        [self playMusicWithIndex:index isSetList:NO];
    }else {
        [playList addObject:model];
        
        [self setPlayerList:playList];
        
        index = [playList indexOfObject:model];
        
        [self playMusicWithIndex:index isSetList:YES];
    }
}

- (void)loadMusicWithIndex:(NSInteger)index {
    
    GKWYMusicModel *model = self.playList[index];
    
    if (![model.song_id isEqualToString:self.currentPlayId]) {

        // 设置coverView列表
        [self.coverView setMusicList:self.playList idx:index];
        
        self.currentPlayId = model.song_id;
        
        self.ifNowPlay = NO;
        
        [kNotificationCenter postNotificationName:GKWYMUSIC_PLAYMUSICCHANGENOTIFICATION object:nil];
        
        self.model = model;
        
        [self getMusicInfo];
    }
}

- (void)playMusic {
    // 首先检查网络状态
    NSString *networkState = [GKWYMusicTool networkState];
    if ([networkState isEqualToString:@"none"]) {
        [GKMessageTool showError:@"网络连接失败"];
        // 设置播放状态为暂停
        [self.controlView setupPauseBtn];
        return;
    }else {
        if (!kPlayer.playUrlStr) { // 没有播放地址
            // 需要重新请求
            [self getMusicInfo];
        }else {
            if (kPlayer.playerState == GKAudioPlayerStateStopped) {
                [kPlayer play];
            }else if (kPlayer.playerState == GKAudioPlayerStatePaused) {
                [kPlayer resume];
            }else {
                [kPlayer play];
            }
        }
    }
}

- (void)pauseMusic {
    [kPlayer pause];
}

- (void)stopMusic {
    [kPlayer stop];
}

- (void)playNextMusic {
    // 重置封面
    [self.coverView resetCoverView];
    
    // 播放
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {
        NSArray *musicList = self.playList;
        
        __block NSUInteger currentIndex = 0;
        [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.song_id isEqualToString:self.model.song_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playNextMusicWithIndex:currentIndex];
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) {
        if (self.isAutoPlay) {  // 循环播放自动播放完毕
            __block NSUInteger currentIndex = 0;
            
            [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.song_id isEqualToString:self.model.song_id]) {
                    currentIndex = idx;
                    *stop = YES;
                }
            }];
            
            // 重置列表
            [self.coverView resetMusicList:self.playList idx:currentIndex];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self playMusic];
            });
        }else {  // 循环播放切换歌曲
            __block NSUInteger currentIndex = 0;
            [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.song_id isEqualToString:self.model.song_id]) {
                    currentIndex = idx;
                    *stop = YES;
                }
            }];
            
            [self playNextMusicWithIndex:currentIndex];
        }
    }else {
        if (!self.playList) {
            self.playList = [self randomArray:self.musicList];
        }
        // 找出乱序后当前播放歌曲的索引
        __block NSInteger currentIndex = 0;
        
        [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.song_id isEqualToString:self.model.song_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playNextMusicWithIndex:currentIndex];
    }
}

- (void)playNextMusicWithIndex:(NSInteger)index {
    if (index < self.playList.count - 1) {
        index ++;
    }else {
        index = 0;
    }
    
    // 切换到下一首
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.coverView scrollChangeDiskIsNext:YES finished:^{
            [self playMusicWithIndex:index isSetList:YES];
        }];
    });
}

- (void)playPrevMusic {
    // 重置封面
    [self.coverView resetCoverView];
    
    // 播放
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {
        __block NSUInteger currentIndex = 0;
        [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.song_id isEqualToString:self.model.song_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playPrevMusicWithIndex:currentIndex];
        
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) {
        __block NSUInteger currentIndex = 0;
        [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.song_id isEqualToString:self.model.song_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playPrevMusicWithIndex:currentIndex];
    }else {
        if (!self.playList) {
            self.playList = [self randomArray:self.musicList];
        }
        // 找出乱序后当前播放歌曲的索引
        __block NSInteger currentIndex = 0;
        
        [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.song_id isEqualToString:self.model.song_id]) {
                currentIndex = idx;
                *stop = YES;
            }
        }];
        
        [self playPrevMusicWithIndex:currentIndex];
    }
}

- (void)playPrevMusicWithIndex:(NSInteger)index {
    // 列表已经打乱顺序，直接播放上一首一首即可
    if (index > 0) {
        index --;
    }else if (index == 0) {
        index = self.playList.count - 1;
    }
    
    // 切换到下一首
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.coverView scrollChangeDiskIsNext:NO finished:^{
            [self playMusicWithIndex:index isSetList:YES];
        }];
    });
}

- (NSArray *)randomArray:(NSArray *)arr {
    NSArray *randomArr = [arr sortedArrayUsingComparator:^NSComparisonResult(GKWYMusicModel *obj1, GKWYMusicModel *obj2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [obj1.song_id compare:obj2.song_id];
        }else {
            return [obj2.song_id compare:obj1.song_id];
        }
    }];
    
    return randomArr;
}

#pragma mark - Private Methods
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_navLineHidden = YES;
    self.gk_navRightBarButtonItem = [UIBarButtonItem itemWithImageName:@"cm2_topbar_icn_share" target:self action:@selector(shareAction)];
    
    // 获取播放方式，并设置
    self.playStyle = [kUserDefaults integerForKey:GKWYMUSIC_USERDEFAULTSKEY_PLAYSTYLE];
    self.controlView.style = self.playStyle;
    
    // 设置titleView
    self.titleView = [UIView new];
    self.titleView.frame = CGRectMake(0, 0, KScreenW - 160.0f, 44.0f);
    self.gk_navTitleView = self.titleView;
    
    self.nameLabel                  = [CBAutoScrollLabel new];
    self.nameLabel.frame            = CGRectMake(0, 0, KScreenW - 160.0f, 20);
    self.nameLabel.textColor        = [UIColor whiteColor];
    self.nameLabel.font             = [UIFont systemFontOfSize:15.0];
    self.nameLabel.textAlignment    = NSTextAlignmentCenter;
    self.nameLabel.labelSpacing     = 30.0f;
    self.nameLabel.pauseInterval    = 1.5f;
    self.nameLabel.fadeLength       = 1.5f;
    [self.titleView addSubview:self.nameLabel];
    
    self.artistLabel            = [UILabel new];
    self.artistLabel.textColor  = [UIColor whiteColor];
    self.artistLabel.font       = [UIFont systemFontOfSize:13.0];
    [self.titleView addSubview:self.artistLabel];
    
    self.nameLabel.gk_y         = 5;
    self.artistLabel.gk_y       = self.nameLabel.gk_bottom + 2;
}

- (void)showLyricView {
    self.lyricView.hidden = NO;
    [self.lyricView hideSystemVolumeView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.lyricView.alpha            = 1.0;
        
        self.coverView.alpha            = 0.0;
        self.controlView.topView.alpha  = 0.0;
    }completion:^(BOOL finished) {
        self.lyricView.hidden           = NO;
        self.coverView.hidden           = YES;
        self.controlView.topView.hidden = YES;
    }];
}

- (void)showCoverView {
    self.coverView.hidden           = NO;
    self.controlView.topView.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.lyricView.alpha            = 0.0;
        
        self.coverView.alpha            = 1.0;
        self.controlView.topView.alpha  = 1.0;
    }completion:^(BOOL finished) {
        self.lyricView.hidden           = YES;
        [self.lyricView showSystemVolumeView];
        self.coverView.hidden           = NO;
        self.controlView.topView.hidden = NO;
    }];
}

/**
 获取歌曲详细信息
 */
- (void)getMusicInfo {
    [self setupTitleWithModel:self.model];
    
    if (self.isPlaying || kPlayer.playerState == GKAudioPlayerStatePaused) {
        self.isPlaying = NO;
        [self stopMusic];
    }
    
    self.bgImageView.image = [UIImage imageNamed:@"cm2_fm_bg-ip6"];
    
    // 初始化数据
    self.lyricView.lyrics = nil;
    
    [self.controlView initialData];
    
    if (self.ifNowPlay) {
        [self.controlView showLoadingAnim];
    }
    
    self.controlView.is_love        = self.model.isLike;
    self.controlView.is_download    = self.model.isDownload;
    
    [self setupLockScreenMediaInfoNull];
    
    if (self.model.isDownload) {
        // 背景图
        NSData *imgData = [NSData dataWithContentsOfFile:self.model.song_imagePath];
        if (imgData) {
            self.bgImageView.image = [UIImage imageWithData:imgData];
        }
        
        [self resetCoverViewWithModel:self.model];
        
        [self setupTitleWithModel:self.model];
        
        NSInteger duration = self.model.file_duration.integerValue;
        // 总时间
        self.controlView.totalTime = [GKWYMusicTool timeStrWithSecTime:duration];
        
        if (self.toSeekProgress) {
            self.controlView.currentTime = [GKWYMusicTool timeStrWithSecTime:duration * self.toSeekProgress];
            
            self.controlView.progress = self.toSeekProgress;
        }
        
        // 设置播放地址
        kPlayer.playUrlStr = self.model.song_localPath;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.ifNowPlay) {
                [kPlayer play];
            }
        });
        
        // 解析歌词
        self.lyricView.lyrics = [GKLyricParser lyricParserWithUrl:self.model.song_lyricPath isDelBlank:YES];
    }else {
        NSString *networkState = [GKWYMusicTool networkState];
        if ([networkState isEqualToString:@"none"]) {
            [GKMessageTool showTips:@"网络连接失败"];
            
            return;
        }
        
        // 获取歌曲信息
        NSString *api = [NSString stringWithFormat:@"baidu.ting.song.play&songid=%@", self.model.song_id];
        
        [kHttpManager get:api params:nil successBlock:^(id responseObject) {
            self.model = [GKWYMusicModel yy_modelWithDictionary:responseObject[@"songinfo"]];
            
            NSDictionary *bitrate = responseObject[@"bitrate"];
            self.model.file_link        = bitrate[@"file_link"];
            self.model.file_duration    = bitrate[@"file_duration"];
            self.model.file_size        = bitrate[@"file_size"];
            self.model.file_extension   = bitrate[@"file_extension"];
            
            // 背景图片
            [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.model.pic_radio] placeholderImage:[UIImage imageNamed:@"cm2_fm_bg-ip6"]];
            
            [self resetCoverViewWithModel:self.model];
            
            [self setupTitleWithModel:self.model];
            
            NSInteger duration = self.model.file_duration.integerValue;
            // 总时间
            self.controlView.totalTime = [GKWYMusicTool timeStrWithSecTime:duration];
            
            if (self.toSeekProgress) {
                self.controlView.currentTime = [GKWYMusicTool timeStrWithSecTime:duration * self.toSeekProgress];
                
                self.controlView.progress = self.toSeekProgress;
            }
            
            // 设置播放地址
            kPlayer.playUrlStr = self.model.file_link;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if (self.ifNowPlay) {
                    [kPlayer play];
                }
            });
            
            // 解析歌词
            self.lyricView.lyrics = [GKLyricParser lyricParserWithUrl:self.model.lrclink isDelBlank:YES];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"获取详情失败==%@", error);
            [GKMessageTool showError:@"数据请求失败，请检查网络后重试！"];
        }];
    }
}

- (void)setupTitleWithModel:(GKWYMusicModel *)model {
    [self.nameLabel setText:model.song_name refreshLabels:YES];
    self.artistLabel.text = model.artist_name;
    
    self.nameLabel.gk_centerX = self.titleView.gk_width * 0.5;
    
    [self.artistLabel sizeToFit];
    self.artistLabel.gk_y       = self.nameLabel.gk_bottom + 2;
    self.artistLabel.gk_centerX = self.titleView.gk_width * 0.5;
}

- (void)resetCoverViewWithModel:(GKWYMusicModel *)model {
    __block NSInteger   index = 0;
    __block BOOL        exist = NO;
    
    NSMutableArray *musicList = [NSMutableArray arrayWithArray:self.musicList];
    
    [musicList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.song_id isEqualToString:model.song_id]) {
            exist = YES;
            index = idx;
            *stop = YES;
        }
    }];
    
    // 更新数据
    if (exist) {
        [musicList replaceObjectAtIndex:index withObject:model];
        
        [self setPlayerList:musicList];
    }
}

- (void)addNotifications {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // 插拔耳机
    [kNotificationCenter addObserver:self selector:@selector(audioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    // 播放打断
    [kNotificationCenter addObserver:self selector:@selector(audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)removeNotifications {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [kNotificationCenter removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [kNotificationCenter removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)shareAction {
    [GKMessageTool showText:@"点击分享"];
}

- (void)setupLockScreenControlInfo {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // 锁屏播放
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"锁屏暂停后点击播放");
        if (!self.isPlaying) {
            [self playMusic];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 锁屏暂停
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"锁屏正在播放点击后暂停");
        
        if (self.isPlaying) {
            [self pauseMusic];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [commandCenter.stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pauseMusic];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 播放和暂停按钮（耳机控制）
    MPRemoteCommand *playPauseCommand = commandCenter.togglePlayPauseCommand;
    playPauseCommand.enabled = YES;
    [playPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        if (self.isPlaying) {
            [self pauseMusic];
        }else {
            [self playMusic];
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 上一曲
    MPRemoteCommand *previousCommand = commandCenter.previousTrackCommand;
    [previousCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        [self playPrevMusic];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 下一曲
    MPRemoteCommand *nextCommand = commandCenter.nextTrackCommand;
    nextCommand.enabled = YES;
    [nextCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        self.isAutoPlay = NO;
        
        if (self.isPlaying) {
            [self stopMusic];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.isChanged  = YES;
            
            [self playNextMusic];
        });
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 快进
    MPRemoteCommand *forwardCommand = commandCenter.seekForwardCommand;
    forwardCommand.enabled = YES;
    [forwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        MPSeekCommandEvent *seekEvent = (MPSeekCommandEvent *)event;
        if (seekEvent.type == MPSeekCommandEventTypeBeginSeeking) {
            [self seekingForwardStart];
        }else {
            [self seekingForwardStop];
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 快退
    MPRemoteCommand *backwardCommand = commandCenter.seekBackwardCommand;
    backwardCommand.enabled = YES;
    [backwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        MPSeekCommandEvent *seekEvent = (MPSeekCommandEvent *)event;
        if (seekEvent.type == MPSeekCommandEventTypeBeginSeeking) {
            [self seekingBackwardStart];
        }else {
            [self seekingBackwardStop];
        }
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 拖动进度条
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            
            MPChangePlaybackPositionCommandEvent *positionEvent = (MPChangePlaybackPositionCommandEvent *)event;
            
            if (positionEvent.positionTime != self.positionTime) {
                self.positionTime = positionEvent.positionTime;
                
                self.currentTime = self.positionTime * 1000;
                
                [kPlayer setPlayerProgress:((float)self.currentTime / self.duration)];
            }
            
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)setupLockScreenMediaInfo {
    MPNowPlayingInfoCenter *playingCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    NSMutableDictionary *playingInfo = [NSMutableDictionary new];
    playingInfo[MPMediaItemPropertyAlbumTitle] = self.model.album_title;
    playingInfo[MPMediaItemPropertyTitle]      = self.model.song_name;
    playingInfo[MPMediaItemPropertyArtist]     = self.model.artist_name;
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.bgImageView.image];
    playingInfo[MPMediaItemPropertyArtwork] = artwork;
    
    // 当前播放的时间
    playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithFloat:(self.duration * self.controlView.progress) / 1000];
    // 进度的速度
    playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = [NSNumber numberWithFloat:1.0];
    // 总时间
    playingInfo[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithFloat:self.duration / 1000];
    if (@available(iOS 10.0, *)) {
        playingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = [NSNumber numberWithFloat:self.controlView.progress];
    } else {
        // Fallback on earlier versions
    }
    playingCenter.nowPlayingInfo = playingInfo;
}

- (void)setupLockScreenMediaInfoNull {
    
    MPNowPlayingInfoCenter *playingCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    NSMutableDictionary *playingInfo = [NSMutableDictionary new];
    playingInfo[MPMediaItemPropertyAlbumTitle] = self.model.album_title;
    playingInfo[MPMediaItemPropertyTitle]      = self.model.song_name;
    playingInfo[MPMediaItemPropertyArtist]     = self.model.artist_name;
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"cm2_default_cover_fm"]];
    playingInfo[MPMediaItemPropertyArtwork] = artwork;
    
    // 当前播放的时间
    playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithFloat:(self.duration * self.controlView.progress) / 1000];
    // 进度的速度
    playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = [NSNumber numberWithFloat:1.0];
    // 总时间
    playingInfo[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithFloat:self.duration / 1000];
    if (@available(iOS 10.0, *)) {
        playingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = [NSNumber numberWithFloat:self.controlView.progress];
    } else {
        // Fallback on earlier versions
    }
    playingCenter.nowPlayingInfo = playingInfo;
}

- (void)lovedCurrentMusic {
    
    self.model.isLove = !self.model.isLove;
    
    [GKWYMusicTool loveMusic:self.model];
    
    self.controlView.is_love = self.model.isLike;
    
    [kNotificationCenter postNotificationName:GKWYMUSIC_LOVEMUSICNOTIFICATION object:nil];
}

#pragma mark - 快进快退方法

// 快进开始
- (void)seekingForwardStart {
    if (!self.isPlaying) return;
    self.isSeeking = YES;
    
    self.currentTime = self.controlView.progress * self.duration;
    
    self.seekTimer = [GKTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(seekingForwardAction) userInfo:nil repeats:YES];
}

// 快进结束
- (void)seekingForwardStop {
    if (!self.isPlaying) return;
    if (!self.seekTimer) return;
    
    self.isSeeking = NO;
    [self seekTimeInvalidated];
    
    [kPlayer setPlayerProgress:((float)self.currentTime / self.duration)];
}

- (void)seekingForwardAction {
    if (self.currentTime >= self.duration) {
        [self seekTimeInvalidated];
    }else {
        self.currentTime += 1000;
        
        self.controlView.progress = self.duration == 0 ? 0 : (float)self.currentTime / self.duration;
        
        self.controlView.currentTime = [GKWYMusicTool timeStrWithMsTime:self.currentTime];
    }
}

// 快退开始
- (void)seekingBackwardStart {
    if (!self.isPlaying) return;
    
    self.isSeeking   = YES;
    
    self.currentTime = self.controlView.progress * self.duration;
    
    self.seekTimer = [GKTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(seekingBackwardAction) userInfo:nil repeats:YES];
}

// 快退结束
- (void)seekingBackwardStop {
    if (!self.isPlaying) return;
    if (!self.seekTimer) return;
    
    self.isSeeking = NO;
    
    [self seekTimeInvalidated];
    
    [kPlayer setPlayerProgress:((float)self.currentTime / self.duration)];
}

- (void)seekingBackwardAction {
    if (self.currentTime <= 0) {
        [self seekTimeInvalidated];
    }else {
        self.currentTime-= 1000;
        
        self.controlView.progress = self.duration == 0 ? 0 : (float)self.currentTime / self.duration;
        
        self.controlView.currentTime = [GKWYMusicTool timeStrWithMsTime:self.currentTime];
    }
}

- (void)seekTimeInvalidated {
    if (self.seekTimer) {
        [self.seekTimer invalidate];
        self.seekTimer = nil;
    }
}

#pragma mark - Notifications
- (void)audioSessionRouteChange:(NSNotification *)notify {
    NSDictionary *interuptionDict = notify.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"耳机插入");
            // 继续播放音频，什么也不用做
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            NSLog(@"耳机拔出");
            // 注意：拔出耳机时系统会自动暂停你正在播放的音频，因此只需要改变UI为暂停状态即可
            if (self.isPlaying) {
                [self pauseMusic];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)audioSessionInterruption:(NSNotification *)notify {
    NSDictionary *interuptionDict = notify.userInfo;
    
    NSInteger interruptionType = [interuptionDict[AVAudioSessionInterruptionTypeKey] integerValue];
    NSInteger interruptionOption = [interuptionDict[AVAudioSessionInterruptionOptionKey] integerValue];
    
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        // 收到播放中断的通知，暂停播放
        if (self.isPlaying) {
            self.isInterrupt = YES;
            [self pauseMusic];
            self.isPlaying = NO;
        }
    }else if (interruptionType == AVAudioSessionInterruptionTypeEnded){
        if (self.isInterrupt) {
            self.isInterrupt = NO;
            // 中断结束，判断是否需要恢复播放
            if (interruptionOption == AVAudioSessionInterruptionOptionShouldResume) {
                if (!self.isPlaying) {
                    [self playMusic];
                    self.isPlaying = YES;
                }
            }
        }
    }
}

#pragma mark - 代理
#pragma mark - GKPlayerDelegate
// 播放状态改变
- (void)gkPlayer:(GKAudioPlayer *)player statusChanged:(GKAudioPlayerState)status {
    switch (status) {
        case GKAudioPlayerStateLoading:{    // 加载中
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView showLoadingAnim];
                [self.controlView setupPauseBtn];
                [self.coverView playedWithAnimated:YES];
            });
            self.isPlaying = NO;
        }
            break;
        case GKAudioPlayerStateBuffering: { // 缓冲中
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView hideLoadingAnim];
                [self.controlView setupPlayBtn];
                [self.coverView playedWithAnimated:YES];
                
                if (self.isAppear) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.nameLabel scrollLabelIfNeeded];
                    });
                }
            });
            
            self.isPlaying = YES;
        }
            break;
        case GKAudioPlayerStatePlaying: {   // 播放中
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView hideLoadingAnim];
                [self.controlView setupPlayBtn];
                [self.coverView playedWithAnimated:YES];
            });
            
            if (self.toSeekProgress > 0) {
                [kPlayer setPlayerProgress:self.toSeekProgress];
                
                self.toSeekProgress = 0;
            }
            
            self.isPlaying = YES;
        }
            break;
        case GKAudioPlayerStatePaused:{     // 暂停
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView hideLoadingAnim];
                [self.controlView setupPauseBtn];
                if (self.isChanged) {
                    self.isChanged = NO;
                }else {
                    [self.coverView pausedWithAnimated:YES];
                }
            });
            self.isPlaying = NO;
        }
            break;
        case GKAudioPlayerStateStoppedBy:{  // 主动停止
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView hideLoadingAnim];
                [self.controlView setupPauseBtn];
                
                if (self.isChanged) {
                    self.isChanged = NO;
                }else {
                    NSLog(@"播放停止后暂停动画");
                    [self.coverView pausedWithAnimated:YES];
                }
            });
            self.isPlaying = NO;
        }
            break;
        case GKAudioPlayerStateStopped:{    // 打断停止
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView hideLoadingAnim];
                [self.controlView setupPauseBtn];
                [self.coverView pausedWithAnimated:YES];
                
                [self pauseMusic];
            });
            self.isPlaying = NO;
        }
            break;
        case GKAudioPlayerStateEnded: {     // 播放结束
            NSLog(@"播放结束了");
            if (self.isPlaying) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.controlView hideLoadingAnim];
                    [self.controlView setupPauseBtn];
                    [self.coverView pausedWithAnimated:YES];
                    self.controlView.currentTime = self.controlView.totalTime;
                });
                
                self.isPlaying = NO;
                
                // 播放结束，自动播放下一首
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.isAutoPlay = YES;
                    
                    [self playNextMusic];
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.controlView hideLoadingAnim];
                    [self.controlView setupPauseBtn];
                    [self.coverView pausedWithAnimated:YES];
                });
                
                self.isPlaying = NO;
            }
        }
            break;
        case GKAudioPlayerStateError: {     // 播放出错
            NSLog(@"播放出错了");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.controlView hideLoadingAnim];
                [self.controlView setupPauseBtn];
                [self.coverView pausedWithAnimated:YES];
            });
            self.isPlaying = NO;
        }
            break;
        default:
            break;
    }
    
    [kNotificationCenter postNotificationName:GKWYMUSIC_PLAYSTATECHANGENOTIFICATION object:nil];
}

// 播放进度改变
- (void)gkPlayer:(GKAudioPlayer *)player currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime progress:(float)progress {
    
    // 记录播放id和进度
    NSDictionary *dic = @{@"play_id": self.currentPlayId, @"play_progress": @(progress)};
    [kUserDefaults setObject:dic forKey:GKWYMUSIC_USERDEFAULTSKEY_PLAYINFO];
    
    if (self.isDraging) return;
    if (self.isSeeking) return;
    
    if (self.toSeekProgress > 0) {
        progress = self.toSeekProgress;
    }
    
    self.controlView.currentTime = [GKWYMusicTool timeStrWithMsTime:currentTime];
    self.controlView.progress    = progress;
    
    // 更新锁屏信息
    [self setupLockScreenMediaInfo];
    
    // 歌词滚动
    if (!self.isPlaying) return;
    
    [self.lyricView scrollLyricWithCurrentTime:currentTime totalTime:totalTime];
}

// 播放总时间
- (void)gkPlayer:(GKAudioPlayer *)player totalTime:(NSTimeInterval)totalTime {
    self.controlView.totalTime = [GKWYMusicTool timeStrWithMsTime:totalTime];
    
    self.duration               = totalTime;
}

// 缓冲进度改变
- (void)gkPlayer:(GKAudioPlayer *)player bufferProgress:(float)bufferProgress {
    self.controlView.bufferProgress = bufferProgress;
}

#pragma mark - GKWYMusicControlViewDelegate
- (void)controlView:(GKWYMusicControlView *)controlView didClickLove:(UIButton *)loveBtn {
    [self lovedCurrentMusic];
    
    if (self.model.isLike) {
        [GKMessageTool showSuccess:@"已添加到我喜欢的音乐" toView:self.view imageName:@"cm2_play_icn_loved" bgColor:[UIColor blackColor]];
    }else {
        [GKMessageTool showText:@"已取消喜欢" toView:self.view bgColor:[UIColor blackColor]];
    }
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickDownload:(UIButton *)downloadBtn {
    NSLog(@"下载");
    if (self.model.isDownload) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"该歌曲已下载，是否删除下载文件？" preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            GKDownloadModel *dModel = [GKDownloadModel new];
            dModel.fileID = self.model.song_id;
            
            [KDownloadManager removeDownloadArr:@[dModel]];
        }]];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }else {
        [GKWYMusicTool downloadMusicWithSongId:self.model.song_id];
    }
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickComment:(UIButton *)commentBtn {
    NSLog(@"评论");
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickMore:(UIButton *)moreBtn {
    NSLog(@"更多");
    NSMutableArray *items = [NSMutableArray new];
    
    GKActionSheetItem *shareItem = [GKActionSheetItem new];
    shareItem.title = @"分享";
    shareItem.imgName = @"cm2_lay_icn_share_new";
    shareItem.enabled = YES;
    shareItem.clickBlock = ^{
        [GKMessageTool showText:@"分享"];
    };
    [items addObject:shareItem];
    
    GKActionSheetItem *artistItem = [GKActionSheetItem new];
    artistItem.title = [NSString stringWithFormat:@"歌手：%@", self.model.artist_name];
    artistItem.imgName = @"cm2_lay_icn_artist_new";
    artistItem.enabled = YES;
    artistItem.clickBlock = ^{
        [self pushToArtistVC];
    };
    [items addObject:artistItem];
    
    GKActionSheetItem *albumItem = [GKActionSheetItem new];
    albumItem.title         = [NSString stringWithFormat:@"专辑：%@", self.model.album_title];
    albumItem.imgName       = @"cm2_lay_icn_alb_new";
    albumItem.enabled       = YES;
    albumItem.clickBlock    = ^{
        [self pushToAlbumVC];
    };
    [items addObject:albumItem];
    
    if (self.model.has_mv) {
        GKActionSheetItem *mvItem = [GKActionSheetItem new];
        mvItem.title = @"查看MV";
        mvItem.imgName = @"cm2_lay_icn_mv_new";
        mvItem.enabled = YES;
        mvItem.clickBlock = ^{
            GKWYVideoViewController *videoVC = [GKWYVideoViewController new];
            videoVC.song_id = self.model.song_id;
            [self.navigationController pushViewController:videoVC animated:YES];
        };
        [items addObject:mvItem];
    }
    
    NSString *title = [NSString stringWithFormat:@"歌曲:%@", self.model.song_name];
    
    [GKActionSheet showActionSheetWithTitle:title itemInfos:items];
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickLoop:(UIButton *)loopBtn {
    if (self.playStyle == GKWYPlayerPlayStyleLoop) {  // 循环->单曲
        self.playStyle = GKWYPlayerPlayStyleOne;
        
        self.playList  = self.musicList;
        
        [self setCoverList];
    }else if (self.playStyle == GKWYPlayerPlayStyleOne) { // 单曲->随机
        self.playStyle = GKWYPlayerPlayStyleRandom;
        
        self.playList  = [self randomArray:self.musicList];
        
        [self setCoverList];
    }else { // 随机-> 循环
        self.playStyle = GKWYPlayerPlayStyleLoop;
        
        self.playList  = self.musicList;
        
        [self setCoverList];
    }
    self.controlView.style = self.playStyle;
    
    [kUserDefaults setInteger:self.playStyle forKey:GKWYMUSIC_USERDEFAULTSKEY_PLAYSTYLE];
}

- (void)setCoverList {
    __block NSUInteger currentIndex = 0;
    
    [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.song_id isEqualToString:self.model.song_id]) {
            currentIndex = idx;
            *stop = YES;
        }
    }];
    
    // 重置列表
    [self.coverView resetMusicList:self.playList idx:currentIndex];
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickPrev:(UIButton *)prevBtn {
    if (self.isCoverScroll) return;
    self.isChanged = YES;
    
    if (self.isPlaying) {
        [self stopMusic];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playPrevMusic];
    });
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickPlay:(UIButton *)playBtn {
    if (self.isPlaying) {
        [self pauseMusic];
    }else {
        [self playMusic];
    }
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickNext:(UIButton *)nextBtn {
    if (self.isCoverScroll) return;
    
    self.isAutoPlay = NO;
    
    if (self.isPlaying) {
        [self stopMusic];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.isChanged  = YES;
        
        [self playNextMusic];
    });
}

- (void)controlView:(GKWYMusicControlView *)controlView didClickList:(UIButton *)listBtn {
    
    self.listView.gk_size = CGSizeMake(self.view.gk_width, 440);
    self.listView.listArr = self.musicList; // 显示原始播放数据

    [GKCover coverFrom:self.navigationController.view
           contentView:self.listView
                 style:GKCoverStyleTranslucent
             showStyle:GKCoverShowStyleBottom
         showAnimStyle:GKCoverShowAnimStyleBottom
         hideAnimStyle:GKCoverHideAnimStyleBottom
              notClick:NO
             showBlock:^{
        self.gk_interactivePopDisabled = YES;
    } hideBlock:^{
        self.gk_interactivePopDisabled = NO;
    }];
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTouchBegan:(float)value {
    self.isDraging = YES;
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTouchEnded:(float)value {
    self.isDraging = NO;
    
    if (self.isPlaying) {
        [kPlayer setPlayerProgress:value];
    }else {
        self.toSeekProgress = value;
    }
    
    // 滚动歌词到对应位置
    [self.lyricView scrollLyricWithCurrentTime:(self.duration * value) totalTime:self.duration];
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderValueChange:(float)value {
    self.isDraging = YES;
    self.controlView.currentTime = [GKWYMusicTool timeStrWithMsTime:(self.duration * value)];
}

- (void)controlView:(GKWYMusicControlView *)controlView didSliderTapped:(float)value {
    self.controlView.currentTime = [GKWYMusicTool timeStrWithMsTime:(self.duration * value)];
    
    if (self.isPlaying) {
        [kPlayer setPlayerProgress:value];
    }else {
        self.toSeekProgress = value;
    }
    
    // 滚动歌词到对应位置
    [self.lyricView scrollLyricWithCurrentTime:(self.duration * value) totalTime:self.duration];
}

#pragma mark - GKWYMusicCoverViewDelegate
- (void)scrollDidScroll {
    self.isCoverScroll = YES;
}

- (void)scrollWillChangeModel:(GKWYMusicModel *)model {
    [self setupTitleWithModel:model];
}

- (void)scrollDidChangeModel:(GKWYMusicModel *)model {
    self.isCoverScroll = NO;

    if (self.isChanged) return;
    
    [self setupTitleWithModel:model];
    
    if ([model.song_id isEqualToString:self.model.song_id]) {
        if (self.isPlaying) {
            [self.coverView playedWithAnimated:YES];
        }
    }else {
        __block NSInteger index = 0;
        
        [self.playList enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.song_id isEqualToString:model.song_id]) {
                index = idx;
            }
        }];
        
        self.isChanged = YES;
        
        [self playMusicWithIndex:index isSetList:NO];
    }
}

#pragma mark - GKWYMusicListViewDelegate
- (void)listViewDidClose:(GKWYMusicListView *)listView {
    [GKCover hideCover];
}

- (void)listView:(GKWYMusicListView *)listView didSelectRow:(NSInteger)row {
    [self playMusicWithIndex:row isSetList:NO];
} 

- (void)listView:(GKWYMusicListView *)listView didLovedWithRow:(NSInteger)row {
    GKWYMusicModel *model = self.playList[row];
    model.isLike = !model.isLike;

    [GKWYMusicTool saveModel:model];

    if ([model.song_id isEqualToString:self.model.song_id]) {
        self.model = model;
        self.controlView.is_love = model.isLike;
    }

    listView.listArr = self.playList;

    [kNotificationCenter postNotificationName:GKWYMUSIC_LOVEMUSICNOTIFICATION object:nil];
}

#pragma mark - GKDownloadManagerDelegate
- (void)gkDownloadManager:(GKDownloadManager *)downloadManager downloadModel:(GKDownloadModel *)downloadModel stateChanged:(GKDownloadManagerState)state {
    // 下载的是当前播放的
    if ([self.model.song_id isEqualToString:downloadModel.fileID]) {
        if (state == GKDownloadManagerStateFinished) { // 下载完成
            dispatch_async(dispatch_get_main_queue(), ^{
                // 下载图片和歌词
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadModel.fileCover]];
                [imgData writeToFile:downloadModel.fileImagePath atomically:YES];
                
                // 歌词
                NSData *lrcData = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadModel.fileLyric]];
                [lrcData writeToFile:downloadModel.fileLyricPath atomically:YES];
                
                // 改变状态
                self.controlView.is_download = self.model.isDownload;
            });
        }
    }
}

- (void)pushToArtistVC {
    NSArray *tinguids = [self.model.all_artist_ting_uid componentsSeparatedByString:@","];
    NSArray *artists  = [self.model.all_artist_id componentsSeparatedByString:@","];
    if (tinguids.count == artists.count && tinguids.count > 1) {
        NSMutableArray *items = [NSMutableArray new];
        NSArray *titles = [self.model.artist_name componentsSeparatedByString:@","];
        
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

- (void)pushToAlbumVC {
    GKWYAlbumViewController *albumVC = [GKWYAlbumViewController new];
    albumVC.album_id = self.model.album_id;
    [self.navigationController pushViewController:albumVC animated:YES];
}

#pragma mark - 懒加载
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView                        = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.contentMode            = UIViewContentModeScaleAspectFill;
        _bgImageView.userInteractionEnabled = NO;
        _bgImageView.clipsToBounds          = YES;
        // 添加模糊效果
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectView.frame = _bgImageView.bounds;
        [_bgImageView addSubview:effectView];
    }
    return _bgImageView;
}

- (GKWYMusicCoverView *)coverView {
    if (!_coverView) {
        _coverView = [GKWYMusicCoverView new];
        _coverView.delegate = self;
    }
    return _coverView;
}

- (GKWYMusicLyricView *)lyricView {
    if (!_lyricView) {
        _lyricView = [GKWYMusicLyricView new];
        _lyricView.backgroundColor = [UIColor clearColor];
        _lyricView.hidden = YES;
    }
    return _lyricView;
}

- (GKWYMusicControlView *)controlView {
    if (!_controlView) {
        _controlView = [GKWYMusicControlView new];
        _controlView.delegate = self;
    }
    return _controlView;
}

- (GKWYMusicListView *)listView {
    if (!_listView) {
        _listView = [GKWYMusicListView new];
        _listView.delegate = self;
    }
    return _listView;
}

@end
