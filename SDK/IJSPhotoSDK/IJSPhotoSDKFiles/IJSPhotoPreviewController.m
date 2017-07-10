//
//  IJSPhotoPreviewController.m
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSPhotoPreviewController.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"
#import "UIView+IJSPhotoLayout.h"
#import "NSBundle+IJSPhotoBundle.h"
#import "IJSConst.h"
#import "IJSPreviewImageCell.h"
#import "IJSImageManager.h"

#import "IJSImagePickerController.h"
#import "IJSPhotoPickerController.h"

#import "IJS3DTouchController.h"


static NSString *const cellID = @"IJSPreviewImageCell";
static NSString *const jsSelectedCell = @"IJSSelectedCell";
@interface IJSPhotoPreviewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIViewControllerPreviewingDelegate>
{
    BOOL _toHiddToolStatus; // 改变工具的状态
    BOOL _buttonSelected;   // button的改变状态
    BOOL _selectedCollectionHidden; // 隐藏选中的selected
    BOOL _isFirstAppear;// 第一次出现
    BOOL _isPlaying;     //正在播放
}
/* 编辑 */
@property(nonatomic,weak) UIButton *editButton;
/* 完成 */
@property(nonatomic,weak) UIButton *finishButton;
/* collection */
@property(nonatomic,weak) UICollectionView *showCollectioView;
/* 解析的数据 */
@property(nonatomic,strong) NSMutableArray *imageDataArr;
/* 工具条 */
@property(nonatomic,weak) UIView *toolBarView;
/* 导航条后边的button */
@property(nonatomic,weak) UIButton *rightButton;
/* 用户选中了的collectionview */
@property(nonatomic,weak) UICollectionView *selectedCollection;
/* 记录一下上点击的坐标 */
@property(nonatomic,assign) NSIndexPath *didClinkIndex;
/* 导航控制器 */
@property(nonatomic,strong) IJSImagePickerController *imagePickerController;
/* 当前可见的cell */
@property(nonatomic,weak) IJSPreviewImageCell *touchCell;
/* 3dtouch */
@property(nonatomic,weak) UIGestureRecognizer *gesture;
/* 播放视频的button */
@property(nonatomic,strong) UIButton *videoPlayButton;
/* 播放控制器 */
@property(nonatomic,strong) AVPlayer *player;

@end

@implementation IJSPhotoPreviewController

-(NSMutableArray *)imageDataArr
{
    if (!_imageDataArr)
    {
        _imageDataArr =[NSMutableArray array];
    }
    return _imageDataArr;
}
-(IJSImagePickerController *)imagePickerController
{
    if (!_imagePickerController)
    {
        _imagePickerController = (IJSImagePickerController *)self.navigationController;
    }
    return _imagePickerController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =  [UIColor blackColor];
    _toHiddToolStatus = YES;
    _isFirstAppear = YES;
    _isPlaying = NO;
    if (self.selectedModels.count > 0)
   {
       _selectedCollectionHidden = NO;
   }else{
       _selectedCollectionHidden = YES;
   }

    [self _createdUI];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.touchCell stopLivePhotos];
    [self.player pause];
}

/*-----------------------------------collection-------------------------------------------------------*/
#pragma mark collectionview delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.showCollectioView)
    {
        if (self.isPreviewButton) return self.previewAssetModelArr.count;
        return self.allAssetModelArr.count;
    }else{
        return self.selectedModels.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == self.showCollectioView)
    {
        IJSPreviewImageCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        IJSAssetModel *assetModel;
        if (self.isPreviewButton)
        {
            assetModel = self.previewAssetModelArr[indexPath.row];
        }else{
            assetModel = self.allAssetModelArr[indexPath.row];
        }
        
        assetModel.networkAccessAllowed = self.imagePickerController.networkAccessAllowed;
        cell.assetModel = assetModel;
        if (iOS9Later)
        {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
            {
                [self registerForPreviewingWithDelegate:(id)self sourceView:cell];
            }
        }
         // 隐藏状态栏
        __weak typeof (cell) weakCell = cell;
        __weak typeof (self) weakSelf = self;
        cell.hiddenNavigationAndToos = ^(BOOL hiddenToolsStatus) {
            weakSelf.videoPlayButton = weakCell.videoView.playButton;
            weakSelf.player = weakCell.videoView.player;
            _toHiddToolStatus = hiddenToolsStatus;
            if (hiddenToolsStatus)
            {
                [self isHiddenStatus:YES];
                [weakCell.videoView.player play];
            } else {
                [self isHiddenStatus:NO];
                [weakCell.videoView.player pause];
            }
        };
        
        return cell;
    }else{ //选中的cell

        IJSSelectedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:jsSelectedCell forIndexPath:indexPath];
        IJSAssetModel *model = self.selectedModels[indexPath.row];
        cell.pushSelectedIndex = self.pushSelectedIndex;  //首次进来的坐标
        model.isFirstAppear = _isFirstAppear;
        cell.selectedModel = model;
        if (self.isPreviewButton) self.didClinkIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        if (self.didClinkIndex && _isFirstAppear)
        {
            IJSSelectedCell *firstAppearCell = (IJSSelectedCell *)[collectionView cellForItemAtIndexPath:self.didClinkIndex];
            [self _resetAssetCellStatus:firstAppearCell];
            if (self.selectedModels.count ==1) [self _resetAssetCellStatus:cell];
        }
        return cell;
    }
    return nil;
}
#pragma mark 点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.showCollectioView) // 展示的cell
   {
   }
    else if(collectionView == self.selectedCollection)
   {
       _isFirstAppear = NO;
       
       NSArray *cellArr = [collectionView visibleCells];
       for (IJSSelectedCell *allCell in cellArr)
       {
           [self _cleanAssetCellStatus:allCell];
       }
       self.didClinkIndex = indexPath;
       IJSSelectedCell *cell = (IJSSelectedCell *)[collectionView cellForItemAtIndexPath:indexPath];
       IJSAssetModel *model = self.selectedModels[indexPath.row];
       if (self.isPreviewButton)
       {
           for (int i = 0; i < self.previewAssetModelArr.count; i++)
           {
               if (self.selectedModels[indexPath.row] == self.previewAssetModelArr[i])
               {
                   self.showCollectioView.contentOffset = CGPointMake(JSScreenWidth * i, 0);
                   break;
               }
           }
       }else{
           self.showCollectioView.contentOffset = CGPointMake(JSScreenWidth * model.onlyOneTag, 0);
       }

       [self _resetAssetCellStatus:cell];
       // 刷新导航条
       [self _resetRightButtonStatus:model.cellButtonNnumber];
   }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.showCollectioView)
    {
        IJSPreviewImageCell *preciewCell = (IJSPreviewImageCell *)cell;
        [preciewCell.scrollView setZoomScale:1.0];
    }
}

#pragma mark 滚动结束
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    if (scrollView == self.showCollectioView)
    {
        // 计算当前的下标值
        NSInteger index = targetContentOffset->x / JSScreenWidth;
        IJSAssetModel *model = self.allAssetModelArr[index];
        if (model.type == JSAssetModelMediaTypeVideo)
        {
            self.rightButton.hidden = YES;
        }else{
            self.rightButton.hidden = NO;
        }
        NSArray *cellArr = [self.selectedCollection visibleCells];
        for (IJSSelectedCell *allCell in cellArr)
        {
            [self _cleanAssetCellStatus:allCell];
        }
       
        if (self.isPreviewButton) // 如果是预览点击进来的
        {
            [self _resetRightButtonStatus:self.previewAssetModelArr[index].cellButtonNnumber];
            
            if (self.previewAssetModelArr[index].cellButtonNnumber ==0)
            {
                _rightButton.titleLabel.text = nil;
            
                [self _cleanRightButtonStatus];
            }
            
            for (int i = 0; i < self.selectedModels.count; i++)
            {
                if (self.selectedModels[i] == self.previewAssetModelArr[index])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i  inSection:0];
                    [self.selectedCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                    IJSSelectedCell *cell = (IJSSelectedCell *)[self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];

                }
            }
          
        }else{   //正常点击进来
        
            for (IJSAssetModel *selectModel in self.selectedModels)
            {
                if (selectModel.onlyOneTag == index)  //对应
                {
            
                    [self _resetRightButtonStatus:selectModel.cellButtonNnumber];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectModel.cellButtonNnumber - 1  inSection:0];
                    [self.selectedCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                    
                    IJSSelectedCell *cell = (IJSSelectedCell *)[self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }else{
                    _rightButton.titleLabel.text = nil;
                    [self _cleanRightButtonStatus];

                }
            }
        }
    }
    else if(scrollView == self.selectedCollection)
    {

        NSArray *cellArr = [self.selectedCollection visibleCells];
        for (IJSSelectedCell *allCell in cellArr)
        {
            [self _cleanAssetCellStatus:allCell];
        }
    
        NSInteger index = self.showCollectioView.contentOffset.x / JSScreenWidth;
    
        if (self.isPreviewButton)
        {
            for (int i = 0 ; i < self.selectedModels.count; i++)
            {
                if (self.selectedModels[i] == self.previewAssetModelArr[index])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i  inSection:0];
                    IJSSelectedCell *cell = (IJSSelectedCell *)[self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }
            }
        }else{
            for (IJSAssetModel *selectModel in self.selectedModels)
            {
                if (selectModel.onlyOneTag == index)  //对应
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectModel.cellButtonNnumber - 1  inSection:0];
                    IJSSelectedCell *cell = (IJSSelectedCell *)[self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }
            }
        }
    }
    // 不要让 playbutton隐藏
    [self isHiddenStatus:NO];
}

// 自动滚动 ---导航条添加按钮执行 处理底部选中数组逻辑cell
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.selectedCollection)
    {
        NSArray *cellArr = [self.selectedCollection visibleCells];
        for (IJSSelectedCell *allCell in cellArr)
        {
            [self _cleanAssetCellStatus:allCell];
        }
        
        NSInteger index = self.showCollectioView.contentOffset.x / JSScreenWidth;
        
        if (self.isPreviewButton)
        {
            for (int i = 0; i < self.selectedModels.count ; i++)
            {
                if (self.selectedModels[i] == self.previewAssetModelArr[index])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i  inSection:0];
                    IJSSelectedCell *cell = (IJSSelectedCell *)[self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }
            }
        }else{
            for (IJSAssetModel *selectModel in self.selectedModels)
            {
                if (selectModel.onlyOneTag == index)  //对应
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectModel.cellButtonNnumber - 1  inSection:0];
                    IJSSelectedCell *cell = (IJSSelectedCell *)[self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }
            }
        }
    }

}
// 滚动执行
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.touchCell stopLivePhotos];
    [self.player pause];
    _toHiddToolStatus = YES;
}



/*-----------------------------------UI-------------------------------------------------------*/
#pragma mark UI
-(void)_createdUI
{
    
   //中间的collectionview
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(JSScreenWidth, JSScreenHeight);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *showCollectioView =[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, JSScreenWidth , JSScreenHeight) collectionViewLayout:layout];
    showCollectioView.backgroundColor =  [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    showCollectioView.alwaysBounceHorizontal = YES;
    showCollectioView.showsVerticalScrollIndicator = NO;
    showCollectioView.showsHorizontalScrollIndicator = NO;
    showCollectioView.pagingEnabled = YES;
    [self.view addSubview:showCollectioView];
    showCollectioView.dataSource = self;
    showCollectioView.delegate = self;
    self.showCollectioView = showCollectioView;
    self.showCollectioView.contentOffset = CGPointMake(JSScreenWidth * self.pushSelectedIndex - 1, 0);
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.pushSelectedIndex inSection:0];
    [self.showCollectioView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    [self.showCollectioView registerClass:[IJSPreviewImageCell class] forCellWithReuseIdentifier:cellID];
    
    // 显示选中的collection
    UICollectionViewFlowLayout *selectedLayout = [[UICollectionViewFlowLayout alloc]init];
    selectedLayout.itemSize = CGSizeMake(80, 80);
    selectedLayout.minimumInteritemSpacing = 0;
    selectedLayout.minimumLineSpacing = 0;
    selectedLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *selectedCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(2, JSScreenHeight - 124, JSScreenWidth, 80)collectionViewLayout:selectedLayout];
    self.selectedCollection = selectedCollection;
    selectedCollection.backgroundColor =  [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    selectedCollection.alwaysBounceHorizontal = YES;
    selectedCollection.showsVerticalScrollIndicator = NO;
    selectedCollection.showsHorizontalScrollIndicator = NO;
   [self.view addSubview:selectedCollection];
    selectedCollection.dataSource = self;
    selectedCollection.delegate = self;
    
    [self.selectedCollection registerClass:[IJSSelectedCell class] forCellWithReuseIdentifier:jsSelectedCell];
    if (_selectedCollectionHidden)
    {
        self.selectedCollection.hidden = YES;
    }else{
        self.selectedCollection.hidden = NO;
    }
    
    //工具背景
    UIView *toolBarView =[[UIView alloc]initWithFrame:CGRectMake(0, self.view.js_height - 44, self.view.js_width, 44)];
    toolBarView.backgroundColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    [self.view addSubview:toolBarView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.toolBarView = toolBarView;
    
    //编辑
    UIButton *editButton =[UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(5, 5, 50, 30);
    [editButton setTitle:[NSBundle localizedStringForKey:@"Edit"] forState:UIControlStateNormal];
     [editButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(_editPhotoAction) forControlEvents:UIControlEventTouchUpInside];
//    [toolBarView addSubview:editButton];
    self.editButton = editButton;
    
    // 完成
    UIButton *finishButton =[UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.frame = CGRectMake(self.view.js_width - 55, 5, 50, 30);   //27 81 28
    finishButton.layer.masksToBounds = YES;
    finishButton.layer.cornerRadius = 2;
    [finishButton setTitle:[NSBundle localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    [finishButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
    finishButton.backgroundColor =[IJSFColor colorWithR:40 G:170 B:40 alpha:1];
    [finishButton addTarget:self action:@selector(_finishSelectImageDisMiss) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:finishButton];
    self.finishButton = finishButton;
    [self _resetToorBarStatus];
    
    // 导航栏左右按钮
    UIButton *leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 20, 20);
    [leftButton setImage:[[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"navi_back@2x" imageType:@"png"] imageAntialias]  forState:UIControlStateNormal];
    leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [leftButton addTarget:self action:@selector(callBackButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    
    UIButton *rightButton =[UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton = rightButton;
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"]  forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"preview_number_icon@2x" imageType:@"png"] forState:UIControlStateSelected];
    rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [rightButton addTarget:self action:@selector(_selectImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
 
    if (self.isPreviewButton)
    {

        [rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"preview_number_icon@2x" imageType:@"png"] forState:UIControlStateNormal];
         [rightButton setTitle:@"1" forState:UIControlStateNormal];

    }else{
        // 正常进来
        if (self.selectedModels.count > 0)
        {
            [rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"] forState:UIControlStateNormal];
            for (IJSAssetModel *model in self.selectedModels)
            {
                if (model.onlyOneTag == self.pushSelectedIndex)
                {
                    [self _resetRightButtonStatus:model.cellButtonNnumber];
                    
                    NSInteger index = model.cellButtonNnumber ;
                    if (index > 4) {index = model.cellButtonNnumber - 2;}
                    
                    self.selectedCollection.contentOffset = CGPointMake(80 * index, 0);
                    if (self.selectedCollection.contentOffset.x <= 160)
                    {
                        self.selectedCollection.contentOffset = CGPointMake(0, 0);
                    }
                    break;
                }
            }
        }
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    IJSAssetModel *model = self.allAssetModelArr[self.pushSelectedIndex];
    if (model.type == JSAssetModelMediaTypeVideo)
    {
        self.rightButton.hidden = YES;
    }else{
        self.rightButton.hidden = NO;
    }
}

/*-----------------------------------点击事件-------------------------------------------------------*/
#pragma mark 点击事件
// 返回
-(void)callBackButtonAction
{

    for (UIViewController *viewc in self.navigationController.childViewControllers)
    {
        if ([viewc isKindOfClass:[IJSPhotoPickerController class]])
        {
            IJSPhotoPickerController *vc = (IJSPhotoPickerController *)viewc;
            if (vc.callBack)
            {
                vc.callBack(self.selectedModels,self.allAssetModelArr);
            }
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

// 编辑按钮
-(void) _editPhotoAction
{

}

// 完成选择
-(void) _finishSelectImageDisMiss
{
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    vc.selectedModels = self.selectedModels;
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
    NSMutableArray *avPlayers = [NSMutableArray array];
    for (NSInteger i = 0; i < vc.selectedModels.count; i++)
    {
        [photos addObject:@1];
        [assets addObject:@1];
        [infoArr addObject:@1];
        [avPlayers addObject:@1];
    }
    // 解析数据并返回
     BOOL noShowAlert = YES;
    
    if (vc.selectedModels.count == 0) // 用户没有选中图片或者视频
    {
        [photos addObject:@1];
        [assets addObject:@1];
        [infoArr addObject:@1];
        [avPlayers addObject:@1];
        
       NSIndexPath *firstIndexPath = [[self.showCollectioView indexPathsForVisibleItems] firstObject];
        IJSAssetModel *model = self.allAssetModelArr[firstIndexPath.row];
        JSAssetModelSourceType type = model.type;
        
        if (type == JSAssetModelMediaTypeVideo)//当前显示的是视频资源
        {
            [self _getBackThumbnailDataPhotos:photos assets:assets infoArr:infoArr avPlayers:avPlayers model:model index:0 networkAccessAllowed:NO noAlert:noShowAlert vc:vc];
        } else {  // 当前显示的是非视频资源
            if (vc.allowPickingOriginalPhoto) // 原图
            {
                [self _getBackOriginalDataPhotos:photos assets:assets infoArr:infoArr avPlayers:nil model:model index:0];
            } else {   //缩略图
                
                [self _getBackThumbnailDataPhotos:photos assets:assets infoArr:infoArr avPlayers:nil model:model index:0 networkAccessAllowed:YES noAlert:noShowAlert vc:vc];
            }
        }
    }else{     // 已经选中了多图
        
        if (vc.allowPickingOriginalPhoto)  // 获取本地原图
        {
            for (int i = 0; i < vc.selectedModels.count; i++)
            {
                IJSAssetModel *model = vc.selectedModels[i];
                [self _getBackOriginalDataPhotos:photos assets:assets infoArr:infoArr avPlayers:nil model:model index:i];
            }
        }else{   //缩略图,默认是828
            
            for (int i = 0; i < vc.selectedModels.count; i++)
            {
                IJSAssetModel *model = vc.selectedModels[i];
                 [self _getBackThumbnailDataPhotos:photos assets:assets infoArr:infoArr avPlayers:avPlayers model:model index:i networkAccessAllowed:YES noAlert:noShowAlert vc:vc];
            }
        }
    }
     [self dismissViewControllerAnimated:YES completion:nil];
}
/// 获取资源的方法---缩略图
-(void)_getBackThumbnailDataPhotos:(NSMutableArray *)photos
                     assets:(NSMutableArray *)assets
                    infoArr:(NSMutableArray *)infoArr
                  avPlayers:(NSMutableArray *)avPlayers
                             model:(IJSAssetModel *)model
                             index:(NSInteger)index
        networkAccessAllowed:(BOOL)networkAccessAllowed
                 noAlert:(BOOL)noAlert
                          vc:(IJSImagePickerController *)vc
{
    __block BOOL noShowAlert = noAlert;
    
    if (model.type == JSAssetModelMediaTypeVideo)
    {
        [[IJSImageManager shareManager] getVideoWithAsset:model.asset networkAccessAllowed:networkAccessAllowed progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            
        } completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            if (playerItem)
            {
                [avPlayers   replaceObjectAtIndex:index withObject:playerItem];
            }
            if (info)  [infoArr  replaceObjectAtIndex:index withObject:info];
            [assets replaceObjectAtIndex:index withObject:model.asset];
            
            for (id item in avPlayers) { if ([item isKindOfClass:[NSNumber class]]) return; }
            
            [self _didGetAllPhotos:nil asset:assets infos:infoArr isSelectOriginalPhoto:YES avPlayers:avPlayers];
            
        }];
        
    }else{
    
        [[IJSImageManager shareManager]getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return ;  // 获取不到高清图
            if (photo)
            {
                [photos replaceObjectAtIndex:index withObject:photo];
            }
            if (info)  [infoArr replaceObjectAtIndex:index withObject:info];
            [assets replaceObjectAtIndex:index withObject:model.asset];
            
            for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
            
            if (noShowAlert)
            {
                [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:NO avPlayers:nil];
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
/// 获取原图
-(void)_getBackOriginalDataPhotos:(NSMutableArray *)photos
                           assets:(NSMutableArray *)assets
                          infoArr:(NSMutableArray *)infoArr
                        avPlayers:(NSMutableArray *)avPlayers
                            model:(IJSAssetModel *)model
                            index:(NSInteger)index
{

    [[IJSImageManager shareManager]getOriginalPhotoWithAsset:model.asset newCompletion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (isDegraded) return ;  // 获取不到高清图
        if (photo)
        {
            [photos replaceObjectAtIndex:index withObject:photo];
        }
        if (info)  [infoArr replaceObjectAtIndex:index withObject:info];
        [assets replaceObjectAtIndex:index withObject:model.asset];
        
        for (id item in photos) { if ([item isKindOfClass:[NSNumber class]]) return; }
        
        [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:YES avPlayers:nil];

    }];
}

//设置返回的数据
- (void)_didGetAllPhotos:(NSArray *)photos asset:(NSArray *)asset infos:(NSArray *)infos isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto avPlayers:(NSArray *)avPlayers
{
    //  block 方式进行数据返回
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    if (vc.didFinishUserPickingImageHandle)
    {
        vc.didFinishUserPickingImageHandle(photos,avPlayers, asset, infos, isSelectOriginalPhoto);
    }
    // 代理方式
    if ([vc.imagePickerDelegate respondsToSelector:@selector(imagePickerController:isSelectOriginalPhoto:didFinishPickingPhotos:assets:infos:avPlayers:)])
    {
       [vc.imagePickerDelegate imagePickerController:vc isSelectOriginalPhoto:isSelectOriginalPhoto didFinishPickingPhotos:photos assets:asset infos:infos avPlayers:avPlayers];
    }
}

// 选图片
-(void)_selectImageButtonAction:(UIButton *)button
{
    [button addSpringAnimation];
    _isFirstAppear = NO;
    NSInteger index = self.showCollectioView.contentOffset.x / JSScreenWidth;
    if (self.isPreviewButton)
    {//1, 处理预览模式下的逻辑
        if (self.rightButton.titleLabel.text == nil)  //增加
        {
            IJSAssetModel *model = self.previewAssetModelArr[index];
            [self.selectedModels addObject:model];
            [self.selectedCollection reloadData];
            
            // 增加属性并替换掉
            model.isSelectedModel = YES;
            model.cellButtonNnumber = self.selectedModels.count;
            model.didClickModelArr = self.selectedModels;
            [self.allAssetModelArr replaceObjectAtIndex:model.onlyOneTag withObject:model];

            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedModels.count -1 inSection:0];
            if (self.selectedModels.count <=5) self.selectedCollection.contentOffset= CGPointMake(-0.5, 0);
            [self.selectedCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            
            [self _resetRightButtonStatus:self.selectedModels.count];
            
        }else{  //删除
            self.rightButton.titleLabel.text = nil;
            for (IJSAssetModel *model in self.selectedModels)
            {
                
                if (model == self.previewAssetModelArr[index])
                {
                    [self.selectedModels removeObject:model];
                    [self.selectedCollection reloadData];
                
                    model.cellButtonNnumber = 0;
                    model.isSelectedModel = NO;
                    model.didClickModelArr = self.selectedModels;
                    
                    [self.allAssetModelArr replaceObjectAtIndex:model.onlyOneTag withObject:model];
                    [self.previewAssetModelArr replaceObjectAtIndex:index withObject:model];

                    [self _cleanRightButtonStatus];
                    break;
                }
            }
            // 重新赋值
            for (int i = 0; i< self.selectedModels.count; i++)
            {
                IJSAssetModel *tempModel =  self.selectedModels[i];
                tempModel.cellButtonNnumber  = i +1 ;
            }
        }
    }
    // 2, 正常点击跳转的逻辑处理
    else
    {
        
        if (_rightButton.titleLabel.text == nil)  //没有选中 选中添加
        {
            
            if (self.selectedModels.count < self.imagePickerController.maxImagesCount) //还没有超标
            {
                IJSAssetModel *model = self.allAssetModelArr[index];
                [self.selectedModels addObject:model];
                [self.selectedCollection reloadData];
                // 增加属性并替换掉
                model.isSelectedModel = YES;
                model.cellButtonNnumber = self.selectedModels.count;
                model.didClickModelArr = self.selectedModels;
                [self.allAssetModelArr replaceObjectAtIndex:index withObject:model];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedModels.count -1 inSection:0];
                if (self.selectedModels.count <=5) self.selectedCollection.contentOffset= CGPointMake(-0.5, 0);
                [self.selectedCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                [self _resetRightButtonStatus:self.selectedModels.count];
                
            }else{  //超标了
                NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a maximum of %zd photos"], self.imagePickerController.maxImagesCount];
                [self.imagePickerController showAlertWithTitle:title];
            }
        }else{  //删除
            
            self.rightButton.titleLabel.text = nil;
            for (IJSAssetModel *model in self.selectedModels)
            {
                if (model.onlyOneTag == index)
                {
                    [self.selectedModels removeObject:model];
                    [self.selectedCollection reloadData];
                    // 替换掉被删除的model
                    model.cellButtonNnumber = 0;
                    model.isSelectedModel = NO;
                    model.didClickModelArr = self.selectedModels;

                    [self.allAssetModelArr replaceObjectAtIndex:index withObject:model];
                    [self _cleanRightButtonStatus];
                    break;
                }
            }
            for (int i = 0; i< self.selectedModels.count; i++)
            {
                IJSAssetModel *tempModel =  self.selectedModels[i];
                tempModel.cellButtonNnumber  = i +1 ;
            }
        }
    }
    
    if (self.selectedModels.count > 0)
    {
        self.selectedCollection.hidden = NO;
    }else{
        self.selectedCollection.hidden = YES;
    }
    
    [self _resetToorBarStatus];
}

/*-----------------------------------私有方法-------------------------------------------------------*/
#pragma mark 私有方法
// 根据cell选中的数量重置toorbar的状态
-(void)_resetToorBarStatus
{
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    vc.selectedModels = self.selectedModels;
    if (vc.selectedModels.count > 0) // 有数据
    {
        [_finishButton setTitle:[NSString stringWithFormat:@"%@(%lu)",[NSBundle localizedStringForKey:@"Done"],(unsigned long)vc.selectedModels.count] forState:UIControlStateNormal];
        self.finishButton.titleLabel.font =[UIFont systemFontOfSize:13];
        [_editButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
    }
    else
    {
        [_finishButton setTitle:[NSBundle localizedStringForKey:@"Done"] forState:UIControlStateNormal];
        self.finishButton.titleLabel.font =[UIFont systemFontOfSize:17];
    }
}
// 清楚cell上的状态
-(void)_cleanAssetCellStatus:(IJSSelectedCell *)cell
{
    cell.backImageView.layer.borderWidth = 0;
    cell.backImageView.layer.cornerRadius = 0;
    cell.backImageView.clipsToBounds=YES;
}
// 添加边框
-(void)_resetAssetCellStatus:(IJSSelectedCell *)cell
{
    cell.backImageView.layer.borderWidth = 2;
    cell.backImageView.layer.cornerRadius = 3;
    cell.backImageView.layer.borderColor=[[UIColor greenColor]CGColor];
    cell.backImageView.clipsToBounds=YES;
}
// 是否隐藏状态栏
-(void)isHiddenStatus:(BOOL)state
{
    if (state)
    {
        self.toolBarView.hidden = YES;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.selectedCollection.hidden = YES;
        self.videoPlayButton.hidden = YES;
    }else{
        self.videoPlayButton.hidden = NO;
        self.toolBarView.hidden = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.videoPlayButton.hidden = NO;
        if (self.selectedModels.count ==0)
        {
            self.selectedCollection.hidden = YES;
        }else{
            self.selectedCollection.hidden = NO;
        }
    }
}
// 清空导航条button的数据
-(void)_cleanRightButtonStatus
{
    [self.rightButton setTitle:nil forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"] forState:UIControlStateNormal];
}
// 重置导航条button的状态
-(void)_resetRightButtonStatus:(NSInteger) number
{
    [self.rightButton setTitle:[NSString stringWithFormat:@"%ld", (long)number] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"preview_number_icon@2x" imageType:@"png"] forState:UIControlStateNormal];
}

/*-----------------------------------3D Touch-------------------------------------------------------*/
#pragma mark - UIViewControllerPreviewingDelegate method
//peek(预览模式)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    [self.touchCell stopLivePhotos];
    IJSPreviewImageCell *cell = (IJSPreviewImageCell* )[self.showCollectioView visibleCells].firstObject; //[previewingContext sourceView]就是按压的那个视图
    if (cell.assetModel.type == JSAssetModelMediaTypeLivePhoto)
    {
        self.touchCell = cell;
        [cell playLivePhotos];
    }
    //获取按压的cell所在行，[previewingContext sourceView]就是按压的那个视图
    NSIndexPath *indexPath = [self.showCollectioView indexPathForCell:(IJSPreviewImageCell* )[previewingContext sourceView]];
    //设定预览的界面
    IJS3DTouchController *touchVC = [[IJS3DTouchController alloc] init];    
    touchVC.model = self.allAssetModelArr[indexPath.row];
    touchVC.preferredContentSize = CGSizeMake(0.0f,500.0f);
    //调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,40);
    previewingContext.sourceRect = rect;
    //返回预览界面
    return touchVC;
}

//pop（继续按压进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
//    IJS3DTouchController *childVC = [[IJS3DTouchController alloc] init];
//    [self.navigationController pushViewController:childVC animated:YES];
//     [self showViewController:viewControllerToCommit sender:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath  isEqual: @"state"])
    {
        NSInteger state = [change[NSKeyValueChangeNewKey] integerValue];
        switch (state)
        {
            case 1:
            case 3:
            case 5:
                [self.touchCell stopLivePhotos];
                break;
            case 4:
               [self.touchCell playLivePhotos];
                break;
            default:
                break;
        }
    }
}


-(void)dealloc
{
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
}

//  优化代码
//     IJSPreviewImageCell *cell = (IJSPreviewImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
//      self.videoPlayButton = cell.videoView.playButton;
//       self.player = cell.videoView.player;
//       __weak typeof (cell) weakCell = cell;
//       // 隐藏状态栏
//       cell.hiddenNavigationAndToos = ^(BOOL hiddenToolsStatus) {
//           _toHiddToolStatus = hiddenToolsStatus;
//           if (hiddenToolsStatus)
//           {
//                 [self isHiddenStatus:YES];
//                [weakCell.videoView.player play];
//           } else {
//                [self isHiddenStatus:NO];
//               [weakCell.videoView.player pause];
//           }
//       };

//       if (_toHiddToolStatus)
//       {
//           [cell.videoView.player play];
//           [self isHiddenStatus:YES];
//
//       }else{
//           [cell.videoView.player pause];
//           [self isHiddenStatus:NO];
//       }
//       _toHiddToolStatus = !_toHiddToolStatus;




@end
