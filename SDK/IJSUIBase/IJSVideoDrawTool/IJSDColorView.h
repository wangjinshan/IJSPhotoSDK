//
//  IJSDColorView.h
//  IJSUExtension
//
//  Created by shan on 2017/8/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IJSDColorView : UIView

@property (nonatomic, copy) void (^rCallBack)(CGFloat width, UIColor *color);     // r
@property (nonatomic, copy) void (^gCallBack)(CGFloat width, UIColor *color);     // g
@property (nonatomic, copy) void (^bCallBack)(CGFloat width, UIColor *color);     // b
@property (nonatomic, copy) void (^widthCallBack)(CGFloat width, UIColor *color); // 宽度

@end
