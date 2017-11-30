//
//  IJSVideoRulerView.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 刻度尺
 */

@interface IJSVideoRulerView : UIView

/**
 *  默认初始化方法
 *
 *  @param widthPerSecond       单位长度
 *  @param themeColor    颜色
 *  @param slideWidth  左边距  默认是 10
 *  @param assetDuration    视频总长度,也就是刻度的总个数
 *
 */
- (instancetype)initWithFrame:(CGRect)frame widthPerSecond:(CGFloat)widthPerSecond themeColor:(UIColor *)themeColor slideWidth:(CGFloat)slideWidth assetDuration:(CGFloat)assetDuration;


@end
