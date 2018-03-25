//
//  IJSIPanDrawingView.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/26.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSIPanDrawingView.h"
#import "IJSIPath.h"
#import "IJSExtension.h"

@interface IJSIPanDrawingView ()
@property (nonatomic, assign) CGSize originalImageSize;           // 原始图片的大小
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture; // 画笔
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture; //轻点
@property (nonatomic, strong) NSMutableArray *allLineArr;         // 所有的线
@property (nonatomic, weak) UIImageView *drawingView;             // 绘制的UI
@end

@implementation IJSIPanDrawingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.allLineArr = [[NSMutableArray alloc] init];
        [self _createdUI];
        [self _addGestureRecognizer];
        self.originalImageSize = self.frame.size;
    }
    return self;
}
- (void)_createdUI
{
    UIImageView *drawingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.js_width, self.js_height)];
    drawingView.center = self.center;
    [self addSubview:drawingView];
    self.drawingView = drawingView;
    self.drawingView.backgroundColor = [UIColor clearColor];
}

#pragma mark 添加手势
- (void)_addGestureRecognizer
{
    //滑动手势
    if (!self.panGesture)
    {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
        self.panGesture.maximumNumberOfTouches = 1;
    }

    if (!self.panGesture.isEnabled)
    {
        self.panGesture.enabled = YES;
    }
    //轻点手势
    if (!self.tapGesture)
    {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidTap:)];
        self.tapGesture.numberOfTouchesRequired = 1;
        self.tapGesture.numberOfTapsRequired = 1;
    }

    [self.drawingView addGestureRecognizer:self.panGesture];
    [self.drawingView addGestureRecognizer:self.tapGesture];
    self.drawingView.userInteractionEnabled = YES;
    self.drawingView.layer.shouldRasterize = YES;
    self.drawingView.layer.minificationFilter = kCAFilterTrilinear;
}
//单击
- (void)drawingViewDidTap:(UITapGestureRecognizer *)sender
{
    if (self.panDrawingViewDidTap)
    {
        self.panDrawingViewDidTap();
    }
}
/*-----------------------------------方法实现-------------------------------------------------------*/
#pragma mark 绘制
- (void)drawingViewDidPan:(UIPanGestureRecognizer *)sender
{
    CGPoint currentDraggingPosition = [sender locationInView:self.drawingView]; //获取到的是手指点击屏幕实时的坐标点
    if (sender.state == UIGestureRecognizerStateBegan)                          //一个手势已经开始但尚未改变或者完成时
    {
        // 初始化一个UIBezierPath对象, 把起始点存储到UIBezierPath对象中, 用来存储所有的轨迹点
        IJSIPath *path = [IJSIPath pathToPoint:currentDraggingPosition pathWidth:self.panWidth != 0 ? self.panWidth : MAX(1, 4)];

        path.pathColor = self.panColor != nil ? self.panColor : [UIColor redColor];
        path.shape.strokeColor = [UIColor greenColor].CGColor; //代表设置它的边框色
        [self.allLineArr addObject:path];                      //添加路线
    }

    if (sender.state == UIGestureRecognizerStateChanged) //手势状态改变
    {
        // 获得数组中的最后一个UIBezierPath对象(因为我们每次都把UIBezierPath存入到数组最后一个,因此获取时也取最后一个)
        IJSIPath *path = [self.allLineArr lastObject];
        [path pathLineToPoint:currentDraggingPosition]; //添加点
        [self drawLine];
        if (self.panDrawingViewdrawingCallBack)
        {
            self.panDrawingViewdrawingCallBack(YES);
        }
    }

    if (sender.state == UIGestureRecognizerStateEnded) // 滑动结束
    {
        if (self.panDrawingViewEndDrawCallBack)
        {
            self.panDrawingViewEndDrawCallBack(NO);
        }
    }
}

#pragma mark 画线
- (void)drawLine
{
    CGSize size = self.drawingView.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0); //创建一个基于位图的上下文/NO 设置透明
    CGContextRef context = UIGraphicsGetCurrentContext();  // 获取当前上下文
    CGContextSetAllowsAntialiasing(context, true);         //去掉锯齿
    CGContextSetShouldAntialias(context, true);
    for (IJSIPath *path in self.allLineArr)
    {
        [path drawPath];
    }
    self.drawingView.image = UIGraphicsGetImageFromCurrentImageContext(); //生成一个image对象
    UIGraphicsEndImageContext();
}
#pragma mark 清楚最后一条线
- (void)cleanLastDrawPath
{
    if (self.allLineArr.count == 0)
    {
        return;
    }
    [self.allLineArr removeLastObject];
    [self drawLine]; //重新绘制
}
#pragma mark 清楚所有
- (void)cleanAllDrawPath
{
    [self.allLineArr removeAllObjects];
    [self drawingView];
}

//完成绘制
- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *temImage = [weakSelf _buildImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock)
            {
                completionBlock(temImage, nil, nil);
            }
        });
    });
}

#pragma mark 绘制当前的界面
- (UIImage *)_buildImage
{
    if (self.originalImageSize.width == 0)
    {
        self.originalImageSize = CGSizeMake(JSScreenWidth, JSScreenHeight);
    }
    UIGraphicsBeginImageContextWithOptions(self.originalImageSize, NO, self.backImage.scale);
    [self.backImage drawAtPoint:CGPointZero];
    [self.drawingView.image drawInRect:CGRectMake(0, 0, self.originalImageSize.width, self.originalImageSize.height)];
    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tmp;
}

@end

// 知识点注释
/*
 解释一下UIGraphicsBeginImageContextWithOptions函数参数的含义：
 第一个参数表示所要创建的图片的尺寸；
 第二个参数用来指定所生成图片的背景是否为不透明，如上我们使用YES而不是NO，则我们得到的图片背景将会是黑色，显然这不是我想要的；
 第三个参数指定生成图片的缩放因子，这个缩放因子与UIImage的scale属性所指的含义是一致的。传入0则表示让图片的缩放因子根据屏幕的分辨率而变化，所以我们得到的图片不管是在单分辨率还是视网膜屏上看起来都会很好。
 */
