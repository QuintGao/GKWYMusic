//
//  GKDownloadManager.m
//  GKDownloadManager
//
//  Created by QuintGao on 2018/4/11.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKDownloadManager.h"
#import "GKDownloadModel.h"
#import "AFNetworking.h"

#define kDocumentDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@interface GKDownloadManager()

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) AFURLSessionManager *manager;

@property (nonatomic, copy) NSString *currentDownloadFileID;

/** 文件句柄对象 */
@property (nonatomic, strong) NSFileHandle *fileHandle;

@property (nonatomic, assign) BOOL isCanBreakpoint;

@end

@implementation GKDownloadManager

+ (instancetype)sharedInstance {
    static GKDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GKDownloadManager new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        // 创建下载文件的保存路径
        [self createDirWithPath:[self downloadDataDir]];
        
        // 初始化队列
//        NSMutableArray *toDownloadArr = [self toDownloadFileList];
//        [toDownloadArr enumerateObjectsUsingBlock:^(GKDownloadModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (obj.state == GKDownloadModelStatePaused) {
//                obj.state = GKDownloadModelStateWaiting;
//            }
//
//            [self updateDownloadModel:obj];
//        }];
    }
    return self;
}

/** 设置是否支持断点续传，默认NO */
- (void)setCanBreakpoint:(BOOL)isCan {
    self.isCanBreakpoint = isCan;
}

- (BOOL)checkDownloadWithID:(NSString *)fileID {
    __block BOOL isDownload = NO;
    
    [[self downloadFileList] enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([fileID isEqualToString:obj.fileID] && obj.state == GKDownloadManagerStateFinished) {
            isDownload = YES;
        }
    }];
    return isDownload;
}

- (GKDownloadModel *)modelWithID:(NSString *)fileID {
    if ([self checkDownloadWithID:fileID]) {
        __block GKDownloadModel *model = nil;
        
        [[self downloadFileList] enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([fileID isEqualToString:obj.fileID]) {
                model = obj;
            }
        }];
        return model;
    }
    return nil;
}

- (void)addDownloadArr:(NSArray<GKDownloadModel *> *)downloadArr {
    
    // 新加入的模型，需要把状态改为等待下载中
    [downloadArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state != GKDownloadManagerStateFinished && obj.state != GKDownloadManagerStateDownloading) {
            obj.state = GKDownloadManagerStateWaiting;
            
            [self updateDownloadModel:obj];
            
            if ([self.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                [self.delegate gkDownloadManager:self downloadModel:obj stateChanged:GKDownloadManagerStateWaiting];
            }
        }
    }];
    
    // 保存数据
    [self saveDownloadModelArr:downloadArr];
    // 开始下载
    [self startDownloadTask];
}

// 删除下载
- (void)removeDownloadArr:(NSArray<GKDownloadModel *> *)downloadArr {
    
    // 如果删除列表中有正在下载的文件，先暂停下载
    __block BOOL exist = NO;
    [downloadArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.fileID isEqualToString:self.currentDownloadFileID]) {
            exist = YES;
            *stop = YES;
        }
    }];
    
    if (exist) {
        if (self.dataTask && self.dataTask.state == NSURLSessionTaskStateRunning) {
            [self.dataTask suspend];
        }else if (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning) {
            [self.downloadTask suspend];
        }
    }
    
    // 删除下载的文件
    [self deleteDownloadModelArr:downloadArr];
    
    if ([self.delegate respondsToSelector:@selector(gkDownloadManager:removedDownloadArr:)]) {
        [self.delegate gkDownloadManager:self removedDownloadArr:downloadArr];
    }
    
    // 开启其他下载
    [self startDownloadTask];
}

- (void)pausedDownloadArr:(NSArray<GKDownloadModel *> *)downloadArr {
    __block BOOL exist = NO;
    [downloadArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.fileID isEqualToString:self.currentDownloadFileID]) {
            exist = YES;
            *stop = YES;
        }
    }];
    
    // 如果当前正在下载的是需要暂停的，找到并暂停当前下载
    if (exist) {
        if (self.dataTask && self.dataTask.state == NSURLSessionTaskStateRunning) {
            [self.dataTask suspend];
        }else if (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning) {
            [self.downloadTask suspend];
        }
    }
    
    // 遍历数据，暂停当前下载
    NSArray *downloadList = [self downloadFileList];
    [downloadList enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        [downloadArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 文件未下载完成，并且是需要暂停的文件
            if ([model.fileID isEqualToString:obj.fileID] && model.state != GKDownloadManagerStateFinished) {
                model.state = GKDownloadManagerStatePaused;
                
                [self updateDownloadModel:model];
                
                if ([self.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                    [self.delegate gkDownloadManager:self downloadModel:model stateChanged:GKDownloadManagerStatePaused];
                }
            }
        }];
    }];
    
    // 开始其他下载
    [self startDownloadTask];
}

// 恢复下载，暂停后才能调用
- (void)resumeDownloadArr:(NSArray<GKDownloadModel *> *)downloadArr {
    NSArray *downloadList = [self downloadFileList];
    
    [downloadList enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        [downloadArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 文件未下载完成并且是需要恢复下载的文件
            if ([model.fileID isEqualToString:obj.fileID] && model.state != GKDownloadManagerStateFinished) {
                model.state = GKDownloadManagerStateWaiting;
                
                [self updateDownloadModel:model];
                
                if ([self.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                    [self.delegate gkDownloadManager:self downloadModel:model stateChanged:GKDownloadManagerStateWaiting];
                }
            }
        }];
    }];
    
    // 开启下载任务
    [self startDownloadTask];
}

- (void)clearDownload {
    if (NSURLSessionTaskStateRunning == self.downloadTask.state) {
        [self.downloadTask suspend];
    }
    
    __block NSMutableArray *toClearArr = [NSMutableArray new];
    
    [[self downloadFileList] enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.state != GKDownloadManagerStateFinished) {
            [toClearArr addObject:obj];
        }
    }];
    
    [self deleteDownloadModelArr:toClearArr];
    
    if ([self.delegate respondsToSelector:@selector(gkDownloadManager:removedDownloadArr:)]) {
        [self.delegate gkDownloadManager:self removedDownloadArr:toClearArr];
    }
}

- (void)startDownloadTask {
    // 正在下载
    if ((self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning) || (self.dataTask && self.dataTask.state == NSURLSessionTaskStateRunning)) {
        // do nothing
    }else {
        NSArray *downloadList = [self downloadFileList];
        
        __block GKDownloadModel *model = nil;
        [downloadList enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.state == GKDownloadManagerStateWaiting) {
                model = obj;
                *stop = YES;
            }
        }];
        
        if (model) {
            self.currentDownloadFileID = model.fileID;
            model.state = GKDownloadManagerStateDownloading;
            
            [self updateDownloadModel:model];
            
            // 下载中
            if ([self.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                [self.delegate gkDownloadManager:self downloadModel:model stateChanged:GKDownloadManagerStateDownloading];
            }
            
            if (self.isCanBreakpoint) {
                [self startBreakpointWithModel:model];
            }else {
                [self startDownloadDataWithModel:model];
            }
        }else { // 没有需要下载的文件
            self.currentDownloadFileID = nil;
        }
    }
}

- (void)startDownloadDataWithModel:(GKDownloadModel *)model {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.fileUrl]];
    
    __weak typeof(self) weakSelf = self;
    self.downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:totalSize:downloadSize:progress:)]) {
            [strongSelf.delegate gkDownloadManager:strongSelf
                                     downloadModel:model
                                         totalSize:(long)downloadProgress.totalUnitCount
                                      downloadSize:(long)downloadProgress.completedUnitCount
                                          progress:1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount];
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:model.fileLocalPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 下载失败
            NSLog(@"普通方式下载失败%@", error);
            // 删除已下载的数据防止出错
            [self deleteDownloadModelArr:@[model]];
            
            model.state = GKDownloadManagerStateFailed;
            [strongSelf updateDownloadModel:model];
            
            if ([strongSelf.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                [strongSelf.delegate gkDownloadManager:self downloadModel:model stateChanged:GKDownloadManagerStateFailed];
            }
        }else { // 下载完成
            model.state = GKDownloadManagerStateFinished;
            
            [strongSelf updateDownloadModel:model];
            
            if ([strongSelf.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                [strongSelf.delegate gkDownloadManager:self downloadModel:model stateChanged:GKDownloadManagerStateFinished];
            }
            
            if ([strongSelf.delegate respondsToSelector:@selector(gkDownloadManager:removedDownloadArr:)]) {
                [strongSelf.delegate gkDownloadManager:strongSelf removedDownloadArr:[NSArray arrayWithObject:model]];
            }
        }
        
        // 停止下载
        if (NSURLSessionTaskStateRunning == strongSelf.downloadTask.state) {
            [strongSelf.downloadTask suspend];
            strongSelf.downloadTask = nil;
        }
        
        // 开始下载下一个
        [strongSelf startDownloadTask];
    }];
    
    if (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateSuspended) {
        [self.downloadTask resume];
    }
}

- (void)startBreakpointWithModel:(GKDownloadModel *)model {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:model.fileUrl]];
    
    // 设置HTTP请求头中的Range
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", model.currentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    __weak typeof(self) weakSelf = self;
    _dataTask = [self.manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        
        if (resp.statusCode == 206) { // 下载成功
            model.state = GKDownloadManagerStateFinished;
            
            [strongSelf updateDownloadModel:model];
            
            if ([strongSelf.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                [strongSelf.delegate gkDownloadManager:self downloadModel:model stateChanged:GKDownloadManagerStateFinished];
            }
            
            if ([strongSelf.delegate respondsToSelector:@selector(gkDownloadManager:removedDownloadArr:)]) {
                [strongSelf.delegate gkDownloadManager:strongSelf removedDownloadArr:[NSArray arrayWithObject:model]];
            }
        }else { // 下载失败
            // 删除已下载的数据防止出错
            [self deleteDownloadModelArr:@[model]];
            
            model.state = GKDownloadManagerStateFailed;
            [strongSelf updateDownloadModel:model];
            
            if ([strongSelf.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                [strongSelf.delegate gkDownloadManager:self downloadModel:model stateChanged:GKDownloadManagerStateFailed];
            }
            
            NSLog(@"断点方式下载失败%@", error);
        }
        
        // 关闭fileHandle
        [strongSelf.fileHandle closeFile];
        strongSelf.fileHandle = nil;
        
        // 停止当前下载
        if (NSURLSessionTaskStateRunning == strongSelf.dataTask.state) {
            [strongSelf.dataTask suspend];
        }
        
        // 下载下一个
        [strongSelf startDownloadTask];
    }];
    
    [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        // 获取下载文件的总长度：请求下载的文件长度 + 当前已下载的文件长度
        model.fileLength = response.expectedContentLength + model.currentLength;
        
        // 这里需要先创建文件的路径，再写入数据
        [strongSelf createFilePathWithPath:model.fileLocalPath];
        
        // 创建文件句柄
        strongSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:model.fileLocalPath];
        
        NSLog(@"%@", strongSelf.fileHandle);
        // 允许处理服务器的响应，才会继续接收服务器返回的数据
        return NSURLSessionResponseAllow;
    }];
    
    [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        // 指定数据的写入位置 - 文件内容的最后面
        [strongSelf.fileHandle seekToEndOfFile];
        
        // 向沙盒写入数据
        [strongSelf.fileHandle writeData:data];
        
        // 拼接文件总长度，并写入本地
        model.currentLength += data.length;
        [strongSelf updateDownloadModel:model];
        
        // 更新进度
        float progress = 0;
        if (model.fileLength == 0) {
            progress = 0;
        }else {
            progress = 1.0 * model.currentLength / model.fileLength;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([strongSelf.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:totalSize:downloadSize:progress:)]) {
                [strongSelf.delegate gkDownloadManager:strongSelf downloadModel:model totalSize:model.fileLength downloadSize:model.currentLength progress:progress];
            }
        });
    }];
    
    if (NSURLSessionTaskStateSuspended == self.dataTask.state) {
        [self.dataTask resume];
    }
}

- (NSString *)convertFromByteNum:(unsigned long long)b {
    if (b == 0) {
        return @"";
    }
    
    NSString *strSize = @"";
    
    if (b / 1024.0f / 1024.0f / 1024.0f >= 1) {
        strSize = [NSString stringWithFormat:@"%.1fGB",b / 1024.0f / 1024.0f / 1024.0f];
    }else if (b / 1024.0f / 1024.0f >= 1 && b / 1024.0f / 1024.0f / 1024.0f < 1) {
        strSize = [NSString stringWithFormat:@"%.1fMB",b / 1024.0f / 1024.0f];
    }else if (b / 1024.0f >= 0 && b / 1024.0f / 1024.0f < 1) {
        strSize = [NSString stringWithFormat:@"%.1fKB",b / 1024.0f];
    }
    
    if (!strSize) {
        strSize = @"";
    }
    
    return strSize;
}

#pragma mark - Private Methods
// 保存数据模型
- (void)saveDownloadModelArr:(NSArray <GKDownloadModel *> *)modelArr {
    NSMutableArray *downloadModelArr = nil;
    if ([self ifPathExist:[self downloadDataFilePath]]) {
        downloadModelArr = [self downloadFileList];
        [modelArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self ifExistDownloadModelWithID:obj.fileID]) {
                [downloadModelArr addObject:obj];
            }
        }];
    }else {
        downloadModelArr = [NSMutableArray arrayWithArray:modelArr];
    }
    
    // 保存
    [self writeToFileWithModelArr:downloadModelArr];
}

// 更新数据模型
- (void)updateDownloadModel:(GKDownloadModel *)model {
    if ([self ifPathExist:[self downloadDataFilePath]]) {
        NSMutableArray *downloadArr = [self downloadFileList];
        
        [downloadArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.fileID isEqualToString:obj.fileID]) {
                if (model.state == GKDownloadManagerStateFinished) {
                    NSInteger fileSize = [self fileSizeWithModel:model];
                    
                    model.file_size = [self convertFromByteNum:fileSize];
                }
                
                [downloadArr replaceObjectAtIndex:idx withObject:model];
                *stop = YES;
            }
        }];
        
        [self writeToFileWithModelArr:downloadArr];
    }
}

// 删除数据模型
- (void)deleteDownloadModelArr:(NSArray <GKDownloadModel *> *)modelArr {
    if ([self ifPathExist:[self downloadDataFilePath]]) {
        NSMutableArray *downloadArr = [self downloadFileList];
        
        [modelArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            [[downloadArr mutableCopy] enumerateObjectsUsingBlock:^(GKDownloadModel   * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([model.fileID isEqualToString:obj.fileID]) {
                    // 状态改变
                    model.state = GKDownloadManagerStateNone;
                    [self updateDownloadModel:model];
                    
                    if ([self.delegate respondsToSelector:@selector(gkDownloadManager:downloadModel:stateChanged:)]) {
                        [self.delegate gkDownloadManager:self downloadModel:model stateChanged:GKDownloadManagerStateNone];
                    }
                    
                    // 删除文件
                    if ([self ifPathExist:obj.fileLocalPath]) {
                        [self removeDirWithPath:obj.fileLocalPath];
                    }
                    // 删除模型
                    [downloadArr removeObject:obj];
                    
                    // 重新保存
                    [self writeToFileWithModelArr:downloadArr];
                }
            }];
        }];
    }
}

// 遍历文件（全部）
- (NSMutableArray <GKDownloadModel *> *)downloadFileList {
    if ([self ifPathExist:[self downloadDataFilePath]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:[self downloadDataFilePath]];
    }
    return nil;
}

// 遍历文件（已下载）
- (NSMutableArray <GKDownloadModel *> *)downloadedFileList {
    if ([self ifPathExist:[self downloadDataFilePath]]) {
        NSMutableArray *downloadArr = [self downloadFileList];
        __block NSMutableArray *downloadedArr = [NSMutableArray new];
        [downloadArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.state == GKDownloadManagerStateFinished) {
                [downloadedArr addObject:obj];
            }
        }];
        
        return downloadedArr;
    }
    return nil;
}

// 遍历文件（未下载、下载中、暂停）
- (NSMutableArray <GKDownloadModel *> *)toDownloadFileList {
    if ([self ifPathExist:[self downloadDataFilePath]]) {
        NSMutableArray *downloadArr = [self downloadFileList];
        __block NSMutableArray *toDownloadArr = [NSMutableArray new];
        [downloadArr enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.state != GKDownloadManagerStateFinished) {
                [toDownloadArr addObject:obj];
            }
        }];
        return toDownloadArr;
    }
    return nil;
}

- (void)writeToFileWithModelArr:(NSArray <GKDownloadModel *> *)modelArr {
    
    [NSKeyedArchiver archiveRootObject:modelArr toFile:[self downloadDataFilePath]];
}

- (BOOL)ifExistDownloadModelWithID:(NSString *)ID {
    __block BOOL exist = NO;
    if ([self ifPathExist:[self downloadDataFilePath]]) {
        NSArray *modelArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self downloadDataFilePath]];
        
        [modelArr enumerateObjectsUsingBlock:^(GKDownloadModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.fileID isEqualToString:ID]) {
                exist = YES;
                *stop = YES;
            }
        }];
    }
    return exist;
}

- (unsigned long long)fileSizeWithModel:(GKDownloadModel *)model {
    if ([self ifPathExist:model.fileLocalPath]) {
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:model.fileLocalPath error:nil] fileSize];
    }
    return 0;
}

#pragma mark - filepath
- (NSString *)downloadDataFilePath {
    return [[self downloadDataDir] stringByAppendingPathComponent:@"downloadModel.plist"];
}

- (NSString *)downloadDataDir {
    return [kDocumentDirectory stringByAppendingPathComponent:@"download"];
}

- (BOOL)ifPathExist:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (BOOL)createDirWithPath:(NSString *)path {
    if (![self ifPathExist:path]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

- (BOOL)createFilePathWithPath:(NSString *)path {
    if (![self ifPathExist:path]) {
        return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    return YES;
}

- (BOOL)removeDirWithPath:(NSString *)path {
    if ([self ifPathExist:path]) {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return YES;
}

#pragma mark - Getters & Setters
- (AFURLSessionManager *)manager {
    if (_manager == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    
    return _manager;
}

@end
