//
//  IJSImageNavigationView.m
//  IJSPhotoSDKProject
//
//  Created by shan on 2017/7/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageNavigationView.h"
#import "IJSExtension.h"

@interface IJSImageNavigationView ()

@end

@implementation IJSImageNavigationView

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
    UIView *navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, self.js_height)];
    [self addSubview:navigationView];

    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleButton.frame = CGRectMake(10, 0, 70, self.js_height);
    [cancleButton setTitle:[NSBundle localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(cancleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [navigationView addSubview:cancleButton];
    self.cancleButton = cancleButton;
    self.cancleButton.js_centerY = self.js_height * 0.5;

    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.frame = CGRectMake(JSScreenWidth - 80, 0, 70, self.js_height);
    [finishButton setTitle:[NSBundle localizedStringForKey:@"OK"] forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [navigationView addSubview:finishButton];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.finishButton = finishButton;
    self.finishButton.js_centerY = self.js_height * 0.5;
}

#pragma mark 点击方法
- (void)cancleButtonAction:(UIButton *)button
{
    if (self.cancleBlock)
    {
        self.cancleBlock();
    }
}

- (void)finishButtonAction:(UIButton *)button
{
    if (self.finishBlock)
    {
        self.finishBlock();
    }
}

@end
