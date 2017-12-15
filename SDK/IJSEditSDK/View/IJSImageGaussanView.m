//
//  IJSImageGaussanView.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/26.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageGaussanView.h"
#import "IJSExtension.h"

@interface IJSImageGaussanView ()
@property (nonatomic, strong) UIImage *nowImage;             // 生成的新图
@property (nonatomic, strong) NSMutableArray *nowPointArray; // 新点
@property (nonatomic, strong) NSMutableArray *allLineArr;    // 所有的线
@property (nonatomic, weak) UILabel *warning;                // 警告

@end

@implementation IJSImageGaussanView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.nowPointArray = [[NSMutableArray alloc] init];
        self.allLineArr = [[NSMutableArray alloc] init];
        //创建手势对象
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    [self.nowImage drawInRect:rect];
}

- (void)setGaussanViewGaussanImage:(UIImage *)gaussanViewGaussanImage
{
    _gaussanViewGaussanImage = gaussanViewGaussanImage;
}

// 获取原图
- (void)setOriginImage:(UIImage *)originImage
{
    _originImage = originImage;
    [self.nowPointArray removeAllObjects];
    [self.allLineArr removeAllObjects];
    //    [self drawSmearView];  //此项目中不需要调用,单独view时候调用
}

#pragma mark 绘制
- (void)drawSmearView
{
    UIGraphicsBeginImageContext(self.originImage.size);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    //    [self.originImage drawInRect:CGRectMake(0, 0,self.originImage.size.width,self.originImage.size.height)]; //此句本文可以不写,但是单独的文件必写
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithPatternImage:self.gaussanViewGaussanImage].CGColor);
    CGContextSetLineWidth(context, 15 * self.originImage.size.width / self.bounds.size.width);
    for (int i = 0; i < self.allLineArr.count; i++)
    {
        NSMutableArray *array = [self.allLineArr objectAtIndex:i];

        for (int i = 0; i < array.count; i++)
        {
            NSValue *value = [array objectAtIndex:i];
            CGPoint p = [value CGPointValue];
            p.x = p.x * self.originImage.size.width / self.bounds.size.width;
            p.y = p.y * self.originImage.size.height / self.bounds.size.height;
            if (i == 0)
            {
                CGContextMoveToPoint(context, p.x, p.y);
                CGContextAddLineToPoint(context, p.x, p.y);
            }
            else
            {
                CGContextAddLineToPoint(context, p.x, p.y);
            }
        }
    }
    CGContextDrawPath(context, kCGPathStroke);

    // 将绘制的结果存储在内存中
    self.nowImage = UIGraphicsGetImageFromCurrentImageContext();

    // 结束绘制
    UIGraphicsEndImageContext();
    [self setNeedsDisplay];
}
#pragma mark 清楚最后一条线
- (void)cleanLastDrawPath
{
    if (self.allLineArr.count != 0)
    {
        [self.allLineArr removeLastObject];
    }
    [self drawSmearView]; //重新绘制
}
// 清除所有
- (void)cleanAllDrawPath
{
    [self.allLineArr removeAllObjects];
    [self drawSmearView];
}

//单击
- (void)viewDidTap:(UITapGestureRecognizer *)recognizer
{
    if (self.gaussanViewDidTap)
    {
        self.gaussanViewDidTap();
    }
}

// 开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint currentDraggingPosition = [[touches anyObject] locationInView:self];

    self.nowPointArray = [[NSMutableArray alloc] init];
    [self.allLineArr addObject:self.nowPointArray];
    [self addPoint:currentDraggingPosition];
}

// 移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    CGPoint currentDraggingPosition = [[touches anyObject] locationInView:self];
    [self addPoint:currentDraggingPosition];
    if (self.gaussanViewdrawingCallBack)
    {
        self.gaussanViewdrawingCallBack(YES);
    }
}
// 结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    CGPoint currentDraggingPosition = [[touches anyObject] locationInView:self];
    [self addPoint:currentDraggingPosition];
    if (self.gaussanViewEndDrawCallBack)
    {
        self.gaussanViewEndDrawCallBack(YES);
    }
}
// 取消
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    CGPoint currentDraggingPosition = [[touches anyObject] locationInView:self];
    [self addPoint:currentDraggingPosition];
    if (self.gaussanViewEndDrawCallBack)
    {
        self.gaussanViewEndDrawCallBack(YES);
    }
}
- (void)addPoint:(CGPoint)p
{
    NSValue *point = [NSValue valueWithCGPoint:p];
    [self.nowPointArray addObject:point];
    [self drawSmearView];
}

- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    if (completionBlock)
    {
        completionBlock(self.nowImage, nil, nil);
    }
}

@end
