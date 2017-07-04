//
//  IJSPhotoPickerController.m
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSPhotoPickerController.h"
#import "UIView+IJSPhotoLayout.h"
#import "IJSPhotoPreviewController.h"
#import "NSBundle+IJSPhotoBundle.h"
#import "IJSConst.h"
#import "IJSPhotoPickerCell.h"
#import "IJSAlbumModel.h"
#import "NSBundle+IJSPhotoBundle.h"
#import "IJSImageManager.h"
#import "IJSImagePickerController.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"


static NSString *const CellID = @"pickerID";
@interface IJSPhotoPickerController ()<UICollectionViewDelegate,UICollectionViewDataSource>

/* 解析出来的照片的个数 */
@property(nonatomic,strong) NSMutableArray *assetModelArr;
/* 预览 */
@property(nonatomic,weak) UIButton *previewButton;
/* 完成 */
@property(nonatomic,weak) UIButton *finishButton;
/* collection */
@property(nonatomic,weak) UICollectionView *showCollectioView;
/* 被选中的cell */
@property(nonatomic,strong) NSMutableArray<IJSPhotoPickerCell *> *hasSelectedCell;
/* 控制器 */
@property(nonatomic,strong) IJSImagePickerController *imagePickerController;

/* 存储被点击的modle */
@property(nonatomic,strong) NSMutableArray<IJSAssetModel *> *selectedModels;

@end

@implementation IJSPhotoPickerController


-(NSMutableArray *)selectedModels
{
    if (!_selectedModels) {
        _selectedModels = [NSMutableArray array];
    }
    return _selectedModels;
}

-(IJSImagePickerController *)imagePickerController
{
    if (!_imagePickerController)
    {
        _imagePickerController = (IJSImagePickerController *)self.navigationController;
    }
    return _imagePickerController;
}
/*-----------------------------------系统的方法-------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    self.hasSelectedCell = [NSMutableArray array];
    self.title = self.albumModel.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[NSBundle localizedStringForKey:@"Cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(_cancleSelectImage)];
   [self _handleCallBackData];
    
    [self _createrData];
    [self _createrBottomToolBarUI];
    [self _createrCollectionView];
   
}
// 处理回调
-(void)_handleCallBackData
{
    // 处理
    __weak typeof (self) weakSelf = self;
    self.callBack = ^(NSMutableArray *selectedModel,NSMutableArray *allAssetModel) {
        weakSelf.selectedModels = selectedModel;
        weakSelf.assetModelArr = allAssetModel;
        [weakSelf.showCollectioView reloadData];
        [weakSelf _resetToorBarStatus];
    };
}

#pragma mark CollectionView代理方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetModelArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   
        IJSPhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
        
        IJSImagePickerController *vc = self.imagePickerController;
        
        __block IJSAssetModel *model = self.assetModelArr[indexPath.row];
        
        cell.indexPath = indexPath;
        cell.type =model.type;
        //给 model设置唯一值
        if (model.onlyOneTag != indexPath.row)
        {
            model.onlyOneTag = indexPath.row;
        }
        // 判断蒙版条件
        if (self.selectedModels.count >vc.maxImagesCount - 1)
        {
            model.didMask = YES;
        }else{
            model.didMask = NO;
        }
        
        cell.model = model;
        
        __weak typeof (self) weakSelf = self;
        __weak typeof (vc) weakVc = vc;
        
        cell.didSelectPhotoBlock = ^(BOOL isSelected, NSIndexPath *index) {
            IJSAssetModel *currentModel = self.assetModelArr[index.row];
            if (isSelected)   // 被选中
            {
                currentModel.isSelectedModel  = YES;
                currentModel.onlyOneTag = indexPath.row;
                currentModel.didMask = YES;
                model = currentModel;
                if (weakVc.selectedModels.count < weakVc.maxImagesCount) // 选中的个数没有超标
                {
                    [weakSelf.selectedModels addObject:model];
                    weakVc.selectedModels = weakSelf.selectedModels;
                    model.didClickModelArr = weakSelf.selectedModels;
                    model.cellButtonNnumber = model.didClickModelArr.count;   // 给button的赋值
                }
                else    // 选中超标
                {
                    NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a maximum of %zd photos"], vc.maxImagesCount];
                    [vc showAlertWithTitle:title];
                }
            }
            else   //  取消选中
            {
                currentModel.isSelectedModel = NO;
                currentModel.didMask = NO;
                currentModel.onlyOneTag = indexPath.row;
                model = currentModel;
                NSArray *selectedModels = [NSArray arrayWithArray:vc.selectedModels];  // 处理用户回调数据
                for (IJSAssetModel *model_item in selectedModels)
                {
                    if ([[[IJSImageManager shareManager] getAssetIdentifier:model.asset] isEqualToString:[[IJSImageManager shareManager] getAssetIdentifier:model_item.asset]])
                    {
                        [weakVc.selectedModels removeObject:model_item];
                        break;
                    }
                }
                model.didClickModelArr = weakSelf.selectedModels;
                currentModel.cellButtonNnumber = 0;
                for (int i = 0; i<model.didClickModelArr .count; i++)
                {
                    IJSAssetModel *tempModel =  model.didClickModelArr[i];
                    tempModel.cellButtonNnumber  = i +1 ;
                }
            }
            [self _resetToorBarStatus]; // 重置 toor
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.showCollectioView reloadData];
            });
        };
     return cell;
  
}
#pragma mark tableview的点击方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

     if (self.selectedModels.count >= self.imagePickerController.maxImagesCount) // 选中的个数超标
     {
          IJSPhotoPreviewController *preViewVc  =[[IJSPhotoPreviewController alloc]init];
         
         for (IJSAssetModel *model in self.selectedModels) //选中的model
         {
             if (model.onlyOneTag == indexPath.row)  //  点击被选中的
             {
                     preViewVc.allAssetModelArr = _assetModelArr;
                     preViewVc.selectedModels = self.selectedModels;
                     preViewVc.pushSelectedIndex = indexPath.row;
                     [self.navigationController pushViewController:preViewVc animated:YES];
                     return;
             }
         } // 点击的非选中的
         NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a maximum of %zd photos"], self.imagePickerController.maxImagesCount];
         [self.imagePickerController showAlertWithTitle:title];
     }
     else  // 选中的个数没有超标超标
     {
             IJSPhotoPreviewController *preViewVc  =[[IJSPhotoPreviewController alloc]init];
             preViewVc.selectedModels = self.selectedModels;
             preViewVc.allAssetModelArr = _assetModelArr;
             preViewVc.pushSelectedIndex = indexPath.row;
             [self.navigationController pushViewController:preViewVc animated:YES];
             return;
     }
}

/*-----------------------------------点击状态-------------------------------------------------------*/
#pragma mark 点击事件
// 跳转预览界面
-(void)_pushPreViewPhoto
{
    if (self.selectedModels.count == 0) return;
    IJSPhotoPreviewController *vc =[[IJSPhotoPreviewController alloc]init];
    vc.allAssetModelArr = self.assetModelArr;
    vc.selectedModels = self.selectedModels;
    vc.isPreviewButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
// 选图完成返回数据 / 执行 block 或者 协议
-(void) _finishSelectImageDisMiss
{
    IJSImagePickerController *vc = self.imagePickerController;
    // 不满足最小要求就警告
    if (vc.minImagesCount && vc.selectedModels.count < vc.minImagesCount)
    {
        NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a minimum of %zd photos"], vc.minImagesCount];
        [vc showAlertWithTitle:title];
        return;
    }
   
    NSMutableArray *photos = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    NSMutableArray *infoArr = [NSMutableArray array];
    for (NSInteger i = 0; i < vc.selectedModels.count; i++)
    {
        [photos addObject:@1];
        [assets addObject:@1];
        [infoArr addObject:@1];
    }
     // 解析数据并返回
    __block BOOL noShowAlert = YES;
    if (vc.allowPickingOriginalPhoto)  // 获取本地原图
    {
        for (int i = 0; i < vc.selectedModels.count; i++)
        {
            IJSAssetModel *model = vc.selectedModels[i];
            [[IJSImageManager shareManager]getOriginalPhotoWithAsset:model.asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) return ;  // 获取不到高清图
                if (photo)
                {
                    [photos replaceObjectAtIndex:i withObject:photo];
                }
                if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
                [assets replaceObjectAtIndex:i withObject:model.asset];
                
                for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
                
                [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:YES];
            }];
        }
    }else{   //缩略图,默认是828
        
        for (int i = 0; i < vc.selectedModels.count; i++)
        {
            IJSAssetModel *model = vc.selectedModels[i];
            [[IJSImageManager shareManager]getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) return ;  // 获取不到高清图
                if (photo)
                {
                    [photos replaceObjectAtIndex:i withObject:photo];
                }
                if (info)  [infoArr replaceObjectAtIndex:i withObject:info];
                [assets replaceObjectAtIndex:i withObject:model.asset];
                
                for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }

                if (noShowAlert)
                {
                    [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:NO];
                }
        
            } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                // 如果图片正在从iCloud同步中,提醒用户
                if (progress < 1 && noShowAlert)
                {
                    [vc showAlertWithTitle:[NSBundle localizedStringForKey:@"Synchronizing photos from iCloud"]];
                    noShowAlert = NO;
                    return;
                }
            } networkAccessAllowed:YES];
        }
    }
    
    if (vc.selectedModels.count <= 0)
    {
        [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:NO];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//设置返回的数据
- (void)_didGetAllPhotos:(NSArray *)photos asset:(NSArray *)asset infos:(NSArray *)infos isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    //  block 方式进行数据返回
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    if (vc.didFinishUserPickingImageHandle)
    {
        vc.didFinishUserPickingImageHandle(photos,nil, asset, infos, isSelectOriginalPhoto);
    }
    // 代理方式
    if ([vc.imagePickerDelegate respondsToSelector:@selector(imagePickerController:isSelectOriginalPhoto:didFinishPickingPhotos:assets:infos:avPlayers:)])
    {
         [vc.imagePickerDelegate imagePickerController:vc isSelectOriginalPhoto:isSelectOriginalPhoto didFinishPickingPhotos:photos assets:asset infos:infos avPlayers:nil];
    }
}


// 取消
-(void) _cancleSelectImage
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*-----------------------------------UI-------------------------------------------------------*/
// 创建底部的工具视图
-(void) _createrBottomToolBarUI
{
    
    //背景
    UIView *toolBarView =[[UIView alloc]initWithFrame:CGRectMake(0, self.view.js_height - 44, self.view.js_width, 44)];
    toolBarView.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    [self.view addSubview:toolBarView];
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    //预览
    UIButton *previewButton =[UIButton buttonWithType:UIButtonTypeCustom];
    previewButton.frame = CGRectMake(5, 5, 50, 30);
    [previewButton setTitle:[NSBundle localizedStringForKey:@"Preview"] forState:UIControlStateNormal];
    [previewButton setTitleColor:[IJSFColor colorWithR:98 G:103 B:109 alpha:1] forState:UIControlStateNormal];
    [previewButton addTarget:self action:@selector(_pushPreViewPhoto) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:previewButton];
    self.previewButton = previewButton;
    
    // 完成
    UIButton *finishButton =[UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.frame = CGRectMake(self.view.js_width - 55, 5, 50, 30);   //27 81 28
    finishButton.backgroundColor =[IJSFColor colorWithR:27 G:81 B:28 alpha:1];
    finishButton.layer.masksToBounds = YES;
    finishButton.layer.cornerRadius = 2;
    [finishButton setTitle:[NSBundle localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    [finishButton setTitleColor:[IJSFColor colorWithR:77 G:128 B:78 alpha:1] forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(_finishSelectImageDisMiss) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:finishButton];
    self.finishButton = finishButton;
    
}
/// 创建 collection
-(void)_createrCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWH = 0.0;
    if (self.columnNumber > 1) itemWH = (self.view.js_width - (self.columnNumber + 1) * cellMargin) / self.columnNumber;
    if (self.columnNumber ==1) itemWH = JSScreenHeight;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = cellMargin;
    layout.minimumLineSpacing = cellMargin;
    UICollectionView *collection =[[UICollectionView alloc]initWithFrame:CGRectMake(cellMargin, NavigationHeight, JSScreenWidth - 2 * cellMargin, JSScreenHeight - NavigationHeight -TabbarHeight) collectionViewLayout:layout];
    collection.backgroundColor = [UIColor whiteColor];
    collection.dataSource = self;
    collection.delegate = self;
    collection.alwaysBounceHorizontal = NO;
    [self.view addSubview:collection];
    self.showCollectioView = collection;
    [self.showCollectioView registerClass:[IJSPhotoPickerCell class] forCellWithReuseIdentifier:CellID];
    NSInteger rows= ( _assetModelArr.count - 1) / self.columnNumber +1;
    self.showCollectioView.contentOffset = CGPointMake(0, itemWH * rows);
}

#pragma mark 私有方法
// 数据解析
-(void)_createrData
{
    [[IJSImageManager shareManager]getAssetsFromFetchResult:self.albumModel.result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<IJSAssetModel *> *models) {
        _assetModelArr =[NSMutableArray arrayWithArray:models];
    }];
}

// 根据cell选中的数量重置toorbar的状态
-(void)_resetToorBarStatus
{
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    if (vc.selectedModels.count > 0) // 有数据
    {
        [self.previewButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
        [self.finishButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
        self.finishButton.backgroundColor =[IJSFColor colorWithR:40 G:170 B:40 alpha:1];
        [_finishButton setTitle:[NSString stringWithFormat:@"%@(%lu)",[NSBundle localizedStringForKey:@"Done"],(unsigned long)vc.selectedModels.count] forState:UIControlStateNormal];
        self.finishButton.titleLabel.font =[UIFont systemFontOfSize:13];
    }
    else
    {
        [_previewButton setTitleColor:[IJSFColor colorWithR:98 G:103 B:109 alpha:1] forState:UIControlStateNormal];
        [_finishButton setTitleColor:[IJSFColor colorWithR:77 G:128 B:78 alpha:1] forState:UIControlStateNormal];
        _finishButton.backgroundColor =[IJSFColor colorWithR:27 G:81 B:28 alpha:1];
         [_finishButton setTitle:[NSBundle localizedStringForKey:@"Done"] forState:UIControlStateNormal];
        self.finishButton.titleLabel.font =[UIFont systemFontOfSize:17];
    }
}
/// 缩放图片,绘制传入的大小
- (UIImage *)_scaleImage:(UIImage *)image toSize:(CGSize)size
{
    if (image.size.width < size.width)
    {
        return image;
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}




// 刷新数据
//         [weakSelf.showCollectioView reloadItemsAtIndexPaths:@[index]];
@end
