//
//  IJSPreviewVideoView.h
//  JSPhotoSDK
//
//  Created by shan on 2017/6/15.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class IJSAssetModel;

@interface IJSPreviewVideoView : UIView

/* 数据模型 */
@property (nonatomic, weak) IJSAssetModel *assetModel;

@property (nonatomic, strong) AVPlayer *player;         /* 视频播放器 */
@property (nonatomic, weak) UIButton *playButton;       /* 中间播放的按钮,按钮不可以点击当做一个UIView */
@property (nonatomic, weak) UIImageView *backVideoView; /* 播放视频的界面 */

@end
