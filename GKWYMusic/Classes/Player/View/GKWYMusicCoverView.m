//
//  GKWYMusicCoverView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMusicCoverView.h"
#import "GKWYDiskView.h"

@interface GKWYMusicCoverView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView            *lineView;

@property (nonatomic, strong) UIView            *diskBgView;

/** 唱片试图 */
@property (nonatomic, strong) GKWYDiskView      *leftDiskView;
@property (nonatomic, strong) GKWYDiskView      *centerDiskView;
@property (nonatomic, strong) GKWYDiskView      *rightDiskView;

/** 指针 */
@property (nonatomic, strong) UIImageView       *needleView;

/** 定时器 */
@property (nonatomic, strong) CADisplayLink     *displayLink;

/** 音乐列表 */
@property (nonatomic, strong) NSArray           *musics;

@property (nonatomic, assign) NSInteger         currentIndex;

/** 当前是否在动画 */
@property (nonatomic, assign) BOOL              isAnimation;
/** 是否由用户点击切换歌曲 */
@property (nonatomic, assign) BOOL              isUserChanged;

@property (nonatomic, copy)   finished          finished;

@end

@implementation GKWYMusicCoverView

- (instancetype)init {
    if (self = [super init]) {
        // 超出部分裁剪
        self.clipsToBounds = YES;
        
        [self addSubview:self.lineView];
        [self addSubview:self.diskBgView];
        [self addSubview:self.diskScrollView];
        [self addSubview:self.needleView];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(0.5f);
        }];
        
        [self.diskBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(66.0f - 2.5f);
            make.width.height.mas_equalTo(KScreenW - 75.0f);
        }];
        
        [self.diskScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.isAnimation = YES;
        
        [self setScrollViewContentOffsetCenter];
        
        [kNotificationCenter addObserver:self selector:@selector(networkChanged:) name:GKWYMUSIC_NETWORKCHANGENOTIFICATION object:nil];
    }
    return self;
}

- (void)networkChanged:(NSNotification *)notify {
    self.currentIndex = self.currentIndex;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.needleView.gk_centerX = KScreenW * 0.5 + 25.0f;
    self.needleView.gk_y       = -25.0f;
    
    [self pausedWithAnimated:NO];
    
    CGFloat diskW = CGRectGetWidth(self.diskScrollView.frame);
    CGFloat diskH = CGRectGetHeight(self.diskScrollView.frame);
    
    // 设置frame
    self.leftDiskView.frame     = CGRectMake(0, 0, diskW, diskH);
    self.centerDiskView.frame   = CGRectMake(diskW, 0, diskW, diskH);
    self.rightDiskView.frame    = CGRectMake(2 * diskW, 0, diskW, diskH);
}

#pragma mark - Public Methods
- (void)initMusicList:(NSArray *)musics idx:(NSInteger)currentIndex {
    [self resetCoverView];
    
    self.musics = musics;
    
    [self setCurrentIndex:currentIndex needChange:YES];
}

- (void)resetMusicList:(NSArray *)musics idx:(NSInteger)currentIndex {
    self.musics = musics;
    
    [self setCurrentIndex:currentIndex needChange:NO];
}

// 滑动切换歌曲
- (void)scrollChangeDiskIsNext:(BOOL)isNext finished:(finished)finished {
    self.isUserChanged = YES;
    
    self.finished = finished;
    
    CGFloat pointX = isNext ? 2 * KScreenW : 0;
    CGPoint offset = CGPointMake(pointX, 0);
    
    [self pausedWithAnimated:YES];
    
    [self.diskScrollView setContentOffset:offset animated:YES];
}

// 播放音乐时，指针恢复，图片旋转
- (void)playedWithAnimated:(BOOL)animated {
    if (self.isAnimation) return;
    NSLog(@"开始旋转");
    self.isAnimation = YES;
    
    [self setAnchorPoint:CGPointMake(25.0f / 97.0f, 25.0f / 153.0f) forView:self.needleView];
    
    if (animated) {
        [UIView animateWithDuration:0.5f animations:^{
            self.needleView.transform = CGAffineTransformIdentity;
        }];
    }else {
        self.needleView.transform = CGAffineTransformIdentity;
    }
    
    // 创建定时器
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(diskAnimation)];
    // 加入到主循环中
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    NSLog(@"旋转定时器创建成功");
}

// 暂停音乐时，指针旋转-30°，图片停止旋转
- (void)pausedWithAnimated:(BOOL)animated {
    if (!self.isAnimation) return;
    NSLog(@"停止旋转");
    self.isAnimation = NO;
    
    [self setAnchorPoint:CGPointMake(25.0f / 97.0f, 25.0f / 153.0f) forView:self.needleView];
    
    if (animated) {
        [UIView animateWithDuration:0.5f animations:^{
            self.needleView.transform = CGAffineTransformMakeRotation(-M_PI_2 / 3);
        }];
    }else {
        self.needleView.transform = CGAffineTransformMakeRotation(-M_PI_2 / 3);
    }
    
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)resetCoverView {
//    if (self.displayLink) {
//        [self.displayLink invalidate];
//        self.displayLink = nil;
//    }
}

- (void)diskAnimation {
    self.centerDiskView.diskImgView.transform = CGAffineTransformRotate(self.centerDiskView.diskImgView.transform, M_PI_4 / 100.0f);
//    NSLog(@"旋转中。。。");
}

#pragma mark - Private Methods
- (void)setCurrentIndex:(NSInteger)currentIndex needChange:(BOOL)needChange {
    if (currentIndex >= 0) {
        self.currentIndex = currentIndex;
        
        NSInteger count         = self.musics.count;
        NSInteger leftIndex     = (currentIndex + count - 1) % count;
        NSInteger rightIndex    = (currentIndex + 1) % count;
        
        GKWYMusicModel *leftM   = self.musics[leftIndex];
        GKWYMusicModel *centerM = self.musics[currentIndex];
        GKWYMusicModel *rightM  = self.musics[rightIndex];
        
        // 设置图片
        self.centerDiskView.imgUrl = centerM.pic_radio;
        
        if (needChange) {
            self.centerDiskView.diskImgView.transform = CGAffineTransformIdentity;
            
            // 每次设置后，移到中间
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self setScrollViewContentOffsetCenter];
                
                self.leftDiskView.imgUrl    = leftM.pic_radio;
                self.rightDiskView.imgUrl   = rightM.pic_radio;
                
                if (self.isUserChanged) {
                    !self.finished ? : self.finished();
                    self.isUserChanged = NO;
                }
            });
        }else {
            self.leftDiskView.imgUrl    = leftM.pic_radio;
            self.rightDiskView.imgUrl   = rightM.pic_radio;
        }
    }
}

- (void)setScrollViewContentOffsetCenter {
    [self.diskScrollView setContentOffset:CGPointMake(KScreenW, 0)];
}

// 设置试图的锚点
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake(view.center.x - transition.x, view.center.y - transition.y);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollW = CGRectGetWidth(scrollView.frame);
    if (scrollW == 0) return;
    // 滑动超过一半时
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (offsetX <= 0.5 * scrollW) { // 左滑
        NSInteger idx = (self.currentIndex - 1 + self.musics.count) % self.musics.count;
        
        if ([self.delegate respondsToSelector:@selector(scrollWillChangeModel:)]) {
            [self.delegate scrollWillChangeModel:self.musics[idx]];
        }
    }else if (offsetX >= 1.5 * scrollW) { // 右滑
        NSInteger idx = (self.currentIndex + 1) % self.musics.count;
        
        if ([self.delegate respondsToSelector:@selector(scrollWillChangeModel:)]) {
            [self.delegate scrollWillChangeModel:self.musics[idx]];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pausedWithAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(scrollDidScroll)]) {
        [self.delegate scrollDidScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEnd:(UIScrollView *)scrollView {
    // 滑动结束时，获取索引
    CGFloat scrollW = CGRectGetWidth(scrollView.frame);
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (offsetX == 2 * scrollW) {
        NSInteger currentIndex = (self.currentIndex + 1) % self.musics.count;
        
        [self setCurrentIndex:currentIndex needChange:YES];
    }else if (offsetX == 0) {
        NSInteger currentIndex = (self.currentIndex - 1 + self.musics.count) % self.musics.count;
        
        [self setCurrentIndex:currentIndex needChange:YES];
    }else {
        [self setScrollViewContentOffsetCenter];
    }
    
    GKWYMusicModel *model = self.musics[self.currentIndex];
    
    if ([self.delegate respondsToSelector:@selector(scrollDidChangeModel:)]) {
        [self.delegate scrollDidChangeModel:model];
    }
}

#pragma mark - 懒加载
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
    }
    return _lineView;
}

- (UIView *)diskBgView {
    if (!_diskBgView) {
        _diskBgView = [UIView new];
        _diskBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        
        _diskBgView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
        _diskBgView.layer.borderWidth = 10.0f;
        _diskBgView.layer.cornerRadius = (KScreenW - 75.0f) * 0.5;
    }
    return _diskBgView;
}

- (UIScrollView *)diskScrollView {
    if (!_diskScrollView) {
        _diskScrollView = [UIScrollView new];
        _diskScrollView.delegate        = self;
        _diskScrollView.pagingEnabled   = YES;
        _diskScrollView.backgroundColor = [UIColor clearColor];
        _diskScrollView.showsHorizontalScrollIndicator = NO;
        
        [_diskScrollView addSubview:self.leftDiskView];
        [_diskScrollView addSubview:self.centerDiskView];
        [_diskScrollView addSubview:self.rightDiskView];
        _diskScrollView.contentSize = CGSizeMake(KScreenW * 3, 0);
    }
    return _diskScrollView;
}

- (GKWYDiskView *)leftDiskView {
    if (!_leftDiskView) {
        _leftDiskView = [GKWYDiskView new];
    }
    return _leftDiskView;
}

- (GKWYDiskView *)centerDiskView {
    if (!_centerDiskView) {
        _centerDiskView = [GKWYDiskView new];
    }
    return _centerDiskView;
}

- (GKWYDiskView *)rightDiskView {
    if (!_rightDiskView) {
        _rightDiskView = [GKWYDiskView new];
    }
    return _rightDiskView;
}

- (UIImageView *)needleView {
    if (!_needleView) {
        _needleView = [UIImageView new];
        _needleView.image = [UIImage imageNamed:@"cm2_play_needle_play"];
        [_needleView sizeToFit];
    }
    return _needleView;
}

@end
