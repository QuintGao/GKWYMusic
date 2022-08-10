//
//  GKWYCoverView.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWYCoverView : UIView

@property (nonatomic, strong) UIImageView *topView;

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *playImgView;
@property (nonatomic, strong) UILabel *countLabel;

- (void)updateCount:(NSString *)count;

- (void)setAlbumLayout:(CGFloat)margin;

@end

NS_ASSUME_NONNULL_END
