//
//  IJSIImputTextView.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/22.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 文字输出UI
 */
#import "IJSImageEditController.h"

@interface IJSIImputTextView : UIView

@property (nonatomic, copy) void (^textCallBackBlock)(UITextView *textView); // 监听确定按钮
@property (nonatomic, copy) void (^textCancelCallBack)(void);                // 取消
@property (nonatomic, strong) UITextView *tapTextView;                       // 单击返回的view

@end
