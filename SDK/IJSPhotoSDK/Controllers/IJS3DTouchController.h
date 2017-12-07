//
//  IJS3DTouchController.h
//  JSPhotoSDK
//
//  Created by shan on 2017/6/24.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSAssetModel.h"
/*
 * 3DTouch控制器
 */
@interface IJS3DTouchController : UIViewController

/* 模型数据 */
@property (nonatomic, strong) IJSAssetModel *model;

@end


// 日志
/*
 0.1.2
 考虑到内存性能问题,暂时不使用3DTouch
 */
