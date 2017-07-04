//
//  IJSPhotoPreviewController.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IJSAssetModel;
/*
 *  照片预览控制器
 */


@interface IJSPhotoPreviewController : UIViewController

/* 接受用户选中的相册 */
@property(nonatomic,strong) NSMutableArray<IJSAssetModel *> *selectedModels;
/* 所有的数据 */
@property(nonatomic,strong) NSMutableArray<IJSAssetModel *> *allAssetModelArr;

/* 当前选中的坐标 */
@property(nonatomic,assign) NSInteger pushSelectedIndex;
/* 预览控制 */
@property(nonatomic,assign)  BOOL isPreviewButton;


@end
