//
//  IJSIPath.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/26.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*
 * 画线类
 */
@interface IJSIPath : NSObject

@property (nonatomic, strong) CAShapeLayer *shape;
@property (nonatomic, strong) UIColor *pathColor; //画笔颜色

+ (instancetype)pathToPoint:(CGPoint)beginPoint pathWidth:(CGFloat)pathWidth;
- (void)pathLineToPoint:(CGPoint)movePoint; //加点
- (void)drawPath;                           //绘制

@end
