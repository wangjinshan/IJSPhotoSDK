//
//  IJSDExportView.h
//  IJSUExtension
//
//  Created by shan on 2017/8/3.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSDrawingModel.h"

@interface IJSDExportView : UIView

@property (nonatomic, strong) UIImage *drawImage; // 绘制图

@property (nonatomic, copy) void (^finishCallBack)(IJSDrawingModel *model); // 宽度

@end
