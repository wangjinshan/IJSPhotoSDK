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

#ifdef DEBUG
#define JSLog(fmt, ...) NSLog((@"<%s : %d> %s  " fmt), [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__);

#else
#define JSLog(...)

#endif

/*-------------------------------------------------关于手机适配-------------------------------*/
#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
#define iOS9_3Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.3f)
#define iOS10Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
#define iOS10_3Later ([UIDevice currentDevice].systemVersion.floatValue >= 10.3f)
#define iOS11Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f)
#define iOS11_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 11.1f)

// 屏幕尺寸宏定义
#define IJS6SWidthRealValue(value) ((value) / 375.0f * [UIScreen mainScreen].bounds.size.width)
#define IJS6SHeightRealValue(value) ((value) / 667.0f * [UIScreen mainScreen].bounds.size.height)
#define IJS6SPWidthRealValue(value) ((value) / 414.0f * [UIScreen mainScreen].bounds.size.width)
#define IJS6SPHeightRealValue(value) ((value) / 736.0f * [UIScreen mainScreen].bounds.size.height)

// 其他手机屏幕
#define iPhone4 ([UIScreen mainScreen].bounds.size.height == 480) && ([UIScreen mainScreen].bounds.size.width == 320)
#define iPhone5 ([UIScreen mainScreen].bounds.size.height == 568) && ([UIScreen mainScreen].bounds.size.width == 320)
#define iPhone6 ([UIScreen mainScreen].bounds.size.height == 667) && ([UIScreen mainScreen].bounds.size.width == 375)
#define iPhone6s ([UIScreen mainScreen].bounds.size.height == 667) && ([UIScreen mainScreen].bounds.size.width == 375)
#define iPhone6p ([UIScreen mainScreen].bounds.size.height == 736) && ([UIScreen mainScreen].bounds.size.width == 414)

#define iPhone7 ([UIScreen mainScreen].bounds.size.height == 667) && ([UIScreen mainScreen].bounds.size.width == 375)
#define iPhone7p ([UIScreen mainScreen].bounds.size.height == 736) && ([UIScreen mainScreen].bounds.size.width == 414)

#define iPhone8 ([UIScreen mainScreen].bounds.size.height == 667) && ([UIScreen mainScreen].bounds.size.width == 375)
#define iPhone8p ([UIScreen mainScreen].bounds.size.height == 736) && ([UIScreen mainScreen].bounds.size.width == 414)

#define iPhoneX ([UIScreen mainScreen].bounds.size.height == 812) && ([UIScreen mainScreen].bounds.size.width == 375)

#define iPhoneSE ([UIScreen mainScreen].bounds.size.height == 569) && ([UIScreen mainScreen].bounds.size.width == 320)

#define iPad1And2Mini1 ([UIScreen mainScreen].bounds.size.height == 1024) && ([UIScreen mainScreen].bounds.size.width == 768)

#define iPad3And4Mini2 ([UIScreen mainScreen].bounds.size.height == 2048) && ([UIScreen mainScreen].bounds.size.width == 1536)

// 为了适配IPhone X
#define IJSGScreenWidth [UIScreen mainScreen].bounds.size.width
#define IJSGScreenHeight [UIScreen mainScreen].bounds.size.height
#define IJSGiPhoneX (IJSGScreenWidth == 375.f && IJSGScreenHeight == 812.f ? YES : NO)
#define IJSGStatusBarHeight (IJSGiPhoneX ? 44.f : 20.f)
#define IJSGNavigationBarHeight 44.f
#define IJSGTabbarHeight (IJSGiPhoneX ? (49.f + 34.f) : 49.f)
#define IJSGTabbarSafeBottomMargin (IJSGiPhoneX ? 34.f : 0.f)
#define IJSGStatusBarAndNavigationBarHeight (IJSGiPhoneX ? 88.f : 64.f)
#define IJSGViewSafeAreInsets(view) ({UIEdgeInsets insets; if(@available(iOS 11.0, *)) {insets = view.safeAreaInsets;} else {insets = UIEdgeInsetsZero;} insets; })

/*-------------------------------------------------------------------------宏代码-------------------------------*/
// 沙盒路径的定义
#define IJSUEMainDocumentDirectory NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject

//XIB
#define interfaceGetXIBClass(name) +(instancetype) loadXIB##name
#define implementationGetXIBClass(name)                                                                        \
+(instancetype) loadXIB##name                                                                              \
{                                                                                                          \
return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject; \
}

// 单例设置
#define interfaceSingleton(name) +(instancetype) share##name

#if __has_feature(objc_arc)
// ARC
#define implementationSingleton(name)                       \
+(instancetype) share##name                             \
{                                                       \
name *instance = [[self alloc] init];               \
return instance;                                    \
}                                                       \
static name *_instance = nil;                           \
+(instancetype) allocWithZone : (struct _NSZone *) zone \
{                                                       \
static dispatch_once_t onceToken;                   \
dispatch_once(&onceToken, ^{                        \
_instance = [[super allocWithZone:zone] init];  \
});                                                 \
return _instance;                                   \
}                                                       \
-(id) copyWithZone : (NSZone *) zone                    \
{                                                       \
return _instance;                                   \
}                                                       \
-(id) mutableCopyWithZone : (NSZone *) zone             \
{                                                       \
return _instance;                                   \
}
#else
// MRC

#define implementationSingleton(name)                       \
+(instancetype) share##name                             \
{                                                       \
name *instance = [[self alloc] init];               \
return instance;                                    \
}                                                       \
static name *_instance = nil;                           \
+(instancetype) allocWithZone : (struct _NSZone *) zone \
{                                                       \
static dispatch_once_t onceToken;                   \
dispatch_once(&onceToken, ^{                        \
_instance = [[super allocWithZone:zone] init];  \
});                                                 \
return _instance;                                   \
}                                                       \
-(id) copyWithZone : (NSZone *) zone                    \
{                                                       \
return _instance;                                   \
}                                                       \
-(id) mutableCopyWithZone : (NSZone *) zone             \
{                                                       \
return _instance;                                   \
}                                                       \
-(oneway void) release                                  \
{                                                       \
}                                                       \
-(instancetype) retain                                  \
{                                                       \
return _instance;                                   \
}                                                       \
-(NSUInteger) retainCount                               \
{                                                       \
return MAXFLOAT;                                    \
}
#endif

// NSUserDefault 
#define IJSNSUserDefaults  [NSUserDefaults standardUserDefaults]


























#endif /* IJSUConst_h */
