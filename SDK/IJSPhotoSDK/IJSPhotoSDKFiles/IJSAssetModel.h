//
//  IJSAssetModel.h
//  JSPhotoSDK
//
//  Created by shan on 2017/6/2.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JSAssetModelSourceType) {
    JSAssetModelMediaTypePhoto = 0,
    JSAssetModelMediaTypeLivePhoto,
    JSAssetModelMediaTypePhotoGif,
    JSAssetModelMediaTypeVideo,
    JSAssetModelMediaTypeAudio
};


@interface IJSAssetModel : NSObject

@property (nonatomic, strong) id asset;                                        /*PHAsset or ALAsset*/
@property (nonatomic, assign) JSAssetModelSourceType type;   /*资源类型*/
@property (nonatomic, copy) NSString *timeLength;

/* 用户保存cell上的数据 */
 /* 用与保存button上的title */
@property(nonatomic,assign) NSInteger cellButtonNnumber;
 /*判断model 有没有被选中选择的状态,改变button的状态,默认是NO*/
@property (nonatomic, assign) BOOL isSelectedModel;

/* 所有照片展示也数据存储 */
/* 设置唯一标识,从前往后传递时候不允许更改 */
@property(nonatomic,assign) NSInteger onlyOneTag;
/* 大于某一个数则 配合隐藏 */
@property(nonatomic,assign) BOOL didMask;
/* 统计存储点击的model */
@property(nonatomic,strong) NSMutableArray *didClickModelArr;
/* 模型的宽高比 */

/*-----------------------------------照片详情页新增属性-------------------------------------------------------*/
// xiang
/* 首次出现 */
@property(nonatomic,assign) BOOL isFirstAppear;
/* 参数说明 */
@property(nonatomic,assign) CGFloat assetHeight;

/* 是否允许网络 */
@property(nonatomic,assign) BOOL networkAccessAllowed;

/**
 *  设置资源类型
 */
+(instancetype)setAssetModelAsset:(id)asset type:(JSAssetModelSourceType)type timeLength:(NSString *)timeLength;
+(instancetype)setAssetModelAsset:(id)asset type:(JSAssetModelSourceType)type;





@end
