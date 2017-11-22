//
//  IJSImageManagerController.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/17.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *  图片裁剪外部开放类
 */
typedef void (^completeBlock)(UIImage *image);

@interface IJSImageManagerController : UIViewController

@property (nonatomic, strong) UIImage *editImage;                     // 传递的数据
@property (nonatomic, strong) NSMutableArray *mapImageArr; // 贴图数据

/**
 *  初始化方法
 */
- (id)initWithEditImage:(UIImage *)image;

/**
 *  回调
 */
- (void)loadImageOnCompleteResult:(completeBlock)completeImage;
/**
 *  设置贴图数据
 */
- (void)addMapViewImageArr:(NSMutableArray *)mapImageArr;

@end
