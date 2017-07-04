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
#import "UIView+IJSPhotoLayout.h"

#import "IJSConst.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"
@interface IJSPhotoPickerCell ()


/* 左上角live标识 */
@property(nonatomic,weak) UIButton *livePhotoButton;
/* 图片的唯一标识 */
@property(nonatomic,strong) NSString *representedAssetIdentifier;
/* 视频 */
@property(nonatomic,weak) UIButton *videoButton;

@end


@implementation IJSPhotoPickerCell
{
    BOOL _select;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self)
    {
        [self _createrUI:frame];
    }
    return self;
}

-(void)_createrUI:(CGRect)frame
{
    UIImageView *backImageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, MarginTop, frame.size.width, frame.size.height)];
    backImageView.backgroundColor =[UIColor whiteColor];
    backImageView.clipsToBounds = YES;
    backImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:backImageView];
    self.backImageView =backImageView;
    
    UIButton *selectButton =[UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.frame = CGRectMake(frame.size.width - 27, 0, ButtonHeight, ButtonHeight);
    [selectButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"] forState:UIControlStateNormal];
     [selectButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_number_icon@2x" imageType:@"png"] forState:UIControlStateSelected];
     [selectButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectButton];
    self.selectButton = selectButton;
    
    UIButton *livePhotoButton =[UIButton buttonWithType:UIButtonTypeCustom];
    livePhotoButton.frame = CGRectMake(2, 0, ButtonHeight, ButtonHeight);
     [livePhotoButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"live" imageType:@"png"] forState:UIControlStateNormal];
    [livePhotoButton addTarget:self action:@selector(seeLivePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:livePhotoButton];
    self.livePhotoButton = livePhotoButton;
    
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoButton.frame = CGRectMake(0, frame.size.height - 10,frame.size.width, 10);
    [videoButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"VideoSendIcon@2x" imageType:@"png"] forState:UIControlStateNormal];
    [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    videoButton.titleLabel.font =[UIFont systemFontOfSize:9];
    videoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    videoButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
    videoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:videoButton];
    self.videoButton = videoButton;
    
    UIView *maskView =[[UIView alloc]initWithFrame:backImageView.frame];
    maskView.backgroundColor =[IJSFColor colorWithR:230 G:230 B:230 alpha:0.6];
    [self.contentView addSubview:maskView];
    self.maskView = maskView;
    maskView.hidden = YES;
}


#pragma mark 数据解析
-(void)setModel:(IJSAssetModel *)model
{
    _model = model;
    [self.videoButton setTitle:self.model.timeLength forState:UIControlStateNormal];
    
    if (model.type != JSAssetModelMediaTypeLivePhoto)
    {
        self.livePhotoButton.hidden = YES;
    }
    if (iOS8Later)
    {
        self.representedAssetIdentifier = [[IJSImageManager shareManager] getAssetIdentifier:model.asset];
    }
    __weak typeof (self) weakSelf = self;
    
    [[IJSImageManager shareManager]getPhotoWithAsset:model.asset photoWidth:self.js_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        
        if (!iOS8Later)
        {
            weakSelf.backImageView.image = photo; return;
        }
        if ([weakSelf.representedAssetIdentifier isEqualToString:[[IJSImageManager shareManager] getAssetIdentifier:model.asset]])
        {
            weakSelf.backImageView.image = photo;
        }
        else
        {
            [[PHImageManager defaultManager] cancelImageRequest:weakSelf.imageRequestID];
        }
        if (!isDegraded)
        {
            weakSelf.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    
    // 改变button的状态
    _select = model.isSelectedModel;
    _selectButton.selected = model.isSelectedModel;

    NSString *buttonTitle = [NSString stringWithFormat:@"%zd",model.cellButtonNnumber];
    if (model.cellButtonNnumber == 0)
    {
        buttonTitle = nil;
    }
    // 给button 加数据
    [_selectButton setTitle:_select ?  buttonTitle : nil forState:0];
    
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

}

- (void)setType:(JSAssetModelSourceType)type
{
    _type = type;
    self.allowPickingGif = NO;
    if (type == JSAssetModelMediaTypePhoto)  // image
    {
        _livePhotoButton.hidden = YES;
        _videoButton.hidden = YES;
        _selectButton.hidden = NO;
    }
    else if (type == JSAssetModelMediaTypeLivePhoto)   // LivePhoto
    {
        _selectButton.hidden = NO;
        _videoButton.hidden = YES;
        _livePhotoButton.hidden = NO;
    }
    else if (type == JSAssetModelMediaTypePhotoGif)     //Gif
    {
        _livePhotoButton.hidden = YES;
        _videoButton.hidden = YES;
        _selectButton.hidden = NO;
    }
    else     //  video
    {
        _selectButton.hidden = YES;
        _livePhotoButton.hidden = YES;
        _videoButton.hidden = NO;
    }
}

/*-----------------------------------点击-------------------------------------------------------*/
#pragma mark 选择图片
-(void)selectPhotoButtonClick:(UIButton *)button
{
    // 添加弹跳动画
        [button addSpringAnimation];
    _select = !_select;   //改变button的状态 刷新ui
    if (self.didSelectPhotoBlock)
    {
        self.didSelectPhotoBlock(_select, self.indexPath);
    }
}




-(void)seeLivePhoto:(UIButton *)button
{
    NSLog(@"eeee");
}

























@end
