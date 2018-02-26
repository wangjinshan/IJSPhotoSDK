//
//  IJSImageManagerController.m
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/17.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSImageManagerController.h"

#import "IJSImageEditController.h"

@interface IJSImageManagerController ()

@end

@implementation IJSImageManagerController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (id)initWithEditImage:(UIImage *)image
{
    return [[IJSImageEditController alloc] initWithEditImage:image];
}

- (void)loadImageOnCompleteResult:(void(^)(UIImage *image,NSURL *outputPath, NSError *error))completeImage
{
    [[IJSImageEditController new] loadImageOnCompleteResult:completeImage];
}
- (void)addMapViewImageArr:(NSMutableArray *)mapImageArr
{
    [[IJSImageEditController new] addMapViewImageArr:mapImageArr];
}

-(void)cancelSelectedData:(void(^)(void))cancelHandler
{
     [[IJSImageEditController new] cancelSelectedData:cancelHandler];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
