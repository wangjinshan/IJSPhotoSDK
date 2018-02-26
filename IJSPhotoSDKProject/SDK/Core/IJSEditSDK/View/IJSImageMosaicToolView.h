//
//  IJSImageMosaicToolView.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/23.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 马赛克UI
 */
@interface IJSImageMosaicToolView : UIView

@property (nonatomic, copy) void (^typeOneCallBack)(UIButton *button);    // 方式1
@property (nonatomic, copy) void (^typeTwoCallBack)(UIButton *button);    // 方式2
@property (nonatomic, copy) void (^cancleLastCallBack)(UIButton *button); // 撤销

/**
 切换Button的状态

 @param button 需要切换的button
 */
- (void)resetButtonStatus:(UIButton *)button;


@end
