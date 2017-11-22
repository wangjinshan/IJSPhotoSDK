//
//  IJSPhotoPickerController.m
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSPhotoPickerController.h"
#import "IJSPhotoPreviewController.h"
#import "IJSConst.h"
#import "IJSPhotoPickerCell.h"
#import "IJSAlbumModel.h"
#import "IJSImageManager.h"
#import "IJSImagePickerController.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"
#import "IJS3DTouchController.h"

static NSString *const CellID = @"pickerID";

@interface IJSPhotoPickerController () <UICollectionViewDelegate, UICollectionViewDataSource,IJSPhotoPickerCellDelegate>

/* 解析出来的照片的个数 */
@property (nonatomic, strong) NSMutableArray<IJSAssetModel *> *assetModelArr;
/* 预览 */
@property (nonatomic, weak) UIButton *previewButton;
/* 完成 */
@property (nonatomic, weak) UIButton *finishButton;
/* collection */
@property (nonatomic, weak) UICollectionView *showCollectioView;
/* 被选中的cell */
@property (nonatomic, strong) NSMutableArray<IJSPhotoPickerCell *> *hasSelectedCell;
/* 存储被点击的modle */
@property (nonatomic, strong) NSMutableArray<IJSAssetModel *> *selectedModels;
@property(nonatomic,weak) IJSLodingView *lodingView;  // 加载界面
@property(nonatomic,assign) CGFloat itemHeight;  // item的高度
@end

@implementation IJSPhotoPickerController

#pragma mark 内存
-(void)dealloc
{
    JSLog(@"----释放----IJSPhotoPickerController");
}
/*------------------------------------正文-------------------------------*/
- (NSMutableArray *)selectedModels
{
    if (!_selectedModels)
    {
        _selectedModels = [NSMutableArray array];
    }
    return _selectedModels;
}
-(NSMutableArray *)assetModelArr
{
    if (_assetModelArr == nil)
    {
        _assetModelArr =[NSMutableArray array];
    }
    return _assetModelArr;
}
-(NSMutableArray *)hasSelectedCell
{
    if (_hasSelectedCell == nil)
    {
        _hasSelectedCell =[NSMutableArray array];
    }
    return _hasSelectedCell;
}
/*-----------------------------------系统的方法-------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.albumModel.name;
    [self _createrBottomToolBarUI];
    [self _createrCollectionView];
    [self _handleCallBackData];
    [self _createrData];
}
// 处理回调
- (void)_handleCallBackData
{
    // 处理
    __weak typeof(self) weakSelf = self;
    self.callBack = ^(NSMutableArray *selectedModel, NSMutableArray *allAssetModel) {
        weakSelf.selectedModels = selectedModel;
        weakSelf.assetModelArr = allAssetModel;
        [weakSelf.showCollectioView reloadData];
        [weakSelf _resetToorBarStatus];
    };
}

#pragma mark CollectionView代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetModelArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IJSPhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    IJSAssetModel *model = self.assetModelArr[indexPath.row];
    cell.type = model.type;
   
    if (model.type == JSAssetModelMediaTypeVideo || model.type == JSAssetModelMediaTypeAudio)
    {
        if (self.selectedModels.count != 0)
        {
            model.didMask = YES;
        }
        else
        {
             model.didMask = NO;
        }
    }
    else
    {
        // 判断蒙版条件
        if (self.selectedModels.count > vc.maxImagesCount - 1)
        {
            model.didMask = YES;
        }
        else
        {
            model.didMask = NO;
        }
    }
    cell.model = model;
    cell.cellDelegate = self;
    
    if (iOS9Later)
    {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
        {
            [self registerForPreviewingWithDelegate:(id) self sourceView:cell];
        }
    }
    return cell;
}
#pragma mark tableview的点击方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    IJSPhotoPreviewController *preViewVc = [[IJSPhotoPreviewController alloc] init];
    preViewVc.isPreviewButton = NO;  // 正常点进去
    if (self.selectedModels.count >= vc.maxImagesCount) // 选中的个数超标
    {
        for (IJSAssetModel *model in self.selectedModels) //选中的model
        {
            if (model.onlyOneTag == indexPath.row) //点击被选中的
            {
                preViewVc.allAssetModelArr = _assetModelArr;
                preViewVc.selectedModels = self.selectedModels;
                preViewVc.pushSelectedIndex = indexPath.row;
                [self.navigationController pushViewController:preViewVc animated:YES];
                return;
            }
        } // 点击的非选中的
        NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a maximum of %zd photos"], vc.maxImagesCount];
        [vc showAlertWithTitle:title];
    }
    else // 选中的个数没有超标超标
    {
        if (self.selectedModels.count == 0) //没选状态下
        {
            preViewVc.allAssetModelArr = _assetModelArr;
            preViewVc.selectedModels = self.selectedModels;
            preViewVc.pushSelectedIndex = indexPath.row;
            [self.navigationController pushViewController:preViewVc animated:YES];
            return;
        }
        else
        {
            IJSAssetModel *tempModel = self.assetModelArr[indexPath.row];
            if (tempModel.type == JSAssetModelMediaTypeVideo || tempModel.type == JSAssetModelMediaTypeAudio)
            {
                NSString *title = [NSString stringWithFormat:@"%@", [NSBundle localizedStringForKey:@"Video cannot be selected"]];
                [vc showAlertWithTitle:title];
                return ;
            }
            else
            {
                preViewVc.selectedModels = self.selectedModels;
                preViewVc.allAssetModelArr = _assetModelArr;
                preViewVc.pushSelectedIndex = indexPath.row;
                [self.navigationController pushViewController:preViewVc animated:YES];
            }
        }
    }
}
#pragma mark - cell的代理方法
-(void)didClickCellButtonWithButtonState:(BOOL)state buttonIndex:(NSInteger)currentIndex
{
    IJSAssetModel *currentModel = self.assetModelArr[currentIndex];
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    if (state) // 被选中
    {
        currentModel.isSelectedModel = YES;
        currentModel.didMask = YES;
        if (vc.selectedModels.count < vc.maxImagesCount) // 选中的个数没有超标
        {
            [self.selectedModels addObject:currentModel];
            vc.selectedModels = self.selectedModels;
            currentModel.didClickModelArr = self.selectedModels;
            currentModel.cellButtonNnumber = currentModel.didClickModelArr.count; // 给button的赋值
        }
        else // 选中超标
        {
            NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a maximum of %zd photos"], vc.maxImagesCount];
            [vc showAlertWithTitle:title];
        }
    }
    else //  取消选中
    {
        currentModel.isSelectedModel = NO;
        currentModel.didMask = NO;

        NSArray *selectedModels = [NSArray arrayWithArray:vc.selectedModels]; // 处理用户回调数据
        for (IJSAssetModel *newModel in selectedModels)
        {
            if ([[[IJSImageManager shareManager] getAssetIdentifier:currentModel.asset] isEqualToString:[[IJSImageManager shareManager] getAssetIdentifier:newModel.asset]])
            {
                [vc.selectedModels removeObject:newModel];
                break;
            }
        }
        currentModel.didClickModelArr = self.selectedModels;
        currentModel.cellButtonNnumber = 0;
        for (int i = 0; i < currentModel.didClickModelArr.count; i++)
        {
            IJSAssetModel *tempModel = currentModel.didClickModelArr[i];
            tempModel.cellButtonNnumber = i + 1;
        }
    }
    [self _resetToorBarStatus]; // 重置 toor
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.showCollectioView reloadData];
    });
}

/*-----------------------------------点击状态-------------------------------------------------------*/
#pragma mark - 点击事件
#pragma mark 跳转预览界面
- (void)_pushPreViewPhoto
{
    if (self.selectedModels.count == 0)
    {
        return;
    }
    IJSPhotoPreviewController *vc = [[IJSPhotoPreviewController alloc] init];
    vc.allAssetModelArr = self.assetModelArr;
    vc.selectedModels = self.selectedModels;
    vc.previewAssetModelArr = [self.selectedModels mutableCopy];
    vc.pushSelectedIndex = 0;
    vc.isPreviewButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 选图完成返回数据 / 执行 block 或者 协议
- (void)_finishSelectImageDisMiss
{
    // lodingView

    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    // 不满足最小要求就警告
    if (vc.minImagesCount && vc.selectedModels.count < vc.minImagesCount)
    {
        NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a minimum of %zd photos"], vc.minImagesCount];
        [vc showAlertWithTitle:title];
        return;
    }
    IJSLodingView *lodingView =[IJSLodingView showLodingViewAddedTo:self.view title:@"正在处理中... ..."];
    self.lodingView = lodingView;
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
    __weak typeof (self) weakSelf = self;
    if (vc.allowPickingOriginalPhoto) // 获取本地原图
    {
        for (int i = 0; i < vc.selectedModels.count; i++)
        {
            IJSAssetModel *model = vc.selectedModels[i];
            
            if (model.image) //裁剪过了
            {
                [photos replaceObjectAtIndex:i withObject:model.image];
                [assets replaceObjectAtIndex:i withObject:model.asset];
                for (id item in photos)
                {
                    if ([item isKindOfClass:[NSNumber class]])
                    {
                        return;
                    }
                }
                [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:YES];
            }
            else
            {
                [[IJSImageManager shareManager] getOriginalPhotoWithAsset:model.asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (isDegraded)
                    {
                        return; // 获取不到高清图
                    }
                    if (photo)
                    {
                        [photos replaceObjectAtIndex:i withObject:photo];
                    }
                    if (info)
                    {
                        [infoArr replaceObjectAtIndex:i withObject:info];
                    }
                    if (model.asset)
                    {
                        [assets replaceObjectAtIndex:i withObject:model.asset];
                    }
                    for (id item in photos)
                    {
                        if ([item isKindOfClass:[NSNumber class]])
                        {
                            return;
                        }
                    }
                    [weakSelf _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:YES];
                }];
            }
        }
    }
    else
    { //缩略图,默认是828
        for (int i = 0; i < vc.selectedModels.count; i++)
        {
            IJSAssetModel *model = vc.selectedModels[i];
            if (model.image)
            {
                [photos replaceObjectAtIndex:i withObject:model.image];
                if (model.asset)
                {
                    [assets replaceObjectAtIndex:i withObject:model.asset];
                }
                for (id item in photos)
                {
                    if ([item isKindOfClass:[NSNumber class]])
                    {
                        return;
                    }
                }
                [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:NO];
            }
            else
            {
                [[IJSImageManager shareManager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (isDegraded)
                        return; // 获取不到高清图
                    if (photo)
                    {
                        [photos replaceObjectAtIndex:i withObject:photo];
                    }
                    if (info)
                    {
                        [infoArr replaceObjectAtIndex:i withObject:info];
                    }
                    if (model.asset)
                    {
                        [assets replaceObjectAtIndex:i withObject:model.asset];
                    }
                    for (id item in photos)
                    {
                        if ([item isKindOfClass:[NSNumber class]])
                        {
                            return;
                        }
                    }
                    if (noShowAlert)
                    {
                        [weakSelf _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:NO];
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
    }
    
    if (vc.selectedModels.count <= 0)  //用户没有选择的情况下直接返回空数据
    {
        [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:NO];
    }
}

//设置返回的数据
- (void)_didGetAllPhotos:(NSArray *)photos asset:(NSArray *)asset infos:(NSArray *)infos isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    [self.lodingView removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:^{
        //  block 方式进行数据返回
        IJSImagePickerController *vc = (IJSImagePickerController *) self.navigationController;
        if (vc.didFinishUserPickingImageHandle)
        {
            vc.didFinishUserPickingImageHandle(photos, nil, asset, infos, isSelectOriginalPhoto,IJSPImageType);
        }
        // 代理方式
        if ([vc.imagePickerDelegate respondsToSelector:@selector(imagePickerController:isSelectOriginalPhoto:didFinishPickingPhotos:assets:infos:avPlayers: sourceType:)])
        {
            [vc.imagePickerDelegate imagePickerController:vc isSelectOriginalPhoto:isSelectOriginalPhoto didFinishPickingPhotos:photos assets:asset infos:infos avPlayers:nil sourceType:IJSPImageType];
        }
    }];
}
#pragma mark 取消
- (void)_cancleSelectImage
{
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    if (vc.didCancelHandle)
    {
        vc.didCancelHandle();
    }
    if ([vc respondsToSelector:@selector(imagePickerControllerDidCancel:)])
    {
        [vc.imagePickerDelegate imagePickerControllerWhenDidCancle];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*-----------------------------------UI-------------------------------------------------------*/
#pragma mark - UI
// 创建底部的工具视图
- (void)_createrBottomToolBarUI
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle localizedStringForKey:@"Cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(_cancleSelectImage)];
    // 导航栏左右按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 70, 15);
    [leftButton setImage:[[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"navi_back@2x" imageType:@"png"] imageAntialias] forState:UIControlStateNormal];
    leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [leftButton addTarget:self action:@selector(_cleanModelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:[NSBundle localizedStringForKey:@"Back"] forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    //背景
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.js_height - 44, self.view.js_width, 44)];
    toolBarView.backgroundColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
    [self.view addSubview:toolBarView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //预览
    UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previewButton.frame = CGRectMake(5, 5, 70, 30);
    [previewButton setTitle:[NSBundle localizedStringForKey:@"Preview"] forState:UIControlStateNormal];
    [previewButton setTitleColor:[IJSFColor colorWithR:98 G:103 B:109 alpha:1] forState:UIControlStateNormal];
    [previewButton addTarget:self action:@selector(_pushPreViewPhoto) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:previewButton];
    self.previewButton = previewButton;
    
    // 完成
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.frame = CGRectMake(self.view.js_width - 70, 5, 70, 30); //27 81 28
    finishButton.backgroundColor = [IJSFColor colorWithR:27 G:81 B:28 alpha:1];
    finishButton.layer.masksToBounds = YES;
    finishButton.layer.cornerRadius = 2;
    [finishButton setTitle:[NSBundle localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    [finishButton setTitleColor:[IJSFColor colorWithR:77 G:128 B:78 alpha:1] forState:UIControlStateNormal];
    [finishButton addTarget:self action:@selector(_finishSelectImageDisMiss) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:finishButton];
    self.finishButton = finishButton;
}
/// 创建 collection
- (void)_createrCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    if (self.columnNumber > 1)
    {
        self.itemHeight = (self.view.js_width - (self.columnNumber + 1) * cellMargin) / self.columnNumber;
    }
    if (self.columnNumber == 1)
    {
        self.itemHeight = JSScreenHeight;
    }
    layout.itemSize = CGSizeMake(self.itemHeight, self.itemHeight);
    layout.minimumInteritemSpacing = cellMargin;
    layout.minimumLineSpacing = cellMargin;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(cellMargin, NavigationHeight, JSScreenWidth - 2 * cellMargin, JSScreenHeight - NavigationHeight - TabbarHeight) collectionViewLayout:layout];
    collection.backgroundColor = [UIColor whiteColor];
    collection.dataSource = self;
    collection.delegate = self;
    collection.alwaysBounceHorizontal = NO;
    [self.view addSubview:collection];
    self.showCollectioView = collection;
    [self.showCollectioView registerClass:[IJSPhotoPickerCell class] forCellWithReuseIdentifier:CellID];
}

#pragma mark 私有方法
// 数据解析
- (void)_createrData
{
    [[IJSImageManager shareManager] getAssetsFromFetchResult:self.albumModel.result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<IJSAssetModel *> *models) {
        self.assetModelArr = [NSMutableArray arrayWithArray:models];
        [self.assetModelArr enumerateObjectsUsingBlock:^(IJSAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.onlyOneTag = idx;
        }];
        [self.showCollectioView reloadData];
        if (self.assetModelArr.count != 0)
        {
            NSInteger rows = (_assetModelArr.count - 1) / self.columnNumber + 1;
            self.showCollectioView.contentOffset = CGPointMake(0, self.itemHeight * rows);
        }
    }];
}

// 根据cell选中的数量重置toorbar的状态
- (void)_resetToorBarStatus
{
    IJSImagePickerController *vc = (IJSImagePickerController *) self.navigationController;
    if (vc.selectedModels.count > 0) // 有数据
    {
        [self.previewButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
        [self.finishButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
        self.finishButton.backgroundColor = [IJSFColor colorWithR:40 G:170 B:40 alpha:1];
        [_finishButton setTitle:[NSString stringWithFormat:@"%@(%lu)", [NSBundle localizedStringForKey:@"Done"], (unsigned long) vc.selectedModels.count] forState:UIControlStateNormal];
        self.finishButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    else
    {
        [_previewButton setTitleColor:[IJSFColor colorWithR:98 G:103 B:109 alpha:1] forState:UIControlStateNormal];
        [_finishButton setTitleColor:[IJSFColor colorWithR:77 G:128 B:78 alpha:1] forState:UIControlStateNormal];
        _finishButton.backgroundColor = [IJSFColor colorWithR:27 G:81 B:28 alpha:1];
        [_finishButton setTitle:[NSBundle localizedStringForKey:@"Done"] forState:UIControlStateNormal];
        self.finishButton.titleLabel.font = [UIFont systemFontOfSize:17];
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

#pragma mark - UIViewControllerPreviewingDelegate method
//peek(预览模式)
- (nullable UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if (iOS9Later)
    {
        NSIndexPath *indexPath = [self.showCollectioView indexPathForCell:(IJSPhotoPickerCell *) [previewingContext sourceView]];
        //设定预览的界面
        IJS3DTouchController *touchVC = [[IJS3DTouchController alloc] init];
        touchVC.model = self.assetModelArr[indexPath.row];
        touchVC.preferredContentSize = CGSizeMake(0.0f, 500.0f);
        CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 40);
        previewingContext.sourceRect = rect;
        return touchVC;
    }
    return nil;
}

#pragma mark 清空数据
- (void)_cleanModelButtonAction
{
    IJSImagePickerController *vc = (IJSImagePickerController *) self.navigationController;
    vc.selectedModels = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    JSLog(@"开始touch");
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// 刷新数据
//         [weakSelf.showCollectioView reloadItemsAtIndexPaths:@[index]];







@end
