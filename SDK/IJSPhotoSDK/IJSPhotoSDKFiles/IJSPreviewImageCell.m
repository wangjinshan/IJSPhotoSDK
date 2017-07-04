//
//  IJSPreviewImageCell.m
//  JSPhotoSDK
//
//  Created by shan on 2017/6/6.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSPreviewImageCell.h"
#import "IJSImageManager.h"
#import "IJSConst.h"
#import "IJSPreviewGifView.h"

#import "IJSPreviewLivePhotoView.h"
@interface IJSPreviewImageCell ()

/* 背景 */
//@property(nonatomic,weak) UIImageView *backImageView;
/* gif视图 */
@property(nonatomic,weak) IJSPreviewGifView *gifView;
/* 图片视图 */
@property(nonatomic,weak) UIImageView *backImageView;

/* livephoto */
@property(nonatomic,weak) IJSPreviewLivePhotoView *livePhoto;

@end

@implementation IJSPreviewImageCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self)
    {
//        [self _createdUI:frame];
    }
    return self;
}
-(void)_createdUI:(CGRect)frame
{
//    self.gifView =[[IJSPreviewGifView alloc]init];
//    _gifView.backgroundColor =[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
//    [self.contentView addSubview:_gifView];
//    
//    _backImageView =[UIImageView new];
//    _backImageView.backgroundColor =[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
//    [self.contentView addSubview:_backImageView];
//    
//    _videoView =[IJSPreviewVideoView new];
//    _videoView.backgroundColor =[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
//    [self.contentView addSubview:_videoView];
//    
//    _livePhoto =[IJSPreviewLivePhotoView new];
//    _livePhoto.backgroundColor =[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
//    [self.contentView addSubview:_livePhoto];
    
}



-(IJSPreviewGifView *)gifView
{
    if (!_gifView)
    {
       IJSPreviewGifView *gifView =[[IJSPreviewGifView alloc]init];
         gifView.backgroundColor =[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        [self.contentView addSubview:gifView];
        _gifView = gifView;
    }
    return _gifView;
}
-(UIImageView *)backImageView
{
    if (!_backImageView)
    {
       UIImageView *backImageView =[UIImageView new];
        backImageView.backgroundColor =[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        [self.contentView addSubview:backImageView];
        _backImageView = backImageView;
    }
    return _backImageView;
}

-(IJSPreviewVideoView *)videoView
{
    if (!_videoView)
    {
       IJSPreviewVideoView *videoView =[IJSPreviewVideoView new];
        videoView.backgroundColor =[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        [self.contentView addSubview:videoView];
        _videoView = videoView;
    }
    return _videoView;
}
-(IJSPreviewLivePhotoView *)livePhoto
{
    if (!_livePhoto)
    {
        IJSPreviewLivePhotoView *livePhoto =[IJSPreviewLivePhotoView new];
        livePhoto.backgroundColor =[UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
        [self.contentView addSubview:livePhoto];
        _livePhoto = livePhoto;
    }
    return _livePhoto;
}

-(void)setAssetModel:(IJSAssetModel *)assetModel
{

    _assetModel = assetModel;
    __weak typeof (self) weakSelf = self;
    if (assetModel.type == JSAssetModelMediaTypePhoto)
    {
        
            [[IJSImageManager shareManager]getOriginalPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        weakSelf.backImageView.image = photo;
                    });
            }];
    
        self.gifView.hidden = YES;
        self.videoView.hidden = YES;
        self.livePhoto.hidden = YES;
        self.backImageView.hidden = NO;
        [self _setBackViewFrame:self.backImageView height:self.assetModel.assetHeight];
    }else if (assetModel.type == JSAssetModelMediaTypePhotoGif){
      
        self.gifView.assetModel = assetModel;
        self.gifView.hidden = NO;
        self.videoView.hidden = YES;
        self.livePhoto.hidden = YES;
        self.backImageView.hidden = YES;
        [self _setBackViewFrame:self.gifView height:self.assetModel.assetHeight];
    }else if (assetModel.type == JSAssetModelMediaTypeVideo){
        self.gifView.hidden = YES;
        self.videoView.hidden = NO;
        self.livePhoto.hidden = YES;
        self.backImageView.hidden = YES;
        self.videoView.assetModel = assetModel;
         [self _setBackViewFrame:self.videoView height:self.assetModel.assetHeight];
    }else if (assetModel.type == JSAssetModelMediaTypeLivePhoto){
        if (iOS9_1Later)
        {
            self.livePhoto.assetModel = assetModel;
            self.gifView.hidden = YES;
            self.videoView.hidden = YES;
            self.livePhoto.hidden = NO;
            self.backImageView.hidden = YES;
             [self _setBackViewFrame:self.livePhoto height:self.assetModel.assetHeight];
        }else{
           
            [[IJSImageManager shareManager]getOriginalPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info) {
                self.backImageView.image = photo;
            }];
            self.gifView.hidden = YES;
            self.videoView.hidden = YES;
            self.livePhoto.hidden = YES;
            self.backImageView.hidden = NO;
            [self _setBackViewFrame:self.backImageView height:self.assetModel.assetHeight];
        }
    }
}

-(void)layoutSubviews
{
    if (self.assetModel.type == JSAssetModelMediaTypeVideo)
    {
        [self _setBackViewFrame:self.videoView height:self.assetModel.assetHeight];
    }
    else if (self.assetModel.type == JSAssetModelMediaTypePhoto)
    {
        [self _setBackViewFrame:self.backImageView height:self.assetModel.assetHeight];
    }
    else if (self.assetModel.type == JSAssetModelMediaTypePhotoGif)
    {
        [self _setBackViewFrame:self.gifView height:self.assetModel.assetHeight];
    }
    else if (self.assetModel.type == JSAssetModelMediaTypeLivePhoto)
    {
         [self _setBackViewFrame:self.livePhoto height:self.assetModel.assetHeight];
    }
}

// 设置大小
-(void) _setBackViewFrame:(UIView *)view height:(CGFloat)height
{
    view.frame =CGRectMake(0, 0, JSScreenWidth, height);
    view.center =  CGPointMake(JSScreenWidth / 2, JSScreenHeight / 2 );
}


-(void) playLivePhotos
{
    [self.livePhoto playLivePhotos];
}
-(void) stopLivePhotos
{
    [self.livePhoto stopLivePhotos];
}

@end







// 用户选中的cell的模型
@interface IJSSelectedCell ()

@end

@implementation IJSSelectedCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        UIImageView *backImageView = [[UIImageView alloc]init];
        backImageView.contentMode = UIViewContentModeScaleAspectFill;
        backImageView.clipsToBounds = YES;
        backImageView.frame= CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10);
        [self.contentView addSubview:backImageView];
        self.backImageView = backImageView;
    }
    return self;
}

-(void) setSelectedModel:(IJSAssetModel *)selectedModel
{
    _selectedModel = selectedModel;

    [[IJSImageManager shareManager]getPhotoWithAsset:selectedModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {

        _backImageView.image = photo;
        
    }];

                    _backImageView.layer.borderWidth = 0;
                    _backImageView.layer.cornerRadius = 0;
                    _backImageView.clipsToBounds=YES;
    
    if (self.pushSelectedIndex == selectedModel.onlyOneTag && selectedModel.isFirstAppear)
    {// 第一次
                _backImageView.layer.borderWidth = 2;
                _backImageView.layer.cornerRadius = 3;
                _backImageView.layer.borderColor=[[UIColor greenColor]CGColor];//设置边框的颜色
                _backImageView.clipsToBounds=YES;
    }
}




@end





