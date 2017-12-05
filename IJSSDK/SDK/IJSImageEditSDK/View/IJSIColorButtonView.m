//
//  IJSIColorButtonView.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/13.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSIColorButtonView.h"
#import "IJSImageConst.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"

@interface IJSIColorButtonView ()
/* 背景 */
@property (nonatomic, weak) UIView *backColorView;
/* 红 */
@property (nonatomic, weak) UIButton *redButton;
/* 橙 */
@property (nonatomic, weak) UIButton *orangeButton;
/* 黄 */
@property (nonatomic, weak) UIButton *yellowButton;
/* 绿 */
@property (nonatomic, weak) UIButton *greenButton;
/* 蓝 */
@property (nonatomic, weak) UIButton *blueButton;
/* 棕 */
@property (nonatomic, weak) UIButton *brownButton;
/* 紫 */
@property (nonatomic, weak) UIButton *purpleButton;

@end

@implementation IJSIColorButtonView

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
    UIView *backColorView = [[UIView alloc] initWithFrame:CGRectMake(ColorButtonViewMarginLeft, 0, JSScreenWidth - 2 * ColorButtonViewMarginLeft, ColorButtonViewHeight)];
    [self addSubview:backColorView];
    self.backColorView = backColorView;

    // 滑动条slider
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(50, ColorButtonViewHeight + 3, JSScreenWidth - 100, 20)];
    slider.minimumValue = 1;                                                                                   // 设置最小值
    slider.maximumValue = 10;                                                                                  // 设置最大值
    slider.value = 5;                                                                                          // 设置初始值
    slider.continuous = YES;                                                                                   // 设置可连续变化
    slider.minimumTrackTintColor = [UIColor greenColor];                                                       //滑轮左边颜色，如果设置了左边的图片就不会显示
    slider.maximumTrackTintColor = [UIColor redColor];                                                         //滑轮右边颜色，如果设置了右边的图片就不会显示
    slider.thumbTintColor = [UIColor whiteColor];                                                              //设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged]; // 针对值变化添加响应方法
    [self addSubview:slider];

    // 创建各色button  红橙黄绿蓝靛紫
    CGFloat buttonSpace = ColorButtonViewButtonSpace;
    for (int i = 0; i < 7; i++)
    {
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        colorButton.layer.cornerRadius = ColorButtonViewButtonWidth / 2;
        colorButton.layer.borderWidth = 0;
        colorButton.frame = CGRectMake(i * buttonSpace, 0, ColorButtonViewButtonWidth, ColorButtonViewButtonWidth);
        colorButton.tag = i;
        [colorButton addTarget:self action:@selector(_colorButtonActionDrawCirle:) forControlEvents:UIControlEventTouchUpInside];
        [backColorView addSubview:colorButton];
        switch (i)
        {
            case 0:
            {
                colorButton.backgroundColor = [UIColor redColor];
                self.redButton = colorButton;
                break;
            }
            case 1:
            {
                colorButton.backgroundColor = [UIColor orangeColor];
                self.orangeButton = colorButton;
                break;
            }
            case 2:
            {
                colorButton.backgroundColor = [UIColor yellowColor];
                self.yellowButton = colorButton;
                break;
            }
            case 3:
            {
                colorButton.backgroundColor = [UIColor greenColor];
                self.greenButton = colorButton;
                break;
            }
            case 4:
            {
                colorButton.backgroundColor = [UIColor blueColor];
                self.blueButton = colorButton;
                break;
            }
            case 5:
            {
                colorButton.backgroundColor = [UIColor brownColor];
                self.brownButton = colorButton;
                break;
            }
            case 6:
            {
                colorButton.backgroundColor = [UIColor purpleColor];
                self.purpleButton = colorButton;
                break;
            }
            default:
                break;
        }
    }

    // 撤销按钮
    UIButton *canclePathButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [canclePathButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"chexiao@2x" imageType:@"png"] forState:UIControlStateNormal];
    canclePathButton.frame = CGRectMake(8 * buttonSpace, 0, ColorButtonViewButtonWidth, ColorButtonViewButtonWidth);
    canclePathButton.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:canclePathButton];
    [canclePathButton addTarget:self action:@selector(canclePathButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.canclePathButton = canclePathButton;
}

- (void)_colorButtonActionDrawCirle:(UIButton *)button
{
    for (UIButton *subView in self.backColorView.subviews)
    {
        [subView drawCirleWithRadius:ColorButtonViewButtonWidth / 2 fillColor:[UIColor clearColor] strokeColor:[UIColor clearColor] isClick:NO];
    }
    UIColor *strokeColor = [UIColor whiteColor];
    BOOL isClick = YES;
    if (button.tag == 0)
    {
        [button drawCirleWithRadius:ColorButtonViewButtonWidth / 2 fillColor:[UIColor redColor] strokeColor:strokeColor isClick:isClick];
    }
    else if (button.tag == 1)
    {
        isClick = !button.isSelected;
        [button drawCirleWithRadius:ColorButtonViewButtonWidth / 2 fillColor:[UIColor orangeColor] strokeColor:strokeColor isClick:isClick];
    }
    else if (button.tag == 2)
    {
        isClick = !button.isSelected;
        [button drawCirleWithRadius:ColorButtonViewButtonWidth / 2 fillColor:[UIColor yellowColor] strokeColor:strokeColor isClick:isClick];
    }
    else if (button.tag == 3)
    {
        isClick = !button.isSelected;
        [button drawCirleWithRadius:ColorButtonViewButtonWidth / 2 fillColor:[UIColor greenColor] strokeColor:strokeColor isClick:isClick];
    }
    else if (button.tag == 4)
    {
        isClick = !button.isSelected;
        [button drawCirleWithRadius:ColorButtonViewButtonWidth / 2 fillColor:[UIColor blueColor] strokeColor:strokeColor isClick:isClick];
    }
    else if (button.tag == 5)
    {
        isClick = !button.isSelected;
        [button drawCirleWithRadius:ColorButtonViewButtonWidth / 2 fillColor:[UIColor brownColor] strokeColor:strokeColor isClick:isClick];
    }
    else if (button.tag == 6)
    {
        isClick = !button.isSelected;
        [button drawCirleWithRadius:ColorButtonViewButtonWidth / 2 fillColor:[UIColor purpleColor] strokeColor:strokeColor isClick:isClick];
    }
    // 颜色回调
    if (self.colorCallBack)
    {
        self.colorCallBack(button.backgroundColor);
    }
}
#pragma mark 滑条的数据值
- (void)sliderValueChanged:(id)sender
{
    UISlider *slider = (UISlider *) sender;
    if (self.sliderCallBack)
    {
        self.sliderCallBack(slider.value);
    }
}
- (void)canclePathButtonAction:(UIButton *)button
{
    if (self.cancleCallBack)
    {
        self.cancleCallBack();
    }
}

@end
