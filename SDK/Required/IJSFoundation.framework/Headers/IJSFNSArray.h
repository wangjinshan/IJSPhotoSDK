//
//  IJSFNSArray.h
//  IJSMapView
//
//  Created by shange on 2017/9/11.
//  Copyright © 2017年 shange. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 数组处理类
 */
@interface IJSFNSArray : NSObject


/**
 拆分数组

 @param array 原始数组
 @param subSize 拆分间距
 @return 拆分完成的数组
 */
+ (NSMutableArray *)splitArray: (NSMutableArray *)array withSubSize:(int)subSize;


@end
