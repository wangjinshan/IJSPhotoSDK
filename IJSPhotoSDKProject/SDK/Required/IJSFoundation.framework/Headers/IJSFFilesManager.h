//
//  IJSFilesManager.h
//  IJSOCproject
//
//  Created by shange on 2017/4/27.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  文件管理类
 */
typedef void (^completion) (NSInteger fileSize);
@interface IJSFFilesManager : NSObject

/**
 *  计算文件夹内容大小
 *
 *  @param directoryPath 文件的路径必须存在
  *  @param completeHandler      返回文件的大小
 */
+ (void) getFileSizeWithDirectoryPath:(NSString *)directoryPath completion:(completion)completeHandler;

/**
 *  删除沙盒缓存文件
 *
 */
+ (void) cleanAllCacheFile;

/**
 *  删除指定文件,返回剩余文件的路径
 *
 *  @param filePath 文件的路径
  *  @param fileSzieHandler 返回剩余文件的数据
 *
 */
+ (void) cleanFileWithFilePath:(NSString *)filePath surplusOfSize:(completion)fileSzieHandler;

/**
 获取某一个文件夹下的所有的资源

 @param folderPath 文件夹路径
 @param completeHandler fileCount文件个数    fileSzie整个文件夹大小      NSArray子文件的路径
 */
+(void)ergodicFilesFromFolderPath:(NSString *)folderPath completeHandler:(void(^)(NSInteger fileCount, NSInteger fileSzie,NSMutableArray<NSString *> *filePath))completeHandler;


@end
