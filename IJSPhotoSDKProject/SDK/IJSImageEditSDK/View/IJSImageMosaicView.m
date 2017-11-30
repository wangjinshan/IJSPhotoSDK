//
//  IJSImageMosaicView.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/26.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageMosaicView.h"
#import "IJSExtension.h"

@interface IJSImageMosaicView ()

@property (nonatomic, strong) UIImageView *surfaceImageView;
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CGMutablePathRef path;
@property (nonatomic, strong) NSMutableArray *allLineArr;    // 路径
@property (nonatomic, strong) NSMutableArray *nowPointArray; // 点坐标
@property (nonatomic, assign) CGSize originalImageSize;      // 原始图片的大小
@end

@implementation IJSImageMosaicView

- (void)dealloc
{
    if (self.path)
    {
        CGPathRelease(_path);
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //创建手势对象
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];

        [self _createdUI];
        self.originalImageSize = self.frame.size;
    }
    return self;
}

- (void)_createdUI
{
    //添加imageview（surfaceImageView）到self上
    self.surfaceImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    //    [self addSubview:self.surfaceImageView];   // 此图本项目中可以不加,单独view用于显示原图

    //添加layer（imageLayer）到self上
    self.imageLayer = [CALayer layer];
    self.imageLayer.frame = self.bounds;
    [self.layer addSublayer:self.imageLayer];

    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = self.bounds;
    self.shapeLayer.lineCap = kCALineCapRound;
    self.shapeLayer.lineJoin = kCALineJoinRound;
    //手指移动时 画笔的宽度
    self.shapeLayer.lineWidth = 30.f;
    self.shapeLayer.strokeColor = [UIColor blueColor].CGColor; //不可设置clean
    self.shapeLayer.fillColor = nil;

    [self.layer addSublayer:self.shapeLayer];

    self.imageLayer.mask = self.shapeLayer; // 子视图完全遮盖马赛克视图

    self.path = CGPathCreateMutable();
    self.allLineArr = [NSMutableArray array];
}

- (void)viewDidTap:(UITapGestureRecognizer *)recognizer
{
    if (self.mosaicViewDidTap)
    {
        self.mosaicViewDidTap();
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (self.path == nil)
    {
        self.path = CGPathCreateMutable();
    }
    CGPathMoveToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    self.nowPointArray = [[NSMutableArray alloc] init];
    [self.nowPointArray addObject:(__bridge id _Nonnull)(path)];
    [self.allLineArr addObject:self.nowPointArray];
    CGPathRelease(path);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
    CGMutablePathRef path = CGPathCreateMutableCopy(self.path);
    [[self.allLineArr lastObject] addObject:(__bridge id _Nonnull)(path)];
    [self drawSmearView];
    CGPathRelease(path);
    if (self.mosaicViewdrawingCallBack)
    {
        self.mosaicViewdrawingCallBack(YES);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.mosaicViewEndDrawCallBack)
    {
        self.mosaicViewEndDrawCallBack(YES);
    }
}

- (void)setMosaicImage:(UIImage *)mosaicImage
{
    //底图
    _mosaicImage = mosaicImage;
    self.imageLayer.contents = (id) mosaicImage.CGImage; // 设置底层的图片,layer的图片都是存在 contents
}

- (void)setSurfaceImage:(UIImage *)surfaceImage
{
    //顶图
    _surfaceImage = surfaceImage;
    //    self.surfaceImageView.image = surfaceImage;    // 工具单独使用使用
}
#pragma mark 绘制
- (void)drawSmearView
{
    for (int i = 0; i < self.allLineArr.count; i++)
    {
        NSMutableArray *array = [self.allLineArr objectAtIndex:i];
        for (int i = 0; i < array.count; i++)
        {
            CGMutablePathRef path = (__bridge CGMutablePathRef)([array objectAtIndex:i]);
            self.shapeLayer.path = path;
        }
    }
}
// 清除绘画
- (void)cleanLastDrawPath
{
    if (self.allLineArr.count != 0)
        [self.allLineArr removeLastObject];
    [self drawSmearView];
    self.path = nil;
    if (self.allLineArr.count == 0)
    {
        self.path = nil;
        self.shapeLayer.path = nil;
    }
}
- (void)cleanAllDrawPath
{
    [self.allLineArr removeAllObjects];
    self.path = nil;
    self.shapeLayer.path = nil;
}
// 完成绘制
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
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.surfaceImage drawAtPoint:CGPointZero];
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
