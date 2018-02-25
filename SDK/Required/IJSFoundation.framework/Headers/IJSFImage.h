//
//  IJSImage.h
//  IJSOCproject
//
//  Created by shange on 2017/4/19.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  图片处理类
 */
@interface IJSFImage : UIImage

/**
 *  图片不经过渲染
 *
 *  @param image 加载的图片
 *
 *  @return 原始图
 */
+ (UIImage *)imageOriginalWithImage:(UIImage *)image;





@end
