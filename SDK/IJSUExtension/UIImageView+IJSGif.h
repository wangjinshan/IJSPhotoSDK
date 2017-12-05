//
//  UIImageView+IJSGif.h
//  IJSPhotoSDKProject
//
//  Created by 山神 on 2017/12/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIImageView分类
 */
@interface UIImageView (IJSGif)


/**
 NSData 转成 Gif展示

 @param data 图片数据
 */
- (void)showGifImageWithData:(NSData *)data;


/**
 URL转成Git展示

 @param url 图片地址
 */
- (void)showGifImageWithURL:(NSURL *)url;











@end
