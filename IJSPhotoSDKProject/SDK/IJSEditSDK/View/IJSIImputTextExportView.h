//
//  IJSIImputTextExportView.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/22.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *   文本输出视图
 */
@interface IJSIImputTextExportView : UIView

@property (nonatomic, strong) NSString *labelText;                                     // 文字
@property (nonatomic, strong) UITextView *textView;                                    // 参数说明
@property (nonatomic, copy) void (^handleSingleTap)(UITextView *textView, BOOL isTap); // 参数说明
@property (nonatomic, copy) void (^textViewExpoetViewPanCallBack)(CGPoint viewPoint);  // 平移

@end
