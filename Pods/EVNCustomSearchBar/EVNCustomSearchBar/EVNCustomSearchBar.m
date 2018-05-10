//
//  EVNCustomSearchBar.m
//  MMB_SaaS
//
//  Created by developer on 2017/9/27.
//  Copyright © 2017年 仁伯安. All rights reserved.
//

#import "EVNCustomSearchBar.h"

@interface EVNCustomSearchBar()<UITextFieldDelegate>
{
//    UIImageView *_iconImgV;
//    UIImageView *_iconCenterImgV;
    EVNCustomSearchBarIconAlign _iconAlignTemp;
    UITextField *_textField;
}

@property (nonatomic, strong) UIButton *iconImgButton;
@property (nonatomic, strong) UIButton *iconCenterImgButton;
@end

@implementation EVNCustomSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initView];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initView];
    [self sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self sizeToFit];
    
    NSLog(@"_textField.width.frame=%@", NSStringFromCGRect(self.frame));
}

/**
 * 撑开view的布局
 @return CGSize
 */
- (CGSize)intrinsicContentSize
{
    return UILayoutFittingExpandedSize;
}

- (void)initView
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 44);
    if (!_isHiddenCancelButton)
    {
        [self addSubview:self.cancelButton];
        self.cancelButton.hidden = YES;
    }

    [self addSubview:self.textField];

    //    self.backgroundColor = [UIColor colorWithRed:0.733 green:0.732 blue:0.756 alpha:1.000];
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

/**
 * 右边取消按钮
 @return UIButton
 */
- (UIButton *)cancelButton
{
    if (!_cancelButton)
    {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(self.frame.size.width-60, 7, 60, 30);
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_cancelButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    return _cancelButton;
}

/**
 * 搜索框
 @return UITextField
 */
- (UITextField *)textField
{
    if (!_textField)
    {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(7, 7, self.frame.size.width-7*2, 30)];
        _textField.delegate = self;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.enablesReturnKeyAutomatically = YES;
        _textField.font = [UIFont systemFontOfSize:14.0f];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.layer.cornerRadius = 3.0f;
        _textField.layer.masksToBounds = YES;
        _textField.leftView.contentMode = UIViewContentModeScaleAspectFit;
        _textField.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    }
    return _textField;
}

- (void)setIconAlign:(EVNCustomSearchBarIconAlign)iconAlign
{
    if(!_iconAlignTemp)
    {
        _iconAlignTemp = iconAlign;
    }
    _iconAlign = iconAlign;
    [self ajustIconWith:_iconAlign];
}

- (UIButton *)iconImgButton
{
    if (!_iconImgButton)
    {
        _iconImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconImgButton.imageEdgeInsets = UIEdgeInsetsMake(5, 7, 5, 7); // 参数分别是top, left, bottom, right
        _iconImgButton.frame = CGRectMake(5, 5, _textField.frame.size.height + 4, _textField.frame.size.height);
        _iconImgButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImgButton;
}

- (UIButton *)iconCenterImgButton
{
    if (!_iconCenterImgButton)
    {
        _iconCenterImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconCenterImgButton.frame = self.iconImgButton.frame;
        _iconCenterImgButton.imageEdgeInsets = UIEdgeInsetsMake(5, 7, 5, 7); // 参数分别是top, left, bottom, right
        _iconCenterImgButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_textField addSubview:_iconCenterImgButton];
    }
    return _iconCenterImgButton;
}

- (void)ajustIconWith:(EVNCustomSearchBarIconAlign)iconAlign
{
    if (_iconAlign == EVNCustomSearchBarIconAlignCenter && ([self.text isKindOfClass:[NSNull class]] || !self.text || [self.text isEqualToString:@""] || self.text.length == 0) && ![_textField isFirstResponder])
    {
        self.iconCenterImgButton.hidden = NO;
        _textField.frame = CGRectMake(7, 7, self.frame.size.width - 7*2, 30);
        _textField.textAlignment = NSTextAlignmentCenter;

        CGSize titleSize; // 输入的内容或者placeholder数据

        titleSize =  [self.placeholder?:@"" sizeWithAttributes: @{NSFontAttributeName:_textField.font}];

//        NSLog(@"----%f", _textField.frame.size.width);
        CGFloat x = _textField.frame.size.width/2.f - titleSize.width/2.f - 30;
        [self.iconCenterImgButton setImage:_iconImage forState:UIControlStateNormal];
        _iconCenterImgButton.frame = CGRectMake(x > 0 ?x:0, 0, self.iconImgButton.frame.size.width, self.iconImgButton.frame.size.height);
        _iconCenterImgButton.hidden = x > 0 ? NO : YES;
        _textField.leftView = x > 0 ? nil : _iconImgButton;
        _textField.leftViewMode =  x > 0 ? UITextFieldViewModeNever : UITextFieldViewModeAlways;
    }
    else
    {
        _iconCenterImgButton.hidden = YES;
        _textField.textAlignment = NSTextAlignmentLeft;
        [_iconImgButton setImage:_iconImage forState:UIControlStateNormal];
        _textField.leftView = _iconImgButton;
        _textField.leftViewMode =  UITextFieldViewModeAlways;
    }
}

- (NSString *)text
{
    return _textField.text;
}

- (void)setText:(NSString *)text
{
    _textField.text = text?:@"";
    [self setIconAlign:_iconAlign];
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    [_textField setFont:_textFont];
}

- (void)setTextBorderStyle:(UITextBorderStyle)textBorderStyle
{
    _textBorderStyle = textBorderStyle;
    _textField.borderStyle = textBorderStyle;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [_textField setTextColor:_textColor];
}

- (void)setIconImage:(UIImage *)iconImage
{
    if (!_iconImage)
    {
        _iconImage = iconImage;

        [self.iconImgButton setImage:_iconImage forState:UIControlStateNormal];
        _textField.leftView = self.iconImgButton;
        _textField.leftViewMode =  UITextFieldViewModeAlways;
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _textField.placeholder = placeholder;
    _textField.contentMode = UIViewContentModeScaleAspectFit;
    if (self.placeholderColor)
    {
        [self setPlaceholderColor:_placeholderColor];
    }
    [self setIconAlign:_iconAlign];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    _keyboardType = keyboardType;
    _textField.keyboardType = _keyboardType;
}

- (void)setInputView:(UIView *)inputView
{
    _inputView = inputView;
    _textField.inputView = _inputView;
}

- (BOOL)isUserInteractionEnabled
{
    return YES;
}

- (void)setInputAccessoryView:(UIView *)inputAccessoryView
{
    _inputAccessoryView = inputAccessoryView;
    _textField.inputAccessoryView = _inputAccessoryView;
}

- (void)setTextFieldColor:(UIColor *)textFieldColor
{
    _textField.backgroundColor = textFieldColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    NSAssert(_placeholderColor, @"Please set placeholder before setting placeholdercolor");

    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 6)
    {
        [_textField setValue:_placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
    }
    else
    {
        if ([self.placeholder isKindOfClass:[NSNull class]] || !self.placeholder || [self.placeholder isEqualToString:@""])
        {
            //
        }
        else
        {
            _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:
                                                @{NSForegroundColorAttributeName:placeholderColor,
                                                  NSFontAttributeName:_textField.font
                                                  }];
        }
    }
}

- (BOOL)isFirstResponder
{
    return [_textField isFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [_textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [_textField becomeFirstResponder];
}

- (void)cancelButtonTouched
{
    _textField.text = @"";
    [_textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)])
    {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

- (void)setAutoCapitalizationMode:(UITextAutocapitalizationType)type
{
    _textField.autocapitalizationType = type;
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)])
    {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(_iconAlignTemp == EVNCustomSearchBarIconAlignCenter)
    {
        self.iconAlign = EVNCustomSearchBarIconAlignLeft;
    }
    if (!_isHiddenCancelButton)
    {
        [UIView animateWithDuration:0.1 animations:^{
            _cancelButton.hidden = NO;
            _textField.frame = CGRectMake(7, 7, _cancelButton.frame.origin.x - 7, 30);
            // _textField.transform = CGAffineTransformMakeTranslation(-_cancelButton.frame.size.width,0);
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)])
    {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)])
    {
        return [self.delegate searchBarShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(_iconAlignTemp == EVNCustomSearchBarIconAlignCenter)
    {
        self.iconAlign = EVNCustomSearchBarIconAlignCenter;
    }
    if (!_isHiddenCancelButton)
    {
        [UIView animateWithDuration:0.1 animations:^{
            _cancelButton.hidden = YES;
            _textField.frame = CGRectMake(7, 7, self.frame.size.width - 7*2, 30);
            // _textField.transform = CGAffineTransformMakeTranslation(-_cancelButton.frame.size.width,0);
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)])
    {
        [self.delegate searchBarTextDidEndEditing:self];
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)])
    {
        return [self.delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)])
    {
        [self.delegate searchBar:self textDidChange:@""];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)])
    {
        [self.delegate searchBarSearchButtonClicked:self];
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isEqual:self] && [keyPath isEqualToString:@"frame"])
    {
        // _textField.frame = CGRectMake(7, 7, self.frame.size.width - 7*2, 30);
        NSLog(@"----%f", self.frame.size.width);
        [self ajustIconWith:_iconAlign];
    }
}

- (void)dealloc
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    [self removeObserver:self forKeyPath:@"frame"];
}

@end
