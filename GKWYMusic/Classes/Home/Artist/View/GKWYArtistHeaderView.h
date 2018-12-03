//
//  GKWYArtistHeaderView.h
//  GKWYMusic
//
//  Created by gaokun on 2018/10/11.
//  Copyright © 2018 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYArtistModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKWYArtistHeaderView : UIView

@property (nonatomic, strong) GKWYArtistModel   *model;

@property (nonatomic, strong) UILabel           *nameLabel;

@end

NS_ASSUME_NONNULL_END
