//
//  IJSVideoEditController.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/21.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
/**
 * 视频编辑类
 */
@interface IJSVideoEditController : UIViewController

@property (nonatomic, strong) NSURL *outputPath; // 裁剪完成界面的视频路径

@property (nonatomic, strong) NSMutableArray *mapImageArr; // 贴图数据

@end
