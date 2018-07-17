//
//  GKWYSearchHeaderView.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/24.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYTagModel.h"

@interface GKWYSearchHeaderView : UIView

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, copy) void(^tagBtnClickBlock)(GKWYTagModel *model);

@end
