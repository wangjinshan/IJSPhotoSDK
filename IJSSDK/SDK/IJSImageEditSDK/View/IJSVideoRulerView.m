//
//  IJSVideoRulerView.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoRulerView.h"

@interface IJSVideoRulerView ()

@property (assign, nonatomic) CGFloat widthPerSecond; // 刻度的跨度
@property (strong, nonatomic) UIColor *themeColor;    // 颜色
@property (nonatomic, assign) CGFloat slideWidth;     // 左边距
@property (nonatomic, assign) CGFloat assetDuration;  // 视频总长
@end

@implementation IJSVideoRulerView
///初始化方法
- (instancetype)initWithFrame:(CGRect)frame widthPerSecond:(CGFloat)widthPerSecond themeColor:(UIColor *)themeColor slideWidth:(CGFloat)slideWidth assetDuration:(CGFloat)assetDuration
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.widthPerSecond = widthPerSecond; //单位刻度长度
        self.themeColor = themeColor;
        self.slideWidth = slideWidth;
        self.assetDuration = assetDuration;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat leftMargin = self.slideWidth; // 左边距
    CGFloat topMargin = 0;                //上
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat minorTickSpace = self.widthPerSecond ?: 10; // 视频总长
    CGFloat majorTickLength = 12;                       //主刻度
    CGFloat minorTickLength = 7;                        // 分刻度

    CGFloat baseY = topMargin + height;
    CGFloat minorY = baseY - minorTickLength; // 大刻度高
    CGFloat majorY = baseY - majorTickLength; // 小刻度
    NSInteger step = 0;                       //开始的秒数
    NSInteger multiple = 5;

    for (CGFloat x = leftMargin; x <= (leftMargin + width); x += minorTickSpace)
    {
        CGContextMoveToPoint(context, x, baseY);

        CGContextSetFillColorWithColor(context, self.themeColor.CGColor);
        if (step % multiple == 0) //绘画大刻度
        {
            CGContextFillRect(context, CGRectMake(x, majorY, 1.75, majorTickLength));

            UIFont *font = [UIFont systemFontOfSize:11];
            UIColor *textColor = self.themeColor;
            NSDictionary *stringAttrs = @{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor};

            NSInteger minutes = step / 60;
            NSInteger seconds = step % 60;
            NSAttributedString *attrStr;
            if (minutes > 0) //分钟
            {
                attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld:%02ld", (long) minutes, (long) seconds] attributes:stringAttrs];
            }
            else
            { // 秒钟
                attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"0:%02ld", (long) seconds] attributes:stringAttrs];
            }
            [attrStr drawAtPoint:CGPointMake(x - 9, majorY - 15)];
        }
        else
        { // 绘制 小刻度
            CGContextFillRect(context, CGRectMake(x, minorY, 1.0, minorTickLength));
        }
        step++;
    }
}


@end
