//
//  IJSVideoCutController.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/14.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 视频裁剪类
 */
#import <AVFoundation/AVFoundation.h>
#import "IJSAssetModel.h"
#import "IJSVideoManager.h"

@interface IJSVideoCutController : UIViewController

@property (nonatomic, strong) AVAsset *avasset; // 编辑的资源

@property (nonatomic, strong) IJSAssetModel *assetModel; // 相册资源数据

@property (nonatomic, assign) CGFloat minCutTime; // 最小截取时间 > 1
@property (nonatomic, assign) CGFloat maxCutTime; // 最大截取时间 > 10

@property (nonatomic, strong) NSMutableArray *mapImageArr; // 贴图数据

@property (nonatomic, assign) BOOL secondCut; // 二次裁剪界面

@end
