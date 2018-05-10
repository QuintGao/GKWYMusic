//
//  GKSearchBar.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKSearchBar.h"

@interface GKSearchBar()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton *leftIconBtn;
@property (nonatomic, strong) UIButton *centerIconBtn;

@end

@implementation GKSearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initView];
    [self sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self sizeToFit];
}

/**
 撑开view的布局

 @return 大小
 */
- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

#pragma mark - Private Methods
- (void)initView {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 44.0f);
    
    if (self.showCancelButton) {
        [self addSubview:self.cancelBtn];
        self.cancelBtn.hidden = YES;
    }
    
    [self addSubview:self.textField];
    
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)adjustIconWithIconAlign:(GKSearchBarIconAlign)iconAlign {
    if (iconAlign == GKSearchBarIconAlignCenter && (([self.text isKindOfClass:[NSNull class]] || !self.text || [self.text isEqualToString:@""] || self.text.length == 0) && ![_textField isFirstResponder])) {
        self.centerIconBtn.hidden = NO;
        self.textField.frame = CGRectMake(7, 7, self.frame.size.width - 14, 30);
        self.textField.textAlignment = NSTextAlignmentCenter;
        if (self.showCancelButton) {
            self.textField.frame = CGRectMake(7, 7, self.cancelBtn.frame.origin.x - 7, 30);
        }
        
        CGSize titleSize = CGSizeZero;
        
        titleSize = [self.placeholder ? : @"" sizeWithAttributes:@{NSFontAttributeName: self.textField.font}];
        
        CGFloat x = self.textField.frame.size.width / 2.0f - titleSize.width / 2.0f - 30;
        [self.centerIconBtn setImage:self.iconImage forState:UIControlStateNormal];
        self.centerIconBtn.frame = CGRectMake(x > 0 ? x : 0, 0, self.leftIconBtn.frame.size.width, self.leftIconBtn.frame.size.height);
        self.centerIconBtn.hidden = x > 0 ? NO : YES;
        self.textField.leftView = x > 0 ? nil : self.leftIconBtn;
        self.textField.leftViewMode = x > 0 ? UITextFieldViewModeNever : UITextFieldViewModeAlways;
    }else {
        self.centerIconBtn.hidden    = YES;
        self.textField.textAlignment = NSTextAlignmentLeft;
        self.textField.leftViewMode  = UITextFieldViewModeAlways;
        
        if (self.showCancelButton) {
            self.textField.frame = CGRectMake(7, 7, self.cancelBtn.frame.origin.x - 7, 30);
        }
    }
}

#pragma mark - User Action
- (void)cancelBtnClick:(id)sender {
    _textField.text = @"";
    [self resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(searchBarCancelBtnClicked:)]) {
        [self.delegate searchBarCancelBtnClicked:self];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_iconAlign == GKSearchBarIconAlignCenter) {
        self.iconAlign = GKSearchBarIconAlignLeft;
    }
    
    if ([self.delegate respondsToSelector:@selector(searchBarDidBeginEditing:)]) {
        [self.delegate searchBarDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [self.delegate searchBarShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarDidEndEditing:)]) {
        [self.delegate searchBarDidEndEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(searchBarShouldClear:)]) {
        return [self.delegate searchBarShouldClear:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(searchBarSearchBtnClicked:)]) {
        [self.delegate searchBarSearchBtnClicked:self];
    }
    return YES;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual:self] && [keyPath isEqualToString:@"frame"])
    {
        // _textField.frame = CGRectMake(7, 7, self.frame.size.width - 7*2, 30);
//        NSLog(@"----%f", self.frame.size.width);
        [self adjustIconWithIconAlign:_iconAlign];
    }
}

- (void)dealloc {
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    [self removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - Setter
- (void)setIconAlign:(GKSearchBarIconAlign)iconAlign {
    _iconAlign = iconAlign;
    
    [self adjustIconWithIconAlign:iconAlign];
}

- (void)setShowCancelButton:(BOOL)showCancelButton {
    _showCancelButton = showCancelButton;
    
    if (showCancelButton) {
        [self addSubview:self.cancelBtn];
        self.cancelBtn.hidden = NO;
    }
}

- (void)setIconImage:(UIImage *)iconImage {
    if (!_iconImage) {
        _iconImage = iconImage;
        
        [self.leftIconBtn setImage:_iconImage forState:UIControlStateNormal];
        self.textField.leftView = self.leftIconBtn;
        self.textField.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    
    self.textField.placeholder = placeholder;
    self.textField.contentMode = UIViewContentModeScaleAspectFit;
    if (self.placeholderColor) {
        [self setPlaceholderColor:_placeholderColor];
    }
    [self setIconAlign:_iconAlign];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    NSAssert(_placeholderColor, @"Please set placeholder before setting placeholdercolor");
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 6.0f) {
        [self.textField setValue:_placeholderColor forKey:@"_placeholderLabel.textColor"];
    }else {
        if ([self.placeholder isKindOfClass:[NSNull class]] || !self.placeholder || [self.placeholder isEqualToString:@""]) {
            return;
        }else {
            self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName : placeholderColor, NSFontAttributeName : self.textField.font}];
        }
    }
}

- (NSString *)text {
    return self.textField.text;
}

- (BOOL)isFirstResponder {
    return self.textField.isFirstResponder;
}

- (BOOL)resignFirstResponder {
    return [self.textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

#pragma mark - 懒加载
- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(self.frame.size.width - 60.0f, 0, 60.0f, self.frame.size.height);
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    return _cancelBtn;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(7, 7, self.frame.size.width - 14, 30.0f)];
        _textField.delegate = self;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.enablesReturnKeyAutomatically = YES;
        _textField.font = [UIFont systemFontOfSize:14.0f];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textField.layer.cornerRadius = 3.0f;
        _textField.layer.masksToBounds = YES;
        _textField.leftView.contentMode = UIViewContentModeScaleAspectFit;
        _textField.backgroundColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0f];
    }
    return _textField;
}

- (UIButton *)leftIconBtn {
    if (!_leftIconBtn) {
        _leftIconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftIconBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 7, 5, 7);
        _leftIconBtn.frame = CGRectMake(5, 5, _textField.frame.size.height + 4, _textField.frame.size.height);
        _leftIconBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _leftIconBtn;
}

- (UIButton *)centerIconBtn {
    if (!_centerIconBtn) {
        _centerIconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _centerIconBtn.frame = self.centerIconBtn.frame;
        _centerIconBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 7, 5, 7);
        _centerIconBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_textField addSubview:_centerIconBtn];
    }
    return _centerIconBtn;
}

@end
