//
//  GKPageController.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <WMPageController/WMPageController.h>

@protocol GKPageControllerDelegate <NSObject>

- (void)pageScrollViewWillBeginScroll;
- (void)pageScrollViewDidEndedScroll;

@end

@interface GKPageController : WMPageController

@property (nonatomic, strong) UIView    *lineView;

@property (nonatomic, weak) id<GKPageControllerDelegate> scrollDelegate;

@end
