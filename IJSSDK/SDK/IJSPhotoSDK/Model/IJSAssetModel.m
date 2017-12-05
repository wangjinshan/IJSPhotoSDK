
//
//  IJSAssetModel.m
//  JSPhotoSDK
//
//  Created by shan on 2017/6/2.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSAssetModel.h"
#import "IJSImageManager.h"
#import "IJSConst.h"
#import "IJSExtension.h"

@implementation IJSAssetModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{};

+ (instancetype)setAssetModelAsset:(id)asset type:(JSAssetModelSourceType)type timeLength:(NSString *)timeLength
{
    IJSAssetModel *model = [self setAssetModelAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

+ (instancetype)setAssetModelAsset:(id)asset type:(JSAssetModelSourceType)type
{
    IJSAssetModel *model = [[IJSAssetModel alloc] init];
    model.asset = asset;
    model.type = type;
    return model;
}

// 缓存模型的高度
- (CGFloat)assetHeight
{
    if (_assetHeight)
    {
        return _assetHeight;
    }
    CGSize imageSize = [[IJSImageManager shareManager] photoSizeWithAsset:self.asset];
    if (imageSize.width == 0)
    {
        return JSScreenHeight;
    }
    CGFloat imageHeight = JSScreenWidth * imageSize.height / imageSize.width;
    if (imageHeight > JSScreenHeight - IJSGStatusBarAndNavigationBarHeight - IJSGTabbarSafeBottomMargin - IJSGNavigationBarHeight)
    {
        return JSScreenHeight - IJSGStatusBarAndNavigationBarHeight - IJSGTabbarSafeBottomMargin - IJSGNavigationBarHeight;
    }
    return imageHeight;
}

@end
