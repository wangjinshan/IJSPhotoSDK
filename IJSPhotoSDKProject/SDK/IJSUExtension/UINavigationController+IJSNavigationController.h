//
//  UINavigationController+IJSNavigationController.h
//  TZScrollViewPopGesture
//
//  Created by 山神 on 2018/2/2.
//  Copyright © 2018年 山神. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UINavigationController (IJSNavigationController) <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

/**
 识别的长度,默认是 100
 */
@property(nonatomic,assign) CGFloat recognizerLength;  // 识别的长度

/**
 自定义的返回手势
 */
@property(nonatomic,strong,readonly) UIPanGestureRecognizer *popPanGestureRecognizer;  // 自定义的返回手势


@end



@interface UIViewController (IJSNPopViewController)

/**
 不需要全屏手势,默认是NO, 也就是直接默认开启全屏手势, YES 就是当前界面放弃全屏
 */
@property(nonatomic,assign) BOOL noPopAction;  // 这个界面是否起作用

@end

