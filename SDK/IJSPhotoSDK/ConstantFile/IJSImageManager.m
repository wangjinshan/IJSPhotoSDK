//
//  IJSImageManager.m
//  JSPhotoSDK
//
//  Created by shan on 2017/5/28.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSImageManager.h"
#import "IJSImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IJSAlbumModel.h"
#import "IJSAlbumPickerCell.h"
#import "IJSAssetModel.h"
#import "IJSConst.h"
//#import "NSBundle+IJSPhotoBundle.h"
#import "IJSExtension.h"

static IJSImageManager *manager;
static CGFloat JSScreenScale;         //缩放比例
static CGSize assetGridThumbnailSize; //预览照片的大小

@interface IJSImageManager ()
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;

//@property(nonatomic,assign) CGFloat JSScreenScale;   //缩放比例
//@property(nonatomic,assign) CGSize assetGridThumbnailSize;  // 预览照片的大小

@end

@implementation IJSImageManager
// 单利
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        //        JSScreenWidth = [[UIScreen mainScreen]bounds].size.width;
        // 测试发现，如果scale在plus真机上取到3.0，内存会增大特别多。故这里写死成2.0
        JSScreenScale = 2.0;
        if (JSScreenWidth > 700)
        {
            JSScreenScale = 1.5;
        }
    });
    return manager;
}

/*-----------------------------------授权-------------------------------------------------------*/
#pragma mark 授权
// 授权状态
+ (NSInteger)authorizationStatus
{
    if (iOS8Later)
    {
        return [PHPhotoLibrary authorizationStatus];
    }
    else
    {
        return [ALAssetsLibrary authorizationStatus];
    }
    return NO;
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
    //    __block IJSAlbumModel *model;
    if (iOS8Later)
    {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!contentVideo)
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        if (!contentImage)
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                                PHAssetMediaTypeVideo];
        if (!self.sortAscendingByModificationDate)
        {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscendingByModificationDate]];
        }
        PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

        for (PHAssetCollection *collection in smartAlbums)
        {
            if (![collection isKindOfClass:[PHAssetCollection class]])
            {
                continue; // 有可能是PHCollectionList类的的对象，过滤掉
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
    else
    {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([group numberOfAssets] < 1)
                return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([self isCameraRollAlbum:name])
            {
                IJSAlbumModel *model = [self modelWithResult:group name:name];
                if (completion)
                {
                    completion(model);
                }
                *stop = YES;
            }
        } failureBlock:nil];
    }
}
// 获取所有的照片信息
- (void)getAllAlbumsContentImage:(BOOL)contentImage contentVideo:(BOOL)contentVideo completion:(void (^)(NSArray<IJSAlbumModel *> *models))completion
{
    NSMutableArray *albumArr = [NSMutableArray array];
    if (iOS8Later)
    {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!contentVideo)
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        if (!contentImage)
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                                PHAssetMediaTypeVideo];
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
                    continue;
                PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                if (fetchResult.count < 1)
                    continue; // 过滤无照片的相册
                if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"])
                    continue;
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

        if (completion && albumArr.count > 0)
            completion(albumArr);
    }
    else // 8之前的处理
    {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil)
            {
                if (completion && albumArr.count > 0)
                    completion(albumArr);
            }
            if ([group numberOfAssets] < 1)
                return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([self isCameraRollAlbum:name])
            {
                [albumArr insertObject:[self modelWithResult:group name:name] atIndex:0];
            }
            else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"])
            {
                if (albumArr.count)
                {
                    [albumArr insertObject:[self modelWithResult:group name:name] atIndex:1];
                }
                else
                {
                    [albumArr addObject:[self modelWithResult:group name:name]];
                }
            }
            else
            {
                [albumArr addObject:[self modelWithResult:group name:name]];
            }
        } failureBlock:nil];
    }
}
#pragma mark 解析相册资源为 PHAsset 对象
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<IJSAssetModel *> *models))completion
{
    NSMutableArray *photoArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) //  8之后
    {
        PHFetchResult *fetResult = (PHFetchResult *) result;
        [fetResult enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            IJSAssetModel *model = [self _setModelWithAsset:obj allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model)
            {
                [photoArr addObject:model];
            }
        }];
        if (completion)
        {
            completion(photoArr);
        }
    }
    else if ([result isKindOfClass:[ALAssetsGroup class]]) //8之前
    {
        ALAssetsGroup *group = (ALAssetsGroup *) result;
        if (allowPickingImage && allowPickingVideo)
        {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        }
        else if (allowPickingVideo)
        {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        }
        else if (allowPickingImage)
        {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil)
            {
                if (completion)
                    completion(photoArr);
            }
            IJSAssetModel *model = [self _setModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
            if (model)
            {
                [photoArr addObject:model];
            }
        };

        if (self.sortAscendingByModificationDate)
        {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock)
                {
                    resultBlock(result, index, stop);
                }
            }];
        }
        else
        {
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (resultBlock)
                {
                    resultBlock(result, index, stop);
                }
            }];
        }
    }
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
                completion(nil);
            return;
        }
        @finally
        {
            NSLog(@"获取的下标数组越界了");
        }
        IJSAssetModel *model = [self _setModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
        ;
        if (completion)
            completion(model);
    }
    else if ([result isKindOfClass:[ALAssetsGroup class]])
    {
        ALAssetsGroup *group = (ALAssetsGroup *) result;
        if (allowPickingImage && allowPickingVideo)
        {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        }
        else if (allowPickingVideo)
        {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        }
        else if (allowPickingImage)
        {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        @try
        {
            [group enumerateAssetsAtIndexes:indexSet options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (!result)
                    return;
                IJSAssetModel *model = [self _setModelWithAsset:result allowPickingVideo:allowPickingVideo allowPickingImage:allowPickingImage];
                ;
                if (completion)
                    completion(model);
            }];
        }
        @catch (NSException *e)
        {
            if (completion)
                completion(nil);
        }
        @finally
        {
            NSLog(@"获取的下标数组越界了");
        }
    }
}

/*-----------------------------------获取封面-------------------------------------------------------*/
#pragma mark 通过模型解析相册资源获取封面照片
- (void)getPostImageWithAlbumModel:(IJSAlbumModel *)model completion:(void (^)(UIImage *postImage))completion
{
    if (iOS8Later)
    {
        id asset = [model.result lastObject];
        if (!self.sortAscendingByModificationDate) //非时间排序
        {
            asset = [model.result firstObject];
        }
        [[IJSImageManager shareManager] getPhotoWithAsset:asset photoWidth:thumbImageViewWidth completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (completion)
                completion(photo);
        }];
    }
    else
    {
        ALAssetsGroup *group = model.result;
        UIImage *postImage = [UIImage imageWithCGImage:group.posterImage];
        if (completion)
            completion(postImage);
    }
}
/*-----------------------------------获取照片-------------------------------------------------------*/
#pragma mark 解析相册资源
/// 无进度条
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    return [[IJSImageManager shareManager] getPhotoWithAsset:asset photoWidth:photoWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}
///
- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    CGFloat fullScreenWidth = JSScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth)
    {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [[IJSImageManager shareManager] getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:nil networkAccessAllowed:YES];
}

- (PHImageRequestID)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed
{
    CGFloat fullScreenWidth = JSScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth)
    {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [[IJSImageManager shareManager] getPhotoWithAsset:asset photoWidth:fullScreenWidth completion:completion progressHandler:progressHandler networkAccessAllowed:networkAccessAllowed];
}
// 总接口
- (PHImageRequestID)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed
{
    if ([asset isKindOfClass:[PHAsset class]])
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

        __block UIImage *image;
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        int32_t imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result)
            {
                image = result;
            }
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
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
                    resultImage = [self scaleImage:resultImage toSize:imageSize];
                    if (!resultImage)
                    {
                        resultImage = image;
                    }
                    resultImage = [self fixOrientation:resultImage];
                    if (completion)
                        completion(resultImage, info, NO);
                }];
            }
        }];
        return imageRequestID;
    }
    else if ([asset isKindOfClass:[ALAsset class]])
    {
        ALAsset *alAsset = (ALAsset *) asset;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            CGImageRef thumbnailImageRef = alAsset.thumbnail;
            UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef scale:2.0 orientation:UIImageOrientationUp];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                    completion(thumbnailImage, nil, YES);

                if (photoWidth == JSScreenWidth || photoWidth == _photoPreviewMaxWidth)
                {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
                        CGImageRef fullScrennImageRef = [assetRep fullScreenImage];
                        UIImage *fullScrennImage = [UIImage imageWithCGImage:fullScrennImageRef scale:2.0 orientation:UIImageOrientationUp];

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion)
                                completion(fullScrennImage, nil, NO);
                        });
                    });
                }
            });
        });
    }
    return 0;
}
/*-----------------------------------获取原图-------------------------------------------------------*/
#pragma mark 获取原图
- (void)getOriginalPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion
{
    [self getOriginalPhotoWithAsset:asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (completion)
        {
            completion(photo, info);
        }
    }];
}

- (void)getOriginalPhotoWithAsset:(id)asset newCompletion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion
{
    if ([asset isKindOfClass:[PHAsset class]])
    {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
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
    }
    else if ([asset isKindOfClass:[ALAsset class]])
    {
        ALAsset *alAsset = (ALAsset *) asset;
        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            CGImageRef originalImageRef = [assetRep fullResolutionImage];
            UIImage *originalImage = [UIImage imageWithCGImage:originalImageRef scale:1.0 orientation:UIImageOrientationUp];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(originalImage, nil, NO);
                }
            });
        });
    }
}

- (void)getOriginalPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion
{
    if ([asset isKindOfClass:[PHAsset class]])
    {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData *_Nullable imageData, NSString *_Nullable dataUTI, UIImageOrientation orientation, NSDictionary *_Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && imageData)
            {
                BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (completion)
                    completion(imageData, info, isDegraded);
            }
        }];
    }
    else if ([asset isKindOfClass:[ALAsset class]])
    {
        // 不在支持 ios7ios7
        //        ALAsset *alAsset = (ALAsset *) asset;
        //        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
        //        Byte *imageBuffer = (Byte *) malloc(assetRep.size);
        //        NSUInteger bufferSize = [assetRep getBytes:imageBuffer fromOffset:0.0 length:assetRep.size error:nil];
        //        NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
        //        if (completion)
        //            completion(imageData, nil, NO);
    }
}
// livephoto
#pragma mark 获取LivePhoto
- (PHImageRequestID)getLivePhotoWithAsset:(id)asset networkAccessAllowed:(BOOL)networkAccessAllowed completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion
{
    CGFloat fullScreenWidth = JSScreenWidth;
    if (fullScreenWidth > _photoPreviewMaxWidth)
    {
        fullScreenWidth = _photoPreviewMaxWidth;
    }
    return [self getLivePhotoWithAsset:asset photoWidth:fullScreenWidth networkAccessAllowed:networkAccessAllowed completion:completion progressHandler:nil];
}
// 获取livephoto
- (PHImageRequestID)getLivePhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth networkAccessAllowed:(BOOL)networkAccessAllowed completion:(void (^)(PHLivePhoto *_Nullable livePhoto, NSDictionary *_Nullable info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
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
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && livePhoto)
                {
                    if (completion)
                        completion(livePhoto, info);
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
- (void)getVideoWithAsset:(id)asset networkAccessAllowed:(BOOL)networkAccessAllowed progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *playerItem, NSDictionary *info))completion
{
    if ([asset isKindOfClass:[PHAsset class]])
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
        [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
            if (completion)
                completion(playerItem, info);
        }];
    }
    else if ([asset isKindOfClass:[ALAsset class]])
    {
        ALAsset *alAsset = (ALAsset *) asset;
        ALAssetRepresentation *defaultRepresentation = [alAsset defaultRepresentation];
        NSString *uti = [defaultRepresentation UTI];
        NSURL *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
        if (completion && playerItem)
        {
            completion(playerItem, nil);
        }
    }
}
/// 获取视频-----没有进行视频方向的旋转
- (void)getAVAssetWithPHAsset:(PHAsset *)asset completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))completion
{
    if ([asset isKindOfClass:[PHAsset class]])
    {
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat; // 速度最快
        option.networkAccessAllowed = NO;                                  // 不加载网络请求
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset *_Nullable asset, AVAudioMix *_Nullable audioMix, NSDictionary *_Nullable info) {
            if (completion)
            {
                completion(asset, audioMix, info);
            }
        }];
    }
}
/// 获取导出的视频
- (void)getExportSessionWithPhAsset:(PHAsset *)asset completion:(void (^)(AVAssetExportSession *exportSession, NSDictionary *info))completion
{
    if ([asset isKindOfClass:[PHAsset class]])
    {
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat; // 速度最快
        option.networkAccessAllowed = NO;                                  // 不加载网络请求
        // exportPreset 控制导出的视频质量
        [[PHImageManager defaultManager] requestExportSessionForVideo:asset options:option exportPreset:AVAssetExportPresetMediumQuality resultHandler:^(AVAssetExportSession *_Nullable exportSession, NSDictionary *_Nullable info) {
            if (completion)
            {
                completion(exportSession, info);
            }
        }];
    }
}

/*-----------------------------------导出视频-------------------------------------------------------*/
#pragma mark 导出视频
- (void)getVideoOutputPathWithAsset:(id)asset completion:(void (^)(NSURL *outputPath, NSError *error, IJSImageState state))completion
{
    if ([asset isKindOfClass:[PHAsset class]])
    {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info) {
            AVURLAsset *videoAsset = (AVURLAsset *) avasset;
            [self _startExportVideoWithVideoAsset:videoAsset completion:completion];
        }];
    }
    else if ([asset isKindOfClass:[ALAsset class]])
    {
        NSURL *videoURL = [asset valueForProperty:ALAssetPropertyAssetURL]; // ALAssetPropertyURLs
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        [self _startExportVideoWithVideoAsset:videoAsset completion:completion];
    }
}
#pragma mark 判断相册是否存在
- (BOOL)isExistFolder:(NSString *)folderName completion:(void (^)(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess))completion
{
    __block BOOL isExisted = NO;
    if (iOS8Later)
    {
        //首先获取用户手动创建相册的集合
        PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        for (PHCollection *collection in collectonResuts)
        {
            if ([collection.localizedTitle isEqualToString:folderName]) // folderName是我们写入照片的相册
            {
                isExisted = YES; // PHAssetColllection
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
    else
    {
        // ios8 之前选择用 block中的数据
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        NSMutableArray *groupsArr = [[NSMutableArray alloc] init];
        //创建相簿
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group)
            {
                [groupsArr addObject:group];
            }
            else
            {
                for (ALAssetsGroup *gp in groupsArr)
                {
                    NSString *name = [gp valueForProperty:ALAssetsGroupPropertyName];
                    if ([name isEqualToString:folderName]) //存在
                    {
                        isExisted = YES;
                    }
                    else
                    { // 不存在
                        isExisted = NO;
                    }
                }
                // 系统允许存在同名的相册多个,回调以便利的最后一个作为返回值
                if (completion)
                {
                    completion(group, nil, isExisted);
                }
            }
        } failureBlock:^(NSError *error) {
            if (completion)
            {
                completion(nil, error, error ? NO : YES);
            }
        }];
    }
    return isExisted;
}
#pragma mark 创建相册
//  创建自定义相册
- (void)createdAlbumName:(NSString *)albumName completion:(void (^)(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess))completion
{
    if ([self authorizationStatusAuthorized])
    {
        if (iOS8Later)
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
        { // ios 8 之前
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            NSMutableArray *groups = [[NSMutableArray alloc] init];
            //创建相簿
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group)
                {
                    [groups addObject:group];
                }
                else
                {
                    BOOL haveHDRGroup = NO;
                    for (ALAssetsGroup *gp in groups)
                    {
                        NSString *name = [gp valueForProperty:ALAssetsGroupPropertyName];
                        if ([name isEqualToString:albumName])
                        {
                            haveHDRGroup = YES;
                            if (completion)
                            {
                                completion(group, nil, YES);
                            }
                            break;
                        }
                    }
                    if (!haveHDRGroup)
                    {
                        haveHDRGroup = YES;
                        [assetsLibrary addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                            // 此处有坑 ios8 之后创建过的相册删除再创建就会创建失败 group为空
                            if (group)
                            {
                                [groups addObject:group];
                            }
                            if (completion)
                            {
                                completion(group, nil, YES);
                            }
                        } failureBlock:nil];
                    }
                }
            } failureBlock:^(NSError *error) {
                if (completion)
                {
                    completion(nil, error, error ? NO : YES);
                }
            }];
        }
    }
    else
    { //没有授权
        if (iOS8Later)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        else
        {
            NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl])
            {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            }
            else
            {
                NSString *message = [NSBundle localizedStringForKey:@"Can not jump to the privacy settings page, please go to the settings page by self, thank you"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle localizedStringForKey:@"Sorry"] message:message delegate:nil cancelButtonTitle:[NSBundle localizedStringForKey:@"OK"] otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

#pragma mark 保存图片到自定义的相册
// 保存图片到自定义的相册
- (BOOL)saveImageIntoAlbumFromImage:(id)image albumName:(NSString *)albumName completion:(void (^)(NSError *error, BOOL isExistedOrIsSuccess))completion
{
    __block NSError *error = nil;
    if (iOS8Later)
    {
        id asset = [self saveImageIntoSystemAlbumFromImage:image completion:nil]; // 保存资源到相机胶卷
        if (asset == nil)
            return NO;
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
                completion(error, YES);
            if (!error)
                return YES;
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
    }
    else
    {
        __weak ALAssetsLibrary *weakLibrary = self.assetLibrary;
        [self saveImageIntoSystemAlbumFromImage:image completion:^(id assetResult, NSError *error, BOOL isExisted) {
            [weakLibrary assetForURL:assetResult resultBlock:^(ALAsset *asset) { // 再把图片保存到对于的文件中
                [weakLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName])
                    {
                        [group addAsset:asset];
                    }
                    if (completion)
                        completion(error, error ? NO : YES);
                } failureBlock:^(NSError *error) {
                    if (completion)
                        completion(error, error ? NO : YES);
                    error = error;
                }];
            } failureBlock:^(NSError *error) {
                if (completion)
                    completion(error, error ? NO : YES);
                error = error;
            }];
        }];
    }
    if (error)
        return NO;
    return YES;
}
#pragma mark 保存视频到指定的目录
- (BOOL)saveVideoIntoAlbumFromVideo:(id)video albumName:(NSString *)albumName completion:(void (^)(NSError *error, BOOL isExistedOrIsSuccess))completion
{
    if (iOS8Later)
    {
        if (![video isKindOfClass:[NSURL class]])
            return NO;
        id asset = [self saveVideoIntoSystemAlbumFromVideoUrl:video completion:nil];
        if (asset == nil)
            return NO;
        __block NSError *error = nil;
        if ([self isExistFolder:albumName completion:nil])
        {
            [self isExistFolder:albumName completion:^(id assetCollection, NSError *error, BOOL isExisted) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                    [request insertAssets:asset atIndexes:[NSIndexSet indexSetWithIndex:0]];
                    if (completion)
                        completion(error, error ? NO : YES);
                } error:&error];

            }];
            if (!error)
                return YES;
        }
        else
        {
            [self createdAlbumName:albumName completion:^(id assetCollection, NSError *error, BOOL isExisted) {
                PHAssetCollection *collection = assetCollection;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                    [request insertAssets:asset atIndexes:[NSIndexSet indexSetWithIndex:0]];
                    if (completion)
                        completion(error, error ? NO : YES);
                } error:&error];

            }];
            if (!error)
                return YES;
        }
    }
    else
    { // ios 8
        __weak ALAssetsLibrary *weakLibrary = self.assetLibrary;
        [self saveVideoIntoSystemAlbumFromVideoUrl:video completion:^(id assetResult, NSError *error, BOOL isExisted) {
            [weakLibrary assetForURL:assetResult resultBlock:^(ALAsset *asset) { // 再把图片保存到对于的文件中
                [weakLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName])
                    {
                        [group addAsset:asset];
                    }
                    if (completion)
                        completion(error, error ? NO : YES);
                } failureBlock:^(NSError *error) {
                    if (completion)
                        completion(error, error ? NO : YES);
                    error = error;
                }];
            } failureBlock:^(NSError *error) {
                if (completion)
                    completion(error, error ? NO : YES);
                error = error;
            }];
        }];
    }
    return YES;
}

// 获取保存到相册中图片
#pragma mark 保存图片到相机胶卷,并返回对象
- (id)saveImageIntoSystemAlbumFromImage:(id)resources completion:(void (^)(id assetResult, NSError *error, BOOL isExistedOrIsSuccess))completion
{
    NSError *error = nil;
    if (iOS8Later)
    {
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
            completion([PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil], error, error ? NO : YES);
        if (error)
            return nil;
        return [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
    }
    else
    { //ios 8 之前
        __weak ALAssetsLibrary *weakLibrary = self.assetLibrary;
        UIImage *resourceImage; // ios 8 之前只支持 UIImage
        if ([resources isKindOfClass:[NSURL class]])
        {
            NSData *imageData = [NSData dataWithContentsOfURL:resources];
            resourceImage = [UIImage imageWithData:imageData];
        }
        // 把图片保存到相机胶卷
        [weakLibrary writeImageToSavedPhotosAlbum:resourceImage.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (completion)
                completion(assetURL, error, error ? NO : YES);
        }];
    }
    return nil;
}
// 保存视频资源到相机胶卷
- (id)saveVideoIntoSystemAlbumFromVideoUrl:(NSURL *)videoUrl completion:(void (^)(id assetResult, NSError *error, BOOL isExistedOrIsSuccess))completion
{
    NSError *error = nil;
    if (iOS8Later)
    {
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
    else
    {
        // ios 8 之前
        __weak ALAssetsLibrary *weakLibrary = self.assetLibrary;
        // 把图片保存到相机胶卷
        [weakLibrary writeVideoAtPathToSavedPhotosAlbum:videoUrl completionBlock:^(NSURL *assetURL, NSError *error) {
            if (completion)
            {
                completion(assetURL, error, error ? NO : YES);
            }
        }];
    }
    return nil;
}
/// 批量删除指定的资源
- (void)deleteAssetArr:(NSArray *)assetArr completion:(completionHandler)completion
{
    if (iOS8Later)
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
                completion(nil, error, success);
        }];
    }
    else
    {
        for (int i = 0; i < assetArr.count; i++)
        {
            if (![assetArr[i] isKindOfClass:[ALAsset class]])
                return;
        }
        for (ALAsset *tempAsset in assetArr)
        {
            if (tempAsset.isEditable)
            {
                [tempAsset setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (completion)
                        completion(assetURL, error, error ? NO : YES);
                }];
            }
        }
    }
}
// 直接删除相册
- (void)deleteAlbum:(NSString *)albumName completion:(completionHandler)completion
{
    //    if (iOS8Later)
    //    {
    //        return;
    //        [self isExistFolder:albumName completion:^(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess) {
    //            if (isExistedOrIsSuccess)
    //            {
    //                PHFetchResult<PHCollectionList *> *list = [PHCollectionList fetchCollectionListsWithType:PHCollectionListTypeFolder subtype:PHCollectionListSubtypeAny options:nil];
    //                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    //
    //                    for (PHCollectionList *listt in list)
    //                    {
    //                        PHCollectionListChangeRequest *request = [PHCollectionListChangeRequest
    //                                                                  changeRequestForCollectionList:listt
    //                                                                  ];
    //                    [request removeChildCollections:@[ listt ]];
    //                    }
    //
    //                } completionHandler:^(BOOL success, NSError *error) {
    //                    NSLog(@"Finished removing album from the folder. %@", (success ? @"Success" : error));
    //                }];
    //
    //
    //
    //
    //                PHFetchResult<PHCollection *>  *coll =[PHCollection fetchTopLevelUserCollectionsWithOptions:nil];
    //
    //                for (PHAssetCollection *collass in coll)
    //                {
    //                     PHFetchResult<PHCollectionList *> *list = [PHCollectionList fetchCollectionListsWithLocalIdentifiers:collass.localizedLocationNames options:nil];
    //                    for (PHCollectionList *temp in list)
    //                    {
    //                        NSLog(@"----------------%@",temp);
    //                    }
    //                }
    //
    //
    ////            PHFetchResult<PHCollectionList *> *list = [PHCollectionList fetchCollectionListsWithType:PHCollectionListTypeFolder subtype:PHCollectionListSubtypeAny options:nil];
    ////                PHFetchResult<PHCollectionList *> *list = [PHCollectionList fetchCollectionListsWithLocalIdentifiers:@[@"ceshi",@"Causal"] options:nil];
    //                for (PHCollectionList *temp in list)
    //                {
    //                    NSLog(@"------%@",temp);
    //                    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
    ////                      PHCollectionList
    //                        if ([temp isKindOfClass:[PHCollectionList class]])
    //                        {
    ////                            NSLog(@"----%@",[PHCollectionList class]);
    ////                             [PHCollectionListChangeRequest deleteCollectionLists:@[temp]];
    //                        }
    //
    //
    //                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
    ////                        if (completion) completion(nil,error,success);
    //                    }];
    //
    //                }
    //
    //////
    ////                                    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
    ////                                        if ([assetCollection isKindOfClass:[PHAssetCollection class]])
    ////                                        {  // PHcollectionlist
    ////                                            [PHCollectionListChangeRequest deleteCollectionLists:@[list]];
    ////                                        }
    ////                                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
    ////                                          if (completion) completion(nil,error,success);
    ////                                    }];
    //////
    //////
    ////                   temp =  [PHCollectionList fetchCollectionListsContainingCollection:assetCol options:nil];
    ////                    NSLog(@"--p--------%@",temp);
    ////
    ////                    [temp enumerateObjectsUsingBlock:^(PHCollectionList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    ////
    ////                        NSLog(@"----;-----%@",obj);
    ////
    ////                    }];
    ////                }
    //
    ////                NSLog(@"---q------%@",list);
    //
    ////                [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
    ////                    if ([assetCollection isKindOfClass:[PHAssetCollection class]])
    ////                    {
    ////                        [PHCollectionListChangeRequest deleteCollectionLists:@[list]];
    ////                    }
    ////                } completionHandler:^(BOOL success, NSError * _Nullable error) {
    ////                      if (completion) completion(nil,error,success);
    ////                }];
    //                 if (completion) completion(nil,error,error? NO : YES);
    //            }else{
    //              if (completion) completion(nil,error,error? NO : YES);
    //            }
    //        }];
    //    }else{
    //        // ios 7 不支持删除相册,或者后面再补充
    //        NSError *error;
    //        if (completion) completion(nil,error,NO);
    //    }
}
//  收藏资源
- (void)collectedAsset:(id)asset completion:(completionBlock)completion
{
    if (iOS8Later)
    {
        if ([asset isKindOfClass:[PHAsset class]])
        {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                // 改变
                PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:asset];
                request.favorite = !request.favorite;
            } completionHandler:^(BOOL success, NSError *error) {
                if (completion)
                    completion(error, error ? NO : YES);
            }];
        }
        else
        {
            return;
        }
    }
    else
    {
        return;
    }
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
    if (iOS8Later)
    {
        PHAsset *phAsset = (PHAsset *) asset;
        return CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight);
    }
    else
    {
        ALAsset *alAsset = (ALAsset *) asset;
        return alAsset.defaultRepresentation.dimensions;
    }
}
// 设置资源的唯一标识
- (NSString *)getAssetIdentifier:(id)asset
{
    if (iOS8Later)
    {
        PHAsset *phAsset = (PHAsset *) asset;
        return phAsset.localIdentifier;
    }
    else
    {
        ALAsset *alAsset = (ALAsset *) asset;
        NSURL *assetUrl = [alAsset valueForProperty:ALAssetPropertyAssetURL];
        return assetUrl.absoluteString;
    }
}
/*-----------------------------------set get方法-------------------------------------------------------*/
#pragma mark get set方法
- (ALAssetsLibrary *)assetLibrary
{
    if (_assetLibrary == nil)
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}
// 设置预览图的宽高
- (void)setColumnNumber:(NSInteger)columnNumber
{
    _columnNumber = columnNumber;
    CGFloat margin = 4;
    CGFloat itemWH = (JSScreenWidth - 2 * margin - 4) / columnNumber - margin;
    assetGridThumbnailSize = CGSizeMake(itemWH * JSScreenScale, itemWH * JSScreenScale);
}
/*-----------------------------------私有方法-------------------------------------------------------*/
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

    if (iOS8Later)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                callCompletionBlock();
            }];
        });
    }
    else
    {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            callCompletionBlock();
        } failureBlock:^(NSError *error) {
            callCompletionBlock();
        }];
    }
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
    else if ([result isKindOfClass:[ALAssetsGroup class]])
    {
        ALAssetsGroup *group = (ALAssetsGroup *) result;
        model.count = [group numberOfAssets];
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
- (IJSAssetModel *)_setModelWithAsset:(id)asset allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage
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
    else
    {
        if (!allowPickingVideo)
        {
            model = [IJSAssetModel setAssetModelAsset:asset type:type];
            return model;
        }
        /// 允许选择视频
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) //是视频
        {
            type = JSAssetModelMediaTypeVideo;
            NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] integerValue];
            NSString *timeLength = [NSString stringWithFormat:@"%0.0f", duration];
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            model = [IJSAssetModel setAssetModelAsset:asset type:type timeLength:timeLength];
        }
        else // 图片
        {
            if (self.hideWhenCanNotSelect)
            {
                // 过滤掉尺寸不满足要求的图片
                if (![self isPhotoSelectableWithAsset:asset])
                {
                    return nil;
                }
            }
            model = [IJSAssetModel setAssetModelAsset:asset type:type];
        }
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
