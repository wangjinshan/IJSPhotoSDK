//
//  IJSVideoEditController.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/21.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSVideoManagerController.h"
/**
 * 视频编辑类
 */

@interface IJSVideoEditController : IJSVideoManagerController


@property(nonatomic,copy) void(^completeHandler)(NSURL *outputPath, NSError *error);  // 数据保存
@property(nonatomic,copy) void(^cancelHandler)(void);  // 取消



@end


