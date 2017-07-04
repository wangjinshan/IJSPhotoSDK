//
//  IJSPreviewVideoView.h
//  JSPhotoSDK
//
//  Created by shan on 2017/6/15.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVPlayer.h>
@class IJSAssetModel;
@interface IJSPreviewVideoView : UIView


/* 数据模型 */
@property(nonatomic,strong) IJSAssetModel *assetModel;


/* 视频播放器 */
@property(nonatomic,strong) AVPlayer *player;
/* 中间播放的按钮 */
@property(nonatomic,weak) UIButton *playButton;



@end
