//
//  IJSURL.h
//  IJSFramework
//
//  Created by shange on 2017/4/12.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  URL的编码和解密
 */
@interface IJSFURL : NSObject

/**
 *  utl中含有中文数字的转换
 *
 *  @param urlString 含有中文的网址
 *
 *  @return 中文转义过的url
 */
+(NSString *)stringByAddingPercentEncodingWithAllowedCharactersWithChinese:(NSString *)urlString;

/**
 *  对url中含有%3A%2F%2F的url转码
 *
 *  @param urlString 含有%3A%2F%2F的网址
 *
 *  @return 转义过的url
 */
+(NSString *)stringByRemovingPercentEncodingWithMessyCode:(NSString *)urlString;





@end
