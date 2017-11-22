//
//  IJSPhotos.h
//  IJSOCproject
//
//  Created by shange on 2017/5/23.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
/**
 *  相册的处理方法
 */

typedef NS_ENUM(NSUInteger, JSSavePhotoState) {
    // 授权
    JSAuthorizationStatusNotDetermined = 0, //提醒打开相册权限,未作出选择
    JSAuthorizationStatusRestricted =1,      //未授权无法访问
    JSAuthorizationStatusDenied =2,     //用户已明确拒绝此应用程序访问的照片数据。
    JSAuthorizationStatusAuthorized =3,  //已经授权
    
    // 创建
    JSCreatedAlbumSuccess = 11,  // 创建相册成功
    JSCreatedAlbumFail =12,        // 创建相册失败
    JSSaveImageSuccess = 13,       // 保存图片成功
    JSSaveImageFail = 14,              // 保存图片失败
    JSPhotosNoNeed = 1999,       // 回调不需要状态
};
/**
 *  存储的信息返回值
 *
  *  @param saveState 保存状态
 *  @param error 错误信息
 *
 */
typedef void (^JSPhotoChangeHandler)(JSSavePhotoState saveState,NSError *error);

@interface IJSFPhotos : NSObject
/**
 *  保存图片到自定义的相册
 *
 *  @param image 需要保存的单张图片
 *  @param albumName 自定义相册的名字
 *  @param saveStateBlock 保存的状态和错误信息
 */
+ (void) imageSaveIntoAlbumFromImage:(UIImage *)image albumName:(NSString *)albumName onSaveStateChanged:(JSPhotoChangeHandler)saveStateBlock;











@end
