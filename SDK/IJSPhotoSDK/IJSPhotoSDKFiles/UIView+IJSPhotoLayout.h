//
//  UIView+IJSPhotoLayout.h
//  JSPhotoSDK
//
//  Created by shan on 2017/5/28.
//  Copyright © 2017年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 * view的延展
 */

@interface UIView (IJSPhotoLayout)

/*宽度*/
@property(nonatomic,assign) CGFloat  js_width;
/*高度*/
@property(nonatomic,assign) CGFloat  js_height;
/*x*/
@property(nonatomic,assign) CGFloat  js_x;
/*y*/
@property(nonatomic,assign) CGFloat   js_y;
/*中心点X*/
@property(nonatomic,assign) CGFloat  js_centerX;
/*中心点Y*/
@property(nonatomic,assign) CGFloat  js_centerY;






@end
