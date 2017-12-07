//
//  IJSIMapViewExportView.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/18.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 导出的贴图UI
 */
@interface IJSIMapViewExportView : UIView

@property (nonatomic, copy) void (^mapViewExpoetViewTapCallBack)(void);              // 单击回调
@property (nonatomic, copy) void (^mapViewExpoetViewPanCallBack)(CGPoint viewPoint); // 平移返回父类的相对位置
@property (nonatomic, weak) UIImage *backImage;                                      // 背景图对象的方法

// 创建
+ (instancetype)initExportViewWithFrame:(CGRect)frame backImage:(UIImage *)image;
// 单击是否隐藏
- (void)hiddenSquareViewState:(BOOL)state;

@end

// 绘制边缘正方形view
@interface IJSIMapViewExportViewSquareView : UIView
@property (nonatomic, strong) UIColor *squareColor; // 正方形的背景颜色
@end
