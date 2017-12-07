//
//  IJSVideoTrimView.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
/**
 * 微调控制板
 */
@protocol IJSVideoTrimViewDelegate;

@interface IJSVideoTrimView : UIView

@property (nonatomic, weak, nullable) id<IJSVideoTrimViewDelegate> delegate; // 协议属性

/**
 *  默认初始化方法
 *
 *  @param frame       尺寸
 *  @param minCutTime    最小裁剪时间
 *  @param maxCutTime  最大裁剪时间
 *  @param assetDuration  视频总长度
 *  @param avasset  视频资源
 *
 */
- (instancetype _Nullable)initWithFrame:(CGRect)frame minCutTime:(CGFloat)minCutTime maxCutTime:(CGFloat)maxCutTime assetDuration:(CGFloat)assetDuration avAsset:(AVAsset *_Nonnull)avasset;
/**
 * 通知一下代理-----需要在外面直接调用
 */
- (void)getVideoLenghtThenNotifyDelegate;

/**
 * 更改中间白线的位置, 视频时间 time
 */
- (void)changeTrackerViewOriginX:(CGFloat)time;

@end

@protocol IJSVideoTrimViewDelegate <NSObject>
/**
 *  完成裁剪进行回调
 *
 *  @param trimView       视图对象
 *  @param startTime    开始时间
 *  @param endTime  结束时间
 *  @param length     视频的长度
 *
 */
- (void)trimView:(IJSVideoTrimView *_Nonnull)trimView startTime:(CGFloat)startTime endTime:(CGFloat)endTime videoLength:(CGFloat)length;

@end

/*
 设计思路:
 默认宽度就是显示的最大尺寸,只需要设置最小的尺寸

 */
