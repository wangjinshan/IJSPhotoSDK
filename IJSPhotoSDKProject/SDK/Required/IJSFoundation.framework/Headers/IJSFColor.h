//
//  IJSColor.h
//  IJSFramework
//
//  Created by shange on 2017/4/18.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  颜色类
 */
@interface IJSFColor : NSObject

/**
 *  普通 RGB 颜色转换
 *
 *  @param R G B 颜色字符串
 *
 *  @return RGB转换的颜色
 */
+(UIColor *)colorWithR:(double)R G:(double)G B:(double)B alpha:(CGFloat)alpha;

/**
 *  16进制颜色转换,默认alpha是1
 *
 *  @param color 颜色字符串
 *
 *  @return 10进制颜色
 */

+ (UIColor *)colorWithHexString:(NSString *)color;

/**
 *  16进制颜色转换,传alpha
 *
 *  @param color 颜色字符串,支持@“#123456”、 @“0X123456”、 @“123456”三种格式
 *
 *  @return 10进制颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;





@end
