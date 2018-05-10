//
//  GKWYMusicListView.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKWYMusicListView;

static NSString *const kWYMusicListViewCellID = @"GKWYMusicListViewCell";

@protocol GKWYMusicListViewDelegate<NSObject>

@optional
- (void)listViewDidClose:(GKWYMusicListView *)listView;

- (void)listView:(GKWYMusicListView *)listView didSelectRow:(NSInteger)row;

- (void)listView:(GKWYMusicListView *)listView didLovedWithRow:(NSInteger)row;

@end

@interface GKWYMusicListView : UIView

@property (nonatomic, weak) id<GKWYMusicListViewDelegate> delegate;

@property (nonatomic, strong) NSArray *listArr;

@end

@interface GKWYMusicListViewCell : UITableViewCell

@property (nonatomic, strong) GKWYMusicModel *model;

@property (nonatomic, copy)   void(^lovedClick)(GKWYMusicModel *model);

@end
