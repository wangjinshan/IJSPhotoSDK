//
//  IJSPhotoPickerController.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *  图片选择控制器,默认是4列显示
 */
@class IJSAlbumModel;

typedef void (^callBackReload)(NSMutableArray *selectedModel, NSMutableArray *allAssetModel);

@interface IJSPhotoPickerController : UIViewController

/* 是否为第一次出现 */
@property (nonatomic, assign) BOOL isFirstAppear;
/* 显示的列数 */
@property (nonatomic, assign) NSInteger columnNumber;
/* 数据模型 */
@property (nonatomic, strong) IJSAlbumModel *albumModel;

/* 数据回调刷新表格 */
@property (nonatomic, copy) callBackReload callBack;

@end
