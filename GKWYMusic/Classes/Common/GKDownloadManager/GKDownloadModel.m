//
//  GKDownloadModel.m
//  GKDownloadManager
//
//  Created by QuintGao on 2018/4/11.
//  Copyright © 2018年 QuintGao. All rights reserved.
//

#import "GKDownloadModel.h"

@implementation GKDownloadModel

- (NSString *)fileID {
    return [NSString stringWithFormat:@"%@", _fileID];
}

- (NSString *)fileLocalPath {
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", self.fileID, self.fileFormat];
    
    return [[KDownloadManager downloadDataDir] stringByAppendingPathComponent:fileName];
}

- (NSString *)fileLyricPath {
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", self.fileID, @"lrc"];
    
    return [[KDownloadManager downloadDataDir] stringByAppendingPathComponent:fileName];
}

- (NSString *)fileImagePath {
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", self.fileID, @"jpg"];
    
    return [[KDownloadManager downloadDataDir] stringByAppendingPathComponent:fileName];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

@end
