//
//  IJSImageNavigationView.h
//  IJSPhotoSDKProject
//
//  Created by shan on 2017/7/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *   导航条的UI
 */
@interface IJSImageNavigationView : UIView

/* 取消事件 */
@property (nonatomic, copy) void (^cancleBlock)(void);
/* 完成涂鸦 */
@property (nonatomic, copy) void (^finishBlock)(void);

@property (nonatomic, weak) UIButton *cancleButton; // 取消
@property (nonatomic, weak) UIButton *finishButton; // 完成

@end
