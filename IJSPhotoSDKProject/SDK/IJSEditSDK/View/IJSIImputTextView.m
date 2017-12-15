//
//  IJSIImputTextView.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/22.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSIImputTextView.h"
#import "IJSImageConst.h"
#import "IJSExtension.h"
#import "IJSIColorButtonView.h"
#import "IJSImageNavigationView.h"
#import "IJSExtension.h"
@interface IJSIImputTextView () <UITextViewDelegate>
@property (nonatomic, weak) UIView *backView; //
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, assign) CGFloat keyboardHeight;               // 键盘高度
@property (nonatomic, strong) IJSIColorButtonView *colorButtonView; // 颜色
@property (nonatomic, weak) UITextView *textView;                   // 文字框
@property (nonatomic, weak) IJSImageNavigationView *navigationView; // 导航条
@end

@implementation IJSIImputTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _createdUI];
        [self _callBackBlock];
    }
    return self;
}

- (void)_createdUI
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.js_width, self.js_height)];
    [self addSubview:backView];
    backView.backgroundColor = [UIColor clearColor];
    self.backView = backView;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.effectView.frame = CGRectMake(0, 0, JSScreenWidth, JSScreenHeight);
    [backView addSubview:self.effectView];

    // 导航条
    IJSImageNavigationView *navigationView;
    if (IJSGiPhoneX)
    {
        navigationView  = [[IJSImageNavigationView alloc] initWithFrame:CGRectMake(0, IJSGNavigationBarHeight, JSScreenWidth, IJSINavigationHeight)];
    }
    else
    {
        navigationView  = [[IJSImageNavigationView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, IJSINavigationHeight)];
    }
    navigationView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [backView addSubview:navigationView];
    self.navigationView = navigationView;

    UITextView *textView = [[UITextView alloc] init];
    textView.delegate = self;
    textView.font = [UIFont systemFontOfSize:25];
    textView.textColor = [UIColor redColor];
    textView.frame = CGRectMake(IJSIImputTextMarginLeft, IJSIImputTextMarginTop, JSScreenWidth - 2 * IJSIImputTextMarginLeft, JSScreenHeight - 2 * IJSIImputTextMarginTop);
    textView.backgroundColor = [UIColor clearColor];
    [backView addSubview:textView];
    self.textView = textView;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    IJSIColorButtonView *colorButtonView = [[IJSIColorButtonView alloc] init];
    colorButtonView.frame = CGRectMake(0, JSScreenHeight - IJSGTabbarSafeBottomMargin - ColorButtonViewWidth , JSScreenWidth, ColorButtonViewWidth);
    [backView addSubview:colorButtonView];
    self.colorButtonView = colorButtonView;
}
- (void)_callBackBlock
{
    __weak typeof(self) weakSelf = self;
    self.colorButtonView.colorCallBack = ^(UIColor *color) {
        weakSelf.textView.textColor = color;
    };

    self.colorButtonView.sliderCallBack = ^(CGFloat width) {
        weakSelf.textView.font = [UIFont systemFontOfSize:10 * width];
    };
    self.colorButtonView.cancleCallBack = ^{
        [weakSelf removeFromSuperview];
    };

    self.navigationView.cancleBlock = ^{
        if (weakSelf.textCancelCallBack)
        {
            weakSelf.textCancelCallBack();
        }
        [weakSelf removeFromSuperview];
    };

    self.navigationView.finishBlock = ^{
        if (weakSelf.textCallBackBlock)
        {
            weakSelf.textCallBackBlock(weakSelf.textView);
        }
        [weakSelf removeFromSuperview];
    };
}

- (void)setTapTextView:(UITextView *)tapTextView
{
    _tapTextView = tapTextView;
    _textView.text = tapTextView.text;
    _textView.font = tapTextView.font;
    _textView.textColor = tapTextView.textColor;

    _textView.frame = CGRectMake(IJSIImputTextMarginLeft, IJSIImputTextMarginTop, JSScreenWidth - 2 * IJSIImputTextMarginLeft, JSScreenHeight - 2 * IJSIImputTextMarginTop);
}

#pragma mark 监听键盘
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardHeight = keyboardRect.size.height;
    self.colorButtonView.frame = CGRectMake(0, JSScreenHeight - self.keyboardHeight  - ColorButtonViewWidth, JSScreenWidth, ColorButtonViewWidth);
    self.textView.frame = CGRectMake(IJSIImputTextMarginLeft, IJSGStatusBarAndNavigationBarHeight, JSScreenWidth - 2 * IJSIImputTextMarginLeft, self.colorButtonView.frame.origin.y);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.colorButtonView.frame = CGRectMake(0, JSScreenHeight - IJSGTabbarSafeBottomMargin - ColorButtonViewWidth, JSScreenWidth, ColorButtonViewWidth);
    self.textView.frame = CGRectMake(IJSIImputTextMarginLeft, IJSGStatusBarAndNavigationBarHeight, JSScreenWidth - 2 * IJSIImputTextMarginLeft, JSScreenHeight - 2 * IJSIImputTextMarginTop - IJSGTabbarSafeBottomMargin);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(CGRect)rect
{
}

@end
