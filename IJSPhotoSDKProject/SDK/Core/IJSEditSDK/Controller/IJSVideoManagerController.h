//
//  IJSVideoManagerController.h
//  IJSEditSDKSimple
//
//  Created by 山神 on 2017/12/11.
//  Copyright © 2017年 山神. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "IJSVideoManager.h"

@interface IJSVideoManagerController : UIViewController

@property (nonatomic, strong) NSURL *inputPath; // 传进需要裁剪的视频路径

@property (nonatomic, assign) CGFloat minCutTime; // 最小截取时间 > 1
@property (nonatomic, assign) CGFloat maxCutTime; // 最大截取时间 > 10

@property (nonatomic, strong) NSMutableArray *mapImageArr; // 贴图数据


/**
 数据回调方法

 @param complete 回调的数据 outputPath 视频的输出路径 NSError 错误信息
 */
-(void)loadVideoOnCompleteResult:(void(^)(NSURL *outputPath, NSError *error))complete;
/**
 取消选择
 
 @param cancelHandler 取消的回调
 */
-(void)cancelSelectedData:(void(^)(void))cancelHandler;

@end


