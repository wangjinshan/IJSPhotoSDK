//
//  IJSVideoCutController.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/14.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IJSVideoManagerController.h"

/**
 * 视频裁剪类
 */

@interface IJSVideoCutController : IJSVideoManagerController


@property (nonatomic, assign) BOOL canEdit; // 进入编辑界面

@property(nonatomic,copy) void(^completeHandler)(NSURL *outputPath, NSError *error);  // 数据保存
@property(nonatomic,copy) void(^cancelHandler)(void);  // 取消

@end



