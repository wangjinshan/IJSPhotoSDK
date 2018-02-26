//
//  IJSPreviewGifView.m
//  JSPhotoSDK
//
//  Created by shan on 2017/6/15.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSPreviewGifView.h"
#import "IJSImageManager.h"
#import "IJSAssetModel.h"

#import <objc/runtime.h>

@interface IJSPreviewGifView ()
/* 背景动态图 */
@property (nonatomic, weak) UIWebView *backWebView;

@end

@implementation IJSPreviewGifView

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
    UIWebView *backWebView = [UIWebView new];
    backWebView.backgroundColor = [UIColor blackColor];
    self.backWebView = backWebView;
    self.backWebView.userInteractionEnabled = NO;
    self.backWebView.scrollView.backgroundColor =[UIColor blackColor];
    self.backWebView.opaque = NO;   // 结局不能设置背景色的问题
    [self addSubview:backWebView];
    
}

- (void)setAssetModel:(IJSAssetModel *)assetModel
{
    _assetModel = assetModel;
    
    if (assetModel.outputPath) //编辑完成的image
    {
        NSData *imageData = [NSData dataWithContentsOfURL:assetModel.outputPath];
        [self.backWebView loadData:imageData MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL URLWithString:@""]];
    }
    else
    {
        if (assetModel.imageRequestID)
        {
            [[PHImageManager defaultManager] cancelImageRequest:assetModel.imageRequestID];  // 取消加载
        }
        assetModel.imageRequestID = [[IJSImageManager shareManager] getOriginalPhotoDataWithAsset:assetModel.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
            [self.backWebView loadData:data MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL URLWithString:@""]];
            if (!isDegraded)
            {
                assetModel.imageRequestID = 0;
            }
        }];
    }
}

- (void)layoutSubviews
{
    self.backWebView.frame = CGRectMake(0, 0, self.frame.size.width, self.assetModel.assetHeight);
}











@end
