//
//  IJSPreviewVideoView.m
//  JSPhotoSDK
//
//  Created by shan on 2017/6/15.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSPreviewVideoView.h"
#import "IJSImageManager.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"
#import "IJSImageManager.h"
#import "IJSAssetModel.h"
@interface IJSPreviewVideoView ()
/* 播放视频的界面 */
@property(nonatomic,weak) UIImageView *backVideoView;

/* 是否允许网络 */
@property(nonatomic,assign) BOOL networkAccessAllowed;

/* AVPlayerLayer */
@property(nonatomic,strong) AVPlayerLayer *playerLayer;

@end


@implementation IJSPreviewVideoView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
         [self _createdUI];
    }
    return self;
}
-(void)_createdUI
{
    UIImageView *backVideoView =[UIImageView new];
    backVideoView.backgroundColor =[UIColor whiteColor];
    [self addSubview:backVideoView];
    self.backVideoView = backVideoView;

    UIButton *playButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [playButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:@"" grandson:@"" imageName:@"MMVideoPreviewPlay@2x" imageType:@"png"] forState:UIControlStateNormal];

    self.playButton = playButton;
    [self addSubview:playButton];
    [self bringSubviewToFront:playButton];
    self.playButton.userInteractionEnabled = NO;
        
}


-(void)setAssetModel:(IJSAssetModel *)assetModel
{
    _assetModel = assetModel;
   
    [self.playerLayer removeFromSuperlayer];
    __weak typeof (self) weakSelf = self;
    [[IJSImageManager shareManager]getVideoWithAsset:assetModel.asset networkAccessAllowed:assetModel.networkAccessAllowed progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    
    } completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        // 注意必须在主线程中操作
        dispatch_async(dispatch_get_main_queue(), ^{
            _player = [AVPlayer playerWithPlayerItem:playerItem];
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            playerLayer.frame = self.bounds;
            [weakSelf.backVideoView.layer addSublayer:playerLayer];
            weakSelf.playerLayer = playerLayer;
        });
    }];
}

-(void)layoutSubviews
{
    self.backVideoView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.playButton.frame = CGRectMake(0, 0, 80, 80);
    self.playButton.center = self.backVideoView.center;
}








@end
