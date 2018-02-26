//
//  IJSNotificationCenterString.h
//  yidaojia
//
//  Created by 山神 on 2018/1/4.
//  Copyright © 2018年 山神. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *  通知
 */
/** TabBarButton被重复点击的通知 */
UIKIT_EXTERN NSString *const JSTabBarButtonDidRepeatClickNotification;

/** titleButton被重复点击的通知 */
UIKIT_EXTERN NSString *const JStitleButtonDidRepeatClickNotification;

//APP的token 有效
UIKIT_EXTERN NSString *const IJSAppLoginTokenIsOKNotification;

// 没有网络
UIKIT_EXTERN NSString *const IJSNoNetwokNotification;
// wifi
UIKIT_EXTERN NSString *const IJSWifiNetwokNotification;
// wan
UIKIT_EXTERN NSString *const IJSWanNetwokNotification;
