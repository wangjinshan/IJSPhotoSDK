//
//  ViewController.m
//  IJSDemo
//
//  Created by shan on 2017/8/9.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "ViewController.h"

#import "IJSImagePickerController.h"
#import "IJSImageManager.h"
#import "IJSExtension.h"
#import "IJSVideoTestController.h"
#import "IJSMapViewModel.h"
#import <IJSFoundation/IJSFoundation.h>
#import <Photos/Photos.h>

static NSString *const cellID = @"cellID";

@interface ViewController () <IJSImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (nonatomic, strong) NSMutableArray<UIImage *> *imageArr; // 图片数组
@property (nonatomic, strong) UITableView *myTableview;            // 参数说明
@property (nonatomic, strong) NSMutableArray *mapDataArr;          // 参数说明

@property (weak, nonatomic) IBOutlet UIButton *pushActionBt;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createTableViewUI];
    [self.view bringSubviewToFront:self.pushActionBt];
    //    NSString *str = [[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp4"];
    //    NSURL *url = [NSURL fileURLWithPath:str];
    //    [[IJSImageManager shareManager] saveVideoIntoSystemAlbumFromVideoUrl:url completion:^(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess) {
    //        NSLog(@"----%@",error);
    //    }];
    
}

#pragma mark 懒加载区域
- (NSMutableArray *)imageArr
{
    if (_imageArr == nil)
    {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}

- (void)createTableViewUI
{
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:tableview];

    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.rowHeight = 300;
    [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    self.myTableview = tableview;
}
#pragma mark Tableview 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.imageView.image = self.imageArr[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction)shareAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:5 columnNumber:4 delegate:self];
    imageVc.minImagesCount = 1;
    imageVc.minVideoCut = 3;
    imageVc.maxVideoCut = 10;
    imageVc.didFinishUserPickingImageHandle = ^(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, BOOL isSelectOriginalPhoto, IJSPExportSourceType sourceType) {
        if (sourceType == IJSPImageType)
        {
            weakSelf.imageArr = [NSMutableArray arrayWithArray:photos];
            [weakSelf.myTableview reloadData];
        }
        else
        {
            IJSVideoTestController *testVc = [[IJSVideoTestController alloc] init];
            AVAsset *avaseet = [AVAsset assetWithURL:avPlayers.firstObject];
            testVc.avasset = avaseet;
            [weakSelf presentViewController:testVc animated:YES completion:nil];
        }
    };

    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
    NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
    [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
        IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
        [self.mapDataArr addObject:model];
        imageVc.mapImageArr = self.mapDataArr;
        [self presentViewController:imageVc animated:YES completion:nil];
    }];
}
- (void)imagePickerController:(IJSImagePickerController *)picker isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto didFinishPickingPhotos:(NSArray<UIImage *> *)photos assets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos avPlayers:(NSArray *)avPlayers sourceType:(IJSPExportSourceType)sourceType
{
    if (sourceType == IJSPVideoType)
    {
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            IJSVideoTestController *testVc =[[IJSVideoTestController alloc] init];
        //            AVAsset *avaseet = [AVAsset assetWithURL:avPlayers.firstObject];
        //            testVc.avasset = avaseet;
        //            [self presentViewController:testVc animated:YES completion:nil];
        //        });
    }
}
#pragma mark 懒加载区域
- (NSMutableArray *)mapDataArr
{
    if (_mapDataArr == nil)
    {
        _mapDataArr = [NSMutableArray array];
    }
    return _mapDataArr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
 if (centerOffSetX - CGRectGetMaxX(self.leftOverlayView.frame) - (centerOffSetX  - CGRectGetMinX(self.rightOverlayView.frame))  <  self.limitLenght)
 {
 centerOffSetX = CGRectGetMaxX(self.leftOverlayView.frame) + self.limitLenght + self.rightOverlayView.js_width /2;
 }
 
 else if (centerOffSetX - self.leftViewMaxOverlyWidth * 0.5 > self.rightViewMaxOverlyWidth) //超过最大值
 {
 centerOffSetX = self.rightViewMaxOverlyWidth + self.leftViewMaxOverlyWidth * 0.5;
 }
 self.rightOverlayView.center = CGPointMake(centerOffSetX, self.leftOverlayView.center.y);
 self.rightStartPoint = point;
 break;

 
 #pragma mark 手势方法
 - (void)leftPanAction:(UIPanGestureRecognizer *)gesture
 {
 if (self.widthPerSecond == 0)
 {
 NSLog(@"加载loding,解析数据中");
 return;
 }
 
 //    switch (gesture.state)
 //    {
 //        case UIGestureRecognizerStateBegan:
 //            self.leftStartPoint = [gesture locationInView:self];
 //            break;
 //        case UIGestureRecognizerStateChanged:
 //        {
 //            CGPoint point = [gesture locationInView:self];
 //            int offSet = point.x - self.leftStartPoint.x; // 偏移量
 //            CGPoint center = self.leftOverlayView.center;
 //            CGFloat centerOffSetX = center.x += offSet; // 中心点偏移量 负数
 //
 //            CGFloat maxWidth = CGRectGetMinX(self.rightOverlayView.frame) - self.limitLength; // 最大宽度
 //
 //            if (self.leftViewMaxOverlyWidth * 0.5 + centerOffSetX < self.slideWidth + 0.1 * JSScreenWidth) // 最小值,调整最左边则 上下 slideWidth + 调整值
 //            {
 //                centerOffSetX = (-self.leftViewMaxOverlyWidth * 0.5) + self.slideWidth + 0.1 * JSScreenWidth;
 //            }
 //            else if (self.leftViewMaxOverlyWidth * 0.5 + centerOffSetX > maxWidth)
 //            {
 //                centerOffSetX = (-self.leftViewMaxOverlyWidth * 0.5) + maxWidth;
 //            }
 //
 //            self.leftOverlayView.center = CGPointMake(centerOffSetX, self.leftOverlayView.center.y);
 //            self.leftStartPoint = point;
 //            [self _updateBoderFrame];  //更新白板子的坐标
 //            break;
 //        }
 //        case UIGestureRecognizerStateEnded:
 //            [self getVideoLenghtThenNotifyDelegate];
 //            break;
 //        default:
 //            break;
 //    }
 }
 - (void)rightPanAction:(UIPanGestureRecognizer *)gesture
 {
 if (self.widthPerSecond == 0)
 {
 NSLog(@"加载loding,解析数据中");
 return;
 }
 //    switch (gesture.state)
 //    {
 //        case UIGestureRecognizerStateBegan:
 //            self.rightStartPoint = [gesture locationInView:self];
 //            break;
 //        case UIGestureRecognizerStateChanged:
 //        {
 //            CGPoint point = [gesture locationInView:self];
 //            int offSet = point.x - self.rightStartPoint.x; // 偏移量
 //            CGPoint center = self.rightOverlayView.center;
 //
 //            CGFloat centerOffSetX = center.x += offSet; // 移动后的中心点的值
 //
 //            CGFloat maxX = self.assetDuration <= self.maxLength + 0.5 ? CGRectGetMaxX(self.backScrollView.frame) : CGRectGetWidth(self.frame) - self.slideWidth; //  最后边值
 //
 //            if (centerOffSetX - CGRectGetMaxX(self.leftOverlayView.frame) - (centerOffSetX - CGRectGetMinX(self.rightOverlayView.frame)) < self.limitLength)
 //            {
 //                centerOffSetX = CGRectGetMaxX(self.leftOverlayView.frame) + self.limitLength + self.rightOverlayView.js_width * 0.5;
 //            }
 //            else if (centerOffSetX - self.leftViewMaxOverlyWidth * 0.5 > maxX) //超过最大值
 //            {
 //                centerOffSetX = maxX + self.leftViewMaxOverlyWidth * 0.5;
 //            }
 //
 //            self.rightOverlayView.center = CGPointMake(centerOffSetX, self.leftOverlayView.center.y);
 //            self.rightStartPoint = point;
 //             [self _updateBoderFrame];   //更新白板子
 //            break;
 //        }
 //        case UIGestureRecognizerStateEnded:
 //            [self getVideoLenghtThenNotifyDelegate];
 //            break;
 //        default:
 //            break;
 //    }
 }
 
 
 */
// 最小值

@end
