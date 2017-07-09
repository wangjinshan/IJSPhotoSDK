//
//  IJSDevice.h
//  IJSFramework
//
//  Created by shange on 2017/4/16.
//  Copyright © 2017年 jinshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 *  网络类型
 */
typedef NS_ENUM(NSUInteger, IJSNetworkType)
{
    /**
     *  无网咯
     */
    IJSNetworkTypeNone         = 0,
    /**
     *  蜂窝网络
     */
    IJSNetworkTypeCellular     = 2,
    /**
     *  WIFI
     */
    IJSNetworkTypeWifi         = 1,
    /**
     *  2G网络
     */
    IJSNetworkTypeCellular2G   = 3,
    /**
     *  3G网络
     */
    IJSNetworkTypeCellular3G   = 4,
    /**
     *  4G网络
     */
    IJSNetworkTypeCellular4G   = 5,
};


/**
 IP版本
 
 - IJSIPVersion4: IPv4
 - IJSIPVersion6: IPv6
 */
typedef NS_ENUM(NSUInteger, IJSIPVersion)
{
    IJSIPVersion4 = 0,
    IJSIPVersion6 = 1,
};

/**
 *  设备类
 */
@interface IJSFDevice : NSObject
/**
 *  判断手机mac地址方法1
 *
 *  @return 手机mac地址
 */
- (NSString *) getMacAddressFuncOne;
/**
 *  判断手机mac地址方法2
 *
 *  @return 手机mac地址
 */
- (NSString *) getMacAddressFuncTwo;

/**
 *  判断设备型号
 *
 *  @return 设备型号
 */
+ (NSString *)getCurrentDeviceModel;

/**
 *  与当前系统版本比较
 *
 *  @param other 需要对比的版本
 *
 *  @return < 0 低于指定版本； = 0 跟指定版本相同；> 0 高于指定版本
 */
+ (NSInteger)versionCompare:(NSString *)other;





@end
