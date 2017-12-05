//
//  IJSImageEditController.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSImageManagerController.h"
/**
 * 图片裁剪控制器
 */
typedef NS_ENUM(NSUInteger, IJSIEditMode) {
    IJSINoneMode,
    IJSIDrawMode,
    IJSIPaperMode,
    IJSITextMode,
    IJSIClipMode,
    IJSIMosaicMode,
};

@interface IJSImageEditController : IJSImageManagerController

/*-----------------------------------内部使用数据-------------------------------------------------------*/

@property (nonatomic, strong) UIScrollView *backScrollView; // 背景scrollview
@property (nonatomic, strong) UIImageView *backImageView;   // 背景图
@property (nonatomic, strong) UIImageView *drawingView;     // 绘画的view图层
@property (nonatomic, strong) UIColor *panColor;            //颜色
@property (nonatomic, assign) CGFloat panWidth;             // 线宽
@property (nonatomic, strong) NSString *textViewText;       // 获取的文字

@end
