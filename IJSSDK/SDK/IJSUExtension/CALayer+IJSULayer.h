//
//  CALayer+IJSULayer.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/19.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (IJSULayer)

@property (nonatomic) CGFloat js_transformScaleX;    ///< key path "tranform.scale.x"
@property (nonatomic) CGFloat js_transformScaleY;    ///< key path "tranform.scale.y"
@property (nonatomic) CGFloat js_transformRotationZ; ///< key path "tranform.rotation.z"

@end
