//
//  IJSImageToolView.m
//  IJSPhotoSDKProject
//
//  Created by shan on 2017/7/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageToolView.h"
#import "IJSExtension.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSImageConst.h"

@interface IJSImageToolView ()

/* 画笔 */
@property (nonatomic, weak) UIButton *panButton;
/* 笑脸 */
@property (nonatomic, weak) UIButton *smileButton;
/* 文字button */
@property (nonatomic, weak) UIButton *textButton;
/* 马赛克 */
@property (nonatomic, weak) UIButton *mosaicButton;
/* 裁剪 */
@property (nonatomic, weak) UIButton *clipButton;

@end

@implementation IJSImageToolView

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
    CGFloat marginLeft = ToolBarMarginLeft;
    CGFloat toolButtonCenterY = self.js_height / 2 - buttonSzieWidth / 2;
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.js_width, self.js_height)];
    [self addSubview:toolBarView];
    self.toolBarView = toolBarView;

    //画笔
    UIButton *panButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [panButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"annotate@2x" imageType:@"png"] forState:UIControlStateNormal];
    [panButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"annotate_selected@2x" imageType:@"png"] forState:UIControlStateSelected];
    panButton.frame = CGRectMake(marginLeft, toolButtonCenterY, buttonSzieWidth, buttonSzieWidth);
    panButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [panButton addTarget:self action:@selector(_panButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:panButton];
    self.panButton = panButton;

    UIButton *smileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [smileButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"smilewhite@2x" imageType:@"png"] forState:UIControlStateNormal];
    [smileButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"smilegreen@2x" imageType:@"png"] forState:UIControlStateSelected];
    smileButton.frame = CGRectMake(panButton.js_centerX + buttonSzieWidth / 2 + marginLeft, toolButtonCenterY, buttonSzieWidth, buttonSzieWidth);
    smileButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [smileButton addTarget:self action:@selector(_smileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:smileButton];
    self.smileButton = smileButton;

    UIButton *textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [textButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"text@2x" imageType:@"png"] forState:UIControlStateNormal];
    [textButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"text_selected@2x" imageType:@"png"] forState:UIControlStateSelected];
    textButton.frame = CGRectMake(smileButton.js_centerX + buttonSzieWidth / 2 + marginLeft, toolButtonCenterY, buttonSzieWidth, buttonSzieWidth);
    textButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [textButton addTarget:self action:@selector(_textButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:textButton];
    self.textButton = textButton;

    UIButton *mosaicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mosaicButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"mosaicblack@2x" imageType:@"png"] forState:UIControlStateNormal];
    [mosaicButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"mosaicgreen@2x" imageType:@"png"] forState:UIControlStateSelected];
    mosaicButton.frame = CGRectMake(textButton.js_centerX + buttonSzieWidth / 2 + marginLeft, toolButtonCenterY, buttonSzieWidth, buttonSzieWidth);
    mosaicButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [mosaicButton addTarget:self action:@selector(_mosaicButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:mosaicButton];
    self.mosaicButton = mosaicButton;

    UIButton *clipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clipButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"clip@2x" imageType:@"png"] forState:UIControlStateNormal];
    clipButton.frame = CGRectMake(mosaicButton.js_centerX + buttonSzieWidth / 2 + marginLeft, toolButtonCenterY, buttonSzieWidth, buttonSzieWidth);
    clipButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [clipButton addTarget:self action:@selector(_clipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:clipButton];
    self.clipButton = clipButton;
}

#pragma mark 点击事件
- (void)_panButtonAction:(UIButton *)button
{
    [self _resetButtonStatus:button];
    if (self.panButtonBlock)
    {
        self.panButtonBlock(button);
    }
    button.selected = !button.selected;
}

- (void)_smileButtonAction:(UIButton *)button
{
    [self _resetButtonStatus:button];
    if (self.smileButtonBlock)
    {
        self.smileButtonBlock(button);
    }
    button.selected = !button.selected;
}
- (void)_textButtonAction:(UIButton *)button
{
    [self _resetButtonStatus:button];
    if (self.textButtonBlock)
    {
        self.textButtonBlock(button);
    }
    button.selected = !button.selected;
}

- (void)_mosaicButtonAction:(UIButton *)button
{
    [self _resetButtonStatus:button];
    if (self.mosaicButtonBlock)
    {
        self.mosaicButtonBlock(button);
    }
    button.selected = !button.selected;
}

- (void)_clipButtonAction:(UIButton *)button
{
    if (self.clipButtonBlock)
    {
        self.clipButtonBlock(button);
    }
}

/*-----------------------------------私有方法-------------------------------------------------------*/
#pragma mark 改变button的状态
- (void)_resetButtonStatus:(UIButton *)button
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
/*------------------------------------视频编辑重新调整button的UI布局-------------------------------*/
- (void)setupUIForVideoEditController
{
    self.mosaicButton.hidden = YES;
    CGFloat marginLeft = (JSScreenWidth - 4 * buttonSzieWidth) / 5;
    self.panButton.js_left = marginLeft;
    self.smileButton.js_left = marginLeft * 2 + buttonSzieWidth;
    self.textButton.js_left = marginLeft * 3 + buttonSzieWidth * 2;
    self.clipButton.js_left = marginLeft * 4 + buttonSzieWidth * 3;
}
/*-----------------------------------------------护肤button的默认状态-------------------------------*/
-(void)resetButtonState
{
    for (UIView *buttonView in self.toolBarView.subviews)
    {
        if ([buttonView isKindOfClass:[UIButton class]])
        {
            ((UIButton *) buttonView).selected = NO;
        }
    }
}










@end
