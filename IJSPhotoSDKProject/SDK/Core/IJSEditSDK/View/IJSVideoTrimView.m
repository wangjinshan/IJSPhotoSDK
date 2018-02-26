//
//  IJSVideoTrimView.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoTrimView.h"
#import "IJSVideoRulerView.h"
#import "IJSVideoSlideView.h"
#import "IJSExtension.h"
#import "IJSImageConst.h"
#import "IJSVideoSlideView.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSVideoManager.h"

@interface IJSVideoTrimView () <UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *backScrollView;      // 滚动图
@property (nonatomic, weak) UIView *backSlideView;             // 滑块的背景
@property (nonatomic, weak) IJSVideoSlideView *leftSlideView;  // 左滑动图
@property (nonatomic, weak) IJSVideoSlideView *rightSlideView; // 右滑动图
@property (nonatomic, weak) IJSVideoRulerView *rulerView;      // 刻度尺

@property (nonatomic, weak) UIView *topBorder;                       // 顶部的白线
@property (nonatomic, weak) UIView *bottomBorder;                    // 底下的白线
@property (strong, nonatomic) UIView *leftOverlayView;               // 左边的覆盖物
@property (strong, nonatomic) UIView *rightOverlayView;              // 右边的覆盖物
@property (nonatomic, weak) UIView *trackerView;                     // 中间的跟中线
@property (nonatomic, weak) UIView *contentView;                     // 承载视频帧图的view
@property (nonatomic, weak) UIView *videoThumView;                   // 承载视频截图的view
@property (nonatomic, assign) CGPoint leftStartPoint;                // 左边的起始点
@property (nonatomic, assign) CGPoint rightStartPoint;               // 右边的起始点
@property (nonatomic, assign) CGFloat widthPerSecond;                // 每一秒的线宽
@property (nonatomic, assign) CGFloat leftViewMaxOverlyWidth;        // 左边划款允许覆盖的最大值
@property (nonatomic, assign) CGFloat minCutTime;                    // 最小截取时间
@property (nonatomic, assign) CGFloat maxCutTime;                    // 最大截取时间
@property (nonatomic, assign) CGFloat slideHeight;                   // 滑条高度
@property (nonatomic, assign) CGFloat slideWidth;                    // 滑条宽度 = 尺子的左边距 直接在此处在改
@property (nonatomic, assign) CGFloat assetDuration;                 // 资源的总时长
@property (nonatomic, assign) CGFloat marginLeft;                    // 滑块的默认左边距
@property (nonatomic, assign) CGFloat limitLength;                   // 允许选取的最小长度
@property (nonatomic, strong) AVAsset *avasset;                      // 视频资源
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator; // 获取缩略图对象
@property (nonatomic, assign) CGFloat startTime;                     // 开始时间
@end

@implementation IJSVideoTrimView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSAssert(NO, @"用默认的初始化方法");
    }
    return self;
}
- (instancetype _Nullable)initWithFrame:(CGRect)frame minCutTime:(CGFloat)minCutTime maxCutTime:(CGFloat)maxCutTime assetDuration:(CGFloat)assetDuration avAsset:(AVAsset *)avasset;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _minCutTime = minCutTime;
        _maxCutTime = maxCutTime;
        _assetDuration = assetDuration;
        _avasset = avasset;
        if (avasset == nil)
        {
            return self;
        }
        [self _setupData];
        [self _setupUI];         // 初始化UI
        [self _setupPanGesture]; // 初始化手势
    }
    return self;
}
#pragma mark 初始化数据
- (void)_setupData
{
    //设置长度设置
    self.slideHeight = self.js_height * 0.7; // 滑块的高度
    self.slideWidth = JSScreenWidth * 0.03;  // 滑块的宽度
    self.marginLeft = JSScreenWidth * 0.1;   //左边的间距

    // 计算单位刻度
    if (self.assetDuration >= self.maxCutTime) // 大于最大值
    {
        self.widthPerSecond = (JSScreenWidth - 2 * self.marginLeft) / self.maxCutTime;
    }
    else if (self.assetDuration <= self.minCutTime) // 小于
    {
        self.widthPerSecond = (JSScreenWidth - 2 * self.marginLeft) / self.minCutTime;
    }
    else // 中间
    {
        self.widthPerSecond = (JSScreenWidth - 2 * self.marginLeft) / self.assetDuration;
    }
    self.limitLength = self.minCutTime * self.widthPerSecond;                                           //最小选取值
    self.leftViewMaxOverlyWidth = CGRectGetWidth(self.frame) - (self.minCutTime * self.widthPerSecond); // 左边允许加载的最大距离
}
#pragma mark 设置UI
- (void)_setupUI
{
    // 背景滚动图
    UIScrollView *backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.js_width, self.js_height)];
    backScrollView.backgroundColor = [UIColor clearColor];
    backScrollView.delegate = self;
    backScrollView.pagingEnabled = NO;
    backScrollView.bounces = NO;
    backScrollView.showsHorizontalScrollIndicator = NO;
    backScrollView.showsVerticalScrollIndicator = NO; //设置垂直滚动条显示
    [self addSubview:backScrollView];
    self.backScrollView = backScrollView;

    // 承载的所有视图的View
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(backScrollView.frame), CGRectGetHeight(backScrollView.frame))];
    [self.backScrollView setContentSize:contentView.frame.size];
    [backScrollView addSubview:contentView];
    self.contentView = contentView;

    // 存放视频截图的view
    UIView *videoThumView = [[UIView alloc] initWithFrame:CGRectMake(self.marginLeft, 0, CGRectGetWidth(self.contentView.frame) - 2 * self.marginLeft, CGRectGetHeight(self.contentView.frame))];
    [self.videoThumView.layer setMasksToBounds:YES];
    [contentView addSubview:videoThumView];
    self.videoThumView = videoThumView;

    // 设置滚动的视频的截图
    [self _setupVideoImage];

    //刻度尺
    CGFloat rulerW = self.marginLeft + self.assetDuration * self.widthPerSecond;
    CGRect rulerFrame = CGRectMake(0, self.slideHeight, rulerW, self.js_height - self.slideHeight);
    IJSVideoRulerView *rulerView = [[IJSVideoRulerView alloc] initWithFrame:rulerFrame widthPerSecond:self.widthPerSecond themeColor:[UIColor whiteColor] slideWidth:self.marginLeft assetDuration:self.assetDuration];
    [self.contentView addSubview:rulerView];
    self.rulerView = rulerView;

    // 左边的覆盖物  // 26 18 10
    UIView *leftOverlayView = [[UIView alloc] initWithFrame:CGRectMake(self.marginLeft - self.leftViewMaxOverlyWidth, 0, self.leftViewMaxOverlyWidth, self.slideHeight)];
    leftOverlayView.backgroundColor = [IJSFColor colorWithR:26 G:18 B:10 alpha:0.5];
    [self addSubview:leftOverlayView];
    self.leftOverlayView = leftOverlayView;
    // 左滑块
    IJSVideoSlideView *leftSlideView = [[IJSVideoSlideView alloc] initWithFrame:CGRectMake(self.leftOverlayView.js_width - self.slideWidth, 0, self.slideWidth, self.slideHeight) backImage:nil isLeft:YES];
    [self.leftOverlayView addSubview:leftSlideView];
    self.leftSlideView = leftSlideView;

    // 右边的覆盖物
    UIView *rightOverlayView = [[UIView alloc] initWithFrame:CGRectMake(JSScreenWidth - self.marginLeft, 0, self.leftViewMaxOverlyWidth, self.slideHeight)];
    rightOverlayView.backgroundColor = [IJSFColor colorWithR:26 G:18 B:10 alpha:0.7];
    [self addSubview:rightOverlayView];
    self.rightOverlayView = rightOverlayView;
    // 右滑块
    IJSVideoSlideView *rightSlideView = [[IJSVideoSlideView alloc] initWithFrame:CGRectMake(0, 0, self.slideWidth, self.slideHeight) backImage:nil isLeft:NO];
    [rightOverlayView addSubview:rightSlideView];
    self.rightSlideView = rightSlideView;

    //中间的条白线
    UIView *trackerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftOverlayView.frame), 1, 3, self.slideHeight - 2)];
    trackerView.backgroundColor = [UIColor redColor];
    [self addSubview:trackerView];
    self.trackerView = trackerView;

    //顶部线
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(self.marginLeft, 0, CGRectGetMinX(self.rightOverlayView.frame) - CGRectGetMaxX(self.leftOverlayView.frame), 1)];
    topBorder.backgroundColor = [UIColor whiteColor];
    [self addSubview:topBorder];
    self.topBorder = topBorder;
    //底部的线
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(topBorder.js_left, self.slideHeight - 1, topBorder.js_width, 1)];
    bottomBorder.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomBorder];
    self.bottomBorder = bottomBorder;
}
#pragma mark 初始化手势
- (void)_setupPanGesture
{
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanAction:)];
    [self.leftOverlayView addGestureRecognizer:leftPan];

    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPanAction:)];
    [self.rightOverlayView addGestureRecognizer:rightPan];
}

#pragma mark 手势方法-------注意最小值的处理可能会少0.1的宽度,直接以最小值处理
- (void)leftPanAction:(UIPanGestureRecognizer *)gesture
{
    if (self.widthPerSecond == 0)
    {
        NSLog(@"加载loding,解析数据中");
        return;
    }
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.leftStartPoint = [gesture locationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            int offSet = point.x - self.leftStartPoint.x; // 偏移量
            CGPoint center = self.leftOverlayView.center;
            CGFloat centerOffSetX = center.x += offSet; // 中心点偏移量 负数

            CGFloat maxWidth = CGRectGetMinX(self.rightOverlayView.frame) - self.limitLength; // 最大宽度

            if (self.leftViewMaxOverlyWidth * 0.5 + centerOffSetX <= 0.1 * JSScreenWidth) // 最小值,调整最左边则 上下 slideWidth + 调整值
            {
                centerOffSetX = (-self.leftViewMaxOverlyWidth * 0.5) + self.marginLeft;
            }
            else if (self.leftViewMaxOverlyWidth * 0.5 + centerOffSetX >= maxWidth) //最大值
            {
                centerOffSetX = (-self.leftViewMaxOverlyWidth * 0.5) + maxWidth;
            }

            self.leftOverlayView.center = CGPointMake(centerOffSetX, self.leftOverlayView.center.y);
            self.leftStartPoint = point;
            [self _updateBoderFrame]; //更新白板子的坐标
            [self getVideoLenghtThenNotifyDelegate];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            // NSLog(@"-----%f", (CGRectGetMinX(self.rightOverlayView.frame) - CGRectGetMaxX(self.leftOverlayView.frame)) / self.widthPerSecond);
            break;
        }
        default:
            break;
    }
}
- (void)rightPanAction:(UIPanGestureRecognizer *)gesture
{
    if (self.widthPerSecond == 0)
    {
        NSLog(@"加载loding,解析数据中");
        return;
    }
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.rightStartPoint = [gesture locationInView:self];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            int offSet = point.x - self.rightStartPoint.x; // 偏移量
            CGPoint center = self.rightOverlayView.center;

            CGFloat centerOffSetX = center.x += offSet; // 移动后的中心点的值

            CGFloat maxX = CGRectGetWidth(self.frame) - self.marginLeft; //  最后边值

            if (centerOffSetX - CGRectGetMaxX(self.leftOverlayView.frame) - (centerOffSetX - CGRectGetMinX(self.rightOverlayView.frame)) < self.limitLength)
            {
                centerOffSetX = CGRectGetMaxX(self.leftOverlayView.frame) + self.limitLength + self.rightOverlayView.js_width * 0.5;
            }
            else if (centerOffSetX - self.leftViewMaxOverlyWidth * 0.5 >= maxX) //超过最大值
            {
                centerOffSetX = maxX + self.leftViewMaxOverlyWidth * 0.5;
            }

            self.rightOverlayView.center = CGPointMake(centerOffSetX, self.leftOverlayView.center.y);

            self.rightStartPoint = point;
            [self _updateBoderFrame]; //更新白板子
            [self getVideoLenghtThenNotifyDelegate];
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            // NSLog(@"-----%f", (CGRectGetMinX(self.rightOverlayView.frame) - CGRectGetMaxX(self.leftOverlayView.frame)) / self.widthPerSecond);
            break;
        }
        default:
            break;
    }
}
#pragma mark 更新白条的坐标
- (void)_updateBoderFrame
{
    self.topBorder.frame = CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), 0, CGRectGetMinX(self.rightOverlayView.frame) - CGRectGetMaxX(self.leftOverlayView.frame), 1);
    self.bottomBorder.frame = CGRectMake(self.topBorder.js_left, self.slideHeight - 1, self.topBorder.js_width, 1);
    self.trackerView.js_left = CGRectGetMaxX(self.leftOverlayView.frame);
}
#pragma mark 代理解析
- (void)getVideoLenghtThenNotifyDelegate
{
    CGFloat startTime = CGRectGetMaxX(self.leftOverlayView.frame) / self.widthPerSecond + (self.backScrollView.contentOffset.x - self.marginLeft) / self.widthPerSecond;
    CGFloat endTime = CGRectGetMinX(self.rightOverlayView.frame) / self.widthPerSecond + (self.backScrollView.contentOffset.x - self.marginLeft) / self.widthPerSecond;

    if (startTime != self.startTime) //重新开始跳转开始的位置
    {
        [self changeTrackerViewOriginX:startTime];
    }
    self.startTime = startTime;
    if ([self.delegate respondsToSelector:@selector(trimView:startTime:endTime:videoLength:)])
    {
        if (startTime < 0)
        {
            startTime = 0;
        }
        if (endTime > self.assetDuration)
        {
            endTime = self.assetDuration; //  最大值最小值中间的
        }
        CGFloat videoLength = endTime - startTime;
        if (videoLength < self.minCutTime)
        {
            videoLength = self.minCutTime;
        }
        if (videoLength > self.maxCutTime)
        {
            videoLength = self.maxCutTime;
        }
        [self.delegate trimView:self startTime:startTime endTime:endTime videoLength:videoLength];
    }
}
#pragma mark 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self getVideoLenghtThenNotifyDelegate];
}

#pragma mark 视频截图
/*
 * 思路: 以一张图片的宽度作为截取,然后换算需要的总的宽度
 */
- (void)_setupVideoImage
{
    // AVAssetImageGenerator是用来提供视频的缩略图或预览视频的帧的类
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.avasset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;

    if ([self isRetina])
    {
        self.imageGenerator.maximumSize = CGSizeMake(CGRectGetWidth(self.videoThumView.frame) * 2, CGRectGetHeight(self.videoThumView.frame) * 2);
    }
    else
    {
        self.imageGenerator.maximumSize = CGSizeMake(CGRectGetWidth(self.videoThumView.frame), CGRectGetHeight(self.videoThumView.frame));
    }

    CGFloat imageWidth = 0; // 截取单张图的宽度
    // 第一张图
    NSError *error;
    CMTime actualTime; // 指向 CMTime的指针,获取视频实际的时间,可以穿 null
    CGImageRef firstImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    UIImage *videoScreen;

    if ([self isRetina])
    {
        videoScreen = [[UIImage alloc] initWithCGImage:firstImage scale:2.0 orientation:UIImageOrientationUp];
    }
    else
    {
        videoScreen = [[UIImage alloc] initWithCGImage:firstImage];
    }

    if (firstImage != NULL)
    {
        UIImageView *temp = [[UIImageView alloc] initWithImage:videoScreen];
        CGRect rect = temp.frame;
        rect.size.width = videoScreen.size.width;
        rect.size.height = self.slideHeight;
        temp.frame = rect;
        [self.videoThumView addSubview:temp];
        imageWidth = temp.frame.size.width; // 单张图片的宽度
        CGImageRelease(firstImage);
    }

    NSMutableArray *times = [[NSMutableArray alloc] init];

    CGFloat timeStep = imageWidth / self.widthPerSecond ?: 30; //截取时间的跨度,多长时间截取
    CGFloat allStep = self.assetDuration / timeStep;           // 总的时间跨度,需要截取几张图

    CGFloat allScrollWidth = allStep * imageWidth; // 总共需要滚动的物理宽度
    [self.contentView setFrame:CGRectMake(0, 0, allScrollWidth, CGRectGetHeight(self.contentView.frame))];
    [self.videoThumView setFrame:CGRectMake(self.marginLeft, 0, allScrollWidth, CGRectGetHeight(self.videoThumView.frame))];
    self.backScrollView.contentSize = CGSizeMake(allScrollWidth + 2 * self.marginLeft, 0);

    for (int i = 1; i <= (int) allStep; i++)
    {
        CMTime time = CMTimeMakeWithSeconds(i * timeStep, self.avasset.duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];

        UIImageView *tempV = [[UIImageView alloc] initWithImage:videoScreen];
        tempV.tag = i;
        if (i == (int) allStep)
        {
            CGFloat lastWidth = (allStep - (int) allStep) * imageWidth;
            tempV.frame = CGRectMake(imageWidth * i, 0, lastWidth, self.slideHeight);
        }
        else
        {
            tempV.frame = CGRectMake(imageWidth * i, 0, imageWidth, self.slideHeight);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoThumView addSubview:tempV];
        });
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (int i = 1; i <= times.count; i++)
        {
            CMTime time = [((NSValue *) [times objectAtIndex:i - 1]) CMTimeValue];
            CGImageRef firstImage = [self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
            UIImage *videoScreen;
            if ([self isRetina])
            {
                videoScreen = [[UIImage alloc] initWithCGImage:firstImage scale:2.0 orientation:UIImageOrientationUp];
            }
            else
            {
                videoScreen = [[UIImage alloc] initWithCGImage:firstImage];
            }
            CGImageRelease(firstImage);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = (UIImageView *) [self.videoThumView viewWithTag:i];
                [imageView setImage:videoScreen];
            });
        }
    });
}

- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale > 1.0));
}
#pragma mark 更改TrackerView坐标
- (void)changeTrackerViewOriginX:(CGFloat)time
{
    CGFloat posToMove = time * self.widthPerSecond + self.marginLeft - self.backScrollView.contentOffset.x;
    CGRect trackerFrame = self.trackerView.frame;
    trackerFrame.origin.x = posToMove;
    self.trackerView.frame = trackerFrame;
}

- (void)drawRect:(CGRect)rect
{
}


@end
