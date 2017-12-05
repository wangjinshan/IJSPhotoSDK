//
//  IJSDrawingController.m
//  IJSUExtension
//
//  Created by shan on 2017/8/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSDrawingController.h"
#import "IJSDToolBarView.h"
#import "IJSDColorView.h"
#import "IJSDrawingView.h"
#import "IJSDExportView.h"

@interface IJSDrawingController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIImageView *backImageView;   // 背景图
@property (nonatomic, weak) IJSDrawingView *drawingView;  // 画板
@property (nonatomic, weak) IJSDToolBarView *toolBarView; // 工具条
@property (nonatomic, weak) IJSDColorView *colorView;     // 颜色板子
@end

@implementation IJSDrawingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self _createdUI];
    [self _action]; //block
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)_createdUI
{
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    //    backImageView.image =[UIImage imageNamed:@"Home_refresh_bg"];
    [self.view addSubview:backImageView];
    self.backImageView = backImageView;

    IJSDrawingView *drawingView = [[IJSDrawingView alloc] initWithFrame:self.view.bounds];
    drawingView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:drawingView];
    self.drawingView = drawingView;

    IJSDToolBarView *toolBarView = [[IJSDToolBarView alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 30)];
    toolBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:toolBarView];
    self.toolBarView = toolBarView;

    IJSDColorView *colorView = [[IJSDColorView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 140, self.view.frame.size.width, 140)];
    [self.view addSubview:colorView];
    self.colorView = colorView;
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
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
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
        [weakSelf presentViewController:picker animated:YES completion:nil];
    };

    self.toolBarView.savePhotoCallBack = ^{

        UIGraphicsBeginImageContextWithOptions(weakSelf.drawingView.frame.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [weakSelf.backImageView drawRect:weakSelf.drawingView.frame];
        [weakSelf.drawingView.layer drawInContext:context]; // layer renderInContext
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (weakSelf.finishCallBack)
            weakSelf.finishCallBack(image);

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //  必须加这个方法 - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
            UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            dispatch_async(dispatch_get_main_queue(), ^{

                           });
        });
        [weakSelf dismissViewControllerAnimated:true completion:nil];
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
    IJSDExportView *exportView = [[IJSDExportView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height - 140 - 30)];
    exportView.backgroundColor = [UIColor clearColor];
    exportView.drawImage = selectedImage;
    [self.view addSubview:exportView];
    __weak typeof(self) weakSelf = self;
    __weak typeof(exportView) weakexportView = exportView;

    exportView.finishCallBack = ^(IJSDrawingModel *model) {
        weakSelf.drawingView.model = model;
        [weakexportView removeFromSuperview];
    };

    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*-----------------------------------setting-------------------------------------------------------*/
- (void)setOriginImage:(UIImage *)originImage
{
    _originImage = originImage;
    self.backImageView.image = originImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
