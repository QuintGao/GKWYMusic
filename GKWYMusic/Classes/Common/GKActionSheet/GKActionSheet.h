//
//  GKActionSheet.h
//  GKAudioPlayerDemo
//
//  Created by gaokun on 2018/4/13.
//  Copyright © 2018年 高坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKActionSheetItem : NSObject

@property (nonatomic, strong) UIImage   *image;
@property (nonatomic, copy) NSString    *imgName;
@property (nonatomic, copy) NSString    *tagImgName; // 标识是否下载
@property (nonatomic, copy) NSString    *title;
@property (nonatomic, assign) BOOL      enabled; // 是否可点
@property (nonatomic, copy) void(^clickBlock)(void);

@end

@interface GKActionSheet : UIView

+ (void)showActionSheetWithTitle:(NSString *)title
                       itemInfos:(NSArray <GKActionSheetItem *> *)itemInfos;

// 更新item
+ (void)updateActionSheetItemWithIndex:(NSInteger)index item:(GKActionSheetItem *)item;

+ (BOOL)hasShow;

@end
