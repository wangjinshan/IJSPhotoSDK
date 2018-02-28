//
//  IJSVideoDrawingView.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/28.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoDrawingView.h"
#import "IJSDExportView.h"
#import "IJSExtension.h"

@interface IJSVideoDrawingView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIImageView *backImageView; // 背景图
@property (nonatomic, assign) CGSize drawingViewSize;   // 画面区域
@property (nonatomic, assign) BOOL isDidTap;            // 单机
@end

@implementation IJSVideoDrawingView

- (instancetype)initWithFrame:(CGRect)frame drawingViewSize:(CGSize)size
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.isDidTap = YES;
        _drawingViewSize = size;
        [self _createdUI];
        [self _action]; //block
    }
    return self;
}

- (void)_createdUI
{
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:backImageView];
    self.backImageView = backImageView;
    backImageView.userInteractionEnabled = YES;

    IJSDrawingView *drawingView =  [[IJSDrawingView alloc] initWithFrame:CGRectMake(0, 0, self.drawingViewSize.width, self.drawingViewSize.height)];
    drawingView.backgroundColor = [UIColor clearColor];
    [self addSubview:drawingView];
    self.drawingView = drawingView;

    IJSDToolBarView *toolBarView = [[IJSDToolBarView alloc] initWithFrame:CGRectMake(0, 0, self.js_width, 30)];
    toolBarView.backgroundColor = [UIColor clearColor];
    [self addSubview:toolBarView];
    self.toolBarView = toolBarView;

    IJSDColorView *colorView = [[IJSDColorView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 140, JSScreenWidth, 140)];
    [self addSubview:colorView];
    self.colorView = colorView;

    [self _addTap]; //手势
}

- (void)_addTap
{
    //创建手势对象
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.drawingView addGestureRecognizer:tap];
}
// 单机方法
- (void)viewDidTap:(UITapGestureRecognizer *)tap
{
    if (self.didTapCallBack)
    {
        self.didTapCallBack(self.isDidTap);
    }
    self.isDidTap = !self.isDidTap;
}
#pragma mark block 方法实现
- (void)_action
{
    __weak typeof(self) weakSelf = self;

    self.colorView.rCallBack = ^(CGFloat width, UIColor *color) {
        weakSelf.drawingView.pathColor = color;
        weakSelf.drawingView.pathWidth = width;

    };
    self.colorView.gCallBack = ^(CGFloat width, UIColor *color) {
        weakSelf.drawingView.pathColor = color;
        weakSelf.drawingView.pathWidth = width;
    };

    self.colorView.bCallBack = ^(CGFloat width, UIColor *color) {
        weakSelf.drawingView.pathColor = color;
        weakSelf.drawingView.pathWidth = width;
    };
    self.colorView.widthCallBack = ^(CGFloat width, UIColor *color) {
        weakSelf.drawingView.pathColor = color;
        weakSelf.drawingView.pathWidth = width;
    };

    self.toolBarView.cancleCallBack = ^{
    };
    // 正在绘制
    self.drawingView.isDrawing = ^{
        if (weakSelf.isDrawing)
        {
            weakSelf.isDrawing();
        }
        [weakSelf _hiddenToolView:YES];
    };
    // 绘制结束
    self.drawingView.isEndDrawing = ^{
        if (weakSelf.isEndDrawing)
        {
            weakSelf.isEndDrawing();
        }
        [weakSelf _hiddenToolView:NO];
    };

    self.toolBarView.cleanAllCallBack = ^{
        [weakSelf.drawingView cleanAllPath];
    };
    self.toolBarView.cleanLastCallBack = ^{
        [weakSelf.drawingView cleanLastPath];
    };
    self.toolBarView.eraseCallBack = ^{
        [weakSelf.drawingView erasePath];
    };
    // 添加照片和保存
    self.toolBarView.addPhotoCallBack = ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.delegate = weakSelf;
        [weakSelf.controller presentViewController:picker animated:YES completion:nil];
    };

    self.toolBarView.savePhotoCallBack = ^{

        UIGraphicsBeginImageContextWithOptions(weakSelf.drawingView.frame.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [weakSelf.backImageView drawRect:weakSelf.drawingView.frame];
        [weakSelf.drawingView.layer drawInContext:context]; // layer renderInContext
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (weakSelf.finishCallBack)
        {
            weakSelf.finishCallBack(image);
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //  必须加这个方法 - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
            UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            dispatch_async(dispatch_get_main_queue(), ^{

                           });
        });
        [weakSelf.controller dismissViewControllerAnimated:true completion:nil];
    };
}
/*-----------------------------------私有方法-------------------------------------------------------*/
#pragma mark 私有方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"%@", image);
}
/*-----------------------------------delegate-------------------------------------------------------*/
#pragma mark 代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info
{
    UIImage *selectedImage = info[@"UIImagePickerControllerOriginalImage"];
    IJSDExportView *exportView = [[IJSDExportView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, (self.frame.size.height - 140 - 30))];
    exportView.backgroundColor = [UIColor clearColor];
    exportView.drawImage = selectedImage;
    [self addSubview:exportView];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*-----------------------------------setting-------------------------------------------------------*/
- (void)setOriginImage:(UIImage *)originImage
{
    _originImage = originImage;
    self.backImageView.image = originImage;
}
- (void)setController:(id)controller
{
    _controller = controller;
}

- (void)layoutSubviews
{
    if (IJSGiPhoneX)
    {
        _drawingView.center = CGPointMake(self.superview.center.x, self.superview.center.y - IJSGStatusBarAndNavigationBarHeight); //
    }
    else
    {
        _drawingView.center = CGPointMake(self.superview.center.x, self.superview.center.y - 44); //
    }
}
#pragma mark - 隐藏
- (void)_hiddenToolView:(BOOL)state
{
    self.toolBarView.hidden = state;
    self.colorView.hidden = state;
}

@end
