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
    [self addSubview:backWebView];
}

- (void)setAssetModel:(IJSAssetModel *)assetModel
{
    _assetModel = assetModel;
  __weak typeof (self) weakSelf = self;
    [[IJSImageManager shareManager] getOriginalPhotoDataWithAsset:assetModel.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
        [weakSelf.backWebView loadData:data MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL URLWithString:@""]];
    }];
}

- (void)layoutSubviews
{
    self.backWebView.frame = CGRectMake(0, 0, self.frame.size.width, self.assetModel.assetHeight);
}

@end
