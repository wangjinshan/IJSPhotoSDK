//
//  NSError+IJSError.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/16.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "NSError+IJSError.h"

@implementation NSError (IJSError)

+ (instancetype)ijsPhotoSDKVideoActionDescription:(NSString *)description
{
    NSDictionary *userinfo = @{ @"description": description };
    NSError *error = [[NSError alloc] initWithDomain:@"PhotoSDKVideoAction" code:100 userInfo:userinfo];
    return error;
}

+ (instancetype)ijsPhotoSDKImageActionDescription:(NSString *)description
{
    NSDictionary *userinfo = @{ @"description": description };
    NSError *error = [[NSError alloc] initWithDomain:@"PhotoSDKImageAction" code:200 userInfo:userinfo];
    return error;
}

@end
