//
//  IJSImageManager.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/28.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@class IJSAlbumModel;
@class IJSAssetModel;
/*
 *  照片管理类
 */
// 导出视频的几种状态
typedef NS_ENUM(NSUInteger, IJSImageState) {
    IJSImageExportSessionStatusUnknown,
    IJSImageExportSessionStatusWaiting,
    IJSImageExportSessionStatusExporting,
    IJSImageExportSessionStatusCompleted,
    IJSImageExportSessionStatusFailed,
};

typedef void (^completionBlock)(NSError *error, BOOL isExistedOrIsSuccess);
/**
 *  回调的参数
 *
 *  @param assetCollection         根据ios8前后返回不同的资源类型 ios8后PHFetchResult<PHAsset *>,前 NSURL照片的路径
 *  @param error          错误信息
 *  @param isExistedOrIsSuccess     资源是否已经存在 / 或者是否成功
 */
typedef void (^completionHandler)(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess);

@interface IJSImageManager : NSObject

/**
 *  单例
 */
+ (instancetype)shareManager;

/**
 *  处理特殊情况的无法授权窗口
 */
- (BOOL)authorizationStatusAuthorized;

/**
 *  授权
 */
+ (NSInteger)authorizationStatus;
/*-----------------------------------获取相册,将相册数据当做 model返回-------------------------------------------------------*/
/**
 *  获取相机胶卷的相册得到PHAsset对象放到IJSAlbumModel中
 */
- (void)getCameraRollAlbumContentImage:(BOOL)contentImage contentVideo:(BOOL)contentVideo completion:(void (^)(IJSAlbumModel *model))completion;
/**
 *  所有的相册,包括用户创建,系统创建等,得到PHAsset对象放到IJSAlbumModel中
 */
- (void)getAllAlbumsContentImage:(BOOL)contentImage contentVideo:(BOOL)contentVideo completion:(void (^)(NSArray<IJSAlbumModel *> *models))completion;

/*-----------------------------------通过 IJSAlbumModel 获取 PHAsset资源模型-------------------------------------------------------*/
/**
 *  将相册的数据解析成 PHAsset数组
 */
- (void)getAssetsFromFetchResult:(PHFetchResult *)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<IJSAssetModel *> *models))completion;
// 获得下标为index的单个照片 如果索引越界, 在回调中返回 nil
- (void)getAssetFromFetchResult:(PHFetchResult *)result atIndex:(NSInteger)index allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(IJSAssetModel *model))completion;

/*-----------------------------------解析PHAsset返回为具体的图片数据缩-- 略图-------------------------------------------------------*/
// 通过模型解析相册资源获取封面照片
- (PHImageRequestID)getPostImageWithAlbumModel:(IJSAlbumModel *)model completion:(void (^)(UIImage *postImage))completion;
/**
 *  将PHAsset数据解析成能够看见的参数
 */
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;
/**
 *  获取图片资源总接口
 *
 *  @param asset         单个资源对象
 *  @param photoWidth          单个照片的宽度
 *  @param completion     返回的照片信息
 *  @param progressHandler   进度条
 *  @return networkAccessAllowed 是否允许从网络下载图片,默认是no,通过progressHandler监听进度
 */
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

/**
 如果想缓存固定尺寸的可以通过下面的方式,图片预览界面固定死参数,处理内存控制内存问题
 */
- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

/*-----------------------------------获取原图-------------------------------------------------------*/
/**
 *  该方法会先返回缩略图，再返回原图，如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图
 */
- (PHImageRequestID)getOriginalPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo, NSDictionary *info))completion;
- (PHImageRequestID)getOriginalPhotoWithAsset:(PHAsset *)asset newCompletion:(void (^)(UIImage *photo, NSDictionary *info, BOOL isDegraded))completion;
- (PHImageRequestID)getOriginalPhotoDataWithAsset:(PHAsset *)asset completion:(void (^)(NSData *data, NSDictionary *info, BOOL isDegraded))completion;

/*-----------------------------------获取livephoto-------------------------------------------------------*/

- (PHImageRequestID)getLivePhotoWithAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)networkAccessAllowed completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion;
- (PHImageRequestID)getLivePhotoWithAsset:(PHAsset *)asset photoWidth:(CGFloat)photoWidth networkAccessAllowed:(BOOL)networkAccessAllowed completion:(void (^)(PHLivePhoto *livePhoto, NSDictionary *info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

/*-----------------------------------获取视频-------------------------------------------------------*/
- (PHImageRequestID)getVideoWithAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)networkAccessAllowed progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(AVPlayerItem *playerItem, NSDictionary *info))completion;
- (PHImageRequestID)getAVAssetWithPHAsset:(PHAsset *)asset completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))completion;
- (PHImageRequestID)getExportSessionWithPhAsset:(PHAsset *)asset completion:(void (^)(AVAssetExportSession *exportSession, NSDictionary *info))completion;
/*----------------------------------导出-----------------------------------------*/
/**
 导出视频

 @param asset PHasset 对象
 @param completion outputPath 视频路径 error具体错误 state 具体的错误值
 */
- (PHImageRequestID)getVideoOutputPathWithAsset:(PHAsset *)asset completion:(void (^)(NSURL *outputPath, NSError *error, IJSImageState state))completion;

/*-----------------------------------其他操作-------------------------------------------------------*/
/// 下面的方法中返回值仅实用ios8 之后
/**
 *  判断创建的相册是否存在,ios8之后使用返回值判断,之前用block中的bool值判断
 */
- (BOOL)isExistFolder:(NSString *)folderName completion:(completionHandler)completion;

/**
 *  创建相册
 */
- (void)createdAlbumName:(NSString *)albumName completion:(completionHandler)completion;
/**
 *  保存图片到相册自定义的相册
 * image 支持 UIImage NSURL的类型
 */
- (BOOL)saveImageIntoAlbumFromImage:(id)image albumName:(NSString *)albumName completion:(completionBlock)completion;
/**
 *  保存视频资源到指定的目录
 */
- (BOOL)saveVideoIntoAlbumFromVideo:(id)video albumName:(NSString *)albumName completion:(completionBlock)completion;

/**
 *  保存资源到相机胶卷,并返回资源的唯一标识,resources 支持 UIImage NSURL类型
 */
- (id)saveImageIntoSystemAlbumFromImage:(id)resources completion:(completionHandler)completion;
/**
 *  保存视频资源到相机胶卷
 */
- (id)saveVideoIntoSystemAlbumFromVideoUrl:(NSURL *)videoUrl completion:(completionHandler)completion;
/**
 *  删除指定文件下的资源
 *  asset 可以是 PHAsset资源的 ALAsset
 *
 */
- (void)deleteAssetArr:(NSArray *)assetArr completion:(completionHandler)completion;
/**
 *  删除相册包括相册中的所有的资源
 */
- (void)deleteAlbum:(NSString *)albumName completion:(completionHandler)completion;
/**
 *  收藏图片
 */
- (void)collectedAsset:(PHAsset *)asset completion:(completionBlock)completion;

/*-----------------------------------判断方法-------------------------------------------------------*/
/* 是否是相机胶卷 */
- (BOOL)isCameraRollAlbum:(NSString *)albumName;

/// 检查照片大小是否满足最小要求
- (BOOL)isPhotoSelectableWithAsset:(PHAsset *)asset;
/**
 *  获取图片的大小
 */
- (CGSize)photoSizeWithAsset:(PHAsset *)asset;

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage;
/* 设置资源的唯一标识 */
- (NSString *)getAssetIdentifier:(PHAsset *)asset;

/*-----------------------------------属性-------------------------------------------------------*/
/* 默认4列, TZPhotoPickerController中的照片collectionView */
@property (nonatomic, assign) NSInteger columnNumber;
/* 修正方向 */
@property (nonatomic, assign) BOOL shouldFixOrientation;
/* Default is 600px / 默认600像素宽 */
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;
/* 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个 */
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;
/// 隐藏不可以选中的图片，默认是NO，不推荐将其设置为YES
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;
/// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
/* 是否允许选择原图 */
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;
/* 是否允许网络获取,默认是NO */
@property (nonatomic, assign) BOOL networkAccessAllowed;

/**
 缓存属性
 */
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

/**
 开始缓存

 @param assets 需要缓存的数组
 @param targetSize 目标大小
 */
-(void)startCachingImagesFormAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSize;

/**
 结束缓存

 @param assets 需要缓存的数组
 @param targetSize 目标大小
 */
-(void)stopCachingImagesFormAssets:(NSArray<PHAsset *> *)assets targetSize:(CGSize)targetSize ;

/**
 取消所有的缓存
 */
- (void)stopCachingImagesFormAllAssets;

@end
