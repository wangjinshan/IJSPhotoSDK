//
//  IJSPreviewImageCell.h
//  JSPhotoSDK
//
//  Created by shan on 2017/6/6.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 展示图片视频预览的大cell
 */
#import "IJSAssetModel.h"
#import "IJSPreviewVideoView.h"
// 展示用的cell
@protocol IJSPreviewImageCellDelegate;

@interface IJSPreviewImageCell : UICollectionViewCell

/* 所有的数据 */
@property (nonatomic, weak) IJSAssetModel *assetModel;
/* 视频界面 */
@property (nonatomic, weak) IJSPreviewVideoView *videoView;
/* 缩放用的scrollview */
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, weak) id<IJSPreviewImageCellDelegate> cellDelegate; // cell的代理方法

- (void)playLivePhotos;
- (void)stopLivePhotos;

@end
///为了优化内存问题,使用代理方法
/*
 * 协议
 */
@protocol IJSPreviewImageCellDelegate <NSObject>

- (void)didClickCellToHiddenNavigationAndToosWithCell:(IJSPreviewImageCell *)cell hiddenToolsStatus:(BOOL)hiddenToolsStatus;

@end
