//
//  IJSVideoManagerController.h
//  IJSEditSDKSimple
//
//  Created by 山神 on 2017/12/11.
//  Copyright © 2017年 山神. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IJSVideoManager.h"

@protocol IJSVideoManagerControllerDelegate;

@interface IJSVideoManagerController : UIViewController

@property (nonatomic, strong) NSURL *inputPath; // 传进需要裁剪的视频路径

@property (nonatomic, assign) CGFloat minCutTime; // 最小截取时间 > 1
@property (nonatomic, assign) CGFloat maxCutTime; // 最大截取时间 > 10

@property (nonatomic, strong) NSMutableArray *mapImageArr; // 贴图数据

@property(nonatomic,weak) id<IJSVideoManagerControllerDelegate > delegate;  // 代理属性

@property(nonatomic,copy) void(^didFinishCutVideoCallBack)(IJSVideoManagerController *controller ,NSURL *outputPath,NSError *error,IJSVideoState state) ;  // 数据回调


@end

// 数据回调的方法
@protocol IJSVideoManagerControllerDelegate <NSObject>

-(void)didFinishCutVideoWithController:(IJSVideoManagerController *)controller  outputPath:(NSURL *)outputPath error:(NSError *)error state:(IJSVideoState)state;

@end
