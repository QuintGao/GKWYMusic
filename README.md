## 前言
前段时间写过一个基于VLCKit实现的网易云音乐播放demo-[GKAudioPlayerDemo](https://github.com/QuintGao/GKAudioPlayerDemo)，以及3篇文章
[iOS-VLCKit实现仿网易云音乐播放音乐（一）](http://www.jianshu.com/p/7ffd61e6b8d4)
[iOS-VLCKit实现仿网易云音乐播放音乐（二）](http://www.jianshu.com/p/41ac0c9d6b21)
[iOS-VLCKit实现仿网易云音乐播放音乐（三）](http://www.jianshu.com/p/c34ce7c69c47)
有兴趣的可以看看。
基于VLCKit实现的有很多问题，比如不能播放本地音乐、不能获取播放进度、播放时有很多情况会被暂停或者闪退(有可能是我写的有问题)。于是经过各种搜索和探寻，最终发现[FreeStreamer](https://github.com/muhku/FreeStreamer)实现的比较好，所以又重新写了[GKWYMusic](https://github.com/QuintGao/GKWYMusic)这个demo，本次demo的数据全部来自百度音乐，仅供学习使用。
## 说明
GKWYMusic实现的有以下功能：

    * 网络音乐的播放、缓存、下载
    * 本地音乐的播放（已下载的音乐）
    * 歌词滚动、音量控制、歌曲切换
    * 设置循环类型、上一曲、下一曲、喜欢歌曲等
    * 锁屏控制（播放、暂停、喜欢、上一曲、下一曲、播放条拖动）
    * 耳机线控（播放、暂停、上一曲、下一曲、快进、快退）
    * 通知监听（插拔耳机、播放打断）
    
    本次主要讲一下对FreeStreamer的封装及使用。
    ## 效果图
    ![gkwymusic.gif](https://upload-images.jianshu.io/upload_images/1598505-6b516562ae47293e.gif?imageMogr2/auto-orient/strip)
    
    ## 封装
    本次对FreeStreamer封装了一个单例类GKAudioPlayer，可在demo中查看，使用到了FreeStreamer中的FSAudioStream。
    1、创建FSAudioStream并监听播放状态，如下
    ```
    #pragma mark - 懒加载
    - (FSAudioStream *)audioStream {
    if (!_audioStream) {
    _audioStream = [[FSAudioStream alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    _audioStream.onCompletion = ^{
    NSLog(@"完成");
    };
    
    _audioStream.onStateChange = ^(FSAudioStreamState state) {
    switch (state) {
    case kFsAudioStreamRetrievingURL:       // 检索url
    NSLog(@"检索url");
    weakSelf.state = GKAudioPlayerStateLoading;
    break;
    case kFsAudioStreamBuffering:           // 缓冲
    NSLog(@"缓冲中。。");
    weakSelf.state = GKAudioPlayerStateBuffering;
    break;
    case kFsAudioStreamSeeking:             // seek
    NSLog(@"seek中。。");
    weakSelf.state = GKAudioPlayerStateLoading;
    break;
    case kFsAudioStreamPlaying:             // 播放
    NSLog(@"播放中。。");
    weakSelf.state = GKAudioPlayerStatePlaying;
    break;
    case kFsAudioStreamPaused:              // 暂停
    NSLog(@"播放暂停");
    weakSelf.state = GKAudioPlayerStatePaused;
    break;
    case kFsAudioStreamStopped:              // 停止
    NSLog(@"播放停止");
    weakSelf.state = GKAudioPlayerStateStopped;
    break;
    case kFsAudioStreamRetryingFailed:              // 检索失败
    NSLog(@"检索失败");
    weakSelf.state = GKAudioPlayerStateError;
    break;
    case kFsAudioStreamRetryingStarted:             // 检索开始
    NSLog(@"检索开始");
    weakSelf.state = GKAudioPlayerStateLoading;
    break;
    case kFsAudioStreamFailed:                      // 播放失败
    NSLog(@"播放失败");
    weakSelf.state = GKAudioPlayerStateError;
    break;
    case kFsAudioStreamPlaybackCompleted:           // 播放完成
    NSLog(@"播放完成");
    weakSelf.state = GKAudioPlayerStateEnded;
    break;
    case kFsAudioStreamRetryingSucceeded:           // 检索成功
    NSLog(@"检索成功");
    weakSelf.state = GKAudioPlayerStateLoading;
    break;
    case kFsAudioStreamUnknownState:                // 未知状态
    NSLog(@"未知状态");
    weakSelf.state = GKAudioPlayerStateError;
    break;
    case kFSAudioStreamEndOfFile:                   // 缓冲结束
    NSLog(@"缓冲结束");
    {
    // 定时器停止后需要再次调用获取进度方法，防止出现进度不准确的情况
    [weakSelf bufferTimerAction:nil];
    
    [weakSelf stopBufferTimer];
    }
    break;
    
    default:
    break;
    }
    [weakSelf setupPlayerState:weakSelf.state];
    };
    }
    return _audioStream;
    }
    ```
    2、缓冲进度的监听，需要在播放时先创建定时器，当缓冲完成时在关闭定时器
    
    ```
    // 创建定时器
    self.bufferTimer = [GKTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(bufferTimerAction:) userInfo:nil repeats:YES];
    ```
    ```
    // 获取进度
    - (void)bufferTimerAction:(id)sender {
    float preBuffer      = (float)self.audioStream.prebufferedByteCount;
    float contentLength  = (float)self.audioStream.contentLength;
    
    // 这里获取的进度不能准确地获取到1
    float bufferProgress = contentLength > 0 ? preBuffer / contentLength : 0;
    
    //    NSLog(@"缓冲进度%.2f", bufferProgress);
    
    // 为了能使进度准确的到1，这里做了一些处理
    int buffer = (int)(bufferProgress + 0.5);
    
    if (bufferProgress > 0.9 && buffer >= 1) {
    [self stopBufferTimer];
    }
    
    if ([self.delegate respondsToSelector:@selector(gkPlayer:bufferProgress:)]) {
    [self.delegate gkPlayer:self bufferProgress:bufferProgress];
    }
    }
    ```
    3、播放，以为播放时会将数据缓存到本地，所以做了删除处理，可根据需求修改。另外做了url的判断，判断是网络还是本地
    ```
    - (void)setPlayUrlStr:(NSString *)playUrlStr {
    if (![_playUrlStr isEqualToString:playUrlStr]) {
    
    // 切换数据，清除缓存
    [self removeCache];
    
    _playUrlStr = playUrlStr;
    
    if ([playUrlStr hasPrefix:@"http"] || [playUrlStr hasPrefix:@"https"]) {
    self.audioStream.url = [NSURL URLWithString:playUrlStr];
    }else {
    self.audioStream.url = [NSURL fileURLWithPath:playUrlStr];
    }
    }
    }
    ```
    4、seek 设置播放进度
    ```
    - (void)setPlayerProgress:(float)progress {
    FSStreamPosition position = {0};
    position.position = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.audioStream seekToPosition:position];
    });
    }
    ```
    ##最后
    本次的demo里面抽离出来了许多工具类如：搜索框、定时器、歌词解析、滑杆、刷新、下载管理等，有需要的可以使用。
    demo会不断更新，如果有需求欢迎随时提出。
    另外推荐下我的图片浏览器[GKPhotoBrowser](https://github.com/QuintGao/GKPhotoBrowser)


