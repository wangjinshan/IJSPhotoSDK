//
//  IJSImageGet.h
//  IJSFramework
//
//  Created by shange on 2017/4/12.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 *  获取资源类
 */
@interface IJSFImageGet : NSObject

/**
 * 获取bundle中图片资源
 *
 *  @param bundleName bundle的名字
  *  @param subFile bundle下子文件的名字
  *  @param grandson subFile下子文件的名字
  *  @param imageName 资源的名字
  *  @param imageType 资源的类型
 *
 *  @return 获取到的资源
 */
+ (UIImage *)loadImageWithBundle:(NSString *)bundleName subFile:(NSString *)subFile grandson:(NSString *)grandson imageName:(NSString *)imageName imageType:(NSString *)imageType;

/**
 *  从bundle中加载图片资源
 *
 *  @param name         图片的名字
 *  @param bundle          bundle对象
 *
 *  @return 获取到的资源
 */
+ (UIImage *)loadImageName:(NSString *)name bundle:(NSBundle *)bundle;

/**
 *  spec.Resource
 *
 *  @param bundleName         bundle
 *  @param imageName          image前缀
 *  @param imageType     image类型
 *
 *  @return 图片对象
 */
+ (UIImage *)loadImageSpecResourceBundleName:(NSString *)bundleName imageName:(NSString *)imageName imageType:(NSString *)imageType;



@end
