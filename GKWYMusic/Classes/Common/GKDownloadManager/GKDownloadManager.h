//
//  GKDownloadManager.h
//  GKDownloadManager
//
//  Created by QuintGao on 2018/4/11.
//  Copyright © 2018年 QuintGao. All rights reserved.
//  文件下载管理者

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GKDownloadModel.h"

#define KDownloadManager [GKDownloadManager sharedInstance]

@class GKDownloadManager;

@protocol GKDownloadManagerDelegate <NSObject>

@optional
// 下载状态改变
- (void)gkDownloadManager:(GKDownloadManager *)downloadManager
            downloadModel:(GKDownloadModel *)downloadModel
             stateChanged:(GKDownloadManagerState)state;
// 删除下载
- (void)gkDownloadManager:(GKDownloadManager *)downloadManager
       removedDownloadArr:(NSArray *)downloadArr;

// 下载进度
- (void)gkDownloadManager:(GKDownloadManager *)downloadManager
            downloadModel:(GKDownloadModel *)downloadModel
                totalSize:(NSInteger)totalSize
             downloadSize:(NSInteger)downloadSize
                 progress:(float)progress;

@end

@interface GKDownloadManager : NSObject

@property (nonatomic, weak) id<GKDownloadManagerDelegate> delegate;

+ (instancetype)sharedInstance;

/** 设置是否支持断点续传，默认NO */
- (void)setCanBreakpoint:(BOOL)isCan;

/** 根据id判断文件是否下载完成 */
- (BOOL)checkDownloadWithID:(NSString *)fileID;

/** 根据id获取本地数据信息 */
- (GKDownloadModel *)modelWithID:(NSString *)fileID;

// 添加下载
- (void)addDownloadArr:(NSArray <GKDownloadModel *> *)downloadArr;
// 删除下载
- (void)removeDownloadArr:(NSArray <GKDownloadModel *> *)downloadArr;
// 暂停下载
- (void)pausedDownloadArr:(NSArray <GKDownloadModel *> *)downloadArr;
// 继续下载
- (void)resumeDownloadArr:(NSArray <GKDownloadModel *> *)downloadArr;

// 遍历文件（全部）
- (NSMutableArray <GKDownloadModel *> *)downloadFileList;

// 遍历文件（已下载）
- (NSMutableArray <GKDownloadModel *> *)downloadedFileList;

// 清除下载（包括下载中和等待下载的）
- (void)clearDownload;

- (NSString *)downloadDataFilePath;
- (NSString *)downloadDataDir;

- (NSString *)convertFromByteNum:(unsigned long long)b;

@end
