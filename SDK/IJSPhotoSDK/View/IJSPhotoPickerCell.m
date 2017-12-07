//
//  IJSPhotoPickerCell.m
//  JSPhotoSDK
//
//  Created by shan on 2017/6/2.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSPhotoPickerCell.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"
#import "IJSImageManager.h"
#import "IJSAssetModel.h"
#import "IJSImagePickerController.h"

#import "IJSConst.h"
#import "IJSExtension.h"

@interface IJSPhotoPickerCell ()

/* 左上角live标识 */
@property (nonatomic, weak) UIButton *livePhotoButton;
/* 图片的唯一标识 */
@property (nonatomic, strong) NSString *representedAssetIdentifier;
/* 视频 */
@property (nonatomic, weak) UIButton *videoButton;
/* 背景图 */
@property (nonatomic, weak) UIImageView *backImageView;
/* 需要外部修改的右上角图片 */
@property (nonatomic, weak) UIButton *selectButton;
/* 多选的蒙版 */
@property (nonatomic, weak) UIView *maskView;

@end

@implementation IJSPhotoPickerCell
{
    BOOL _select;
}

#pragma mark 懒加载区域
-(UIImageView *)backImageView
{
    if (_backImageView == nil)
    {
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.js_width,self.js_height)];
        backImageView.backgroundColor = [UIColor whiteColor];
        backImageView.clipsToBounds = YES;
        backImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:backImageView];
        _backImageView = backImageView;
    }
    return _backImageView;
}

-(UIButton *)selectButton
{
    if (_selectButton == nil)
    {
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame = CGRectMake(self.js_width - ButtonHeight, 0, ButtonHeight, ButtonHeight);
        [selectButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"] forState:UIControlStateNormal];
        [selectButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_number_icon@2x" imageType:@"png"] forState:UIControlStateSelected];
        [selectButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectButton];
        _selectButton = selectButton;
    }
    return _selectButton;
}
-(UIButton *)livePhotoButton
{
    if (_livePhotoButton == nil)
    {
        UIButton *livePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        livePhotoButton.frame = CGRectMake(2, 0, ButtonHeight, ButtonHeight);
        [livePhotoButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"live@2x" imageType:@"png"] forState:UIControlStateNormal];
        [self.contentView addSubview:livePhotoButton];
        _livePhotoButton = livePhotoButton;
    }
    return _livePhotoButton;
}
-(UIButton *)videoButton
{
    if (_videoButton == nil)
    {
        UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        videoButton.frame = CGRectMake(0, self.js_height - 10, self.js_width, 10);
        [videoButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"VideoSendIcon@2x" imageType:@"png"] forState:UIControlStateNormal];
        [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        videoButton.titleLabel.font = [UIFont systemFontOfSize:12];
        videoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        videoButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
        videoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:videoButton];
        _videoButton = videoButton;
    }
    return _videoButton;
}
-(UIView *)maskView
{
    if (_maskView == nil)
    {
        UIView *maskView = [[UIView alloc] initWithFrame:_backImageView.frame];
        maskView.backgroundColor = [IJSFColor colorWithR:230 G:230 B:230 alpha:0.8];
        [self.contentView addSubview:maskView];
        _maskView = maskView;
        maskView.hidden = YES;
        [self bringSubviewToFront:maskView];
    }
    return _maskView;
}

#pragma mark 数据解析
- (void)setModel:(IJSAssetModel *)model
{
    _model = model;
    self.backImageView.image = nil;
    [self.videoButton setTitle:model.timeLength forState:UIControlStateNormal];
    if (model.type != JSAssetModelMediaTypeLivePhoto)
    {
        self.livePhotoButton.hidden = YES;
    }
    
    self.representedAssetIdentifier = [[IJSImageManager shareManager] getAssetIdentifier:model.asset]; //设置资源唯一标识
    __weak typeof(self) weakSelf = self;

    // 选择性加载图片裁剪的图片
    if (model.outputPath)
    {
        NSData *resultData = [NSData dataWithContentsOfURL:model.outputPath];
        UIImage *resultImage = [UIImage imageWithData:resultData];
        _backImageView.image = resultImage;
    }
    else
    {
        if (model.imageRequestID)
        {
            [[PHImageManager defaultManager] cancelImageRequest:model.imageRequestID];
        }
        model.imageRequestID =  [[IJSImageManager shareManager] getPhotoWithAsset:model.asset photoWidth:self.js_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            
            if ([weakSelf.representedAssetIdentifier isEqualToString:[[IJSImageManager shareManager] getAssetIdentifier:model.asset]])
            {
                weakSelf.backImageView.image = photo;
            }
            else
            {
                [[PHImageManager defaultManager] cancelImageRequest:model.imageRequestID];
            }
            if (!isDegraded)
            {
                model.imageRequestID = 0;
            }
        } progressHandler:nil networkAccessAllowed:NO];
    }
    // 改变button的状态
    _select = model.isSelectedModel;
    _selectButton.selected = model.isSelectedModel;

    NSString *buttonTitle = [NSString stringWithFormat:@"%zd", model.cellButtonNnumber];
    if (model.cellButtonNnumber == 0)
    {
        buttonTitle = nil;
    }
    // 给button 加数据
    [_selectButton setTitle:_select ? buttonTitle : nil forState:0];

    // 蒙版
    if (model.didMask)
    {
        self.maskView.hidden = NO;
        for (IJSAssetModel *temp in model.didClickModelArr)
        {
            if (temp.onlyOneTag == model.onlyOneTag)
            {
                self.maskView.hidden = YES;
            }
        }
    }
    else
    {
        self.maskView.hidden = YES;
    }
    // 给模型的button加tag 用于回传数据使用
    _selectButton.tag = model.onlyOneTag;
}

- (void)setType:(JSAssetModelSourceType)type
{
    _type = type;
    self.allowPickingGif = NO;
     self.backImageView.hidden = NO;
    if (type == JSAssetModelMediaTypePhoto) // image
    {
        self.livePhotoButton.hidden = YES;
        self.videoButton.hidden = YES;
        self.selectButton.hidden = NO;
    }
    else if (type == JSAssetModelMediaTypeLivePhoto) // LivePhoto
    {
        self.selectButton.hidden = NO;
        self.videoButton.hidden = YES;
        self.livePhotoButton.hidden = NO;
    }
    else if (type == JSAssetModelMediaTypePhotoGif) //Gif
    {
        self.livePhotoButton.hidden = YES;
        self.videoButton.hidden = YES;
        self.selectButton.hidden = NO;
    }
    else //  video
    {
        self.selectButton.hidden = YES;
        self.livePhotoButton.hidden = YES;
        self.videoButton.hidden = NO;
    }
}

/*-----------------------------------点击-------------------------------------------------------*/
#pragma mark 选择图片
- (void)selectPhotoButtonClick:(UIButton *)button
{
    // 添加弹跳动画
     [button addSpringAnimation];
    _select = !_select; //改变button的状态 刷新ui
    if ([self.cellDelegate respondsToSelector:@selector(didClickCellButtonWithButton:ButtonState:buttonIndex:)])
    {
        [self.cellDelegate didClickCellButtonWithButton:button ButtonState:_select buttonIndex:button.tag];
    }
}

- (void)seeLivePhoto:(UIButton *)button
{
}

@end
