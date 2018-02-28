//
//  ViewController.m
//  IJSEditSDKSimple
//
//  Created by 山神 on 2017/12/10.
//  Copyright © 2017年 山神. All rights reserved.
//

#import "ViewController.h"

#import "IJSVideoTestController.h"


#import <IJSFoundation/IJSFoundation.h>


#import "IJSEditSDK.h"



@interface ViewController ()<IJSVideoManagerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property(nonatomic,strong) NSMutableArray *mapDataArr;  // 贴图
@end

@implementation ViewController
#pragma mark 懒加载区域
-(NSMutableArray *)mapDataArr
{
    if (_mapDataArr == nil)
    {
        _mapDataArr =[NSMutableArray array];
    }
    return _mapDataArr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // 设置贴图数据
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
    NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
    [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
        IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
        [self.mapDataArr addObject:model];
    }];
    
}


- (IBAction)_imageEdit:(UIButton *)sender
{
    __weak typeof (self) weakSelf = self;
    UIImage *image =[UIImage imageNamed:@"8"];
    IJSImageManagerController *vc =[[IJSImageManagerController alloc]initWithEditImage:image];
    [vc loadImageOnCompleteResult:^(UIImage *image, NSURL *outputPath, NSError *error) {
        weakSelf.backImageView.image = image;
    }];
    vc.mapImageArr = self.mapDataArr;
    [self presentViewController:vc animated:YES completion:nil];
}


- (IBAction)_cutVideo:(UIButton *)sender
{
    IJSVideoCutController *vc =[[IJSVideoCutController alloc] init];
   NSString *str =  [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
//    http://dvideo.spriteapp.cn/video/2017/1210/5a2d27ea6e697_wpd.mp4
    NSURL *inputPath= [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", str]];  //注意本地视频需要加头
//     NSURL *inputPath= [NSURL URLWithString:@"http://dvideo.spriteapp.cn/video/2017/1210/5a2d27ea6e697_wpd.mp4"];  //注意本地视频需要加头
    vc.canEdit = NO;
    vc.inputPath = inputPath;
    vc.didFinishCutVideoCallBack = ^(IJSVideoManagerController *controller, NSURL *outputPath, NSError *error, IJSVideoState state) {
        NSLog(@"%@",controller);
        NSLog(@"%@",outputPath);
        NSLog(@"%@",error);
        NSLog(@"%lu",(unsigned long)state);
    };
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)_videoEdit:(id)sender
{
    IJSVideoEditController *vc =[[IJSVideoEditController alloc]init];
    NSString *str =  [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    NSURL *inputPath= [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", str]];  //注意本地视频需要加头
//         NSURL *inputPath= [NSURL URLWithString:@"http://dvideo.spriteapp.cn/video/2017/1210/5a2d27ea6e697_wpd.mp4"];  //注意本地视频需要加头
    vc.inputPath = inputPath;
    vc.didFinishCutVideoCallBack = ^(IJSVideoManagerController *controller, NSURL *outputPath, NSError *error, IJSVideoState state) {
        NSLog(@"--block------%@",controller);
        NSLog(@"--block------%@",outputPath);
        NSLog(@"--block------%@",error);
        NSLog(@"--block------%lu",(unsigned long)state);
    };
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
//    [self presentViewController:vc animated:YES completion:nil];
}

-(void)didFinishCutVideoWithController:(IJSVideoManagerController *)controller outputPath:(NSURL *)outputPath error:(NSError *)error state:(IJSVideoState)state
{
            IJSVideoTestController *testVc = [[IJSVideoTestController alloc] init];
            AVAsset *avaseet = [AVAsset assetWithURL:outputPath];
            testVc.avasset = avaseet;
            [self presentViewController:testVc animated:YES completion:nil];
}


























- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}






@end
