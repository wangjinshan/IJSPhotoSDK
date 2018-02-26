//
//  IJSDToolBarView.m
//  IJSUExtension
//
//  Created by shan on 2017/8/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSDToolBarView.h"

@implementation IJSDToolBarView

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
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.barTintColor = [UIColor colorWithRed:190 / 255.0 green:172 / 255.0 blue:153 / 255.0 alpha:1];
    toolBar.tintColor =[UIColor whiteColor];
    [self addSubview:toolBar];

    toolBar.frame = CGRectMake(0, 0, self.frame.size.width, 30);

    //    UIBarButtonItem *cancle =[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction:)];
    UIBarButtonItem *cleanAll = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@", @"清屏"] style:UIBarButtonItemStylePlain target:self action:@selector(cleanAllAction:)];

    UIBarButtonItem *cleanLast = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@", @"撤销"] style:UIBarButtonItemStylePlain target:self action:@selector(cleanLastAction:)];
    //    UIBarButtonItem *erase =[[UIBarButtonItem alloc]initWithTitle:@"擦除" style:UIBarButtonItemStylePlain target:self action:@selector(eraseAction:)];
    //    UIBarButtonItem *addPhoto =[[UIBarButtonItem alloc]initWithTitle:@"照片" style:UIBarButtonItemStylePlain target:self action:@selector(addPhotoAction:)];
    //   UIBarButtonItem *sivePhoto =[[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(sivePhotoAction:)];
    [toolBar setItems:@[cleanAll, cleanLast]];
}

- (void)cancleAction:(UIBarButtonItem *)item
{
    if (self.cancleCallBack)
    {
        self.cancleCallBack();
    }
}
- (void)cleanAllAction:(UIBarButtonItem *)item
{
    if (self.cleanAllCallBack)
    {
        self.cleanAllCallBack();
    }
}
- (void)cleanLastAction:(UIBarButtonItem *)item
{
    if (self.cleanLastCallBack)
    {
        self.cleanLastCallBack();
    }
}
- (void)eraseAction:(UIBarButtonItem *)item
{
    if (self.eraseCallBack)
    {
        self.eraseCallBack();
    }
}
- (void)addPhotoAction:(UIBarButtonItem *)item
{
    if (self.addPhotoCallBack)
    {
        self.addPhotoCallBack();
    }
}
- (void)sivePhotoAction:(UIBarButtonItem *)item
{
    if (self.savePhotoCallBack)
    {
        self.savePhotoCallBack();
    }
}

- (void)drawRect:(CGRect)rect
{
}

@end
