//
//  GKWYPlayListHeaderView.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/22.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYPlayListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKWYPlayListHeaderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) GKWYPlayListModel *model;

@end

NS_ASSUME_NONNULL_END
