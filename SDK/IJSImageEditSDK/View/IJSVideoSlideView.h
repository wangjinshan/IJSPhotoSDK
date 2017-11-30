//
//  IJSVideoSlideView.h
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 左右滑块
 */
@interface IJSVideoSlideView : UIView

@property (nonatomic, assign) BOOL isLeft;      // yes为左半图
@property (nonatomic, weak) UIImage *backImage; // 替换为自己需要的图
/**
 * 初始化
 */
- (instancetype)initWithFrame:(CGRect)frame backImage:(UIImage *)backImage isLeft:(BOOL)isLeft;

@end
