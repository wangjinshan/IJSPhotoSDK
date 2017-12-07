//
//  IJSImageMosaicTool.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/23.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageMosaicTool.h"
#import "IJSExtension.h"
#import "IJSImageConst.h"

@interface IJSImageMosaicTool ()

@end

@implementation IJSImageMosaicTool

#pragma mark 重写父类的方法
- (instancetype)initToolWithViewController:(IJSImageEditController *)controller
{
    self = [super initToolWithViewController:controller];
    if (self)
    {
        self.editorController = controller;
        self.allLineArr = [NSMutableArray array];
        [self cleanupTool];
        [self setupTool];
    }
    return self;
}

- (void)cleanupTool
{
    self.editorController.backImageView.userInteractionEnabled = NO;
    self.editorController.backScrollView.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGesture.enabled = NO;
}

- (void)setMosaicToolGaussanImage:(UIImage *)mosaicToolGaussanImage
{
    mosaicToolGaussanImage = mosaicToolGaussanImage;
    self.guassanView.gaussanViewGaussanImage = mosaicToolGaussanImage;
}

- (void)setupTool
{
    //初始化数据
    self.originalImageSize = self.editorController.backImageView.image.size;
    self.drawingView = self.editorController.drawingView;
    self.drawingView.userInteractionEnabled = YES;
    self.drawingView.layer.shouldRasterize = YES;
    self.drawingView.layer.minificationFilter = kCAFilterTrilinear;

    self.editorController.backScrollView.panGestureRecognizer.minimumNumberOfTouches = 2;
    self.editorController.backScrollView.panGestureRecognizer.delaysTouchesBegan = NO;
    self.editorController.backScrollView.pinchGestureRecognizer.delaysTouchesBegan = NO;

    if (self.graffitiType == JSGaussanType)
    {
        self.guassanView.hidden = NO;
    }
    if (self.graffitiType == JSMosaicType)
    {
        self.mosaicView.hidden = NO;
    }
}
#pragma mark 重写set方法
- (IJSImageGaussanView *)guassanView
{
    if (_guassanView == nil)
    {
        // 绘制初始值
        IJSImageGaussanView *guassanView = [[IJSImageGaussanView alloc] initWithFrame:self.editorController.backImageView.bounds];
        guassanView.originImage = self.editorController.backImageView.image;
        guassanView.center = self.drawingView.superview.center;
        [self.drawingView addSubview:guassanView];
        _guassanView = guassanView;
        guassanView.backgroundColor = [UIColor clearColor];

        __weak typeof(self) weakSelf = self;
        guassanView.gaussanViewDidTap = ^{
            if (weakSelf.drawToolDidTap)
            {
                weakSelf.drawToolDidTap();
            }
        };

        guassanView.gaussanViewdrawingCallBack = ^(BOOL isDrawing) {
            if (weakSelf.drawingCallBack)
            {
                weakSelf.drawingCallBack(isDrawing);
            }
        };
        guassanView.gaussanViewEndDrawCallBack = ^(BOOL isEndDraw) {
            if (weakSelf.drawEndCallBack)
            {
                weakSelf.drawEndCallBack(isEndDraw);
            }
        };
    }
    return _guassanView;
}
- (IJSImageMosaicView *)mosaicView
{
    if (_mosaicView == nil)
    {
        // 获取自定义的马赛克图
        UIImage *showImage = [self.editorController.backImageView.image getMosaicImageFromOrginImageBlockLevel:IJSImageMosaicLevel];
        IJSImageMosaicView *mosaicView = [[IJSImageMosaicView alloc] initWithFrame:self.editorController.backImageView.bounds];
        mosaicView.surfaceImage = self.editorController.backImageView.image;
        mosaicView.mosaicImage = showImage;
        mosaicView.center = self.drawingView.superview.center;
        [self.drawingView addSubview:mosaicView];
        _mosaicView = mosaicView;

        __weak typeof(self) weakSelf = self;
        mosaicView.mosaicViewDidTap = ^{
            if (weakSelf.drawToolDidTap)
            {
                weakSelf.drawToolDidTap();
            }
        };
        mosaicView.mosaicViewdrawingCallBack = ^(BOOL isDrawing) {
            if (weakSelf.drawingCallBack)
            {
                weakSelf.drawingCallBack(isDrawing);
            }
        };
        mosaicView.mosaicViewEndDrawCallBack = ^(BOOL isEndDraw) {
            if (weakSelf.drawEndCallBack)
            {
                weakSelf.drawEndCallBack(isEndDraw);
            }
        };
    }
    return _mosaicView;
}

- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    if (self.graffitiType == JSMosaicType)
    {
        [self.mosaicView didFinishHandleWithCompletionBlock:completionBlock];
    }
    if (self.graffitiType == JSGaussanType)
    {
        [self.guassanView didFinishHandleWithCompletionBlock:completionBlock];
    }
}

@end
