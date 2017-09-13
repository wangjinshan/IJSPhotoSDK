//
//  IJSDToolBarView.h
//  IJSUExtension
//
//  Created by shan on 2017/8/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IJSDToolBarView : UIView

@property (nonatomic, copy) void (^cancleCallBack)(void);    // 清楚所有
@property (nonatomic, copy) void (^cleanAllCallBack)(void);  // 清楚所有
@property (nonatomic, copy) void (^cleanLastCallBack)(void); // 清楚最后一条
@property (nonatomic, copy) void (^eraseCallBack)(void);     // 擦除
@property (nonatomic, copy) void (^addPhotoCallBack)(void);  // 添加照片
@property (nonatomic, copy) void (^savePhotoCallBack)(void); // 添加照片

@end
