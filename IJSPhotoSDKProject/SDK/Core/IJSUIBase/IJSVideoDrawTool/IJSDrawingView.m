//
//  IJSDrawingView.m
//  IJSUExtension
//
//  Created by shan on 2017/8/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSDrawingView.h"
#import "IJSDrawingModel.h"

@interface IJSDrawingView ()
@property (nonatomic, strong) NSMutableArray<IJSDrawingModel *> *allPathArr; // 路径数组
@property (nonatomic, strong) NSMutableArray *imageArr;                      // 图片的数组
@end

@implementation IJSDrawingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _addpanGesture];
    }
    return self;
}

- (void)_addpanGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingPanAction:)];
    [self addGestureRecognizer:pan];
}

- (void)drawingPanAction:(UIPanGestureRecognizer *)pan
{
    CGPoint currentPoint = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        [path moveToPoint:currentPoint];
        
        IJSDrawingModel *model = [IJSDrawingModel new];
        model.path = path;
        if (self.pathWidth == 0)
        {
            self.pathWidth = 25;
        }
        if (self.pathColor == nil)
        {
            self.pathColor = [UIColor redColor];
        }
        model.pathColor = self.pathColor;
        model.pathWidth = self.pathWidth;
        [self.allPathArr addObject:model];
    }
    else if (pan.state == UIGestureRecognizerStateChanged)
    {
        if (self.isDrawing)
        {
            self.isDrawing();
        }
        [((IJSDrawingModel *) self.allPathArr.lastObject).path addLineToPoint:currentPoint];
        [self setNeedsDisplay];
    }
    else if (pan.state == UIGestureRecognizerStateEnded)
    {
        if (self.isEndDrawing)
        {
            self.isEndDrawing();
        }
    }
}
#pragma mark 绘制
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    for (IJSDrawingModel *model in self.imageArr)
    {
        UIImage *image = model.drawingImage;
        CGRect drawingRect = model.drawingRect;
        [image drawInRect:CGRectMake(drawingRect.origin.x, drawingRect.origin.y + 30, drawingRect.size.width, drawingRect.size.height)];
    }

    for (IJSDrawingModel *model in self.allPathArr)
    {
        [model.pathColor set];
        model.path.lineWidth = model.pathWidth;
        [model.path stroke];
    }
}

- (void)didFinishDrawImage:(finishCallBack)finishCallBack
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIGraphicsBeginImageContext(self.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (finishCallBack)
            {
                finishCallBack(image);
            }
        });
    });
}

/*-----------------------------------事件-------------------------------------------------------*/
- (void)cleanAllPath
{
    [self.allPathArr removeAllObjects];
    [self setNeedsDisplay];
}
- (void)cleanLastPath
{
    [self.allPathArr removeLastObject];
    [self setNeedsDisplay];
}
- (void)erasePath
{
    self.pathColor = [UIColor whiteColor];
    [self setNeedsDisplay];
}

/*-----------------------------------setting方法-------------------------------------------------------*/
- (void)setPathColor:(UIColor *)pathColor
{
    _pathColor = pathColor;
}
- (void)setPathWidth:(CGFloat)pathWidth
{
    _pathWidth = pathWidth;
}
- (void)setModel:(IJSDrawingModel *)model
{
    _model = model;
    [_imageArr addObject:model];
    [self setNeedsDisplay];
}

/*-----------------------------------懒加载-------------------------------------------------------*/
- (NSMutableArray *)allPathArr
{
    if (!_allPathArr)
    {
        _allPathArr = [NSMutableArray array];
    }
    return _allPathArr;
}
- (NSMutableArray *)imageArr
{
    if (!_imageArr)
    {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}

@end
