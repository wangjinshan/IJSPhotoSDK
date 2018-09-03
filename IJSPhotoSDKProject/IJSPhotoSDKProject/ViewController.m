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

// 二维码模块
#import "IJSQRCodeController.h"

static NSString *const cellID = @"cellID";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

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
    self.view.backgroundColor =[UIColor whiteColor];
    [self createTableViewUI];
//    [self.view bringSubviewToFront:self.pushActionBt];
//
        NSString *str = [[NSBundle mainBundle] pathForResource:@"2002" ofType:@"mov"];
    
    NSURL *url;
    if (str)
    {
     url  =  [NSURL fileURLWithPath:str];
    }
    
//        [[IJSImageManager shareManager] saveVideoIntoSystemAlbumFromVideoUrl:url completion:^(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess) {
//            NSLog(@"----%@",error);
//        }];
//    [self testMemory];

//    [UIColor redColor];
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
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
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
    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:5 columnNumber:4];
    // 可选--------------------------------------------------------
    //  更加项目需求进行配置
//    imageVc.minImagesCount = 2;
//    imageVc.minVideoCut = 4;
//    imageVc.maxVideoCut = 10;
//    imageVc.sortAscendingByModificationDate = NO;
//    imageVc.allowPickingVideo = YES;   // 不能选视频
//    imageVc.allowPickingImage = NO;
//    imageVc.isHiddenEdit = NO;
    imageVc.allowPickingOriginalPhoto = YES;
    imageVc.hiddenOriginalButton = NO;
    //-----------------------------------------------------------------
    // 获取数据的方法
    [imageVc loadTheSelectedData:^(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType,NSError *error) {
      
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
        NSLog(@"完成选择");
    }];
    
    [imageVc cancelSelectedData:^{
        NSLog(@"--------取消选择----------");
    }];
    
    // 可选--------------------------------------------------
    // 添加 贴图的方法 如果不加则默认读取 里面的配置
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
    NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
    
    [IJSFFilesManager ergodicFilesFromFolderPath:bundlePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray<NSString *> *filePath) {
        
        IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
        [self.mapDataArr addObject:model];
        imageVc.mapImageArr = self.mapDataArr;
    }];
    
    [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
        
        IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
        [self.mapDataArr addObject:model];
        imageVc.mapImageArr = self.mapDataArr;
    }];
    ///-----------------------------------------------------
    
    [self presentViewController:imageVc animated:YES completion:nil];
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
        
        IJSAlbumModel *model = models.firstObject;
        
//        for (IJSAlbumModel *model in models)
//        {
        int i = 0;
            for (PHAsset *asset in model.result)
            {
                NSLog(@"-------------%d",i);
                if (i > 9)
                {
                    break;
                }
//                [[IJSImageManager shareManager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
//                    NSLog(@"------ww----------%@",photo);
//                    self.backImageView.image = photo;
//
//                }];
                
                [[IJSImageManager shareManager]getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    
                    NSLog(@"------ww----------%@",photo);
                }];
                
                     i ++;
            }
//        }
    }];
    
}

- (IBAction)cutTest:(UIButton *)sender
{
    NSString *str = [[NSBundle mainBundle] pathForResource:@"2002" ofType:@"mov"];
    NSURL *inputPath= [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", str]];
    AVAsset *avasset =[AVAsset assetWithURL:inputPath];
    [IJSVideoManager cutVideoAndExportVideoWithVideoAsset:avasset startTime:0 endTime:5 completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {
        
        IJSVideoTestController *testVc = [[IJSVideoTestController alloc] init];
        AVAsset *avaseet = [AVAsset assetWithURL:outputPath];
        testVc.avasset = avaseet;
        [self presentViewController:testVc animated:YES completion:nil];
    }];
}

/// 二维码控制器
- (IBAction)qrcodeAction:(UIButton *)sender
{
    IJSQRCodeController *vc =[IJSQRCodeController new];
    [self presentViewController:vc animated:YES completion:nil];
}
















- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    JSLog("内存警告");
    [[IJSImageManager shareManager] stopCachingImagesFormAllAssets];
}



























@end
