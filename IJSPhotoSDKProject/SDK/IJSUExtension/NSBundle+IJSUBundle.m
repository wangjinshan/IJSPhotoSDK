//
//  NSBundle+IJSUBundle.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "NSBundle+IJSUBundle.h"

@implementation NSBundle (IJSUBundle)

+ (instancetype)_imagePickerBundle
{
    static NSBundle *jsBundle = nil;
    if (jsBundle == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
        if (!path)
        {
            path = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle" inDirectory:@"Frameworks/JSPhotoSDK.framework/"];
        }
        jsBundle = [NSBundle bundleWithPath:path];
    }
    return jsBundle;
}

+ (NSString *)localizedStringForKey:(NSString *)key
{
    return [self localizedStringForKey:key value:@""];
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language rangeOfString:@"zh-Hans"].location != NSNotFound)
        {
            language = @"zh-Hans";
        }
        else
        {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle _imagePickerBundle] pathForResource:language ofType:@"lproj"]];
    }
    NSString *needValue = [bundle localizedStringForKey:key value:value table:nil];
    return needValue;
}

// 动态BundleName
+ (instancetype)_imagePickerBundleName:(NSString *)name
{
    static NSBundle *jsBundle = nil;
    if (jsBundle == nil)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"bundle"];
        if (!path)
        {
            path = [[NSBundle mainBundle] pathForResource:name ofType:@"bundle" inDirectory:[NSString stringWithFormat:@"Frameworks/%@.framework/",name]];
        }
        jsBundle = [NSBundle bundleWithPath:path];
    }
    return jsBundle;
}
// 方法调用
+ (NSString *)localizedStringForKey:(NSString *)key bundleName:(NSString *)name
{
    return [self localizedStringForKey:key value:@"" bundleName:name];
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value bundleName:(NSString *)name
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language rangeOfString:@"zh-Hans"].location != NSNotFound)
        {
            language = @"zh-Hans";
        }
        else
        {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle _imagePickerBundleName:name] pathForResource:language ofType:@"lproj"]];
    }
    NSString *needValue = [bundle localizedStringForKey:key value:value table:nil];
    return needValue;
}



















@end
