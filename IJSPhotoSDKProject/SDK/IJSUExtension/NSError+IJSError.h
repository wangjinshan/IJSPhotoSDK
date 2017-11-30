//
//  NSError+IJSError.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/16.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 错误码表
 */
@interface NSError (IJSError)

/**
 * video错误码
 */
+ (instancetype)ijsPhotoSDKVideoActionDescription:(NSString *)description;

/**
 * image错误码
 */
+ (instancetype)ijsPhotoSDKImageActionDescription:(NSString *)description;

@end
