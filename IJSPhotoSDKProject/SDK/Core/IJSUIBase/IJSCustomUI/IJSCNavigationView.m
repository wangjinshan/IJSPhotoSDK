//
//  IJSCNavigationView.m
//  IJSPhotoSDKProject
//
//  Created by 山神 on 2017/12/18.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSCNavigationView.h"
#import "IJSExtension.h"
#import <IJSFoundation/IJSFoundation.h>

@implementation IJSCNavigationView

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title backColor:(UIColor *)backColor
{
    self =[super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

-(void)_setupUI
{
    UIButton *leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setTitle:[NSBundle localizedStringForKey:@"Back"] forState:UIControlStateNormal];
    [leftButton setImage:[IJSFImageGet loadImageWithBundle:@"" subFile:@"" grandson:nil imageName:@"" imageType:@""] forState:UIControlStateNormal];
    [self addSubview:leftButton];
    self.leftButton = leftButton;
    
    
    
    
}

















@end
