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
#import "IJSConst.h"
#import "IJSPreviewImageCell.h"
#import "IJSImageManager.h"

#import "IJSImagePickerController.h"
#import "IJSPhotoPickerController.h"

#import "IJS3DTouchController.h"
#import "IJSImageManagerController.h"
#import "IJSSelectedCell.h"

#import "IJSEditSDK.h"

static NSString *const IJSShowCellID = @"IJSPreviewImageCell";
static NSString *const IJSSelectedCellID = @"IJSSelectedCell";

@interface IJSPhotoPreviewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerPreviewingDelegate, IJSPreviewImageCellDelegate>

@property (nonatomic, assign) BOOL toHiddToolStatus;              // 改变工具的状态
@property (nonatomic, assign) BOOL buttonSelected;                // button的改变状态
@property (nonatomic, assign) BOOL selectedCollectionHidden;      // 隐藏选中的selected
@property (nonatomic, assign) BOOL isFirstAppear;                 // 第一次出现
@property (nonatomic, assign) BOOL isPlaying;                     //正在播放
@property (nonatomic, weak) UIButton *editButton;                 /* 编辑 */
@property (nonatomic, weak) UIButton *finishButton;               /* 完成 */
@property (nonatomic, weak) UICollectionView *showCollectioView;  /* collection */
@property (nonatomic, strong) NSMutableArray *imageDataArr;       /* 解析的数据 */
@property (nonatomic, weak) UIView *toolBarView;                  /* 工具条 */
@property (nonatomic, weak) UIButton *rightButton;                /* 导航条后边的button */
@property (nonatomic, weak) UICollectionView *selectedCollection; /* 用户选中了的collectionview */
@property (nonatomic, assign) NSIndexPath *didClinkIndex;         /* 记录一下上点击的坐标 */
@property (nonatomic, weak) IJSPreviewImageCell *touchCell;       /* 当前可见的cell */
@property (nonatomic, weak) UIGestureRecognizer *gesture;         /* 3dtouch */
@property (nonatomic, strong) UIButton *videoPlayButton;          /* 播放视频的button */
@property (nonatomic, strong) AVPlayer *player;                   /* 播放控制器 */
@property (nonatomic, assign) BOOL isDoing;                       // 正在处理,稍等
@property (nonatomic, strong) IJSLodingView *lodingView;          // lodingView
@property (nonatomic, strong) NSTimer *listenPlayerTimer;         // 监听的时间
@property (nonatomic, assign) CGFloat videoDuraing;               // 视频长度
@property (nonatomic, strong) NSMutableArray *mapDataArr; // 贴图数据
@end

@implementation IJSPhotoPreviewController

- (NSMutableArray *)imageDataArr
{
    if (!_imageDataArr)
    {
        _imageDataArr = [NSMutableArray array];
    }
    return _imageDataArr;
}
- (NSMutableArray *)mapDataArr
{
    if (_mapDataArr == nil)
    {
        _mapDataArr = [NSMutableArray array];
    }
    return _mapDataArr;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _toHiddToolStatus = YES;
    _isFirstAppear = YES;
    _isPlaying = NO;
    _isDoing = NO;
    if (self.selectedModels.count > 0)
    {
        _selectedCollectionHidden = NO;
    }
    else
    {
        _selectedCollectionHidden = YES;
    }
    [self _setupMapData];
    [self _createdUI];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.touchCell stopLivePhotos];
    [self.player pause];
    [self removeListenPlayerTimer];
    [[IJSImageManager shareManager] stopCachingImagesFormAllAssets];
}
#pragma mark - 设置map数据
- (void)_setupMapData
{
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    if (vc.mapImageArr == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
        NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) )
        {  //不存在
            return;
        }

        [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
            IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
            [self.mapDataArr addObject:model];
            vc.mapImageArr = self.mapDataArr;
        }];
    }
}
/*-----------------------------------collection-------------------------------------------------------*/
#pragma mark collectionview delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.showCollectioView)
    {
        if (self.isPreviewButton)
        {
            return self.previewAssetModelArr.count; //预览模式
        }
        return self.allAssetModelArr.count;
    }
    else
    {
        return self.selectedModels.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.showCollectioView)
    {
        IJSPreviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IJSShowCellID forIndexPath:indexPath];
        IJSAssetModel *assetModel;
        if (self.isPreviewButton)
        {
            assetModel = self.previewAssetModelArr[indexPath.row];
        }
        else
        {
            assetModel = self.allAssetModelArr[indexPath.row];
        }
        assetModel.networkAccessAllowed = ((IJSImagePickerController *) self.navigationController).networkAccessAllowed;
        cell.assetModel = assetModel;
        cell.cellDelegate = self;
        return cell;
    }
    else
    { //选中的cell
        IJSSelectedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IJSSelectedCellID forIndexPath:indexPath];
        IJSAssetModel *model = self.selectedModels[indexPath.row];
        cell.pushSelectedIndex = self.pushSelectedIndex; //首次进来的坐标
        model.isFirstAppear = _isFirstAppear;
        if (self.isPreviewButton)
        {
            model.isPreviewButton = YES;
        }
        else
        {
            model.isPreviewButton = NO;
        }
        cell.selectedModel = model;
        
        return cell;
    }
    return nil;
}
/// cell 点击代理
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.showCollectioView) // 展示的cell
    {
    }
    else if (collectionView == self.selectedCollection)
    {
        [self _resetUpSelectedDidClick:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.showCollectioView)
    {
        IJSPreviewImageCell *preciewCell = (IJSPreviewImageCell *) cell;
        [preciewCell.scrollView setZoomScale:1.0];
    }
}
#pragma mark - IJSPreviewImageCellDelegate 代理方法
- (void)didClickCellToHiddenNavigationAndToosWithCell:(IJSPreviewImageCell *)cell hiddenToolsStatus:(BOOL)hiddenToolsStatus
{
    _toHiddToolStatus = hiddenToolsStatus;
    if (hiddenToolsStatus)
    {
        [self isHiddenStatus:YES];
    }
    else
    {
        [self isHiddenStatus:NO];
    }
    if (cell.assetModel.type == JSAssetModelMediaTypeVideo)   //视频单独处理
    {
        self.videoPlayButton = cell.videoView.playButton;
        self.player = cell.videoView.player;
        if (hiddenToolsStatus)
        {
            [cell.videoView.player play];
            self.videoPlayButton.hidden = YES;
            [self startListenPlayerTimer];
        }
        else
        {
            [cell.videoView.player pause];
            self.videoPlayButton.hidden = NO;
        }
        [[IJSImageManager shareManager] getAVAssetWithPHAsset:cell.assetModel.asset completion:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            self.videoDuraing = CMTimeGetSeconds([asset duration]);
        }];
    }
    // livePhoto
    if (cell.assetModel.type == JSAssetModelMediaTypeLivePhoto)
    {
        [cell stopLivePhotos];
        [cell playLivePhotos];
        self.touchCell = cell;
        // 考虑到内存性能问题,暂时不使用3DTouch
//        if (iOS9Later)
//        {
//            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
//            {
//                [self registerForPreviewingWithDelegate:(id) self sourceView:cell];
//            }
//        }
    }
}

#pragma mark - 滚动结束
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
        }
        else
        {
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
            if (self.previewAssetModelArr[index].cellButtonNnumber == 0)
            {
                _rightButton.titleLabel.text = nil;
                [self _cleanRightButtonStatus];
            }
            for (int i = 0; i < self.selectedModels.count; i++)
            {
                if (self.selectedModels[i] == self.previewAssetModelArr[index])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                    [self.selectedCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                    IJSSelectedCell *cell = (IJSSelectedCell *) [self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                }
            }
        }
        else
        { //正常点击进来
            
            for (IJSAssetModel *selectModel in self.selectedModels)
            {
                if (selectModel.onlyOneTag == index) //对应
                {
                    [self _resetRightButtonStatus:selectModel.cellButtonNnumber];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectModel.cellButtonNnumber - 1 inSection:0];
                    [self.selectedCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                    
                    IJSSelectedCell *cell = (IJSSelectedCell *) [self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }
                else
                {
                    _rightButton.titleLabel.text = nil;
                    [self _cleanRightButtonStatus];
                }
            }
        }
    }
    else if (scrollView == self.selectedCollection)
    {
        NSArray *cellArr = [self.selectedCollection visibleCells];
        for (IJSSelectedCell *allCell in cellArr)
        {
            [self _cleanAssetCellStatus:allCell];
        }
        
        NSInteger index = self.showCollectioView.contentOffset.x / JSScreenWidth;
        
        if (self.isPreviewButton)
        {
            for (int i = 0; i < self.selectedModels.count; i++)
            {
                if (self.selectedModels[i] == self.previewAssetModelArr[index])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                    IJSSelectedCell *cell = (IJSSelectedCell *) [self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }
            }
        }
        else
        {
            for (IJSAssetModel *selectModel in self.selectedModels)
            {
                if (selectModel.onlyOneTag == index) //对应
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectModel.cellButtonNnumber - 1 inSection:0];
                    IJSSelectedCell *cell = (IJSSelectedCell *) [self.selectedCollection cellForItemAtIndexPath:indexPath];
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
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.selectedCollection)
    {
        NSArray *cellArr = [self.selectedCollection visibleCells];
        for (IJSSelectedCell *allCell in cellArr)
        {
            [self _cleanAssetCellStatus:allCell];
        }
        // 其他开发者提出的建议修复 多图预览选中滑动上下图标不对应问题
        NSInteger index = self.showCollectioView.contentOffset.x / JSScreenWidth + 0.5;
        
        if (self.isPreviewButton)
        {
            for (int i = 0; i < self.selectedModels.count; i++)
            {
                if (self.selectedModels[i] == self.previewAssetModelArr[index])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                    IJSSelectedCell *cell = (IJSSelectedCell *) [self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }
            }
        }
        else
        {
            for (IJSAssetModel *selectModel in self.selectedModels)
            {
                if (selectModel.onlyOneTag == index) //对应
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:selectModel.cellButtonNnumber - 1 inSection:0];
                    IJSSelectedCell *cell = (IJSSelectedCell *) [self.selectedCollection cellForItemAtIndexPath:indexPath];
                    [self _resetAssetCellStatus:cell];
                    break;
                }
            }
        }
    }
}
// 滚动执行
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.touchCell stopLivePhotos];
    [self.player pause];
    _toHiddToolStatus = YES;
}
/*-----------------------------------UI-------------------------------------------------------*/
#pragma mark - UI
- (void)_createdUI
{
    // 不让内容下移动
    self.automaticallyAdjustsScrollViewInsets = NO;
    //中间的collectionview
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(JSScreenWidth, JSScreenHeight - IJSGStatusBarAndNavigationBarHeight - IJSGTabbarSafeBottomMargin - TabbarHeight);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *showCollectioView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, IJSGStatusBarAndNavigationBarHeight, JSScreenWidth,  JSScreenHeight -IJSGStatusBarAndNavigationBarHeight  - IJSGTabbarSafeBottomMargin - TabbarHeight) collectionViewLayout:layout];
    showCollectioView.backgroundColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
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
    
    [self.showCollectioView registerClass:[IJSPreviewImageCell class] forCellWithReuseIdentifier:IJSShowCellID];
    
    // 显示选中的collection
    UICollectionViewFlowLayout *selectedLayout = [[UICollectionViewFlowLayout alloc] init];
    selectedLayout.itemSize = CGSizeMake(80, 80);
    selectedLayout.minimumInteritemSpacing = 0;
    selectedLayout.minimumLineSpacing = 0;
    selectedLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *selectedCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, JSScreenHeight - 124, JSScreenWidth, 80) collectionViewLayout:selectedLayout];
    if (IJSGiPhoneX)
    {
        selectedCollection.frame = CGRectMake(0, JSScreenHeight - 124 - IJSGTabbarSafeBottomMargin, JSScreenWidth, 80);
    }
    self.selectedCollection = selectedCollection;
    selectedCollection.backgroundColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
    selectedCollection.alwaysBounceHorizontal = YES;
    selectedCollection.showsVerticalScrollIndicator = NO;
    selectedCollection.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:selectedCollection];
    selectedCollection.dataSource = self;
    selectedCollection.delegate = self;
    
    [self.selectedCollection registerClass:[IJSSelectedCell class] forCellWithReuseIdentifier:IJSSelectedCellID];
    
    if (_selectedCollectionHidden)
    {
        self.selectedCollection.hidden = YES;
    }
    else
    {
        self.selectedCollection.hidden = NO;
    }
    
    //工具背景
    UIView *toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.js_height - TabbarHeight, self.view.js_width, TabbarHeight)];
    toolBarView.backgroundColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
    [self.view addSubview:toolBarView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.toolBarView = toolBarView;
    if (IJSGiPhoneX)
    {
        toolBarView.frame = CGRectMake(0, JSScreenHeight - TabbarHeight - IJSGTabbarSafeBottomMargin, JSScreenWidth, TabbarHeight);
    }
    
    //编辑
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(5, 5, 70, 30);
    editButton.layer.masksToBounds = YES;
    editButton.layer.cornerRadius = 2;
    [editButton setTitle:[NSBundle localizedStringForKey:@"Edit"] forState:UIControlStateNormal];
    editButton.backgroundColor = [IJSFColor colorWithR:40 G:170 B:40 alpha:1];
    [editButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(_editPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:editButton];
    self.editButton = editButton;
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    if (vc.isHiddenEdit)
    {
        self.editButton.hidden = YES;
    }
    // 完成
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.frame = CGRectMake(self.view.js_width - 75, 5, 70, 30); //27 81 28
    finishButton.layer.masksToBounds = YES;
    finishButton.layer.cornerRadius = 2;
    [finishButton setTitle:[NSBundle localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    [finishButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
    finishButton.backgroundColor = [IJSFColor colorWithR:40 G:170 B:40 alpha:1];
    [finishButton addTarget:self action:@selector(_finishSelectImageDisMiss) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:finishButton];
    self.finishButton = finishButton;
    [self _resetToorBarStatus];
    
    // 左按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle localizedStringForKey:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(callBackButtonAction)];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:dict forState:UIControlStateNormal];
    
    // 右边
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton = rightButton;
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"preview_number_icon@2x" imageType:@"png"] forState:UIControlStateSelected];
    rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [rightButton addTarget:self action:@selector(_selectImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isPreviewButton)
    {
        [rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"preview_number_icon@2x" imageType:@"png"] forState:UIControlStateNormal];
        [rightButton setTitle:@"1" forState:UIControlStateNormal];
    }
    else
    { // 正常进来
        if (self.selectedModels.count > 0)
        {
            [rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"] forState:UIControlStateNormal];
            for (IJSAssetModel *model in self.selectedModels)
            {
                if (model.onlyOneTag == self.pushSelectedIndex)
                {
                    [self _resetRightButtonStatus:model.cellButtonNnumber];
                    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:model.cellButtonNnumber - 1 inSection:0];
                    [self.selectedCollection scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                    break;
                }
            }
        }
    }
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightView addSubview:rightButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    IJSAssetModel *model = self.allAssetModelArr[self.pushSelectedIndex];
    if (model.type == JSAssetModelMediaTypeVideo)
    {
        self.rightButton.hidden = YES;
    }
    else
    {
        self.rightButton.hidden = NO;
    }
    
    if (_isFirstAppear && self.isPreviewButton)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self _resetUpSelectedDidClick:indexPath];
        });
    }
}

/*-----------------------------------点击事件-------------------------------------------------------*/
#pragma mark 点击事件
// 返回
- (void)callBackButtonAction
{
    for (UIViewController *viewc in self.navigationController.childViewControllers)
    {
        if ([viewc isKindOfClass:[IJSPhotoPickerController class]])
        {
            IJSPhotoPickerController *vc = (IJSPhotoPickerController *) viewc;
            if (vc.callBack)
            {
                vc.callBack(self.selectedModels, self.allAssetModelArr);
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 编辑按钮
- (void)_editPhotoAction:(UIButton *)button
{
    __weak typeof(self) weakSelf = self;
    __block IJSAssetModel *model;
    __block NSUInteger index = 0;
    model = [self _selectedCurrentModel:model]; //判断选中当前的模型数据
    // 先处理不支持的类型
    IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
    if ((model.type == JSAssetModelMediaTypeVideo || model.type == JSAssetModelMediaTypeAudio) && !vc.allowPickingVideo)
    {
        NSString *title = [NSString stringWithFormat:@"%@", [NSBundle localizedStringForKey:@"Do not support selection of video types"]];
        [vc showAlertWithTitle:title];
        return;
    }
    if ((model.type != JSAssetModelMediaTypeVideo || model.type != JSAssetModelMediaTypeAudio) && !vc.allowPickingImage)
    {
        NSString *title = [NSString stringWithFormat:@"%@", [NSBundle localizedStringForKey:@"Do not support selection of image types"]];
        [vc showAlertWithTitle:title];
        return;
    }

    if (model.type != JSAssetModelMediaTypeVideo)
    {
        // 判断数据
        if (_rightButton.titleLabel.text == nil)
        {
            [self _selectImageButtonAction:nil]; // 选择添加
        }
        [self _selectedCurrentModel:model]; //判断选中当前的模型数据
        [self.selectedModels enumerateObjectsUsingBlock:^(IJSAssetModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.onlyOneTag == model.onlyOneTag)
            {
                model = obj; // 统一内存地址
                index = idx;
            }
        }];
    }
    if (model.type == JSAssetModelMediaTypeVideo)
    {
        if (self.isDoing)
        {
            return;
        }
        self.isDoing = YES;
        
        IJSLodingView *lodingView = [IJSLodingView showLodingViewAddedTo:self.view title:@"正在加载... ..."];
        
        [[IJSImageManager shareManager] getVideoOutputPathWithAsset:model.asset completion:^(NSURL *outputPath, NSError *error, IJSImageState state) {
            [lodingView removeFromSuperview];
            weakSelf.isDoing = NO;
            if (error)
            {
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"%@", error] preferredStyle:(UIAlertControllerStyleActionSheet)];
                UIAlertAction *cancle = [UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *_Nonnull action) {
                    [alertView dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertView addAction:cancle];
                [weakSelf presentViewController:alertView animated:YES completion:nil];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVAsset *asset = [AVAsset assetWithURL:outputPath];
                    Float64 duration = CMTimeGetSeconds([asset duration]);
                    IJSImagePickerController *vc = (IJSImagePickerController *) weakSelf.navigationController;
                    CGFloat minCut = vc.minVideoCut ?: 4;
                    CGFloat maxCut = vc.maxVideoCut ?: 10;
                    
                    if (duration >= minCut && duration <= maxCut)
                    {
                        IJSVideoEditController *videoEditVc = [[IJSVideoEditController alloc] init];
                        videoEditVc.inputPath = outputPath;
                        
                        [videoEditVc loadVideoOnCompleteResult:^(NSURL *outputPath, NSError *error) { //完成
                            if (error)
                            {
                                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"%@", error] preferredStyle:(UIAlertControllerStyleActionSheet)];
                                UIAlertAction *cancle = [UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *_Nonnull action) {
                                    [alertView dismissViewControllerAnimated:YES completion:nil];
                                }];
                                [alertView addAction:cancle];
                                [weakSelf presentViewController:alertView animated:YES completion:nil];
                                
                                if (weakSelf.selectedHandler)
                                {
                                    weakSelf.selectedHandler(nil, nil, nil, nil, IJSPVideoType, error);
                                }
                            }
                            else
                            {
                                if (weakSelf.selectedHandler)
                                {
                                    weakSelf.selectedHandler(nil, @[outputPath], nil, nil, IJSPVideoType, error);
                                }
                            }
                        }];
                        
                        [videoEditVc cancelSelectedData:^{
                            if (weakSelf.cancelHandler)
                            {
                                weakSelf.cancelHandler();
                            }
                        }];
                        videoEditVc.mapImageArr = [(IJSImagePickerController *) weakSelf.navigationController mapImageArr]; //贴图数据
                        [vc pushViewController:videoEditVc animated:YES];
                    }
                    else
                    {
                        IJSVideoCutController *videoCutVc = [[IJSVideoCutController alloc] init];
                        videoCutVc.minCutTime = vc.minVideoCut;
                        videoCutVc.maxCutTime = vc.maxVideoCut;
                        videoCutVc.inputPath = outputPath;
                        
                        [videoCutVc loadVideoOnCompleteResult:^(NSURL *outputPath, NSError *error) {
                            if (error)
                            {
                                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"%@", error] preferredStyle:(UIAlertControllerStyleActionSheet)];
                                UIAlertAction *cancle = [UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *_Nonnull action) {
                                    [alertView dismissViewControllerAnimated:YES completion:nil];
                                }];
                                [alertView addAction:cancle];
                                [weakSelf presentViewController:alertView animated:YES completion:nil];
                                if (weakSelf.selectedHandler)
                                {
                                   weakSelf.selectedHandler(nil, nil, nil, nil, IJSPVideoType, error);
                                }
                            }
                            else
                            {
                                if (weakSelf.selectedHandler)
                                {
                                    weakSelf.selectedHandler(nil, @[outputPath], nil, nil, IJSPVideoType, error);
                                }
                            }
                        }];
                        [videoCutVc cancelSelectedData:^{
                            if (weakSelf.cancelHandler)
                            {
                                weakSelf.cancelHandler();
                            }
                        }];
                        videoCutVc.canEdit = YES;  // 可以进入编辑界面
                        videoCutVc.mapImageArr = [(IJSImagePickerController *) weakSelf.navigationController mapImageArr]; //贴图数据
                        [vc pushViewController:videoCutVc animated:YES];
                    }
                });
            }
        }];
    }
    else
    {
        NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:index inSection:0];
        // 执行点击操作
        if (model.outputPath) // 上次已经编辑过,直接编辑编辑过的图片
        {
            UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:model.outputPath]];
            IJSImageManagerController *managerVc = [[IJSImageManagerController alloc] initWithEditImage:image];
            
            [managerVc loadImageOnCompleteResult:^(UIImage *image, NSURL *outputPath, NSError *error) {
                if (error)
                {
                    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"%@", error] preferredStyle:(UIAlertControllerStyleActionSheet)];
                    UIAlertAction *cancle = [UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *_Nonnull action) {
                        [alertView dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [alertView addAction:cancle];
                    [weakSelf presentViewController:alertView animated:YES completion:nil];
                }
                else
                {
                    model.outputPath = outputPath;
                    [weakSelf.showCollectioView reloadData]; // 重载
                    [weakSelf.selectedCollection reloadData];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf _resetUpSelectedDidClick:currentIndex];
                    });
                }
            }];
            
            managerVc.mapImageArr = [(IJSImagePickerController *) weakSelf.navigationController mapImageArr];
            [weakSelf presentViewController:managerVc animated:YES completion:nil];
        }
        else
        {
            IJSImagePickerController *vc = (IJSImagePickerController *) self.navigationController;
            if (vc.allowPickingOriginalPhoto)  // 允许原图
            {
                [[IJSImageManager shareManager]getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                    UIImage *photo =[UIImage imageWithData:data];
                    [weakSelf _pushImageControllerFromModel:model photo:photo isDegraded:isDegraded currentIndex:currentIndex];
                }];
            }
            else   // 非原图
            {
                [[IJSImageManager shareManager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    [weakSelf _pushImageControllerFromModel:model photo:photo isDegraded:isDegraded currentIndex:currentIndex];
                }];
            }
        }
    }
}
/// 跳转的私有方法
-(void)_pushImageControllerFromModel:( IJSAssetModel *)model photo:(UIImage *)photo isDegraded:(BOOL)isDegraded currentIndex:(NSIndexPath *)currentIndex
{
    __weak typeof (self) weakSelf = self;
    if (isDegraded)
    {
        return; // 获取不到高清图
    }
    if (photo)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            IJSImageManagerController *managerVc = [[IJSImageManagerController alloc] initWithEditImage:photo];
            [managerVc loadImageOnCompleteResult:^(UIImage *image, NSURL *outputPath, NSError *error) {
                model.outputPath = outputPath;
                [weakSelf.showCollectioView reloadData]; // 重载
                [weakSelf.selectedCollection reloadData];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf _resetUpSelectedDidClick:currentIndex];
                });
            }];
            managerVc.mapImageArr = [(IJSImagePickerController *) weakSelf.navigationController mapImageArr];
            [weakSelf presentViewController:managerVc animated:YES completion:nil];
        });
    }
}

#pragma mark - 执行刷新选择UI的操作
/// 执行刷新选择UI的操作
- (void)_resetUpSelectedDidClick:(NSIndexPath *)indexPath
{
    _isFirstAppear = NO;
    NSArray *cellArr = [self.selectedCollection visibleCells];
    for (IJSSelectedCell *allCell in cellArr)
    {
        [self _cleanAssetCellStatus:allCell];
    }
    self.didClinkIndex = indexPath;
    IJSSelectedCell *cell = (IJSSelectedCell *) [self.selectedCollection cellForItemAtIndexPath:indexPath];
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
    }
    else
    {
        self.showCollectioView.contentOffset = CGPointMake(JSScreenWidth * model.onlyOneTag, 0);
    }
    [self _resetAssetCellStatus:cell];                      //加边框
    [self _resetRightButtonStatus:model.cellButtonNnumber]; // 刷新导航条
}
/// 选则需要的模型
- (IJSAssetModel *)_selectedCurrentModel:(IJSAssetModel *)model
{
    NSIndexPath *firstIndexPath = [[self.showCollectioView indexPathsForVisibleItems] firstObject];
    if (self.isPreviewButton) //预览模式下
    {                         //获取的是不变的数据
        model = self.previewAssetModelArr[firstIndexPath.row];
    }
    else
    {
        model = self.allAssetModelArr[firstIndexPath.row]; // 正常模式
    }
    return model;
}

#pragma mark 完成选择
- (void)_finishSelectImageDisMiss
{
    IJSImagePickerController *vc = (IJSImagePickerController *) self.navigationController;
    vc.selectedModels = self.selectedModels;
    
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
        // 先处理不支持的类型
        IJSImagePickerController *vc = (IJSImagePickerController *)self.navigationController;
        if ((model.type == JSAssetModelMediaTypeVideo || model.type == JSAssetModelMediaTypeAudio) && !vc.allowPickingVideo)
        {
            NSString *title = [NSString stringWithFormat:@"%@", [NSBundle localizedStringForKey:@"Do not support selection of video types"]];
            [vc showAlertWithTitle:title];
            return;
        }
        if ((model.type != JSAssetModelMediaTypeVideo || model.type != JSAssetModelMediaTypeAudio) && !vc.allowPickingImage)
        {
            NSString *title = [NSString stringWithFormat:@"%@", [NSBundle localizedStringForKey:@"Do not support selection of image types"]];
            [vc showAlertWithTitle:title];
            return;
        }
        if (type == JSAssetModelMediaTypeVideo) //当前显示的是视频资源
        {
            [self _getBackThumbnailDataPhotos:photos assets:assets infoArr:infoArr avPlayers:avPlayers model:model index:0 networkAccessAllowed:NO noAlert:noShowAlert vc:vc];
        }
        else
        {
            // 不满足最小要求就警告
            if (vc.minImagesCount && vc.selectedModels.count < vc.minImagesCount)
            {
                NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a minimum of %zd photos"], vc.minImagesCount];
                [vc showAlertWithTitle:title];
                return;
            }
            // 当前显示的是非视频资源
            if (vc.allowPickingOriginalPhoto) // 原图
            {
                [self _getBackOriginalDataPhotos:photos assets:assets infoArr:infoArr avPlayers:nil model:model index:0];
            }
            else
            { //缩略图
                
                [self _getBackThumbnailDataPhotos:photos assets:assets infoArr:infoArr avPlayers:nil model:model index:0 networkAccessAllowed:YES noAlert:noShowAlert vc:vc];
            }
        }
    }
    else
    { // 已经选中了多图
        // 不满足最小要求就警告
        if (vc.minImagesCount && vc.selectedModels.count < vc.minImagesCount)
        {
            NSString *title = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a minimum of %zd photos"], vc.minImagesCount];
            [vc showAlertWithTitle:title];
            return;
        }
        if (vc.allowPickingOriginalPhoto) // 获取本地原图
        {
            for (int i = 0; i < vc.selectedModels.count; i++)
            {
                IJSAssetModel *model = vc.selectedModels[i];
                [self _getBackOriginalDataPhotos:photos assets:assets infoArr:infoArr avPlayers:nil model:model index:i];
            }
        }
        else
        { //缩略图,默认是828
            for (int i = 0; i < vc.selectedModels.count; i++)
            {
                IJSAssetModel *model = vc.selectedModels[i];
                [self _getBackThumbnailDataPhotos:photos assets:assets infoArr:infoArr avPlayers:avPlayers model:model index:i networkAccessAllowed:YES noAlert:noShowAlert vc:vc];
            }
        }
    }
}
/// 获取资源的方法---缩略图
- (void)_getBackThumbnailDataPhotos:(NSMutableArray *)photos
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
    
    if (model.type == JSAssetModelMediaTypeVideo) //导出视频
    {
        if (_isDoing)
        {
            return;
        }
        _isDoing = YES;
        __weak typeof (self) weakSelf = self;
        [[IJSImageManager shareManager] getAVAssetWithPHAsset:model.asset completion:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            IJSImagePickerController *imagePick = (IJSImagePickerController *) weakSelf.navigationController;
            Float64 duration = CMTimeGetSeconds([asset duration]);
            NSInteger maxTime = 10;
            
            if (imagePick.minVideoCut || imagePick.maxVideoCut)
            {
                if (duration >= imagePick.minVideoCut && duration <= imagePick.maxVideoCut)
                {
                    maxTime = duration;
                }
                else
                {
                    maxTime = 10;
                }
            }
            else
            { // 没有设置就导出原视频
                maxTime = duration;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.lodingView = [IJSLodingView showLodingViewAddedTo:self.view title:@"正在处理... ..."];
            });
            
            [IJSVideoManager cutVideoAndExportVideoWithVideoAsset:asset startTime:0 endTime:maxTime completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {
                if (outputPath)
                {
                    [avPlayers replaceObjectAtIndex:index withObject:outputPath];
                }
                if (error)
                {
                    [infoArr replaceObjectAtIndex:index withObject:error];
                }
                [assets replaceObjectAtIndex:index withObject:model.asset];
                for (id item in avPlayers)
                {
                    if ([item isKindOfClass:[NSNumber class]])
                    {
                        return;
                    }
                }
                [self _didGetAllPhotos:nil asset:assets infos:infoArr isSelectOriginalPhoto:YES avPlayers:avPlayers sourceType:IJSPVideoType];
            }];
            
        }];
    }
    else
    {                    // 图片
        if (model.outputPath) // 裁剪过了
        {
            UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:model.outputPath]];
            [photos replaceObjectAtIndex:index withObject:image];
            [assets replaceObjectAtIndex:index withObject:model.asset];
            for (id item in photos)
            {
                if ([item isKindOfClass:[NSNumber class]])
                {
                    return;
                }
            }
            [self _didGetAllPhotos:photos asset:assets infos:nil isSelectOriginalPhoto:NO avPlayers:nil sourceType:IJSPImageType];
        }
        else
        { // 没有裁剪过
            
            [[IJSImageManager shareManager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded)
                    return; // 获取不到高清图
                if (photo)
                {
                    [photos replaceObjectAtIndex:index withObject:photo];
                }
                if (info)
                {
                    [infoArr replaceObjectAtIndex:index withObject:info];
                }
                [assets replaceObjectAtIndex:index withObject:model.asset];
                for (id item in photos)
                {
                    if ([item isKindOfClass:[NSNumber class]])
                    {
                        return;
                    }
                }
                
                if (noShowAlert)
                {
                    [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:NO avPlayers:nil sourceType:IJSPImageType];
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
/// 获取原图
- (void)_getBackOriginalDataPhotos:(NSMutableArray *)photos
                            assets:(NSMutableArray *)assets
                           infoArr:(NSMutableArray *)infoArr
                         avPlayers:(NSMutableArray *)avPlayers
                             model:(IJSAssetModel *)model
                             index:(NSInteger)index
{
    if (model.outputPath) //裁剪过了
    {
        UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:model.outputPath]];
        [photos replaceObjectAtIndex:index withObject:image];
        [assets replaceObjectAtIndex:index withObject:model.asset];
        for (id item in photos)
        {
            if ([item isKindOfClass:[NSNumber class]])
            {
                return;
            }
        }
        [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:YES avPlayers:nil sourceType:IJSPImageType];
    }
    else
    {
        [[IJSImageManager shareManager] getOriginalPhotoDataWithAsset:model.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded)
            {
                return; // 获取不到高清图
            }
            if (data)
            {
                UIImage *photo =[UIImage imageWithData:data];
                [photos replaceObjectAtIndex:index withObject:photo];
            }
            if (info)
            {
                [infoArr replaceObjectAtIndex:index withObject:info];
            }
            [assets replaceObjectAtIndex:index withObject:model.asset];
            
            for (id item in photos)
            {
                if ([item isKindOfClass:[NSNumber class]])
                {
                    return;
                }
            }
            
            [self _didGetAllPhotos:photos asset:assets infos:infoArr isSelectOriginalPhoto:YES avPlayers:nil sourceType:IJSPImageType];
        }];
    }
}

//设置返回的数据
- (void)_didGetAllPhotos:(NSArray *)photos asset:(NSArray *)asset infos:(NSArray *)infos isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto avPlayers:(NSArray *)avPlayers sourceType:(IJSPExportSourceType)sourceType
{
    _isDoing = NO;
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.lodingView removeFromSuperview];
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.selectedHandler)
            {
                weakSelf.selectedHandler(photos, avPlayers, asset, infos, sourceType, nil);
            }
        }];
    });
}
#pragma mark - 导航条按钮选图片
- (void)_selectImageButtonAction:(UIButton *)button
{
    [button addSpringAnimation];
    _isFirstAppear = NO;
    NSInteger index = self.showCollectioView.contentOffset.x / JSScreenWidth;
    if (self.isPreviewButton)
    {                                                //1, 处理预览模式下的逻辑
        if (self.rightButton.titleLabel.text == nil) //增加
        {
            IJSAssetModel *model = self.previewAssetModelArr[index];
            [self.selectedModels addObject:model];
            [self.selectedCollection reloadData];
            
            // 增加属性并替换掉
            model.isSelectedModel = YES;
            model.cellButtonNnumber = self.selectedModels.count;
            model.didClickModelArr = self.selectedModels;
            [self.allAssetModelArr replaceObjectAtIndex:model.onlyOneTag withObject:model];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedModels.count - 1 inSection:0];
            if (self.selectedModels.count <= 5)
            {
                self.selectedCollection.contentOffset = CGPointMake(-0.5, 0);
            }
            [self.selectedCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            
            [self _resetRightButtonStatus:self.selectedModels.count];
        }
        else
        { //删除
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
            for (int i = 0; i < self.selectedModels.count; i++)
            {
                IJSAssetModel *tempModel = self.selectedModels[i];
                tempModel.cellButtonNnumber = i + 1;
            }
        }
    }
    else // 2, 正常点击跳转的逻辑处理
    {
        if (_rightButton.titleLabel.text == nil) //没有选中 选中添加
        {
            if (self.selectedModels.count < ((IJSImagePickerController *) self.navigationController).maxImagesCount) //还没有超标
            {
                IJSAssetModel *model = self.allAssetModelArr[index];
                [self.selectedModels addObject:model];
                [self.selectedCollection reloadData];
                // 增加属性并替换掉
                model.isSelectedModel = YES;
                model.cellButtonNnumber = self.selectedModels.count;
                model.didClickModelArr = self.selectedModels;
                [self.allAssetModelArr replaceObjectAtIndex:index withObject:model];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedModels.count - 1 inSection:0];
                if (self.selectedModels.count <= 5)
                    self.selectedCollection.contentOffset = CGPointMake(-0.5, 0);
                [self.selectedCollection scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                [self _resetRightButtonStatus:self.selectedModels.count];
            }
            else
            { //超标了
                NSString *editTitle = [NSString stringWithFormat:@"%@", [NSBundle localizedStringForKey:@"Please edit the selected picture"]];
                NSString *countTitle = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Select a maximum of %zd photos"], ((IJSImagePickerController *) self.navigationController).maxImagesCount];
                NSString *alertTitle = [NSString stringWithFormat:@"%@,%@", countTitle, editTitle];
                [((IJSImagePickerController *) self.navigationController) showAlertWithTitle:alertTitle];
            }
        }
        else
        { //删除
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
            for (int i = 0; i < self.selectedModels.count; i++)
            {
                IJSAssetModel *tempModel = self.selectedModels[i];
                tempModel.cellButtonNnumber = i + 1;
            }
        }
    }
    if (self.selectedModels.count > 0)
    {
        self.selectedCollection.hidden = NO;
    }
    else
    {
        self.selectedCollection.hidden = YES;
    }
    [self _resetToorBarStatus];
}

/*-----------------------------------私有方法-------------------------------------------------------*/
#pragma mark 私有方法
// 根据cell选中的数量重置toorbar的状态
- (void)_resetToorBarStatus
{
    IJSImagePickerController *vc = (IJSImagePickerController *) self.navigationController;
    vc.selectedModels = self.selectedModels;
    if (vc.selectedModels.count > 0) // 有数据
    {
        [_finishButton setTitle:[NSString stringWithFormat:@"%@(%lu)", [NSBundle localizedStringForKey:@"Done"], (unsigned long) vc.selectedModels.count] forState:UIControlStateNormal];
        self.finishButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_editButton setTitleColor:[IJSFColor colorWithR:232 G:236 B:239 alpha:1] forState:UIControlStateNormal];
    }
    else
    {
        [_finishButton setTitle:[NSBundle localizedStringForKey:@"Done"] forState:UIControlStateNormal];
        self.finishButton.titleLabel.font = [UIFont systemFontOfSize:17];
    }
}

// 清楚cell上的状态
- (void)_cleanAssetCellStatus:(IJSSelectedCell *)cell
{
    cell.backImageView.layer.borderWidth = 0;
    cell.backImageView.layer.cornerRadius = 0;
    cell.backImageView.clipsToBounds = YES;
}
// 添加边框
- (void)_resetAssetCellStatus:(IJSSelectedCell *)cell
{
    cell.backImageView.layer.borderWidth = 2;
    cell.backImageView.layer.cornerRadius = 3;
    cell.backImageView.layer.borderColor = [[UIColor greenColor] CGColor];
    cell.backImageView.clipsToBounds = YES;
}
// 是否隐藏状态栏
- (void)isHiddenStatus:(BOOL)state
{
    if (state)
    {
        self.toolBarView.hidden = YES;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.selectedCollection.hidden = YES;
    }
    else
    {
        self.toolBarView.hidden = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        if (self.selectedModels.count == 0)
        {
            self.selectedCollection.hidden = YES;
        }
        else
        {
            self.selectedCollection.hidden = NO;
        }
    }
}
// 清空导航条button的数据
- (void)_cleanRightButtonStatus
{
    [self.rightButton setTitle:nil forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"photo_def_previewVc@2x" imageType:@"png"] forState:UIControlStateNormal];
}
// 重置导航条button的状态
- (void)_resetRightButtonStatus:(NSInteger)number
{
    [self.rightButton setTitle:[NSString stringWithFormat:@"%ld", (long) number] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"preview_number_icon@2x" imageType:@"png"] forState:UIControlStateNormal];
}

/*-----------------------------------3D Touch-------------------------------------------------------*/
#pragma mark - UIViewControllerPreviewingDelegate method
//peek(预览模式)
- (nullable UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    [self.touchCell stopLivePhotos];
    IJSPreviewImageCell *cell = (IJSPreviewImageCell *) [self.showCollectioView visibleCells].firstObject;
    if (cell.assetModel.type == JSAssetModelMediaTypeLivePhoto)
    {
        self.touchCell = cell;
        [cell playLivePhotos];
    }
    if (iOS9Later)
    {
        NSIndexPath *indexPath = [self.showCollectioView indexPathForCell:(IJSPreviewImageCell *) [previewingContext sourceView]];
        IJS3DTouchController *touchVC = [[IJS3DTouchController alloc] init];
        touchVC.model = self.allAssetModelArr[indexPath.row];
        touchVC.preferredContentSize = CGSizeMake(0.0f, 500.0f);
        
        CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 40);
        previewingContext.sourceRect = rect;
        return touchVC;
    }
    return nil;
}

//pop（继续按压进入）
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    //    IJS3DTouchController *childVC = [[IJS3DTouchController alloc] init];
    //    [self.navigationController pushViewController:childVC animated:YES];
    //     [self showViewController:viewControllerToCommit sender:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    if ([keyPath isEqual:@"state"])
    {
        NSInteger state = [change[NSKeyValueChangeNewKey] integerValue];
        switch (state)
        {
            case 1:
            case 3:
            case 5:
            {
                [self.touchCell stopLivePhotos];
                break;
            }
            case 4:
            {
                [self.touchCell playLivePhotos];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - 播放监听器
#pragma mark 开始定时器
- (void)startListenPlayerTimer
{
    [self removeListenPlayerTimer];
    self.listenPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(listenPlayerTimerResetTimer) userInfo:nil repeats:YES];
}
#pragma mark 清空定时器
- (void)removeListenPlayerTimer
{
    if (self.listenPlayerTimer)
    {
        [self.listenPlayerTimer invalidate];
        self.listenPlayerTimer = nil;
    }
}
#pragma mark 监听播放的状态
// 播放中
- (void)listenPlayerTimerResetTimer
{
    CGFloat current = CMTimeGetSeconds([self.player currentTime]);
    if (current >= self.videoDuraing)
    {
        CMTime time = CMTimeMakeWithSeconds(0, self.player.currentTime.timescale);
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[IJSImageManager shareManager] stopCachingImagesFormAllAssets];
    JSLog(@"内存警告了");
}











@end
