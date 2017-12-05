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
#import "IJSVideoManager.h"
#import "IJSAlbumModel.h"

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
    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:50 columnNumber:4 delegate:self];
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
      //作为测试
//     NSString *path = [IJSVideoManager getAllVideoPath];
//        NSLog(@"%@",path);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [IJSVideoManager cleanAllVideo];  // 清理缓存
//        });
        
//        IJSVideoTestController *testVc = [[IJSVideoTestController alloc] init];
//        AVAsset *avaseet = [AVAsset assetWithURL:avPlayers.firstObject];
//        testVc.avasset = avaseet;
//        [self presentViewController:testVc animated:YES completion:nil];
        
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



-(void)testMemory
{
    [[IJSImageManager shareManager] getAllAlbumsContentImage:YES contentVideo:YES completion:^(NSArray<IJSAlbumModel *> *models) {
        
        for (IJSAlbumModel *model in models)
        {
            for (PHAsset *asset in model.result)
            {
                [[IJSImageManager shareManager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                    self.backImageView.image = photo;
                }];
            }
        }
    }];
    
    
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    JSLog("内存警告");
    [[IJSImageManager shareManager] stopCachingImagesFormAllAssets];
}



























@end
