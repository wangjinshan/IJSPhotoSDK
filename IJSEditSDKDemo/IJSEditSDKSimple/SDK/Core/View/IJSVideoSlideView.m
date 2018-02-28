//
//  IJSVideoSlideView.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoSlideView.h"
#import "IJSExtension.h"
#import <IJSFoundation/IJSFoundation.h>

@implementation IJSVideoSlideView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame backImage:(UIImage *)backImage isLeft:(BOOL)isLeft
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backImage = backImage;
        self.isLeft = isLeft;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.backImage != nil)
    {
        [self.backImage drawInRect:CGRectMake(0, 0, self.js_width, self.js_height)];
    }
    else
    {
        if (_isLeft)
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.js_width, self.js_height) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5, 5)];
            [[IJSFColor colorWithR:170 G:170 B:170 alpha:1] set];
            [path fill];
            UIBezierPath *verticalLine = [UIBezierPath bezierPathWithRect:CGRectMake(self.js_width * 0.5, 10, 1, self.js_height - 20)];
            [[UIColor whiteColor] set];
            [verticalLine fill];
        }
        else
        {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.js_width, self.js_height) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
            [[IJSFColor colorWithR:170 G:170 B:170 alpha:1] set];
            [path fill];
            UIBezierPath *verticalLine = [UIBezierPath bezierPathWithRect:CGRectMake(self.js_width * 0.5, 10, 1, self.js_height - 20)];
            [[UIColor whiteColor] set];
            [verticalLine fill];
        }
    }
}
#pragma mark set方法
- (void)setIsLeft:(BOOL)isLeft
{
    _isLeft = isLeft;
}
- (void)setBackImage:(UIImage *)backImage
{
    _backImage = backImage;
}

@end
