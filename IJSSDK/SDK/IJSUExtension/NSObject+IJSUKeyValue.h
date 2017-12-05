//
//  NSObject+IJSUKeyValue.h
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  数据转换类
 */
@interface NSObject (IJSUKeyValue)

/**
 *  数据转模型
 *
 *  @param keyValues 数据
 *
 *  @return 模型类型
 */
+ (instancetype)objectWithKeyValues:(id)keyValues;

@end
