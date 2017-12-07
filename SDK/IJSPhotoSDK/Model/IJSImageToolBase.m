//
//  IJSImageToolBase.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/14.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageToolBase.h"

@interface IJSImageToolBase ()
@end

@implementation IJSImageToolBase

- (instancetype)initToolWithViewController:(IJSImageEditController *)controller
{
    self = [super init];
    if (self)
    {
        self.editorController = controller;
    }
    return self;
}

- (void)setupTool {}
- (void)cleanupTool {}
// 撤销最后的绘制
- (void)cleanLastDrawPath {}
- (void)didFinishHandleWithCompletionBlock:(void (^)(UIImage *image, NSError *error, NSDictionary *userInfo))completionBlock
{
    if (completionBlock)
    {
        completionBlock(self.editorController.backImageView.image, nil, nil);
    }
}

@end
