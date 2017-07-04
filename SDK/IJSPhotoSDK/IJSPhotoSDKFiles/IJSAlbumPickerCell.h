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
/*-----------------------------------ui常量-------------------------------------------------------*/
//static CGFloat const thumbImageMarginTop = 2;
//static CGFloat const thumbImageMarginleft =  2;
//static CGFloat const thumbImageViewWidth =  55;
//static CGFloat const thumbImageViewHeight =  55;
//static CGFloat const titleFontSize =  17;
//static CGFloat const titleMarginLeft =  10;
//static CGFloat const titleMarginTop =  20;
//static CGFloat const titleHeight =  20;
//static CGFloat const numberWidth =  50;
//static CGFloat const numberHeight =  20;
//static CGFloat const arrowImageWidth =  10;
//static CGFloat const arrowImageHeight =  10;
//static CGFloat const arrowImageMarginTop =  20;
//static CGFloat const arrowImageMarginRight =  20;


@interface IJSAlbumPickerCell : UITableViewCell

/* 展示数据 */
@property(nonatomic,strong) IJSAlbumModel *models;


@end
