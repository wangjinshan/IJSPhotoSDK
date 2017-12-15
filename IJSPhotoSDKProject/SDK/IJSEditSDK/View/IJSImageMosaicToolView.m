//
//  IJSImageMosaicToolView.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/23.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageMosaicToolView.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSImageConst.h"
#import "IJSUConst.h"
#import "IJSExtension.h"

@interface IJSImageMosaicToolView ()
@property (nonatomic, weak) UIView *toolBarView; // 参数说明
@end

@implementation IJSImageMosaicToolView

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
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.js_width, self.js_height)];
    [self addSubview:toolBarView];
    self.toolBarView = toolBarView;

    CGFloat marginLeft = (JSScreenWidth - IJSImageMosaicButtonHeight * 3) / 4;
    UIButton *typeOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [typeOne setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"mosaiconew@2x" imageType:@"png"] forState:UIControlStateNormal];
    [typeOne setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"mosaiconeg@2x" imageType:@"png"] forState:UIControlStateSelected];
    typeOne.frame = CGRectMake(marginLeft, 0, IJSImageMosaicButtonHeight, IJSImageMosaicButtonHeight);
    typeOne.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.toolBarView addSubview:typeOne];
    [typeOne addTarget:self action:@selector(typeOneAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *typeTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    [typeTwo setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"mosaictwow@2x" imageType:@"png"] forState:UIControlStateNormal];
    [typeTwo setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"mosaictwog@2x" imageType:@"png"] forState:UIControlStateSelected];
    typeTwo.frame = CGRectMake(2 * marginLeft + IJSImageMosaicButtonHeight, 0, IJSImageMosaicButtonHeight, IJSImageMosaicButtonHeight);
    [self.toolBarView addSubview:typeTwo];
    typeTwo.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [typeTwo addTarget:self action:@selector(typeTwoAction:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *cancleLast = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleLast setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"chexiao@2x" imageType:@"png"] forState:UIControlStateNormal];
    [cancleLast setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"chexiao@2x" imageType:@"png"] forState:UIControlStateSelected];
    cancleLast.frame = CGRectMake(3 * marginLeft + 2 * IJSImageMosaicButtonHeight, 0, IJSImageMosaicButtonHeight, IJSImageMosaicButtonHeight);
    [self.toolBarView addSubview:cancleLast];
    [cancleLast addTarget:self action:@selector(cancleLastAction:) forControlEvents:UIControlEventTouchUpInside];
    cancleLast.imageView.contentMode = UIViewContentModeScaleAspectFit;
}
// 点击回调
- (void)typeOneAction:(UIButton *)button
{
    [self resetButtonStatus:button];
    if (self.typeOneCallBack)
    {
        self.typeOneCallBack(button);
    }
    button.selected = !button.selected;
}

- (void)typeTwoAction:(UIButton *)button
{
    [self resetButtonStatus:button];
    if (self.typeTwoCallBack)
    {
        self.typeTwoCallBack(button);
    }
    button.selected = !button.selected;
}
- (void)cancleLastAction:(UIButton *)button
{
    [self resetButtonStatus:button];
    if (self.cancleLastCallBack)
    {
        self.cancleLastCallBack(button);
    }
    button.selected = !button.selected;
}

#pragma mark 改变button的状态
- (void)resetButtonStatus:(UIButton *)button
{
    BOOL selected = button.selected;
    for (UIView *buttonView in self.toolBarView.subviews)
    {
        if ([buttonView isKindOfClass:[UIButton class]])
        {
            ((UIButton *) buttonView).selected = NO;
        }
    }
    button.selected = selected;
}

@end
