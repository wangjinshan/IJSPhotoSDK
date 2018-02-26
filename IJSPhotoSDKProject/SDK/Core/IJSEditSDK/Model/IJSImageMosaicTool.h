//
//  IJSImageMosaicTool.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/23.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageToolBase.h"
#import "IJSImageGaussanView.h"
#import "IJSImageMosaicView.h"
typedef NS_ENUM(NSUInteger, JSGraffitiType) {
    JSMosaicType,
    JSGaussanType,
};

@interface IJSImageMosaicTool : IJSImageToolBase

@property (nonatomic, assign) JSGraffitiType graffitiType; // 涂鸦模式

@property (nonatomic, weak) UIImage *mosaicToolGaussanImage; // 外界传入的高斯图

@property (nonatomic, weak) IJSImageMosaicView *mosaicView;   // 马赛克视图
@property (nonatomic, weak) IJSImageGaussanView *guassanView; // 高斯视图

@end
