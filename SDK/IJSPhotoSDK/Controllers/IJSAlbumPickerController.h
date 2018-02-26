//
//  IJSAlbumPickerController.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSImagePickerController.h"

/*
 *  相册列表控制器
 */

@interface IJSAlbumPickerController : UIViewController
/* 列数 */
@property (nonatomic, assign) NSInteger columnNumber;

@property(nonatomic,copy) void(^selectedHandler)(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType,NSError *error);  // 数据回调

@property(nonatomic,copy) void(^cancelHandler)(void);  // 取消选择的属性

@end
