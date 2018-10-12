//
//  GKWYArtistHeaderView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/10/11.
//  Copyright © 2018 gaokun. All rights reserved.
//

#import "GKWYArtistHeaderView.h"

@interface GKWYArtistHeaderView()

@property (nonatomic, strong) UIImageView           *imgView;
@property (nonatomic, strong) UIVisualEffectView    *effectView;

@property (nonatomic, assign) CGRect                imageViewFrame;

@end

@implementation GKWYArtistHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        [self addSubview:self.imgView];
//        [self addSubview:self.effectView];
//
//        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self);
//        }];
//
//        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self);
//        }];
        self.imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm2_default_artist_banner"]];
        self.imgView.clipsToBounds = YES;
        self.imgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imgView];
        
        self.imageViewFrame = self.imgView.frame;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height - 30, 200, 30)];
        label.font = [UIFont systemFontOfSize:20];
        label.text = @"1212121211";
        label.textColor = [UIColor redColor];
        [self addSubview:label];
    }
    return self;
}

- (void)setModel:(GKWYArtistModel *)model {
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:self.model.avatar_s500] placeholderImage:[UIImage imageNamed:@"cm2_default_artist_banner"]];
}

- (void)scrollViewDidScroll:(CGFloat)contentOffsetY {
    CGRect frame = self.imageViewFrame;
    frame.size.height -= contentOffsetY;
    frame.origin.y = contentOffsetY;
    self.imgView.frame = frame;
}

//#pragma mark - 懒加载
//- (UIImageView *)imgView {
//    if (!_imgView) {
//        _imgView                 = [UIImageView new];
//        _imgView.contentMode     = UIViewContentModeScaleAspectFill;
//        _imgView.frame           = CGRectMake(0, 0, KScreenW, kArtistHeaderHeight);
//        _imgView.clipsToBounds   = YES;
//        _imgView.image           = [UIImage imageNamed:@"cm2_default_artist_banner"];
//    }
//    return _imgView;
//}
//
//- (UIVisualEffectView *)effectView {
//    if (!_effectView) {
//        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//
//        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//        _effectView.alpha = 0;
//    }
//    return _effectView;
//}

@end
