//
//  ZFPlayerStatusBar.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFPlayerStatusBar.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "UIView+ZFFrame.h"
#import "ZFReachabilityManager.h"
#import "ZFUtilities.h"

@interface ZFPlayerTimerTarget: NSProxy
@property (nonatomic, weak) id target;

@end

@implementation ZFPlayerTimerTarget

+ (instancetype)proxyWithTarget:(id)target {
    ZFPlayerTimerTarget *proxy = [ZFPlayerTimerTarget alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = nil;
    if ([self.target respondsToSelector:sel]) {
        signature = [self.target methodSignatureForSelector:sel];
    } else {
        /// 动态造一个 void object selector arg 函数签名。
        /// 目的是返回有效signature，不要因为找不到而crash
        signature = [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.target];
    }
}

@end

@interface ZFPlayerStatusBar()
/// 时间
@property (nonatomic, strong) UILabel *dateLabel;
/// 电池
@property (nonatomic, strong) UIView *batteryView;
/// 充电标识
@property (nonatomic, strong) UIImageView *batteryImageView;
/// 充电层
@property (nonatomic, strong) CAShapeLayer *batteryLayer;
/// 电池边框
@property (nonatomic, strong) CAShapeLayer *batteryBoundLayer;
/// 电池正极
@property (nonatomic, strong) CAShapeLayer *batteryPositiveLayer;
/// 电量百分比
@property (nonatomic, strong) UILabel *batteryLabel;
/// 网络状态
@property (nonatomic, strong) UILabel *networkLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ZFPlayerStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.dateLabel sizeToFit];
    [self.networkLabel sizeToFit];
    [self.batteryLabel sizeToFit];
    
    self.dateLabel.zf_size = CGSizeMake(self.dateLabel.zf_width, 16);
    self.batteryView.frame = CGRectMake(self.bounds.size.width - 35 - (iPhoneX ? 44 : 0), 0, 22, 10);
    self.batteryLabel.frame = CGRectMake(self.batteryView.zf_x - 42, 0, self.batteryLabel.zf_width, 16);
    self.networkLabel.frame = CGRectMake(self.batteryLabel.zf_x - 40, 0, self.networkLabel.zf_width + 13, 14);
    
    self.dateLabel.center = self.center;
    self.batteryView.zf_centerY = self.zf_centerY;
    self.batteryLabel.zf_right = self.batteryView.zf_x - 5;
    self.batteryLabel.zf_centerY = self.batteryView.zf_centerY;
    self.networkLabel.zf_right = self.batteryLabel.zf_x - 10;
    self.networkLabel.zf_centerY = self.batteryView.zf_centerY;
}

- (void)dealloc {
    [self destoryTimer];
}

- (void)setup {
    self.refreshTime = 3.0;
    /// 时间
    [self addSubview:self.dateLabel];
    [self addSubview:self.batteryView];
    /// 电池
    [self.batteryView.layer addSublayer:self.batteryBoundLayer];
    /// 正极
    [self.batteryView.layer addSublayer:self.batteryPositiveLayer];
    /// 是否在充电
    [self.batteryView.layer addSublayer:self.batteryLayer];
    [self.batteryView addSubview:self.batteryImageView];
    [self addSubview:self.batteryLabel];
    [self addSubview:self.networkLabel];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelDidChangeNotification:)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateDidChangeNotification:)
                                                 name:UIDeviceBatteryStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeDidChangeNotification:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDidChangeNotification:)
                                                 name:ZFReachabilityDidChangeNotification
                                               object:nil];
    
    
}

- (void)batteryLevelDidChangeNotification:(NSNotification *)noti {
    [self updateUI];
}

- (void)batteryStateDidChangeNotification:(NSNotification *)noti {
    [self updateUI];
}

- (void)localeDidChangeNotification:(NSNotification *)noti {
    [self.dateFormatter setLocale:[NSLocale currentLocale]];
    [self updateUI];
}

- (void)networkDidChangeNotification:(NSNotification *)noti {
    self.networkLabel.text = [self networkStatus];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)startTimer {
    self.timer = [NSTimer timerWithTimeInterval:self.refreshTime target:[ZFPlayerTimerTarget proxyWithTarget:self] selector:@selector(updateUI) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

- (void)destoryTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - update UI

- (void)updateUI {
    [self updateDate];
    [self updateBattery];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)updateDate {
    NSMutableString *dateString = [[NSMutableString alloc] initWithString:[self.dateFormatter stringFromDate:[NSDate date]]];
    NSRange amRange = [dateString rangeOfString:[self.dateFormatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[self.dateFormatter PMSymbol]];
    if (amRange.location != NSNotFound) {
        [dateString deleteCharactersInRange:amRange];
    } else if (pmRange.location != NSNotFound) {
        [dateString deleteCharactersInRange:pmRange];
    }
    self.dateLabel.text = dateString;
}

- (void)updateBattery {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    /// -1是模拟器
    if (batteryLevel < 0) { batteryLevel = 1.0; }
    CGRect rect = CGRectMake(1.5, 1.5, (20-3)*batteryLevel, 10-3);
    UIBezierPath *batteryPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2];
    
    UIColor *batteryColor;
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) { /// 在充电
        self.batteryImageView.hidden = NO;
    } else {
        self.batteryImageView.hidden = YES;
    }
    if (@available(iOS 9.0, *)) {
        if ([NSProcessInfo processInfo].lowPowerModeEnabled) { /// 低电量模式
            batteryColor = UIColorFromHex(0xF9CF0E);
        } else {
            if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) { /// 在充电
                batteryColor = UIColorFromHex(0x37CB46);
            } else if (batteryLevel <= 0.2) { /// 电量低
                batteryColor = UIColorFromHex(0xF02C2D);
            } else { /// 电量正常 白色
                batteryColor = [UIColor whiteColor];
            }
        }
    } else {
        if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) { /// 在充电
            batteryColor = UIColorFromHex(0x37CB46);
        } else if (batteryLevel <= 0.2) { /// 电量低
            batteryColor = UIColorFromHex(0xF02C2D);
        } else { /// 电量正常 白色
            batteryColor = [UIColor whiteColor];
        }
    }
    
    self.batteryLayer.strokeColor = [UIColor clearColor].CGColor;
    self.batteryLayer.path = batteryPath.CGPath;
    self.batteryLayer.fillColor = batteryColor.CGColor;
    self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%", batteryLevel*100];
}

- (NSString *)networkStatus {
    NSString *net = @"WIFI";
    ZFReachabilityStatus netStatus = [ZFReachabilityManager sharedManager].networkReachabilityStatus;
    switch (netStatus) {
        case ZFReachabilityStatusReachableViaWiFi:
            net = @"WIFI";
            break;
        case ZFReachabilityStatusNotReachable:
            net = @"无网络";
            break;
        case ZFReachabilityStatusReachableVia2G:
            net = @"2G";
            break;
        case ZFReachabilityStatusReachableVia3G:
            net = @"3G";
            break;
        case ZFReachabilityStatusReachableVia4G:
            net = @"4G";
            break;
        case ZFReachabilityStatusReachableVia5G:
            net = @"5G";
            break;
        default:
            net = @"未知";
            break;
    }
    return net;
}

#pragma mark - getter

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.bounds = CGRectMake(0, 0, 100, 16);
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:12];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateLabel;
}

- (NSDateFormatter*)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _dateFormatter;
}

- (UIView *)batteryView {
    if (!_batteryView) {
        _batteryView = [[UIView alloc] init];
    }
    return _batteryView;
}

- (UIImageView *)batteryImageView {
    if (!_batteryImageView) {
        _batteryImageView = [[UIImageView alloc] init];
        _batteryImageView.bounds = CGRectMake(0, 0, 8, 12);
        _batteryImageView.center = CGPointMake(10, 5);
        _batteryImageView.image = ZFPlayer_Image(@"ZFPlayer_battery_lightning");
    }
    return _batteryImageView;
}

- (CAShapeLayer *)batteryLayer {
    if (!_batteryLayer) {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
        UIBezierPath *batteryPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1.5, 1.5, (20-3)*batteryLevel, 10-3) cornerRadius:2];
        _batteryLayer = [CAShapeLayer layer];
        _batteryLayer.lineWidth = 1;
        _batteryLayer.strokeColor = [UIColor clearColor].CGColor;
        _batteryLayer.path = batteryPath.CGPath;
        _batteryLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    return _batteryLayer;
}

- (CAShapeLayer *)batteryBoundLayer {
    if (!_batteryBoundLayer) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 20, 10) cornerRadius:2.5];
        _batteryBoundLayer = [CAShapeLayer layer];
        _batteryBoundLayer.lineWidth = 1;
        _batteryBoundLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
        _batteryBoundLayer.path = bezierPath.CGPath;
        _batteryBoundLayer.fillColor = nil;
    }
    return _batteryBoundLayer;
}

- (CAShapeLayer *)batteryPositiveLayer {
    if (!_batteryPositiveLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(22, 3, 1, 3) byRoundingCorners:(UIRectCornerTopRight|UIRectCornerBottomRight) cornerRadii:CGSizeMake(2, 2)];
        _batteryPositiveLayer = [CAShapeLayer layer];
        _batteryPositiveLayer.lineWidth = 0.5;
        _batteryPositiveLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
        _batteryPositiveLayer.path = path.CGPath;
        _batteryPositiveLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
    }
    return _batteryPositiveLayer;
}

- (UILabel *)batteryLabel {
    if (!_batteryLabel) {
        _batteryLabel = [[UILabel alloc] init];
        _batteryLabel.textColor = [UIColor whiteColor];
        _batteryLabel.font = [UIFont systemFontOfSize:11];
        _batteryLabel.textAlignment = NSTextAlignmentRight;
    }
    return _batteryLabel;
}

- (UILabel *)networkLabel {
    if (!_networkLabel) {
        _networkLabel = [[UILabel alloc] init];
        _networkLabel.layer.cornerRadius = 7;
        _networkLabel.layer.borderWidth = 1;
        _networkLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _networkLabel.textColor = [UIColor whiteColor];
        _networkLabel.font = [UIFont systemFontOfSize:9];
        _networkLabel.textAlignment = NSTextAlignmentCenter;
        _networkLabel.text = @"WIFI";
    }
    return _networkLabel;
}

@end
