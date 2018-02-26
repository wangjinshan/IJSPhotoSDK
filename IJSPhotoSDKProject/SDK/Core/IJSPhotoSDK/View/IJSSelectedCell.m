//
//  IJSSelectedCell.m
//  IJSDemo
//
//  Created by shan on 2017/8/10.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSSelectedCell.h"
#import "IJSAssetModel.h"
#import "IJSImageManager.h"

@interface IJSSelectedCell()


@end

@implementation IJSSelectedCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *backImageView = [[UIImageView alloc] init];
        backImageView.contentMode = UIViewContentModeScaleAspectFill;
        backImageView.clipsToBounds = YES;
        backImageView.frame = CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10);
        [self.contentView addSubview:backImageView];
        self.backImageView = backImageView;
    }
    return self;
}

- (void)setSelectedModel:(IJSAssetModel *)selectedModel
{
    _selectedModel = selectedModel;
    if (selectedModel.outputPath)
    {
        UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:selectedModel.outputPath]];
        _backImageView.image = image;
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        if (selectedModel.imageRequestID)
        {
            [[PHImageManager defaultManager] cancelImageRequest:selectedModel.imageRequestID];  // 取消加载
        }
        selectedModel.imageRequestID =  [[IJSImageManager shareManager] getPhotoWithAsset:selectedModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            weakSelf.backImageView.image = photo;
            if (!isDegraded)
            {
                selectedModel.imageRequestID = 0;
            }
        }];
    }
    _backImageView.layer.borderWidth = 0;
    _backImageView.layer.cornerRadius = 0;
    _backImageView.clipsToBounds = YES;

    if ((self.pushSelectedIndex == selectedModel.onlyOneTag && selectedModel.isFirstAppear) && !selectedModel.isPreviewButton)
    { // 第一次
        [self _addBorderForBackImageView];
    }
}
/// 点亮方法
- (void)_addBorderForBackImageView
{
    _backImageView.layer.borderWidth = 2;
    _backImageView.layer.cornerRadius = 3;
    _backImageView.layer.borderColor = [[UIColor greenColor] CGColor]; //设置边框的颜色
    _backImageView.clipsToBounds = YES;
}

@end
