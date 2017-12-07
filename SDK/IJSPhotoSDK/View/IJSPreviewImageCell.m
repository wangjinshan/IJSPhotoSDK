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
#import "IJSExtension.h"
@interface IJSPreviewImageCell () <UIScrollViewDelegate>
/* gif视图 */
@property (nonatomic, weak) IJSPreviewGifView *gifView;
/* 图片视图 */
@property (nonatomic, strong) UIImageView *backImageView;
/* livephoto */
@property (nonatomic, weak) IJSPreviewLivePhotoView *livePhoto;
/* 单击隐藏的状态 */
@property (nonatomic, assign) BOOL hiddenToolsStatus;

@end

@implementation IJSPreviewImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.hiddenToolsStatus = YES;
    }
    return self;
}
#pragma mark 懒加载区域
- (IJSPreviewGifView *)gifView
{
    if (!_gifView)
    {
        IJSPreviewGifView *gifView = [[IJSPreviewGifView alloc] init];
        gifView.backgroundColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
        [self.scrollView addSubview:gifView];
        _gifView = gifView;
        [self _addTapWithView:_gifView];
    }
    return _gifView;
}

- (UIImageView *)backImageView
{
    if (!_backImageView)
    {
        _backImageView = [UIImageView new];
        _backImageView.backgroundColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.scrollView addSubview:_backImageView];
        [self _addTapWithView:_backImageView];
    }
    return _backImageView;
}

- (IJSPreviewVideoView *)videoView
{
    if (!_videoView)
    {
        IJSPreviewVideoView *videoView = [IJSPreviewVideoView new];
        videoView.backgroundColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
        _videoView = videoView;
        [self.scrollView addSubview:videoView];
        [self _addTapWithView:videoView];
    }
    return _videoView;
}

- (IJSPreviewLivePhotoView *)livePhoto
{
    if (!_livePhoto)
    {
        IJSPreviewLivePhotoView *livePhoto = [IJSPreviewLivePhotoView new];
        livePhoto.backgroundColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
        [self.scrollView addSubview:livePhoto];
        _livePhoto = livePhoto;
        [self _addTapWithView:livePhoto];
    }
    return _livePhoto;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.js_width,  self.js_height)];
        _scrollView.pagingEnabled = NO;
        _scrollView.minimumZoomScale = miniZoomScale;
        _scrollView.maximumZoomScale = maxZoomScale;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor blackColor];
        [_scrollView setZoomScale:1];
        [self.contentView addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)setAssetModel:(IJSAssetModel *)assetModel
{
    _assetModel = assetModel;
    __weak typeof(self) weakSelf = self;
    if (assetModel.type == JSAssetModelMediaTypePhoto)
    {
        self.backImageView.image = nil;    // 先置空解决图片乱跳的问题
        if (assetModel.outputPath) //编辑完成的image
        {
            UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:assetModel.outputPath]];
            self.backImageView.image = image;
        }
        else
        {
            if (assetModel.asset && assetModel.imageRequestID)
            {
                [[PHImageManager defaultManager] cancelImageRequest:assetModel.imageRequestID];  // 取消加载
            }
            assetModel.imageRequestID = [[IJSImageManager shareManager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                weakSelf.backImageView.image = photo;
                if (!isDegraded)
                {
                    assetModel.imageRequestID = 0;
                }
            }];
        }
        self.gifView.hidden = YES;
        self.videoView.hidden = YES;
        self.livePhoto.hidden = YES;
        self.backImageView.hidden = NO;
        [self _setBackViewFrame:self.backImageView height:self.assetModel.assetHeight];
    }
    else if (assetModel.type == JSAssetModelMediaTypePhotoGif)
    {
        self.gifView.assetModel = assetModel;
        self.gifView.hidden = NO;
        self.videoView.hidden = YES;
        self.livePhoto.hidden = YES;
        self.backImageView.hidden = YES;
        [self _setBackViewFrame:self.gifView height:self.assetModel.assetHeight];
    }
    else if (assetModel.type == JSAssetModelMediaTypeVideo)
    {
        self.gifView.hidden = YES;
        self.videoView.hidden = NO;
        self.livePhoto.hidden = YES;
        self.backImageView.hidden = YES;
        [self _setBackViewFrame:self.videoView height:self.assetModel.assetHeight];
        self.videoView.assetModel = assetModel;
    }
    else if (assetModel.type == JSAssetModelMediaTypeLivePhoto)
    {
        if (iOS9_1Later)
        {
            self.livePhoto.assetModel = assetModel;
            self.gifView.hidden = YES;
            self.videoView.hidden = YES;
            self.livePhoto.hidden = NO;
            self.backImageView.hidden = YES;
            [self _setBackViewFrame:self.livePhoto height:self.assetModel.assetHeight];
        }
        else
        {
            if (assetModel.outputPath)
            {
                UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:assetModel.outputPath]];
                self.backImageView.image = image;
            }
            else
            {
                if (assetModel.asset && assetModel.imageRequestID)
                {
                    [[PHImageManager defaultManager] cancelImageRequest:assetModel.imageRequestID];  // 取消加载
                }
                assetModel.imageRequestID = [[IJSImageManager shareManager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    weakSelf.backImageView.image = photo;
                    if (!isDegraded)
                    {
                        assetModel.imageRequestID = 0;
                    }
                }];
            }
            self.gifView.hidden = YES;
            self.videoView.hidden = YES;
            self.livePhoto.hidden = YES;
            self.backImageView.hidden = NO;
            [self _setBackViewFrame:self.backImageView height:self.assetModel.assetHeight];
        }
    }
}

- (void)layoutSubviews
{
}

// 设置大小
- (void)_setBackViewFrame:(UIView *)view height:(CGFloat)height
{
    view.frame = CGRectMake(0, 0, JSScreenWidth, height);
    view.js_centerY = self.scrollView.js_height *0.5;
}
// 给view添加手势
- (void)_addTapWithView:(UIView *)view
{
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTwoFingerTap:)];

    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    doubleTap.numberOfTapsRequired = 2;       //需要点两下
    twoFingerTap.numberOfTouchesRequired = 2; //需要两个手指touch

    [view addGestureRecognizer:singleTap];
    [view addGestureRecognizer:doubleTap];
    [view addGestureRecognizer:twoFingerTap];

    [self.scrollView addGestureRecognizer:singleTap]; // 当视频区域小的时候响应时间

    [singleTap requireGestureRecognizerToFail:doubleTap]; //如果双击了，则不响应单击事件
}

- (void)playLivePhotos
{
    [self.livePhoto playLivePhotos];
}
- (void)stopLivePhotos
{
    [self.livePhoto stopLivePhotos];
}
#pragma mark 单机
- (void)_handleSingleTap:(UITapGestureRecognizer *)singleTap
{
    if ([self.cellDelegate respondsToSelector:@selector(didClickCellToHiddenNavigationAndToosWithCell:hiddenToolsStatus:)])
    {
        [self.cellDelegate didClickCellToHiddenNavigationAndToosWithCell:self hiddenToolsStatus:self.hiddenToolsStatus];
    }
    self.hiddenToolsStatus = !self.hiddenToolsStatus;
}

#pragma mark - 双击
- (void)_handleDoubleTap:(UITapGestureRecognizer *)doubleTap
{
    if (doubleTap.numberOfTapsRequired == 2)
    {
        if (self.scrollView.zoomScale == 1)
        {
            CGFloat newScale = self.scrollView.zoomScale * 2;
            CGRect zoomRect = [self zoomRectForScale:newScale location:[doubleTap locationInView:doubleTap.view]];
            [self.scrollView zoomToRect:zoomRect animated:YES];
        }
        else
        {
            CGFloat newScale = self.scrollView.zoomScale / 2;
            CGRect zoomRect = [self zoomRectForScale:newScale location:[doubleTap locationInView:doubleTap.view]];
            [self.scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}

#pragma mark 捏合

- (void)_handleTwoFingerTap:(UITapGestureRecognizer *)tap
{
    CGFloat newScale = self.scrollView.zoomScale / 2;
    CGRect zoomRect = [self zoomRectForScale:newScale location:[tap locationInView:tap.view]];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark 获取缩放的大小

- (CGRect)zoomRectForScale:(CGFloat)newScale location:(CGPoint)center
{
    CGRect zoomRect;
    // 大小
    zoomRect.size.width = self.scrollView.frame.size.width / newScale;
    zoomRect.size.height = self.scrollView.frame.size.height / newScale;

    // 原点
    zoomRect.origin.x = center.x - zoomRect.size.width / 2;
    zoomRect.origin.y = center.y - zoomRect.size.height / 2;
    return zoomRect;
}

#pragma mark UIScrollViewDelegaete
/**
 *  scroll view处理缩放和平移手势，必须需要实现委托下面两个方法,另外 maximumZoomScale和minimumZoomScale两个属性要不一样
 */
// 1.返回要缩放的图片
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.assetModel.type == JSAssetModelMediaTypePhoto)
    {
        return self.backImageView;
    }
    else if (self.assetModel.type == JSAssetModelMediaTypeLivePhoto)
    {
        return self.livePhoto;
    }
    else if (self.assetModel.type == JSAssetModelMediaTypePhotoGif)
    {
        return self.gifView;
    }
    else if (self.assetModel.type == JSAssetModelMediaTypeVideo)
    {
        return self.videoView;
    }
    else if (self.assetModel.type == JSAssetModelMediaTypeAudio)
    {
        return nil;
    }
    return nil;
}

// 让图片保持在屏幕中央，防止图片放大时，位置出现跑偏
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *anyView;
    if (self.assetModel.type == JSAssetModelMediaTypePhoto)
    {
        anyView = self.backImageView;
    }
    if (self.assetModel.type == JSAssetModelMediaTypeLivePhoto)
    {
        anyView = self.livePhoto;
    }
    if (self.assetModel.type == JSAssetModelMediaTypePhotoGif)
    {
        anyView = self.gifView;
    }
    if (self.assetModel.type == JSAssetModelMediaTypeVideo)
    {
        anyView = self.videoView;
    }
    if (self.assetModel.type == JSAssetModelMediaTypeAudio)
    {
        anyView = nil;
    }
    CGFloat offsetX = 0.0;
    if (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)
    {
        offsetX = (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5;
    }
    CGFloat offsetY = 0.0;
    if ((self.scrollView.bounds.size.height > self.scrollView.contentSize.height))
    {
        offsetY = (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5;
    }

    anyView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX, self.scrollView.contentSize.height * 0.5 + offsetY);
}

// 2.重新确定缩放完后的缩放倍数
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale + 0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

@end
