//
//  IJSAlbumPickerCell.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSAlbumModel.h"
/*
 * 相册列表的cell
 */

@interface IJSAlbumPickerCell : UITableViewCell

/* 展示数据 */
@property (nonatomic, weak) IJSAlbumModel *models;

@end
