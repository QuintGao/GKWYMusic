//
//  GKWYPlayListViewCell.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/3.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYPlayListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKWYPlayListItemView : UIView

@property (nonatomic, strong) GKWYPlayListModel *model;

@end

@interface GKWYPlayListViewCell : UITableViewCell

@property (nonatomic, strong) GKWYPlayListModel *model;

@end

NS_ASSUME_NONNULL_END
