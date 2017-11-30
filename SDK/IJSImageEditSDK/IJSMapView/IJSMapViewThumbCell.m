//
//  IJSMapViewThumbCell.m
//  IJSMapView
//
//  Created by shange on 2017/9/10.
//  Copyright © 2017年 shange. All rights reserved.
//

#import "IJSMapViewThumbCell.h"
#import "IJSExtension.h"
#import <IJSFoundation/IJSFoundation.h>

@interface IJSMapViewThumbCell ()
@property (nonatomic, weak) UIImageView *thumbImageView; // 缩略图
@end

@implementation IJSMapViewThumbCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.js_width - 10, self.js_height - 10)];
        [self addSubview:thumbImageView];
        thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.thumbImageView = thumbImageView;
    }
    return self;
}

- (void)setImageModel:(IJSMapViewModel *)imageModel
{
    _imageModel = imageModel;
    self.thumbImageView.image = [UIImage imageWithContentsOfFile:imageModel.imageDataArr[10]];
    if (imageModel.isDidClick)
    {
        self.backgroundColor = [IJSFColor colorWithR:240 G:240 B:240 alpha:1];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
