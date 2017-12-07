//
//  IJSDrawingModel.h
//  IJSUExtension
//
//  Created by shan on 2017/8/3.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IJSDrawingModel : NSObject

@property (nonatomic, assign) CGFloat pathWidth;  // 宽度
@property (nonatomic, strong) UIColor *pathColor; // 颜色
@property (nonatomic, strong) UIBezierPath *path; // 路径

@property (nonatomic, strong) UIImage *drawingImage; // 绘画的图片
@property (nonatomic, assign) CGRect drawingRect;    // 绘画的坐标

@end
