//
//  IJSMapViewModel.h
//  IJSMapView
//
//  Created by shange on 2017/9/10.
//  Copyright © 2017年 shange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IJSMapViewModel : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *imageDataArr; // 模型数据

@property (nonatomic, assign) BOOL isDidClick; // 当前的cell

/**
 初始化

 @param imageArr 图片数组
 @return 自己
 */
- (instancetype)initWithImageDataModel:(NSMutableArray<NSString *> *)imageArr;

@end
