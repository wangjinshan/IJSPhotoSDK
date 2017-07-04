//
//  IJSPreviewImageCell.h
//  JSPhotoSDK
//
//  Created by shan on 2017/6/6.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSAssetModel.h"
#import "IJSPreviewVideoView.h"
// 展示用的cell
@interface IJSPreviewImageCell : UICollectionViewCell

/* 所有的数据 */
@property(nonatomic,strong) IJSAssetModel *assetModel;
/* 视频界面 */
@property(nonatomic,weak)  IJSPreviewVideoView*videoView;

-(void) playLivePhotos;
-(void) stopLivePhotos;

@end



// 用户选中的cell的模型
@interface IJSSelectedCell :UICollectionViewCell

/* 选中的数据 */
@property(nonatomic,strong) IJSAssetModel *selectedModel;
/* 刷新UI的block */
@property(nonatomic,copy) void(^didClickButton)(BOOL isSelected);
/* 记录一下第一次进来的时候的index */
@property(nonatomic,assign) NSInteger pushSelectedIndex;

/* 参数说明 */
@property(nonatomic,weak) UIImageView *backImageView;



@end
