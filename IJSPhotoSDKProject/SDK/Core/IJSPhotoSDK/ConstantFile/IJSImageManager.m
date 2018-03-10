//
//  IJSImageManager.m
//  JSPhotoSDK
//
//  Created by shan on 2017/5/28.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSImageManager.h"
#import "IJSImagePickerController.h"
#import "IJSAlbumModel.h"
#import "IJSAlbumPickerCell.h"
#import "IJSAssetModel.h"
#import "IJSConst.h"
#import "IJSExtension.h"

static IJSImageManager *manager;
static CGFloat JSScreenScale;         //缩放比例
static CGSize assetGridThumbnailSize; //预览照片的大小

@interface IJSImageManager ()

@end

@implementation IJSImageManager
// 单利
+ (instancetype)shareManager
{
    manager = [[self alloc] init];
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:zone] init];
        manager.cachingImageManager = [[PHCachingImageManager alloc] init];
        manager.cachingImageManager.allowsCachingHighQualityImages = YES;
        // 测试发现，如果scale在plus真机上取到3.0，内存会增大特别多。故这里写死成
        JSScreenScale = 2;
        if (JSScreenWidth > 700)
        {
            JSScreenScale = 1.5;
        }
        manager.photoPreviewMaxWidth = 6000;
    });
    return manager;
}
- (id)copyWithZone:(NSZone *)zone
{
    return manager;
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return manager;
}

/*-----------------------------------授权-------------------------------------------------------*/
#pragma mark 授权
// 授权状态
+ (NSInteger)authorizationStatus
{
    return [PHPhotoLibrary authorizationStatus];
}
// 弹出系统授权的窗口
- (BOOL)authorizationStatusAuthorized
{
    NSInteger status = [self.class authorizationStatus];
    if (status == 0)
    {
        /**
         * 当某些情况下AuthorizationStatus == AuthorizationStatusNotDetermined时，无法弹出系统首次使用的授权alertView，系统应用设置里亦没有相册的设置，此时将无法使用，故作以下操作，弹出系统首次使用的授权alertView
         */
        [self _requestAuthorizationWithCompletion:nil];
    }
    return status == 3;
}

#pragma mark 获取相册
// 获取相机胶卷的相册得到PHAsset对象放到IJSAlbumModel中
- (void)getCameraRollAlbumContentImage:(BOOL)contentImage contentVideo:(BOOL)contentVideo completion:(void (^)(IJSAlbumModel *model))completion
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!contentVideo)
    {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    }
    if (!contentImage)
    {
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
    }
    if (!self.sortAscendingByModificationDate)
    {
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
    }
    PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *collection in smartAlbums)
    {
        if (![collection isKindOfClass:[PHAssetCollection class]])
        {
            continue;  // 有可能是PHCollectionList类的的对象，过滤掉
        }
        if ([self isCameraRollAlbum:collection.localizedTitle])
        {
            PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            IJSAlbumModel *model = [self modelWithResult:fetchResult name:collection.localizedTitle];
            if (completion)
            {
                completion(model);
            }
            break;
        }
    }
}
// 获取所有的照片信息
- (void)getAllAlbumsContentImage:(BOOL)contentImage contentVideo:(BOOL)contentVideo completion:(void (^)(NSArray<IJSAlbumModel *> *models))completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *albumArr = [NSMutableArray array];
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!contentVideo)
        {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
        if (!contentImage)
        {
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
        if (!self.sortAscendingByModificationDate)
        {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        // 用户照片
        PHFetchResult<PHAssetCollection *> *myPhotoStreamAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil]; //用户的 iCloud 照片流
        PHFetchResult<PHCollection *> *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        PHFetchResult<PHAssetCollection *> *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        PHFetchResult<PHAssetCollection *> *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil]; //用户使用 iCloud 共享的相册
        // 智能相册
        PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        NSArray *allAlbums = @[myPhotoStreamAlbum, smartAlbums, topLevelUserCollections, syncedAlbums, sharedAlbums];
        for (PHFetchResult *fetchResult in allAlbums)
        {
            for (PHAssetCollection *collection in fetchResult)
            {
                // 有可能是PHCollectionList类的的对象，过滤掉
                if (![collection isKindOfClass:[PHAssetCollection class]])
                {
                    continue;
                }
                PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                if (fetchResult.count < 1)
                {
                    continue; // 过滤无照片的相册
                }
                if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"])
                {
                    continue;
                }
                if ([self isCameraRollAlbum:collection.localizedTitle]) // 相机胶卷
                {
                    [albumArr insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:0];
                }
                else // 非相机胶卷
                {
                    [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion && albumArr.count > 0)
            {
                completion(albumArr);
            }
        });
    });
}
#pragma mark 解析相册资源为 PHAsset 对象
- (void)getAssetsFromFetchResult:(PHFetchResult *)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<IJSAssetModel *> *models))completion
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *photoArr = [NSMutableArray array];
        PHFetchResult *fetResult = (PHFetchResult *) result;
        [fetResult enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            IJSAssetModel *model = [self _setModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model)
            {
                [photoArr addObject:model];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(photoArr);
            }
        });
    });
}

- (void)getAssetFromFetchResult:(id)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(IJSAssetModel *model))completion
{
    if ([result isKindOfClass:[PHFetchResult class]])
    {
        PHFetchResult *fetchResult = (PHFetchResult *) result;
        PHAsset *asset;
        @try
        {
            asset = fetchResult[index];
        }
        @catch (NSException *e)
        {
            if (completion)
            {
                completion(nil);
            }
            return;
        }
        @finally
        {
            NSLog(@"获取的下标数组越界了");
        }
        IJSAssetModel *model = [self _setModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        if (completion)
        {
            completion(model);
        }
    }
}

/*-----------------------------------获取封面-------------------------------------------------------*/
#pragma mark 通过模型解析相册资源获取封面照片
- (PHImageRequestID)getPostImageWithAlbumModel:(IJSAlbumModel *)model completion:(void (^)(UIImage *postImage))completion
{
    id asset = [model.result lastObject];
    if (!self.sortAscendingByModificationDate) //非时间排序
    {
        asset = [model.result firstObject];
    }
    PHImageRequestID imageRequestID = [[IJSImageManager shareManager] getPhotoWithAsset:asset photoWidth:thumbImageViewWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion)
        {
            completion(photo);
        }
    }];
    return imageRequestID;
}
/*-----------------------------------获取照片-------------------------------------------------------*/
#pragma mark 解析相册资源
/// 无进度条
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    return [[IJSImageManager shareManager] getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}
///
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    CGFloat fullScreenWidth = JSScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth)
    {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [[IJSImageManager shareManager] getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed
{
    CGFloat fullScreenWidth = JSScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth)
    {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [[IJSImageManager shareManager] getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}
// 获取照片总接口
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed
{
    CGSize imageSize;
    if (photoWidth < JSScreenWidth && photoWidth < _photoPreviewMaxWidth)
    {
        imageSize = assetGridThumbnailSize;
    }
    else
    {
        PHAsset *phAsset = (PHAsset *) asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat) phAsset.pixelHeight;
        CGFloat pixelWidth = photoWidth * JSScreenScale;
        // 超宽图片
        if (aspectRatio > 1)
        {
            pixelWidth = pixelWidth * aspectRatio;
        }
        // 超高图片
        if (aspectRatio < 0.2)
        {
            pixelWidth = pixelWidth * 0.5;
        }
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        imageSize = CGSizeMake(pixelWidth, pixelHeight);
    }
  
    [self startCachingImagesFormAssets:@[asset] targetSize:imageSize];
    return [self _requestImageForAsset:asset targetSize:imageSize completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}
// 图片预览界面单独设置
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed
{
    return  [self _requestImageForAsset:asset targetSize:targetSize completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}
///  为了定制大小分开
-(PHImageRequestID)_requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset
                                                                                 targetSize:targetSize
                                                                                contentMode:PHImageContentModeAspectFill
                                                                                    options:option resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                        UIImage *image;
                                                                                        if (result)
                                                                                        {
                                                                                            image = result;
                                                                                        }
                                                                                         BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];  //表示已经获取了高清图
                                                                                        if (downloadFinined && result)
                                                                                        {
                                                                                            result = [self fixOrientation:result];
                                                                                            if (completion)
                                                                                            {
                                                                                                completion(result, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                                                                                            }
                                                                                        }
                                                                                        // Download image from iCloud / 从iCloud下载图片
                                                                                        if ([info objectForKey:PHImageResultIsInCloudKey] && !result && networkAccessAllowed)
                                                                                        {
                                                                                            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                                                                                            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                    if (progressHandler)
                                                                                                    {
                                                                                                        progressHandler(progress, error, stop, info);
                                                                                                    }
                                                                                                });
                                                                                            };
                                                                                            options.networkAccessAllowed = YES;
                                                                                            options.resizeMode = PHImageRequestOptionsResizeModeFast;
                                                                                            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                                                                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                                                                                                resultImage = [self scaleImage:resultImage toSize:targetSize];
                                                                                                if (!resultImage)
                                                                                                {
                                                                                                    resultImage = image;
                                                                                                }
                                                                                                resultImage = [self fixOrientation:resultImage];
                                                                                                if (completion)
                                                                                                {
                                                                                                    completion(resultImage, info, NO);
                                                                                                }
                                                                                            }];
                                                                                        }
                                                                                    }];
    return imageRequestID;
}

/*-----------------------------------获取原图-------------------------------------------------------*/
#pragma mark 获取原图
- (PHImageRequestID)getOriginalPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion
{
    PHImageRequestID imageRequestID = [self getOriginalPhotoWithAsset:asset
                                                        newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                                                            if (completion)
                                                            {
                                                                completion(photo, info);
                                                            }
                                                        }];
    return imageRequestID;
}

- (PHImageRequestID)getOriginalPhotoWithAsset:(PHAsset *)asset newCompletion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset
                                                                                 targetSize:PHImageManagerMaximumSize
                                                                                contentMode:PHImageContentModeAspectFit
                                                                                    options:option
                                                                              resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                                                                                  
                                                                                   BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];  //表示已经获取了高清图
                                                                                  if (downloadFinined && result)
                                                                                  {
                                                                                      result = [self fixOrientation:result]; // 修复方向
                                                                                      BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                                                                      if (completion)
                                                                                      {
                                                                                          completion(result, info, isDegraded);
                                                                                      }
                                                                                  }
                                                                              }];
    return imageRequestID;
}

- (PHImageRequestID)getOriginalPhotoDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                                                        options:option
                                                                                  resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, UIImageOrientation orientation, NSDictionary *_Nullable info) {
                                                                                      
                                                                                       BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];  //表示已经获取了高清图
                                                                                      if (downloadFinined && imageData)
                                                                                      {
                                                                                          BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                                                                          if (completion)
                                                                                          {
                                                                                              completion(imageData, info, isDegraded);
                                                                                          }
                                                                                      }
                                                                                  }];
    return imageRequestID;
}
// livephoto
#pragma mark 获取LivePhoto
- (PHImageRequestID)getLivePhotoWithAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)networkAccessAllowed completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion
{
    CGFloat fullScreenWidth = JSScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth)
    {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self getLivePhotoWithAsset:asset photoWidth:fullScreenWidth networkAccessAllowed:networkAccessAllowed completion:completion progressHandler:nil];
}
// 获取livephoto
- (PHImageRequestID)getLivePhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth networkAccessAllowed:(BOOL)networkAccessAllowed completion:(void (^)(PHLivePhoto *_Nullable livePhoto, NSDictionary *_Nullable info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    if (iOS9_1Later)
    {
        CGSize imageSize;
        if (photoWidth < JSScreenWidth && photoWidth < _photoPreviewMaxWidth) // _photoPreviewMaxWidth默认是600
        {
            imageSize = assetGridThumbnailSize;
        }
        else
        {
            PHAsset *phAsset = (PHAsset *) asset;
            CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat) phAsset.pixelHeight;
            CGFloat pixelWidth = photoWidth * JSScreenScale * 1.5;
            // 超宽图片
            if (aspectRatio > 1)
            {
                pixelWidth = pixelWidth * aspectRatio;
            }
            // 超高图片
            if (aspectRatio < 0.2)
            {
                pixelWidth = pixelWidth * 0.5;
            }
            CGFloat pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSizeMake(pixelWidth, pixelHeight);
        }
        
        if (iOS9_1Later)
        {
            PHLivePhotoRequestOptions *livePhotoOptions = [[PHLivePhotoRequestOptions alloc] init];
            livePhotoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic; //可能获取多个结果
            livePhotoOptions.networkAccessAllowed = networkAccessAllowed;
            livePhotoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progressHandler)
                    {
                        progressHandler(progress, error, stop, info);
                    }
                });
            };
            PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:livePhotoOptions resultHandler:^(PHLivePhoto *_Nullable livePhoto, NSDictionary *_Nullable info) {
                // 排除取消，错误，低清图三种情况，即已经获取到了高清图
                 BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];  //表示已经获取了高清图
                if (downloadFinined && livePhoto)
                {
                    if (completion)
                    {
                        completion(livePhoto, info);
                    }
                }
            }];
            return imageRequestID;
        }
        else
        {
            return 0;
        }
    }
    else
    { //之前
        return 0;
    }
}

/*-----------------------------------获取视频-------------------------------------------------------*/
#pragma mark 获取视频
- (PHImageRequestID)getVideoWithAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)networkAccessAllowed progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *playerItem, NSDictionary *info))completion
{
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = networkAccessAllowed;
    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler)
            {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    PHImageRequestID imageRequestID =  [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if (completion)
        {
            completion(playerItem, info);
        }
    }];
    return imageRequestID;
}
/// 获取视频-----没有进行视频方向的旋转
- (PHImageRequestID)getAVAssetWithPHAsset:(PHAsset *)asset completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))completion
{
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat; // 速度最快
    option.networkAccessAllowed = NO;                                  // 不加载网络请求
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset *_Nullable asset, AVAudioMix *_Nullable audioMix, NSDictionary *_Nullable info) {
        if (completion)
        {
            completion(asset, audioMix, info);
        }
    }];
    return imageRequestID;
}
/// 获取导出的视频
- (PHImageRequestID)getExportSessionWithPhAsset:(PHAsset *)asset completion:(void (^)(AVAssetExportSession *exportSession, NSDictionary *info))completion
{
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat; // 速度最快
    option.networkAccessAllowed = NO;                                  // 不加载网络请求
    // exportPreset 控制导出的视频质量
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestExportSessionForVideo:asset options:option exportPreset:AVAssetExportPresetMediumQuality resultHandler:^(AVAssetExportSession *_Nullable exportSession, NSDictionary *_Nullable info) {
        if (completion)
        {
            completion(exportSession, info);
        }
    }];
    return imageRequestID;
}

/*-----------------------------------导出视频-------------------------------------------------------*/
#pragma mark 导出视频
- (PHImageRequestID)getVideoOutputPathWithAsset:(PHAsset *)asset completion:(void (^)(NSURL *outputPath, NSError *error, IJSImageState state))completion
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info) {
        AVURLAsset *videoAsset = (AVURLAsset *) avasset;
        [self _startExportVideoWithVideoAsset:videoAsset completion:completion];
    }];
    return imageRequestID;
}
#pragma mark 判断相册是否存在
- (BOOL)isExistFolder:(NSString *)folderName completion:(void (^)(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess))completion
{
    __block BOOL isExisted = NO;
    //首先获取用户手动创建相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    for (PHCollection *collection in collectonResuts)
    {
        if ([collection.localizedTitle isEqualToString:folderName]) // folderName是我们写入照片的相册
        {
            isExisted = YES;   // PHAssetColllection
            if (completion)
            {
                completion(collection, nil, isExisted);
            }
            break;
        }
    }
    if (!isExisted)
    {
        if (completion)
        {
            completion(nil, nil, NO);
        }
    }
    return isExisted;
}
#pragma mark 创建相册
//  创建自定义相册
- (void)createdAlbumName:(NSString *)albumName completion:(void (^)(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess))completion
{
    if ([self authorizationStatusAuthorized])
    {
        if ([self isExistFolder:albumName completion:nil]) // 已经存在
        {
            if (completion)
            {
                [self isExistFolder:albumName completion:completion];
            }
        }
        else
        {                                             //不存在
            if ([self authorizationStatusAuthorized]) // 已经授权
            {
                /* 没有创建过相册 */
                //2 创建自己相册的 唯一标识,生成占位对象
                NSError *error = nil;
                __block NSString *photoID = nil;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    photoID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
                } error:&error];
                // 创建相册成功,并返回
                if (completion)
                {
                    completion([PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[photoID] options:nil].firstObject, error, error ? NO : YES);
                }
            }
            else
            { // 没有授权直接打开
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
    }
    else
    { //没有授权
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark 保存图片到自定义的相册
// 保存图片到自定义的相册
- (BOOL)saveImageIntoAlbumFromImage:(id)image albumName:(NSString *)albumName completion:(void (^)(NSError *error, BOOL isExistedOrIsSuccess))completion
{
    __block NSError *error = nil;
    id asset = [self saveImageIntoSystemAlbumFromImage:image completion:nil]; // 保存资源到相机胶卷
    if (asset == nil)
    {
        return NO;
    }
    if ([self isExistFolder:albumName completion:nil]) // 已经存在直接保存
    {
        [self isExistFolder:albumName completion:^(id assetCollection, NSError *error, BOOL isExisted) {
            // 3,添加刚才保存的图片到自定义相册
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                [request insertAssets:asset atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
        }];
        if (completion)
        {
            completion(error, YES);
        }
        if (!error)
        {
            return YES;
        }
    }
    else
    { // 创建相册
        [self createdAlbumName:albumName completion:^(id assetCollection, NSError *error, BOOL isExisted) {
            PHAssetCollection *collection = assetCollection;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                [request insertAssets:asset atIndexes:[NSIndexSet indexSetWithIndex:0]];
            } error:&error];
        }];
        if (completion)
            completion(error, error ? NO : YES);
        if (!error)
            return YES;
    }
    if (error)
    {
        return NO;
    }
    return YES;
}
#pragma mark 保存视频到指定的目录
- (BOOL)saveVideoIntoAlbumFromVideo:(id)video albumName:(NSString *)albumName completion:(void (^)(NSError *error, BOOL isExistedOrIsSuccess))completion
{
    if (![video isKindOfClass:[NSURL class]])
    {
        return NO;
    }
    id asset = [self saveVideoIntoSystemAlbumFromVideoUrl:video completion:nil];
    if (asset == nil)
    {
        return NO;
    }
    __block NSError *error = nil;
    if ([self isExistFolder:albumName completion:nil])
    {
        [self isExistFolder:albumName completion:^(id assetCollection, NSError *error, BOOL isExisted) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                [request insertAssets:asset atIndexes:[NSIndexSet indexSetWithIndex:0]];
                if (completion)
                {
                    completion(error, error ? NO : YES);
                }
            } error:&error];
            
        }];
        if (!error)
        {
            return YES;
        }
    }
    else
    {
        [self createdAlbumName:albumName completion:^(id assetCollection, NSError *error, BOOL isExisted) {
            PHAssetCollection *collection = assetCollection;
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                [request insertAssets:asset atIndexes:[NSIndexSet indexSetWithIndex:0]];
                if (completion)
                {
                    completion(error, error ? NO : YES);
                }
            } error:&error];
            
        }];
        if (!error)
        {
            return YES;
        }
    }
    return YES;
}

// 获取保存到相册中图片
#pragma mark 保存图片到相机胶卷,并返回对象
- (id)saveImageIntoSystemAlbumFromImage:(id)resources completion:(void (^)(id assetResult, NSError *error, BOOL isExistedOrIsSuccess))completion
{
    NSError *error = nil;
    // 1,保存图片到相机胶卷
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        if ([resources isKindOfClass:[UIImage class]]) //
        {
            assetID = [PHAssetChangeRequest creationRequestForAssetFromImage:resources].placeholderForCreatedAsset.localIdentifier;
        }
        else if ([resources isKindOfClass:[NSURL class]])
        {
            assetID = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:resources].placeholderForCreatedAsset.localIdentifier;
        }
    } error:&error];
    if (completion)
    {
        completion([PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil], error, error ? NO : YES);
    }
    if (error)
    {
        return nil;
    }
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}
// 保存视频资源到相机胶卷
- (id)saveVideoIntoSystemAlbumFromVideoUrl:(NSURL *)videoUrl completion:(void (^)(id assetResult, NSError *error, BOOL isExistedOrIsSuccess))completion
{
    NSError *error = nil;
    // 1,保存图片到相机胶卷
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (completion)
    {
        completion([PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil], error, YES);
    }
    if (error)
    {
        return nil;
    }
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
}
/// 批量删除指定的资源
- (void)deleteAssetArr:(NSArray *)assetArr completion:(completionHandler)completion
{
    for (int i = 0; i < assetArr.count; i++)
    {
        if (![assetArr[i] isKindOfClass:[PHAsset class]])
            return;
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:assetArr];
    } completionHandler:^(BOOL success, NSError *_Nullable error) {
        if (completion)
        {
            completion(nil, error, success);
        }
    }];
}
// 直接删除相册
- (void)deleteAlbum:(NSString *)albumName completion:(completionHandler)completion
{
}
//  收藏资源
- (void)collectedAsset:(PHAsset *)asset completion:(completionBlock)completion
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 改变
        PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:asset];
        request.favorite = !request.favorite;
    } completionHandler:^(BOOL success, NSError *error) {
        if (completion)
        {
            completion(error, error ? NO : YES);
        }
    }];
    
}

/*-----------------------------------设置-------------------------------------------------------*/
/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(id)asset
{
    CGSize photoSize = [self photoSizeWithAsset:asset];
    if (self.minPhotoWidthSelectable > photoSize.width || self.minPhotoHeightSelectable > photoSize.height)
    {
        return NO;
    }
    return YES;
}
//  获取图片的像素大小
- (CGSize)photoSizeWithAsset:(id)asset
{
    PHAsset *phAsset = (PHAsset *) asset;
    return CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
}
/*-------------------------------------------------------------------------缓存-------------------------------*/
#pragma mark 缓存
-(void)startCachingImagesFormAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSize
{
    [self.cachingImageManager startCachingImagesForAssets:assets
                                               targetSize:targetSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil];
}
-(void)stopCachingImagesFormAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSize
{
    [self.cachingImageManager stopCachingImagesForAssets:assets
                                              targetSize:targetSize
                                             contentMode:PHImageContentModeAspectFill
                                                 options:nil];
}
- (void)stopCachingImagesFormAllAssets
{
    [self.cachingImageManager stopCachingImagesForAllAssets];
}

/*-------------------------------------------------------------------------set-------------------------------*/
#pragma mark get  set 方法
// 设置资源的唯一标识
- (NSString *)getAssetIdentifier:(id)asset
{
    PHAsset *phAsset = (PHAsset *) asset;
    return phAsset.localIdentifier;
}

// 设置预览图的宽高
- (void)setColumnNumber:(NSInteger)columnNumber
{
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat itemWH = (JSScreenWidth - 2 * margin - 4) / columnNumber - margin;
    assetGridThumbnailSize = CGSizeMake(itemWH * JSScreenScale, itemWH * JSScreenScale);
}

#pragma mark 私有方法
//AuthorizationStatus == AuthorizationStatusNotDetermined 时询问授权弹出系统授权alertView

- (void)_requestAuthorizationWithCompletion:(void (^)(void))completion
{
    void (^callCompletionBlock)(void) = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion();
            }
        });
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (callCompletionBlock)
            {
                callCompletionBlock();
            }
        }];
    });
}

// 判断是否是相机胶卷
- (BOOL)isCameraRollAlbum:(NSString *)albumName
{
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1)
    {
        versionStr = [versionStr stringByAppendingString:@"00"];
    }
    else if (versionStr.length <= 2)
    {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802)
    {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    }
    else
    {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}
// 设置相册目录model参数
- (IJSAlbumModel *)modelWithResult:(id)result name:(NSString *)name
{
    IJSAlbumModel *model = [[IJSAlbumModel alloc] init];
    model.result = result; // 结果数据
    model.name = name;     // 名字
    if ([result isKindOfClass:[PHFetchResult class]])
    {
        PHFetchResult *fetchResult = (PHFetchResult *) result;
        model.count = fetchResult.count; //总数
    }
    return model;
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    if (image.size.width > size.width)
    {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    else
    {
        return image;
    }
}
/// 设置图片的model
- (IJSAssetModel *)_setModelWithAsset:(PHAsset *)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage
{
    IJSAssetModel *model;
    JSAssetModelSourceType type = JSAssetModelMediaTypePhoto;
    if ([asset isKindOfClass:[PHAsset class]]) // PHAsset类型
    {
        PHAsset *phAsset = (PHAsset *) asset;
        if (phAsset.mediaType == PHAssetMediaTypeVideo)
        {
            type = JSAssetModelMediaTypeVideo;
        }
        else if (phAsset.mediaType == PHAssetMediaTypeAudio)
        {
            type = JSAssetModelMediaTypeAudio;
        }
        else if (phAsset.mediaType == PHAssetMediaTypeImage)
        {
            if (iOS9_1Later) //PhotoLive
            {
                if (phAsset.mediaSubtypes == PHAssetMediaSubtypePhotoLive)
                {
                    type = JSAssetModelMediaTypeLivePhoto;
                }
            }
            // Gif
            if ([[phAsset valueForKey:@"filename"] hasSuffix:@"GIF"])
            {
                type = JSAssetModelMediaTypePhotoGif;
            }
        } // 判断资源类型结束
        if (!allowPickingVideo && type == JSAssetModelMediaTypeVideo)
        {
            return nil;
        }
        if (!allowPickingImage && type == JSAssetModelMediaTypePhoto)
        {
            return nil;
        }
        if (!allowPickingImage && type == JSAssetModelMediaTypePhotoGif)
        {
            return nil;
        }
        
        if (!allowPickingImage && type == JSAssetModelMediaTypeLivePhoto)
        {
            return nil; //LivePhoto
        }
        if (self.hideWhenCanNotSelect)
        {
            // 过滤掉尺寸不满足要求的图片
            if (![self isPhotoSelectableWithAsset:phAsset])
            {
                return nil;
            }
        }
        NSString *timeLength = type == JSAssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f", phAsset.duration] : @"";
        timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue]; //需要的格式显示
        model = [IJSAssetModel setAssetModelAsset:asset type:type timeLength:timeLength];
    }
    return model;
}
// 解析获取到的视频时间为需要的数据
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration
{
    NSString *newTime;
    if (duration < 10)
    {
        newTime = [NSString stringWithFormat:@"0:0%zd", duration];
    }
    else if (duration < 60)
    {
        newTime = [NSString stringWithFormat:@"0:%zd", duration];
    }
    else
    {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10)
        {
            newTime = [NSString stringWithFormat:@"%zd:0%zd", min, sec];
        }
        else
        {
            newTime = [NSString stringWithFormat:@"%zd:%zd", min, sec];
        }
    }
    return newTime;
}

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage
{
    if (!self.shouldFixOrientation)
    {
        return aImage;
    }
    if (aImage.imageOrientation == UIImageOrientationUp)
    {
        return aImage;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        }
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        }
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        }
        default:
            break;
    }
    
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        }
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        }
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.height, aImage.size.width), aImage.CGImage);
            break;
        }
        default:
        {
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.width, aImage.size.height), aImage.CGImage);
            break;
        }
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    if (ctx)
    {
        CGContextRelease(ctx);
    }
    if (cgimg)
    {
        CGImageRelease(cgimg);
    }
    return img;
}
/// 导出视频
- (void)_startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset completion:(void (^)(NSURL *outputPath, NSError *error, IJSImageState state))completion
{
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    if ([presets containsObject:AVAssetExportPresetHighestQuality])
    {
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetHighestQuality];
        
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *outputPath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/output-%@.mp4", [formater stringFromDate:[NSDate date]]];
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        // 是否允许网络
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4])
        {
            session.outputFileType = AVFileTypeMPEG4;
        }
        else if (supportedTypeArray.count == 0)
        {
            NSError *error = [NSError ijsPhotoSDKVideoActionDescription:@"视频类型暂不支持导出"];
            if (completion)
            {
                completion(nil, error, IJSImageExportSessionStatusFailed);
            }
            return;
        }
        else
        {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        AVMutableVideoComposition *videoComposition = [self _fixedCompositionWithAsset:videoAsset];
        if (videoComposition.renderSize.width)
        {
            session.videoComposition = videoComposition; // 修正视频转向
        }
        //导出
        __block NSError *error;
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            switch (session.status)
            {
                case AVAssetExportSessionStatusUnknown:
                {
                    error = [NSError ijsPhotoSDKVideoActionDescription:@"AVAssetExportSessionStatusUnknown"];
                    if (completion)
                    {
                        completion(nil, error, IJSImageExportSessionStatusUnknown);
                    }
                    break;
                }
                case AVAssetExportSessionStatusWaiting:
                {
                    error = [NSError ijsPhotoSDKVideoActionDescription:@"AVAssetExportSessionStatusWaiting"];
                    if (completion)
                    {
                        completion(nil, error, IJSImageExportSessionStatusWaiting);
                    }
                    break;
                }
                case AVAssetExportSessionStatusExporting:
                {
                    error = [NSError ijsPhotoSDKVideoActionDescription:@"AVAssetExportSessionStatusExporting"];
                    if (completion)
                    {
                        completion(nil, error, IJSImageExportSessionStatusExporting);
                    }
                    break;
                }
                case AVAssetExportSessionStatusCompleted:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion)
                        {
                            completion(session.outputURL, nil, IJSImageExportSessionStatusCompleted);
                        }
                    });
                    break;
                }
                case AVAssetExportSessionStatusFailed:
                {
                    error = [NSError ijsPhotoSDKVideoActionDescription:[NSString stringWithFormat:@"导出失败:%@", session.error]];
                    if (completion)
                    {
                        completion(nil, error, IJSImageExportSessionStatusFailed);
                    }
                    break;
                }
                default:
                    break;
            }
        }];
    }
}

/// 获取优化后的视频转向信息
- (AVMutableVideoComposition *)_fixedCompositionWithAsset:(AVAsset *)videoAsset
{
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    // 视频转向
    int degrees = [self _degressFromVideoFileWithAsset:videoAsset];
    if (degrees != 0)
    {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degrees == 90)
        {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        else if (degrees == 180)
        {
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        else if (degrees == 270)
        {
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2 * 3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}
/// 获取视频角度
- (int)_degressFromVideoFileWithAsset:(AVAsset *)asset
{
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0)
    {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            // Portrait
            degress = 90;
        }
        else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)
        {
            // PortraitUpsideDown
            degress = 270;
        }
        else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            // LandscapeRight
            degress = 0;
        }
        else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

@end
