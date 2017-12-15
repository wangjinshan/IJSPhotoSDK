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

@interface IJSImageManagerController : UIViewController

@property (nonatomic, strong) UIImage *editImage;          // 传递的数据
@property (nonatomic, strong) NSMutableArray *mapImageArr; // 贴图数据

/**
 *  初始化方法
 */
- (id)initWithEditImage:(UIImage *)image;

/**
 *  回调数据 outputPath 图片存储的路径 error错误信息
 */
- (void)loadImageOnCompleteResult:(void(^)(UIImage *image,NSURL *outputPath, NSError *error))completeImage;
/**
 取消选择
 
 @param cancelHandler 取消的回调
 */
-(void)cancelSelectedData:(void(^)(void))cancelHandler;
/**
 *  设置贴图数据
 */
- (void)addMapViewImageArr:(NSMutableArray *)mapImageArr;

@end
