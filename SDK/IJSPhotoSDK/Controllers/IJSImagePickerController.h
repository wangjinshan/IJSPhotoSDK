//
//  IJSImagePickerController.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/28.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class IJSAssetModel;
@class IJSMapViewModel; //贴图数据模型
/*
 *  导航栏控制器，通过改变该控制器的一些属性来达到你想要的效果,开放的外部接口
 */
typedef NS_ENUM(NSUInteger, IJSPExportSourceType) {
    IJSPImageType,
    IJSPVideoType,
    IJSPVoiceType,
};

@interface IJSImagePickerController : UINavigationController

/**
 *  初始化方法
 *
 */
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount;
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber;
/**
 *  总接口初始化方法
 *
 *  @param maxImagesCount         最大选取的个数
 *  @param columnNumber          显示的列数需要固定 2--6
 *  @param pushPhotoPickerVc   是否直接跳转到照片列表界面
 *
 */
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber pushPhotoPickerVc:(BOOL)pushPhotoPickerVc;
/**
 *  警告
 */
- (void)showAlertWithTitle:(NSString *)title;

/**
 数据回调方法
 
 @param selectedHandler 回调数据 photos 选中的数据  avPlayers 音视频数据  infos 资源信息 isSelectOriginalPhoto 是否原图 sourceType 资源类型
 */
-(void)loadTheSelectedData:(void(^)(NSArray<UIImage *> *photos, NSArray<NSURL *> *avPlayers, NSArray<PHAsset *> *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType,NSError *error))selectedHandler;

/**
 取消选择
 
 @param cancelHandler 取消的回调
 */
-(void)cancelSelectedData:(void(^)(void))cancelHandler;

/*-----------------------------------属性-------------------------------------------------------*/

/* 默认最大可选9张图片 */
@property (nonatomic, assign) NSInteger maxImagesCount;

/* 最小照片必选张数,默认是0 */
@property (nonatomic, assign) NSInteger minImagesCount;

/* 是否允许网络获取,默认是NO */
@property (nonatomic, assign) BOOL networkAccessAllowed;

/* 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面 */
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

/* 默认828像素宽 */
@property (nonatomic, assign) CGFloat photoWidth;

/* 预览图默认750像素宽 */
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/* 是否选择原图 注意: 选中原图不宜大于 9张否则可能出现闪退*/
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;

/* 默认为YES，如果设置为NO,用户将不能选择发送图片 */
@property (nonatomic, assign) BOOL allowPickingImage;

/*默认为YES，如果设置为NO,用户将不能选择视频 */
@property (nonatomic, assign) BOOL allowPickingVideo;

/* 默认为NO，如果设置为YES,用户可以选择gif图片 */
@property (nonatomic, assign) BOOL allowPickingGif;

@property(nonatomic,assign) BOOL isHiddenEdit;  // 隐藏编辑按钮

/*  默认为YES，如果设置为NO,拍照按钮将隐藏,用户将不能选择照片 */
@property (nonatomic, assign) BOOL allowTakePicture;

/* 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中 */
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;

/* 是否要选择原图 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

/* 用户选取并且需要返回的数据 */
@property (nonatomic, strong) NSMutableArray<IJSAssetModel *> *selectedModels;
/**
 最小裁剪尺寸
 */
@property (nonatomic, assign) NSInteger minVideoCut;
/**
 最大裁剪尺寸
 */
@property (nonatomic, assign) NSInteger maxVideoCut; // 最大裁剪尺寸

/*-----------------------------------编辑使用的贴图数组-------------------------------------------------------*/
@property (nonatomic, strong) NSMutableArray<IJSMapViewModel *> *mapImageArr; // 贴图数据




@end

