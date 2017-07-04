//
//  IJSPhotoPickerCell.h
//  JSPhotoSDK
//
//  Created by shan on 2017/6/2.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "IJSAssetModel.h"
#define MarginTop 2
#define ButtonHeight 25



@interface IJSPhotoPickerCell : UICollectionViewCell

/* 数据模型 */
@property (nonatomic, strong) IJSAssetModel *model;
/* 图片请求的ID */
@property (nonatomic, assign) PHImageRequestID imageRequestID;
/* type 用于显示控件*/
@property(nonatomic,assign)  JSAssetModelSourceType type;
/* 选择gif */
@property (nonatomic, assign) BOOL allowPickingGif;
/* 选中照片 */
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL, NSIndexPath *) ;


/* 需要外部修改的右上角图片 */
@property(nonatomic,weak) UIButton *selectButton;
/* 背景图 */
@property(nonatomic,weak) UIImageView *backImageView;
/* 多选的蒙版 */
@property(nonatomic,weak) UIView *maskView;
/* 回传的indexpath */
@property (nonatomic, strong) NSIndexPath *indexPath;





@end
