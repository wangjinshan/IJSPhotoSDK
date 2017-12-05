//
//  IJSUConst.h
//  IJSExtensionProject
//
//  Created by shan on 2017/7/9.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#ifndef IJSUConst_h
#define IJSUConst_h

#define JSScreenWidth [[UIScreen mainScreen] bounds].size.width
#define JSScreenHeight [[UIScreen mainScreen] bounds].size.height

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
#define iOS9_3Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.3f)
#define iOS10Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
#define iOS10_3Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.3f)
#define iOS11Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)
#define iOS11_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.1f)

#ifdef DEBUG
#define JSLog(fmt, ...) NSLog((@"<%s : %d> %s  " fmt), [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#define JSLog(...)
#endif

// 为了适配IPhone X
#define  IJSGScreenWidth   [UIScreen mainScreen].bounds.size.width
#define  IJSGScreenHeight  [UIScreen mainScreen].bounds.size.height
#define  IJSGiPhoneX (IJSGScreenWidth == 375.f && IJSGScreenHeight == 812.f ? YES : NO)
#define  IJSGStatusBarHeight      (IJSGiPhoneX ? 44.f : 20.f)
#define  IJSGNavigationBarHeight  44.f
#define  IJSGTabbarHeight         (IJSGiPhoneX ? (49.f+34.f) : 49.f)
#define  IJSGTabbarSafeBottomMargin         (IJSGiPhoneX ? 34.f : 0.f)
#define  IJSGStatusBarAndNavigationBarHeight  (IJSGiPhoneX ? 88.f : 64.f)
#define IJSGViewSafeAreInsets(view) ({UIEdgeInsets insets; if(@available(iOS 11.0, *)) {insets = view.safeAreaInsets;} else {insets = UIEdgeInsetsZero;} insets;})





#endif /* IJSUConst_h */
