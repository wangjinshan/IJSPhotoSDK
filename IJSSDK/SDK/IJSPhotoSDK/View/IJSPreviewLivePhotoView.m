//
//  IJSPreviewLivePhotoView.m
//  JSPhotoSDK
//
//  Created by shan on 2017/6/15.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSPreviewLivePhotoView.h"
#import <PhotosUI/PhotosUI.h>
#import "IJSImageManager.h"
#import "IJSAssetModel.h"
#import "IJSConst.h"

@interface IJSPreviewLivePhotoView ()

/* 播放视图 */

@property (nonatomic, weak) PHLivePhotoView *backLivePhtotoView;

@end

@implementation IJSPreviewLivePhotoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _createdUI];
    }
    return self;
}

- (void)_createdUI
{
    if (iOS9_1Later)
    {
        PHLivePhotoView *backLivePhotoView = [PHLivePhotoView new];
        backLivePhotoView.backgroundColor = [UIColor whiteColor];
        self.backLivePhtotoView = backLivePhotoView;
        self.backLivePhtotoView.userInteractionEnabled = NO;
        [self addSubview:backLivePhotoView];
    }
}

- (void)layoutSubviews
{
    self.backLivePhtotoView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setAssetModel:(IJSAssetModel *)assetModel
{
    _assetModel = assetModel;

    if (iOS9_1Later)
    {
        __weak typeof(self) weakSelf = self;
        if (assetModel.imageRequestID)
        {
            [[PHImageManager defaultManager] cancelImageRequest:assetModel.imageRequestID];  // 取消加载
        }
        assetModel.imageRequestID = [[IJSImageManager shareManager] getLivePhotoWithAsset:assetModel.asset photoWidth:JSScreenWidth networkAccessAllowed:YES completion:^(PHLivePhoto *livePhoto, NSDictionary *info) {
            weakSelf.backLivePhtotoView.livePhoto = livePhoto;
          
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info){
            if (error)
            {
                assetModel.imageRequestID = 0;
            }
        }];
    }
}

- (void)playLivePhotos
{
    if (iOS9_1Later)
    {
        [self.backLivePhtotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
    }
}
- (void)stopLivePhotos
{
    [self.backLivePhtotoView stopPlayback];
}

@end
