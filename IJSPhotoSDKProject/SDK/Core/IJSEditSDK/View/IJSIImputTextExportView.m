//
//  IJSIImputTextExportView.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/22.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSIImputTextExportView.h"
#import "IJSIMapViewExportView.h"
#import "IJSImageConst.h"
#import "IJSExtension.h"

@interface IJSIImputTextExportView ()
@property (nonatomic, weak) UILabel *textLabel;                          // 文字
@property (nonatomic, weak) IJSIMapViewExportViewSquareView *squareView; // 参数说明
@end

@implementation IJSIImputTextExportView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _createdUI];
        [self _initGestures];
    }
    return self;
}

- (void)_createdUI
{
    CGFloat squareMargin = IJSIMapViewExportViewImageSquareWidth;
    IJSIMapViewExportViewSquareView *squareView = [[IJSIMapViewExportViewSquareView alloc] initWithFrame:CGRectMake(squareMargin, squareMargin, self.js_width - 2 * squareMargin, self.js_height - 2 * squareMargin)];
    squareView.squareColor = [UIColor whiteColor];
    squareView.backgroundColor = [UIColor clearColor];
    [self addSubview:squareView];
    self.squareView = squareView;

    UILabel *textLable = [[UILabel alloc] initWithFrame:CGRectMake(IJSIMapViewExportViewImageMarginLeft, IJSIMapViewExportViewImageMarginLeft, self.js_width - 2 * IJSIMapViewExportViewImageMarginLeft, self.js_height - 2 * IJSIMapViewExportViewImageMarginLeft)];
    textLable.numberOfLines = 0;
    [self addSubview:textLable];
    self.textLabel = textLable;
}

- (void)setLabelText:(NSString *)labelText
{
    _labelText = labelText;
    _textLabel.text = labelText;
}

// 准备重算高度
- (void)setTextView:(UITextView *)textView
{
    _textView = textView;
    _textLabel.text = textView.text;
    _textLabel.font = textView.font;
    _textLabel.textColor = textView.textColor;
    // 计算文字高度
    CGFloat squareMargin = IJSIMapViewExportViewImageSquareWidth;
    CGFloat textHeight = 2 * squareMargin;
    CGSize textMaxSize = CGSizeMake(JSScreenWidth, MAXFLOAT); // 计算文字的高度需要控件的宽度和文字的大小

    textHeight += [_textLabel.text boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: _textLabel.font } context:nil].size.height;

    CGSize textWidthSize = CGSizeMake(MAXFLOAT, JSScreenHeight);
    CGFloat textWidth = 2 * squareMargin;

    textWidth += [_textLabel.text boundingRectWithSize:textWidthSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: _textLabel.font } context:nil].size.width;

    textHeight += 2 * squareMargin;
    textWidth += 2 * squareMargin;
    if (textWidth >= JSScreenWidth)
        textWidth = JSScreenWidth;

    self.frame = CGRectMake(0, 0, textWidth, textHeight);
    self.center = self.superview.center;
    self.squareView.frame = CGRectMake(0, 0, textWidth, textHeight);
    self.textLabel.frame = CGRectMake(squareMargin, squareMargin, textWidth - 2 * squareMargin, textHeight - 2 * squareMargin);
    //    [self.gestureManager addGesturesForView:self.textLabel];
    [self _hiddenSquareViewState:NO];
}

- (void)_initGestures
{
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidRotation:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidLongPress:)];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    longPress.minimumPressDuration = 2;

    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:rotation];
    [self addGestureRecognizer:longPress];
    [self addGestureRecognizer:singleTap];
}

#pragma mark 手势方法
// 单击
- (void)handleSingleTap:(UITapGestureRecognizer *)singleTap
{
    [self _hiddenSquareViewState:NO];
    if (self.handleSingleTap)
    {
        self.handleSingleTap(self.textView, YES);
    }
    [self removeFromSuperview];
}
// 移动
- (void)viewDidPan:(UIPanGestureRecognizer *)recognizer
{
    [self _hiddenSquareViewState:NO];
    UIView *view = self;
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:view.superview]; //返回在横坐标上、纵坐标上拖动了多少像素
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [recognizer setTranslation:CGPointZero inView:view.superview]; //拖动完之后，每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.textViewExpoetViewPanCallBack)
        {
            self.textViewExpoetViewPanCallBack(self.center);
        }
    }
}
// 旋转
- (void)viewDidRotation:(UIRotationGestureRecognizer *)recognizer
{
    [self _hiddenSquareViewState:NO];
    UIView *view = self;
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation);
        [recognizer setRotation:0];
    }
}
//捏合
- (void)viewDidPinch:(UIPinchGestureRecognizer *)recognizer
{
    [self _hiddenSquareViewState:NO];
    UIView *view = self;
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale);
        recognizer.scale = 1;
    }
}
// 长按2秒删除
- (void)viewDidLongPress:(UILongPressGestureRecognizer *)recognizer
{
    [self _hiddenSquareViewState:NO];
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self removeFromSuperview];
    }
}

- (void)_hiddenSquareViewState:(BOOL)state
{
    self.squareView.hidden = state;
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.squareView.hidden = YES;
    });
}

- (void)drawRect:(CGRect)rect
{
}

@end
