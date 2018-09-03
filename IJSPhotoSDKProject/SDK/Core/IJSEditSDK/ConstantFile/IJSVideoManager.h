//
//  IJSVideoManager.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/15.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, IJSVideoState) {
    IJSExportSessionStatusUnknown,
    IJSExportSessionStatusWaiting,
    IJSExportSessionStatusExporting,
    IJSExportSessionStatusCompleted,
    IJSExportSessionStatusFailed,
};


/**
 *   outputPath     保存到tem的路径,命名规则是根据时间生成
 *   error  错误信息
 *    state  导出状态值
 */
typedef void (^cutVideoCompletionBlock)(NSURL *outputPath, NSError *error, IJSVideoState state);

@interface IJSVideoManager : NSObject

/**
 * 单利
 */
+ (instancetype)shareManager;

/**
 *  裁剪视频,并导出视频
 *
 *  @param videoAsset       视频资源
 *  @param startTime    开始时间
 *  @param endTime  结束时间
 *  @param completion     回调信息
 *
 */
+ (void)cutVideoAndExportVideoWithVideoAsset:(AVAsset *)videoAsset startTime:(CGFloat)startTime endTime:(CGFloat)endTime completion:(cutVideoCompletionBlock)completion;

/**
 *  裁剪视频,并导出视频
 *
 *  @param videoAsset       导入的资源 AVURLAsset类型
 *  @param startTime   开始时间
 *  @param endTime   结束时间
 *  @param completion     回调信息
 */
+ (void)exportVideoWithVideoAsset:(AVAsset *)videoAsset startTime:(CGFloat)startTime endTime:(CGFloat)endTime completion:(cutVideoCompletionBlock)completion;
/**
 *  获取视频截图
 *
 *  @param avasset       视频资源
 *  @param time    截取时间
 *
 *  @return 视频截图
 */
+ (UIImage *)getScreenShotImageFromAvasset:(AVAsset *)avasset time:(CGFloat)time;

/**
 *  根据角度旋转视频
 *
 *  @param videoAsset       视频资源
 *
 *  @return 内体组件
 */
+ (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset;

/**
 *  获取视频的方向
 *
 *  @param asset       资源
 *
 *  @return 视频的角度 分别是 0 90 180  270
 */
+ (int)degressFromVideoFileWithAsset:(AVAsset *)asset;

/**
 *  添加水印-----传入一张和视频等比例的图片,图片铺满视频层
 *
 *  @param videoAsset       资源
 *  @param waterImage    水印
 *  @param describe     描述
 *  @param completion     回调信息
 */

+ (void)addWatermarkForVideoAsset:(AVAsset *)videoAsset waterImage:(UIImage *)waterImage describe:(NSString *)describe completion:(void (^)(NSURL *outputPath, NSError *error, IJSVideoState state))completion;

/**
 * 获取视频的尺寸,返回视频的大小
 */
+ (CGSize)getVideSizeFromAvasset:(AVAsset *)videoAsset;

/**
 清楚所有视频/图片路径,
 */
+(void)cleanAllVideoAndImage;

/**
 获取视频/图片文件等等保存路径

 @return 视频/图片保存文件夹
 */
+(NSString *)getAllVideoPathAndImagePath;

/**
 将图片数据写入到沙盒

 @param image 原始图片
 @param completion 返回的数据 outputPath:图片存储的路径, error具体错误信息
 */
+(void)saveImageToSandBoxImage:(UIImage *)image completion:(void (^)(NSURL *outputPath, NSError *error))completion;

@end
