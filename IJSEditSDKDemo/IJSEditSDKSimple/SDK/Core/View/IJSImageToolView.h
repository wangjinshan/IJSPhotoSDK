//
//  IJSImageToolView.h
//  IJSPhotoSDKProject
//
//  Created by shan on 2017/7/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * 工具面板类
 */
@interface IJSImageToolView : UIView
/* 工具view */
@property (nonatomic, weak) UIView *toolBarView;

@property (nonatomic, copy) void (^panButtonBlock)(UIButton *button);    // 添加画笔面板
@property (nonatomic, copy) void (^smileButtonBlock)(UIButton *button);  // 添加图片
@property (nonatomic, copy) void (^textButtonBlock)(UIButton *button);   // 添加文字
@property (nonatomic, copy) void (^mosaicButtonBlock)(UIButton *button); // 马赛克
@property (nonatomic, copy) void (^clipButtonBlock)(UIButton *button);   // 裁剪

/**
 * 视频裁剪界面使用重新布局UI
 */
- (void)setupUIForVideoEditController;

/**
 复原所有button的初始未选中状态
 */
-(void)resetButtonState;

@end
