//
//  IJSImageDrawTool.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/14.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageToolBase.h"
#import "IJSIPanDrawingView.h"
/*
 *  绘画类
 */
@interface IJSImageDrawTool : IJSImageToolBase

@property (nonatomic, weak) IJSIPanDrawingView *panDrawingView; // 绘画的view

@end
