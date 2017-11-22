//
//  IJSImagePickerController.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/28.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IJSAssetModel;
@class IJSMapViewModel;  //贴图数据模型
/*
 *  导航栏控制器，通过改变该控制器的一些属性来达到你想要的效果,开放的外部接口
 */
typedef NS_ENUM(NSUInteger, IJSPExportSourceType) {
    IJSPImageType,
    IJSPVideoType,
    IJSPVoiceType,
};
@protocol IJSImagePickerControllerDelegate;

@interface IJSImagePickerController : UINavigationController

/**
 *  初始化方法
 *
 */
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<IJSImagePickerControllerDelegate>)delegate;
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<IJSImagePickerControllerDelegate>)delegate;
/**
 *  总接口初始化方法
 *
 *  @param maxImagesCount         最大选取的个数
 *  @param columnNumber          显示的列数需要固定 2--6
 *  @param delegate     代理方法获取数据需要
 *  @param pushPhotoPickerVc   是否直接跳转到照片列表界面
 *
 */
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<IJSImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc;
/**
 *  警告
 */
- (void)showAlertWithTitle:(NSString *)title;

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

/* 预览图默认600像素宽 */
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/* 是否选择原图 */
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;

/* 默认为YES，如果设置为NO,用户将不能选择发送图片 */
@property (nonatomic, assign) BOOL allowPickingImage;

/*默认为YES，如果设置为NO,用户将不能选择视频 */
@property (nonatomic, assign) BOOL allowPickingVideo;

/* 默认为NO，如果设置为YES,用户可以选择gif图片 */
@property (nonatomic, assign) BOOL allowPickingGif;

/*  默认为YES，如果设置为NO,拍照按钮将隐藏,用户将不能选择照片 */
@property (nonatomic, assign) BOOL allowTakePicture;

/* 默认为YES，如果设置为NO,预览按钮将隐藏,用户将不能去预览照片 */
@property (nonatomic, assign) BOOL allowPreview;

/* 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中 */
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;

/* 是否要选择原图 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

/* 用户选中过的图片数组 */
@property (nonatomic, strong) NSMutableArray *selectedAssets;
/* 用户选取并且需要返回的数据 */
@property (nonatomic, strong) NSMutableArray<IJSAssetModel *> *selectedModels;
/**
 最小裁剪尺寸
 */
@property(nonatomic,assign) NSInteger minVideoCut;
/**
 最大裁剪尺寸
 */
@property(nonatomic,assign) NSInteger maxVideoCut;  // 最大裁剪尺寸

/*-----------------------------------返回用户选取的图片-------------------------------------------------------*/
/* block属性保存方式返回用户选取的图片 ,此处返回的是一个默认是828像素,经过缩放的图片,如果想获取原图,可以解析assets对象*/
@property (nonatomic, copy) void (^didFinishUserPickingImageHandle)(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, BOOL isSelectOriginalPhoto,IJSPExportSourceType sourceType);
/* 代理属性 */
@property(nonatomic,copy) void(^didCancelHandle)(void);  // 取消选择

@property (nonatomic, weak) id<IJSImagePickerControllerDelegate> imagePickerDelegate;

/*-----------------------------------编辑使用的贴图数组-------------------------------------------------------*/
@property (nonatomic, strong) NSMutableArray<IJSMapViewModel *> *mapImageArr; // 贴图数据

/*-----------------------------------UI-------------------------------------------------------*/
@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName;
@property (nonatomic, copy) NSString *photoNumberIconImageName;
// 外观颜色 + 按钮文字
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;

@property (nonatomic, strong) UIColor *naviBgColor;
@property (nonatomic, strong) UIColor *naviTitleColor;
@property (nonatomic, strong) UIFont *naviTitleFont;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *barItemTextFont;

@property (nonatomic, copy) NSString *doneBtnTitleStr;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;
@property (nonatomic, copy) NSString *previewBtnTitleStr;
@property (nonatomic, copy) NSString *fullImageBtnTitleStr;
@property (nonatomic, copy) NSString *settingBtnTitleStr;
@property (nonatomic, copy) NSString *processHintStr;

@end
/*-----------------------------------协议-------------------------------------------------------*/
/*
 * 协议
 */
@protocol IJSImagePickerControllerDelegate <NSObject>

@optional

/**
 选择图片

 @param picker 控制器
 @param isSelectOriginalPhoto 是否选择原图
 @param photos 选中的数据
 @param assets 原始数据
 @param infos 资源信息
 @param avPlayers 音视频数据
 @param sourceType 资源类型
 */
- (void)imagePickerController:(IJSImagePickerController *)picker isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto didFinishPickingPhotos:(NSArray<UIImage *> *)photos assets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos avPlayers:(NSArray *)avPlayers sourceType:(IJSPExportSourceType)sourceType;

/**
 取消选择图片
 */
-(void)imagePickerControllerWhenDidCancle;

@end
