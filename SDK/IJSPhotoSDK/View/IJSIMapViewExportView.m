//
//  IJSIMapViewExportView.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/18.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSIMapViewExportView.h"
#import "IJSImageConst.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"

@interface IJSIMapViewExportView ()

@property (nonatomic, weak) UIImageView *backImageView;                  // 背景
@property (nonatomic, weak) UIButton *deleteButton;                      // 删除按钮
@property (nonatomic, weak) IJSIMapViewExportViewSquareView *squareView; //
@end

@implementation IJSIMapViewExportView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _createdUI:frame];
        [self _initGestures];
    }
    return self;
}

- (void)_initGestures
{
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPinch:)];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidRotation:)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;

    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:rotation];
}

- (void)_createdUI:(CGRect)frame
{
    CGFloat squareMargin = IJSIMapViewExportViewImageSquareWidth;
    IJSIMapViewExportViewSquareView *squareView = [[IJSIMapViewExportViewSquareView alloc] initWithFrame:CGRectMake(squareMargin, squareMargin, frame.size.width - 2 * squareMargin, frame.size.height - 2 * squareMargin)];
    squareView.squareColor = [UIColor whiteColor];
    squareView.backgroundColor = [UIColor clearColor];
    [self addSubview:squareView];
    self.squareView = squareView;

    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(IJSIMapViewExportViewImageMarginLeft, IJSIMapViewExportViewImageMarginLeft, frame.size.width - 2 * IJSIMapViewExportViewImageMarginLeft, frame.size.height - 2 * IJSIMapViewExportViewImageMarginLeft)];
    [self addSubview:backImageView];
    backImageView.backgroundColor = [UIColor clearColor];
    self.backImageView = backImageView;

    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(0, 0, IJSIMapViewExportViewButtonHeight, IJSIMapViewExportViewButtonHeight);
    [deleteButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"Combined Shape@2x" imageType:@"png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    self.deleteButton = deleteButton;
    [self hiddenSquareViewState:NO];
}

//单击
- (void)viewDidTap:(UITapGestureRecognizer *)sender
{
    if (self.mapViewExpoetViewTapCallBack)
    {
        self.mapViewExpoetViewTapCallBack();
    }
}

+ (instancetype)initExportViewWithFrame:(CGRect)frame backImage:(UIImage *)image
{
    IJSIMapViewExportView *export = [[IJSIMapViewExportView alloc] initWithFrame:frame];
    export.backImage = image;
    [export hiddenSquareViewState:NO];
    [export _initGestures];
    return export;
}

- (void)deleteButtonAction:(UIButton *)button
{
    [self removeFromSuperview];
}

- (void)setBackImage:(UIImage *)backImage
{
    _backImage = backImage;
    self.backImageView.image = backImage;
}

#pragma mark 手势方法
// 移动
- (void)viewDidPan:(UIPanGestureRecognizer *)recognizer
{
    [self hiddenSquareViewState:NO];
    UIView *view = self;
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:view.superview]; //返回在横坐标上、纵坐标上拖动了多少像素
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [recognizer setTranslation:CGPointZero inView:view.superview]; //拖动完之后，每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    }
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.mapViewExpoetViewPanCallBack)
        {
            self.mapViewExpoetViewPanCallBack(self.center);
        }
    }
}
// 旋转
- (void)viewDidRotation:(UIRotationGestureRecognizer *)recognizer
{
    [self hiddenSquareViewState:NO];
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
    [self hiddenSquareViewState:NO];
    UIView *view = self;
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged)
    {
        view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale);
        recognizer.scale = 1;
    }
}

- (void)hiddenSquareViewState:(BOOL)state
{
    self.squareView.hidden = state;
    self.deleteButton.hidden = state;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.squareView.hidden = YES;
        weakSelf.deleteButton.hidden = YES;
    });
}

@end

/*-----------------------------------画线的label-------------------------------------------------------*/
// 绘制后面的label
@implementation IJSIMapViewExportViewSquareView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // 4边角
    CGFloat marginW = self.js_width - IJSIMapViewExportViewImageSquareWidth;
    CGFloat marginH = self.js_height - IJSIMapViewExportViewImageSquareWidth;
    CGFloat marginLine = IJSIMapViewExportViewImageSquareWidth / 2;
    UIColor *lineColor = [UIColor whiteColor];
    [self addSquareViewFillColor:lineColor viewRect:CGRectMake(0, 0, IJSIMapViewExportViewImageSquareWidth, IJSIMapViewExportViewImageSquareWidth) cornerRadius:0];
    [self addSquareViewFillColor:lineColor viewRect:CGRectMake(marginW, 0, IJSIMapViewExportViewImageSquareWidth, IJSIMapViewExportViewImageSquareWidth) cornerRadius:0];
    [self addSquareViewFillColor:lineColor viewRect:CGRectMake(0, marginH, IJSIMapViewExportViewImageSquareWidth, IJSIMapViewExportViewImageSquareWidth) cornerRadius:0];
    [self addSquareViewFillColor:lineColor viewRect:CGRectMake(marginW, marginH, IJSIMapViewExportViewImageSquareWidth, IJSIMapViewExportViewImageSquareWidth) cornerRadius:0];
    // 4线
    [self addLineFillColor:lineColor viewRect:CGRectMake(marginLine, marginLine, 1, self.js_height)];
    [self addLineFillColor:lineColor viewRect:CGRectMake(marginLine, marginLine, self.js_width, 1)];
    [self addLineFillColor:lineColor viewRect:CGRectMake(marginLine, self.js_height - marginLine, self.js_width, 1)];
    [self addLineFillColor:lineColor viewRect:CGRectMake(self.js_width - marginLine, 0, 1, self.js_height)];
}

- (void)addSquareViewFillColor:(UIColor *)color viewRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *topRightSquare = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    [color setFill];
    [topRightSquare fill];
}

- (void)addLineFillColor:(UIColor *)color viewRect:(CGRect)rect
{
    UIBezierPath *topRightSquare = [UIBezierPath bezierPathWithRect:rect];
    [color setFill];
    [topRightSquare fill];
}

@end
