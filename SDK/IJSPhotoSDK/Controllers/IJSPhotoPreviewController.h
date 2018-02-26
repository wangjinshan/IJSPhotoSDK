//
//  IJSPhotoPreviewController.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSImagePickerController.h"
@class IJSAssetModel;
/*
 *  照片预览控制器
 */

@interface IJSPhotoPreviewController : UIViewController
//不管有没有值都需要传递----否则导致无数据崩溃
/* 接受用户选中的相册 */
@property (nonatomic, strong) NSMutableArray<IJSAssetModel *> *selectedModels;
/* 所有的数据 */
@property (nonatomic, strong) NSMutableArray<IJSAssetModel *> *allAssetModelArr;
/* 预览模式传递一个当前控制器不可改变的数组,大图展示的数据,预览模式进来和selectedModels相同,内部不能增删*/
@property (nonatomic, strong) NSMutableArray<IJSAssetModel *> *previewAssetModelArr;

/* 当前选中的坐标 */
@property (nonatomic, assign) NSInteger pushSelectedIndex;
/* 预览控制,yes表示在预览模式下跳转 */
@property (nonatomic, assign) BOOL isPreviewButton;

@property(nonatomic,copy) void(^selectedHandler)(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType,NSError *error);  // 数据回调

@property(nonatomic,copy) void(^cancelHandler)(void);  // 取消选择的属性



@end
