//
//  IJSQRCodeController.m
//  IJSPhotoSDKProject
//
//  Created by 山神 on 2017/12/18.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSQRCodeController.h"
#import "IJSCNavigationView.h"
#import "IJSExtension.h"

@interface IJSQRCodeController ()


@end

@implementation IJSQRCodeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    [self _setupUI];
}

#pragma mark 初始化UI
-(void)_setupUI
{
    self.title = @"文字测试";
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor redColor]}];
    
    // 导航条
//    IJSCNavigationView *navc =[[IJSCNavigationView alloc]initWithFrame:(CGRect)CGRectMake(0, IJSGStatusBarHeight, JSScreenWidth, IJSGNavigationBarHeight) title:@"扫一扫" backColor:[UIColor blackColor]];
//    [self.view addSubview:navc];
//
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 200, 100, 100)];
//    view.backgroundColor =[UIColor redColor];
//    [self.view addSubview:view];
    

}




















- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
}



@end
