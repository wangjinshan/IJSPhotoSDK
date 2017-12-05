//
//  IJSJson.h
//  IJSFramework
//
//  Created by shange on 2017/4/12.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  JSON工具类
 */
@interface IJSFJson : NSObject


/**
 *  对象序列化为Json字符串
 *
 *  @param object 任意对象
 *
 *  @return Json字符串
 */
- (NSString *)jsonStringFromObject:(id)object;

/**
 *  通过JSON字符串反序列化为对象
 *
 *  @param jsonString JSON字符串
 *
 *  @return OC对象
 */
- (id)objectFromJSONString:(NSString *)jsonString;




@end

