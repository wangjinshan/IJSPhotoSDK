//
//  IJSLodingView.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/25.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IJSLodingView : UIView
/**
 * 加载 ,最后 需要remove 这个view
 */
+ (instancetype)showLodingViewAddedTo:(UIView *)view title:(NSString *)title;

@end
