//
//  IJSDrawingController.h
//  IJSUExtension
//
//  Created by shan on 2017/8/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IJSDrawingController : UIViewController
@property (nonatomic, strong) UIImage *originImage;                 // 原始图
@property (nonatomic, copy) void (^finishCallBack)(UIImage *image); // 完成

@end
