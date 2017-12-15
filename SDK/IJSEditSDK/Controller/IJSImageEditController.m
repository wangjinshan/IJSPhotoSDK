//
//  IJSImageEditController.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageEditController.h"

#import "IJSImageNavigationView.h"
#import "IJSImageToolView.h"
#import "IJSImageConst.h"
#import "IJSIColorButtonView.h"
#import "IJSImageToolBase.h"
#import "IJSImageDrawTool.h"
#import "IJSMapView.h"
#import "IJSMapViewModel.h"
#import "IJSIMapViewExportView.h"
#import "IJSIImputTextView.h"
#import "IJSIImputTextExportView.h"
#import "IJSImageMosaicToolView.h"
#import "IJSImageMosaicTool.h"

#import <IJSFoundation/IJSFoundation.h>
#import "TOCropViewController-Bridging-Header.h"


#import "IJSExtension.h"
#import "IJSVideoManager.h"

@interface IJSImageEditController () <UIScrollViewDelegate, TOCropViewControllerDelegate>
@property (nonatomic, weak) UIView *backPlacehodelView;              // 站位背景图
@property (nonatomic, weak) IJSImageNavigationView *navigationView;  //导航view
@property (nonatomic, weak) IJSImageToolView *toolsView;             // 工具条
@property (nonatomic, assign) CGFloat imageHeight;                   //图片的高度
@property (nonatomic, weak) IJSIColorButtonView *colorButtonView;    //工具笔条
@property (nonatomic, weak) IJSMapView *mapView;                     // 贴图
@property (nonatomic, weak) IJSIMapViewExportView *exportView;       // 导出的贴图
@property (nonatomic, weak) IJSIImputTextExportView *exportTextView; // 导出的文字视图
@property (nonatomic, weak) IJSIImputTextView *imputTextView;        // 文字视图
@property (nonatomic, strong) IJSImageDrawTool *drawTool;            //绘画的工具/
@property (nonatomic, strong) IJSImageMosaicTool *mosaicTool;        // 马赛克绘制工具
@property (nonatomic, weak) IJSImageMosaicToolView *mosaicToolView;  // 马赛克工具条
@property (nonatomic, assign) BOOL hiddenToolView;                   //是否隐藏工具条
@property (nonatomic, strong) UIImage *completeEditImage;            //处理的image
@property (nonatomic, copy) void (^completeEditImageCallBlock)(UIImage *image,NSURL *outputPath, NSError *error);
@property(nonatomic,copy) void(^cancelHandler)(void);  // 取消
@property (nonatomic, assign) IJSIEditMode currentModel; // 当前的模式
@property (nonatomic, weak) UIView *placeholderToolView; // 工具站位视图
@property (nonatomic, strong) UIImage *gaussanImage;     // 提前获取好高斯图
@property (nonatomic, assign) CGRect cropImageRect;      // 裁剪的尺寸
@property (nonatomic, strong) NSTimer *listenGuassTimer; // 监听高斯的时间表
@property (nonatomic, weak) IJSLodingView *lodingView;   // 正在渲染loding
@property (nonatomic, assign) BOOL isGetingGuassImage;   // 正在获取高斯图
@end

@implementation IJSImageEditController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hiddenToolView = YES;
    self.isGetingGuassImage = YES;
    [self _getImageSize];
    [self _createdUI];

    [self _buttonClickAction];
    [self _resetUIHierarchy];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    self.navigationController.navigationBarHidden = NO;
    [self _removeListenFromObjc];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.drawingView.frame = self.backImageView.superview.frame;
}

#pragma mark 父类实现
- (id)initWithEditImage:(UIImage *)image
{
    self = [self init];
    if (self)
    {
        self.editImage = image;
    }
    return self;
}

- (void)loadImageOnCompleteResult:(void(^)(UIImage *image,NSURL *outputPath, NSError *error))completeImage
{
    self.completeEditImageCallBlock = completeImage;
}
-(void)cancelSelectedData:(void (^)(void))cancelHandler
{
    self.cancelHandler = cancelHandler;
}

- (void)addMapViewImageArr:(NSMutableArray *)mapImageArr
{
    self.mapImageArr = mapImageArr;
}
/*-----------------------------------点击事件-------------------------------------------------------*/
#pragma mark 点击事件处理,取消或者完成绘制
- (void)_buttonClickAction
{
    //取消
    __weak typeof(self) weakSelf = self;
    self.navigationView.cancleBlock = ^{
        if (weakSelf.navigationController)
        {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    // 完成绘制
    self.navigationView.finishBlock = ^{
        [weakSelf _completeCallback:^(UIImage *image) {

            weakSelf.editImage = image;
            if (weakSelf.completeEditImageCallBlock)
            {
                [IJSVideoManager saveImageToSandBoxImage:image completion:^(NSURL *outputPath, NSError *error) {
                    if (weakSelf.navigationController)
                    {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                        if (weakSelf.completeEditImageCallBlock)
                        {
                            weakSelf.completeEditImageCallBlock(image,outputPath,error);
                        }
                    }
                    else
                    {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{
                            if (weakSelf.completeEditImageCallBlock)
                            {
                                weakSelf.completeEditImageCallBlock(image,outputPath,error);
                            }
                        }];
                    }
                }];
            }
        }];
    };

    // 工具条点击
    // 画笔
    self.toolsView.panButtonBlock = ^(UIButton *button) {

        [weakSelf.mosaicToolView resetButtonStatus:nil];  // 恢复button的原始状态
        BOOL isHidden = button.isSelected;

        weakSelf.currentModel = IJSIDrawMode;
        [weakSelf _hiddenplaceholderToolViewSubView];
         [weakSelf _hiddenPlaceholderToolView:NO];
        weakSelf.placeholderToolView.frame = CGRectMake(0, JSScreenHeight - ToolBarMarginBottom - ColorButtonViewWidth, JSScreenWidth, ColorButtonViewWidth);
        if (IJSGiPhoneX)
        {
            weakSelf.placeholderToolView.frame = CGRectMake(0, JSScreenHeight -IJSGTabbarSafeBottomMargin - ToolBarMarginBottom - ColorButtonViewWidth, JSScreenWidth, ColorButtonViewWidth);
        }
        [weakSelf _hiddenPlaceholderToolView:isHidden];
        [weakSelf _hiddenColorButtonView:isHidden];
        if (!button.selected) //选中
        {
            [weakSelf _drawingViewSubViewUserInteractionEnabled:weakSelf.drawTool.panDrawingView state:YES];
        }
        else
        {
            [weakSelf _drawingViewSubViewUserInteractionEnabled:weakSelf.drawTool.panDrawingView state:NO];
        }
    };
    
    // 笑脸图
    self.toolsView.smileButtonBlock = ^(UIButton *button) {
        [weakSelf.mosaicToolView resetButtonStatus:nil];  // 恢复button的原始状态
        weakSelf.currentModel = IJSIPaperMode;
        [weakSelf _hiddenplaceholderToolViewSubView];
        weakSelf.placeholderToolView.frame = CGRectMake(0, JSScreenHeight -IJSGTabbarSafeBottomMargin - JSScreenHeight * 230 / 667, JSScreenWidth, JSScreenHeight * 230 / 667);
        weakSelf.mapView.hidden = NO;
        if (weakSelf.mapImageArr)
        {
            [weakSelf _hiddenPlaceholderToolView:NO];
            [weakSelf.view bringSubviewToFront:weakSelf.placeholderToolView];
        }
        else
        {
            [weakSelf _hiddenPlaceholderToolView:YES];
        }
        [weakSelf _drawingViewSubViewUserInteractionEnabled:nil state:NO];
    };

    // 文字
    self.toolsView.textButtonBlock = ^(UIButton *button) {
        [weakSelf.mosaicToolView resetButtonStatus:nil];  // 恢复button的原始状态
        weakSelf.currentModel = IJSITextMode;
        [weakSelf _hiddenplaceholderToolViewSubView];
        weakSelf.imputTextView.hidden = NO;
        [weakSelf _drawingViewSubViewUserInteractionEnabled:nil state:NO];
    };

    // 马赛克
    self.toolsView.mosaicButtonBlock = ^(UIButton *button) {
        weakSelf.currentModel = IJSIMosaicMode;
        [weakSelf _hiddenplaceholderToolViewSubView];
        [weakSelf _hiddenPlaceholderToolView:NO];

        if (IJSGiPhoneX)
        {
             weakSelf.placeholderToolView.frame = CGRectMake(0, JSScreenHeight - IJSGTabbarSafeBottomMargin - ToolBarMarginBottom - IJSImageMosaicButtonHeight, JSScreenWidth, IJSImageMosaicButtonHeight);
        }
        else
        {
            weakSelf.placeholderToolView.frame = CGRectMake(0, JSScreenHeight - ToolBarMarginBottom - IJSImageMosaicButtonHeight, JSScreenWidth, IJSImageMosaicButtonHeight);
        }
        weakSelf.mosaicToolView.hidden = NO;
        [weakSelf _drawingViewSubViewUserInteractionEnabled:nil state:NO];
    };
    // 裁剪
    self.toolsView.clipButtonBlock = ^(UIButton *button) {
        [weakSelf.mosaicToolView resetButtonStatus:nil];  // 恢复button的原始状态
        weakSelf.currentModel = IJSIClipMode;
         [weakSelf _hiddenPlaceholderToolView:YES];
        [weakSelf _completeCallback:^(UIImage *image) {
            TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithCroppingStyle:TOCropViewCroppingStyleDefault image:image];
            cropViewController.delegate = weakSelf;
            [weakSelf presentViewController:cropViewController animated:YES completion:nil];
        }];
        [weakSelf _resetImageToolViewButtonSelectedState:NO]; // 设置button没选中
    };
}

/*-----------------------------------UI控件-------------------------------------------------------*/
#pragma mark 初始化控件
#pragma mark UI
- (void)_createdUI
{
    // 滚动view
    UIScrollView *backScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    backScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backScrollView.pagingEnabled = NO;
    backScrollView.minimumZoomScale = miniVideoZoomScale;
    backScrollView.maximumZoomScale = maxVideoZoomScale;
    backScrollView.showsVerticalScrollIndicator = NO;
    backScrollView.showsHorizontalScrollIndicator = NO;
    backScrollView.bounces = NO;
    backScrollView.delegate = self;
    backScrollView.backgroundColor = [UIColor blackColor];
    [backScrollView setZoomScale:1];
    [self.view addSubview:backScrollView];
    self.backScrollView = backScrollView;

    // 占位背景图
    UIView *backPlacehodelView = [[UIView alloc] initWithFrame:self.view.bounds];
    [backScrollView addSubview:backPlacehodelView];
    self.backPlacehodelView = backPlacehodelView;

    // 背景图片
    self.backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, self.imageHeight)];
    _backImageView.center = self.view.center;
    _backImageView.image = self.editImage;
    [self.backPlacehodelView addSubview:self.backImageView];

    // 绘画图

    self.drawingView = [[UIImageView alloc] init];
    self.drawingView.contentMode = UIViewContentModeCenter;
    self.drawingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    self.drawingView.backgroundColor = [UIColor clearColor];
    [self.backImageView.superview addSubview:self.drawingView];
    self.drawingView.userInteractionEnabled = YES;

    // 导航条
    IJSImageNavigationView *navigationView;
    if (IJSGiPhoneX)
    {
        navigationView = [[IJSImageNavigationView alloc] initWithFrame:CGRectMake(0, IJSGStatusBarHeight, JSScreenWidth, IJSINavigationHeight)];
    }
    else
    {
        navigationView = [[IJSImageNavigationView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, IJSINavigationHeight)];
    }
    navigationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navigationView];
    self.navigationView = navigationView;
    [self.view bringSubviewToFront:navigationView];
    [navigationView.cancleButton setTitle:[NSBundle localizedStringForKey:@"Back"] forState:UIControlStateNormal];
    
    // 工具站位视图
    UIView *placeholderToolView = [[UIView alloc] initWithFrame:CGRectMake(0, JSScreenHeight - IJSIMapViewHeight, JSScreenWidth, IJSIMapViewHeight)];
    placeholderToolView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:placeholderToolView];
    placeholderToolView.hidden = NO;
    self.placeholderToolView = placeholderToolView;

    // 工具条
    IJSImageToolView *toolsView = [[IJSImageToolView alloc] initWithFrame:CGRectMake(0, JSScreenHeight - ToolBarMarginBottom, JSScreenWidth, ToolBarMarginBottom)];
    if (IJSGiPhoneX)
    {
        toolsView.frame = CGRectMake(0, JSScreenHeight - IJSGTabbarSafeBottomMargin - ToolBarMarginBottom, JSScreenWidth, ToolBarMarginBottom);
    }
    [self.view addSubview:toolsView];
    toolsView.backgroundColor = [UIColor clearColor];
    self.toolsView = toolsView;
    [self.view bringSubviewToFront:self.toolsView];
}
// 排版层次
- (void)_resetUIHierarchy
{
    [self.drawingView insertSubview:self.mosaicTool.guassanView atIndex:0];
    [self.drawingView insertSubview:self.mosaicTool.mosaicView atIndex:1];
    [self.drawingView insertSubview:self.drawTool.panDrawingView atIndex:2];
    [self _drawingViewSubViewUserInteractionEnabled:nil state:NO];
}

- (void)_getImageSize
{
    CGSize imageSize = self.editImage.size;
    if (imageSize.width != 0)
    {
        self.imageHeight = imageSize.height / imageSize.width * JSScreenWidth;
    }
}
#pragma mark - 获取高斯图片
- (void)_getGaussanImage
{
    if (self.isGetingGuassImage)
    {
        self.isGetingGuassImage = NO;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *realImage = [weakSelf.editImage getImageWithOldImage];
            UIImage *filterGaussan = [realImage getImageFilterForGaussianBlur:10];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.gaussanImage = filterGaussan;
                weakSelf.mosaicTool.mosaicToolGaussanImage = weakSelf.gaussanImage;
                weakSelf.isGetingGuassImage = YES;
                JSLog(@"渲染完成");
            });
        });
    }
}
/*-----------------------------------懒加载区域-------------------------------------------------------*/
#pragma mark 懒加载区域
- (IJSImageDrawTool *)drawTool
{
    if (_drawTool == nil)
    {
        _drawTool = [[IJSImageDrawTool alloc] initToolWithViewController:self];

        __weak typeof(self) weakSelf = self;

        // 文字视图单击
        _drawTool.drawToolDidTap = ^{

            if (weakSelf.currentModel == IJSIDrawMode)
            {
                [weakSelf.view bringSubviewToFront:weakSelf.toolsView];
                [weakSelf _hiddenToolsView:weakSelf.hiddenToolView];
                [weakSelf _hiddenPlaceholderToolView:weakSelf.hiddenToolView];
            }
            else
            {
                [weakSelf.view bringSubviewToFront:weakSelf.toolsView];
                [weakSelf _hiddenplaceholderToolViewSubView];
                [weakSelf _hiddenToolsView:weakSelf.hiddenToolView];
            }
            weakSelf.hiddenToolView = !weakSelf.hiddenToolView;
        };
        // 绘制中
        _drawTool.drawingCallBack = ^(BOOL isDrawing) {
            if (weakSelf.currentModel != IJSIDrawMode)
            {
                [weakSelf _hiddenplaceholderToolViewSubView];
            }
            if (isDrawing)
            {
                [weakSelf _hiddenToolsView:YES];
                [weakSelf _hiddenPlaceholderToolView:YES];
            }
            else
            {
                [weakSelf _hiddenToolsView:NO];
                [weakSelf _hiddenPlaceholderToolView:NO];
            }
        };
        // 绘制结束
        _drawTool.drawEndCallBack = ^(BOOL isEndDraw) {
            [weakSelf _hiddenToolsView:isEndDraw];
        };
    }
    return _drawTool;
}
//画笔板子
- (IJSIColorButtonView *)colorButtonView
{
    if (_colorButtonView == nil)
    {
        IJSIColorButtonView *colorButtonView = [[IJSIColorButtonView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, ColorButtonViewWidth)];
        [self.placeholderToolView addSubview:colorButtonView];
        _colorButtonView = colorButtonView;

        __weak typeof(self) weakSelf = self;

        _colorButtonView.colorCallBack = ^(UIColor *color) {
            weakSelf.panColor = color;
        };
        _colorButtonView.sliderCallBack = ^(CGFloat width) {
            weakSelf.panWidth = width;
        };
        // 撤销
        _colorButtonView.cancleCallBack = ^{
            [weakSelf.drawTool cleanLastDrawPath];
        };
    }
    return _colorButtonView;
}

// 贴图
- (IJSMapView *)mapView
{
    if (_mapView == nil)
    {
        __weak typeof(self) weakSelf = self;

        if (self.mapImageArr)
        {
            NSMutableArray *imageData = self.mapImageArr;
            IJSMapView *mapView = [[IJSMapView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, JSScreenHeight * 230 / 667) imageData:imageData];
            [self.placeholderToolView addSubview:mapView];
            [self.view bringSubviewToFront:self.placeholderToolView];
            _mapView = mapView;
            // 点击回调添加图片
            mapView.didClickItemCallBack = ^(NSInteger index, UIImage *indexImage) {
                weakSelf.exportView.backImage = indexImage;
                [weakSelf _hiddenPlaceholderToolView:YES];
            };
            mapView.cancelCallBack = ^{
                [weakSelf _hiddenPlaceholderToolView:YES];
            };
        }
    }
    return _mapView;
}

// 文字视图
- (IJSIImputTextView *)imputTextView
{
    __weak typeof(self) weakSelf = self;
    if (_imputTextView == nil)
    {
        IJSIImputTextView *imputView = [[IJSIImputTextView alloc] initWithFrame:self.view.bounds];
        imputView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:imputView];
        [self.view bringSubviewToFront:imputView];
        _imputTextView = imputView;

        _imputTextView.textCallBackBlock = ^(UITextView *textView) {
            weakSelf.exportTextView.textView = textView;
        };
    }
    return _imputTextView;
}

//导出贴图视图
- (IJSIMapViewExportView *)exportView
{
    IJSIMapViewExportView *exportView = [[IJSIMapViewExportView alloc] initWithFrame:CGRectMake(0, 0, IJSIMapViewExportViewImageHeight, IJSIMapViewExportViewImageHeight)];
    exportView.center = [self.backImageView.superview convertPoint:self.backImageView.center toView:self.drawingView];
    [self.drawingView addSubview:exportView];
    exportView.backgroundColor = [UIColor clearColor];
    _exportView = exportView;

    __weak typeof(exportView) weakExportView = exportView;

    exportView.mapViewExpoetViewTapCallBack = ^{
        [weakExportView hiddenSquareViewState:NO];
    };
    //改变导出视图的中心点
    __weak typeof(self) weakSelf = self;
    exportView.mapViewExpoetViewPanCallBack = ^(CGPoint viewPoint) {

        // x
        if (viewPoint.x < 0 ||
            viewPoint.x > JSScreenWidth)
        {
            weakExportView.center = weakSelf.drawingView.center;
        }
        // y
        if (viewPoint.y < weakSelf.drawTool.panDrawingView.js_top - weakExportView.js_width * 0.3 ||
            viewPoint.y > weakSelf.drawTool.panDrawingView.js_bottom + weakExportView.js_width * 0.3)
        {
            weakExportView.center = weakSelf.drawingView.center;
        }
        // 最大值
        if (viewPoint.y < IJSVideoEditNavigationHeight ||
            viewPoint.y > JSScreenHeight - IJSVideoEditNavigationHeight - ToolBarMarginBottom)
        {
            weakExportView.center = weakSelf.drawingView.center;
        }
    };

    return _exportView;
}
// 文字文字视图
- (IJSIImputTextExportView *)exportTextView
{
    IJSIImputTextExportView *exportTextView = [[IJSIImputTextExportView alloc] initWithFrame:CGRectMake(0, 0, IJSIMapViewExportViewImageHeight, IJSIMapViewExportViewImageHeight)];
    exportTextView.center = [self.backImageView.superview convertPoint:self.backImageView.center toView:self.drawingView];
    [self.drawingView addSubview:exportTextView];
    exportTextView.backgroundColor = [UIColor clearColor];
    _exportTextView = exportTextView;

    // 单击
    __weak typeof(self) weakSelf = self;
    __weak typeof(exportTextView) weakExportTextView = exportTextView;
    exportTextView.handleSingleTap = ^(UITextView *textView, BOOL isTap) {
        weakSelf.imputTextView.tapTextView = textView;
    };
    // 改变坐标
    exportTextView.textViewExpoetViewPanCallBack = ^(CGPoint viewPoint) {
        // x
        if (viewPoint.x < 0 ||
            viewPoint.x > JSScreenWidth)
        {
            weakExportTextView.center = weakSelf.drawingView.center;
        }
        // y
        if (viewPoint.y < weakSelf.drawTool.panDrawingView.js_top ||
            viewPoint.y > weakSelf.drawTool.panDrawingView.js_bottom)
        {
            weakExportTextView.center = weakSelf.drawingView.center;
        }
        // 最大值
        if (viewPoint.y < IJSVideoEditNavigationHeight ||
            viewPoint.y > JSScreenHeight - IJSVideoEditNavigationHeight - ToolBarMarginBottom)
        {
            weakExportTextView.center = weakSelf.drawingView.center;
        }
    };

    return _exportTextView;
}
// 马赛克工具条
- (IJSImageMosaicToolView *)mosaicToolView
{
    if (_mosaicToolView == nil)
    {
        IJSImageMosaicToolView *mosaicToolView = [[IJSImageMosaicToolView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, IJSImageMosaicButtonHeight)];
        _mosaicToolView = mosaicToolView;
        mosaicToolView.backgroundColor = [UIColor clearColor];
        [self.placeholderToolView addSubview:mosaicToolView];
        [self.view bringSubviewToFront:self.placeholderToolView];

        __weak typeof(self) weakSelf = self;
        _mosaicToolView.typeOneCallBack = ^(UIButton *button) { //马赛克

            weakSelf.mosaicTool.graffitiType = JSMosaicType;
            weakSelf.mosaicTool.mosaicView.backgroundColor = [UIColor clearColor];
            [weakSelf _drawingViewSubViewUserInteractionEnabled:weakSelf.mosaicTool.mosaicView state:YES];
            weakSelf.mosaicTool.drawToolDidTap = ^{
                [weakSelf _hiddenToolsView:weakSelf.hiddenToolView];
                weakSelf.hiddenToolView = !weakSelf.hiddenToolView;
            };
            weakSelf.mosaicTool.drawingCallBack = ^(BOOL isDrawing) {
                [weakSelf _hiddenToolsView:YES];
            };
            weakSelf.mosaicTool.drawEndCallBack = ^(BOOL isEndDraw) {
                [weakSelf _hiddenToolsView:NO];
            };

        };

        mosaicToolView.typeTwoCallBack = ^(UIButton *button) { // 高斯

            weakSelf.mosaicTool.graffitiType = JSGaussanType;
            weakSelf.mosaicTool.guassanView.backgroundColor = [UIColor clearColor];
            [weakSelf _drawingViewSubViewUserInteractionEnabled:weakSelf.mosaicTool.guassanView state:YES];
            weakSelf.mosaicTool.drawToolDidTap = ^{
                [weakSelf _hiddenToolsView:weakSelf.hiddenToolView];
                weakSelf.hiddenToolView = !weakSelf.hiddenToolView;
            };

            weakSelf.mosaicTool.drawingCallBack = ^(BOOL isDrawing) {
                [weakSelf _hiddenToolsView:YES];
            };
            weakSelf.mosaicTool.drawEndCallBack = ^(BOOL isEndDraw) {
                [weakSelf _hiddenToolsView:NO];
            };

            if (weakSelf.gaussanImage == nil)
            {
                IJSLodingView *lodingView = [IJSLodingView showLodingViewAddedTo:weakSelf.view title:@"正在处理... ..."];
                weakSelf.lodingView = lodingView;
                [weakSelf _startListenPlayerTimer];
                [weakSelf _getGaussanImage];
            }
        };

        mosaicToolView.cancleLastCallBack = ^(UIButton *button) { // 取消

            if (weakSelf.mosaicTool.graffitiType == JSMosaicType)
            {
                [weakSelf.mosaicTool.mosaicView cleanLastDrawPath];
            }
            else if (weakSelf.mosaicTool.graffitiType == JSGaussanType)
            {
                [weakSelf.mosaicTool.guassanView cleanLastDrawPath];
            }
            else
            {
                return;
            }
        };
    }
    return _mosaicToolView;
}

//马赛克笔
- (IJSImageMosaicTool *)mosaicTool
{
    if (_mosaicTool == nil)
    {
        IJSImageMosaicTool *mosaicTool = [[IJSImageMosaicTool alloc] initToolWithViewController:self];
        _mosaicTool = mosaicTool;
    }
    return _mosaicTool;
}

/*-----------------------------------私有方法-------------------------------------------------------*/
#pragma mark 隐藏工具条和导航栏
- (void)_hiddenToolsView:(BOOL)state
{
    self.navigationView.hidden = state;
    self.toolsView.hidden = state;
    self.placeholderToolView.hidden = state;
}
- (void)_hiddenPlaceholderToolView:(BOOL)state
{
    self.placeholderToolView.hidden = state;
}
- (void)_hiddenColorButtonView:(BOOL)state
{
    self.colorButtonView.hidden = state;
}
#pragma mark 单击隐藏
- (void)_hiddenViewDidTap
{
}
- (void)_hiddenplaceholderToolViewSubView
{
    for (UIView *subView in self.placeholderToolView.subviews)
    {
        subView.hidden = YES;
    }
}
// 子视图不可交互设置
- (void)_drawingViewSubViewUserInteractionEnabled:(UIView *)view state:(BOOL)state
{
    for (UIView *subView in self.drawingView.subviews)
    {
        subView.userInteractionEnabled = NO;
        if (view.class == subView.class)
        {
            view.userInteractionEnabled = state;
        }
        if ([subView isKindOfClass:[IJSIMapViewExportView class]] || [subView isKindOfClass:[IJSIImputTextExportView class]])
        {
            subView.userInteractionEnabled = YES;
        }
    }
}
// 清除所有的路径
- (void)_cleanAllSubViewLine
{
    for (UIView *subView in self.drawingView.subviews)
    {
        if ([subView isKindOfClass:[IJSIPanDrawingView class]])
        {
            [(IJSIPanDrawingView *) subView cleanAllDrawPath];
        }
        if ([subView isKindOfClass:[IJSImageGaussanView class]])
        {
            [(IJSImageGaussanView *) subView cleanAllDrawPath];
        }
        if ([subView isKindOfClass:[IJSImageMosaicView class]])
        {
            [(IJSImageMosaicView *) subView cleanAllDrawPath];
        }
    }
}
// 清除所有的贴图
- (void)_cleanAllExportView
{
    for (UIView *subView in self.drawingView.subviews)
    {
        if ([subView isKindOfClass:[IJSIMapViewExportView class]] && [subView isKindOfClass:[IJSIImputTextExportView class]])
        {
            [subView removeFromSuperview];
        }
    }
}
// 清楚所有的子视图
- (void)_cleanAllSubView
{
    for (UIView *subView in self.drawingView.subviews)
    {
        [subView removeFromSuperview];
    }
}
// 工具条所有button设置成飞选中状态
- (void)_resetImageToolViewButtonSelectedState:(BOOL)state
{
    for (UIView *subView in self.toolsView.toolBarView.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            ((UIButton *) subView).selected = state;
        }
    }
}

/*-----------------------------------逻辑处理-------------------------------------------------------*/
#pragma mark 逻辑处理
#pragma mark 绘图
+ (UIImage *)_screenshot:(UIView *)view orientation:(UIDeviceOrientation)orientation usePresentationLayer:(BOOL)usePresentationLayer
{
    CGSize size = view.bounds.size;
    CGSize targetSize = CGSizeMake(size.width * view.layer.js_transformScaleX, size.height * view.layer.js_transformScaleY);

    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [view drawViewHierarchyInRect:CGRectMake(0, 0, targetSize.width, targetSize.height) afterScreenUpdates:NO];
    CGContextRestoreGState(ctx);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
/*-----------------------------------内部数据处理-------------------------------------------------------*/
#pragma mark 解析回调的数据处理
- (void)_completeCallback:(void (^)(UIImage *image))completeCallback
{
    CGFloat WS = self.backImageView.js_width / self.drawingView.js_width;
    CGFloat HS = self.backImageView.js_height / self.drawingView.js_height;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.backImageView.image.size.width, self.backImageView.image.size.height),
                                           NO,
                                           self.backImageView.image.scale);
    [self.backImageView.image drawAtPoint:CGPointZero];

    CGFloat viewToimgW = self.backImageView.js_width / self.backImageView.image.size.width;
    CGFloat viewToimgH = self.backImageView.js_height / self.backImageView.image.size.height;
    __unused CGFloat drawX = self.backImageView.js_left / viewToimgW;
    CGFloat drawY = self.backImageView.js_top / viewToimgH;
    [_drawingView.image drawInRect:CGRectMake(0, -drawY, self.backImageView.image.size.width / WS, self.backImageView.image.size.height / HS)];
    for (UIView *subView in _drawingView.subviews)
    {
        UIView *exportView = subView;
        UIImage *textImg = [self.class _screenshot:exportView orientation:UIDeviceOrientationPortrait usePresentationLayer:YES];
        CGFloat rotation = exportView.layer.js_transformRotationZ;
        textImg = [textImg imageRotatedByRadians:rotation];

        CGFloat selfRw = self.backImageView.bounds.size.width / self.backImageView.image.size.width;
        CGFloat selfRh = self.backImageView.bounds.size.height / self.backImageView.image.size.height;

        CGFloat sw = textImg.size.width / selfRw;
        CGFloat sh = textImg.size.height / selfRh;

        [textImg drawInRect:CGRectMake(exportView.js_left / selfRw, (exportView.js_top / selfRh) - drawY, sw, sh)];
    }

    UIImage *tmp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageWithCGImage:tmp.CGImage scale:self.backImageView.image.scale orientation:UIImageOrientationUp];
        if (completeCallback)
        {
            completeCallback(image);
        }
    });
}

#pragma mark UIScrollViewDelegaete
/**
 *  scroll view处理缩放和平移手势，必须需要实现委托下面两个方法,另外 maximumZoomScale和minimumZoomScale两个属性要不一样
 */

// 1.返回要缩放的图片
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.backPlacehodelView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {}
#pragma mark 裁剪的代理方法
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.backImageView.image = image;
    self.editImage = image;
    [self _layoutImageView];
    [self _cleanAllExportView];
    [self _cleanAllSubView];
    self.drawTool.panDrawingView = nil;
    self.mosaicTool.mosaicView = nil;
    self.mosaicTool.guassanView = nil;
    [self _resetUIHierarchy];

    self.cropImageRect = cropRect;
    [cropViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// 重布局
- (void)_layoutImageView
{
    if (self.backImageView.image == nil)
    {
        return;
    }
    CGRect imageFrame = CGRectMake(0, 0, JSScreenWidth, JSScreenWidth * self.backImageView.image.size.height / self.backImageView.image.size.width);
    self.backImageView.frame = imageFrame;
    self.backImageView.center = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
}

#pragma mark - 定时器
#pragma mark 开始定时器
- (void)_startListenPlayerTimer
{
    [self _removeListenFromObjc];
    self.listenGuassTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(_listenObjcAction) userInfo:nil repeats:YES];
}
#pragma mark 清空定时器
- (void)_removeListenFromObjc
{
    if (self.listenGuassTimer)
    {
        [self.listenGuassTimer invalidate];
        self.listenGuassTimer = nil;
    }
}
- (void)_listenObjcAction
{
    if (self.gaussanImage)
    {
        [self _removeListenFromObjc];
        [self.lodingView removeFromSuperview];
    }
    else
    {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//  https://github.com/TimOliver/TOCropViewController
@end
