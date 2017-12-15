//
//  IJSImagePickerController.m
//  JSPhotoSDK
//
//  Created by shan on 2017/5/28.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSImagePickerController.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"

#import "IJSAlbumPickerController.h"
#import "IJSPhotoPickerController.h"
#import "IJSImageManager.h"
#import "IJSConst.h"
#import "IJSMapViewModel.h"

@interface IJSImagePickerController ()
{
    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingBtn;
    BOOL _pushPhotoPickerVc; // 是否直接跳转
    BOOL _didPushPhotoPickerVc;
}
/* 默认的列数 */
@property (nonatomic, assign) NSInteger columnNumber;
@property(nonatomic,weak) IJSAlbumPickerController *albumVc;  // 相册控制器
@property(nonatomic,weak) IJSPhotoPickerController *photoVc;  // 相册预览界面
@end

@implementation IJSImagePickerController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self _createrUI];    // 设置UI
    [self configNaviTitleAppearance];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)loadTheSelectedData:(void(^)(NSArray<UIImage *> *photos, NSArray<NSURL *> *avPlayers, NSArray<PHAsset *> *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType,NSError *error))selectedHandler
{
    self.albumVc.selectedHandler = selectedHandler;
    self.photoVc.selectedHandler = selectedHandler;
}

-(void)cancelSelectedData:(void(^)(void))cancelHandler
{
    self.albumVc.cancelHandler = cancelHandler;
    self.photoVc.cancelHandler = cancelHandler;
}

/*-----------------------------------初始化方法-------------------------------------------------------*/
#pragma mark 初始化方法
// 默认是4个返回值
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount
{
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4  pushPhotoPickerVc:YES];
}
// 自定义
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber
{
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber  pushPhotoPickerVc:YES];
}
// 统一接口
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber pushPhotoPickerVc:(BOOL)pushPhotoPickerVc
{
    _pushPhotoPickerVc = pushPhotoPickerVc;
    IJSAlbumPickerController *albumPickerVc = [[IJSAlbumPickerController alloc] init];
    self.albumVc = albumPickerVc;
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc]; // 设置返回的跟控制器
    if (self)
    {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.selectedModels = [NSMutableArray array];
        self.columnNumber = columnNumber;

        [self setupDefaultData]; // 初始化信息

        if (![[IJSImageManager shareManager] authorizationStatusAuthorized]) // 没有授权,自定义的界面
        {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.backgroundColor = [UIColor redColor];
            _tipLabel.frame = CGRectMake(8, 200, self.view.js_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.layer.cornerRadius = 5;
            _tipLabel.layer.masksToBounds =YES;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
            if (!appName)
                appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
            NSString *tipText;
            if ([NSBundle localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""] != nil)
            {
                tipText = [NSString stringWithFormat:[NSBundle localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""], appName];
            }
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];

            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:[NSBundle localizedStringForKey:@"Setting"] forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(JSScreenWidth / 2 - 50, 280, 100, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:20];
            _settingBtn.tintColor =[UIColor blueColor];
            _settingBtn.backgroundColor =[UIColor greenColor];
            _settingBtn.layer.borderWidth =1;
            _settingBtn.layer.cornerRadius = 5;
            _settingBtn.layer.masksToBounds = YES;
            [_settingBtn addTarget:self action:@selector(_settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];

            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(_observeAuthrizationStatusChange) userInfo:nil repeats:YES];
        }
        else // 已经授权
        {
            [self _pushPhotoPickerVc];
        }
    }
    return self;
}

/*-----------------------------------属性初始化-------------------------------------------------------*/
// 初始化时间排序的信息
- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate
{
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [IJSImageManager shareManager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}

/*-----------------------------------私有方法-------------------------------------------------------*/
#pragma mark 私有方法
// 监听授权状态
- (void)_settingBtnClick
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}
- (void)_observeAuthrizationStatusChange
{
    if ([[IJSImageManager shareManager] authorizationStatusAuthorized])
    {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];
        [_timer invalidate];
        _timer = nil;
        [self _pushPhotoPickerVc];
    }
}

// 跳转界面
- (void)_pushPhotoPickerVc
{
    _didPushPhotoPickerVc = NO;
    if (!_didPushPhotoPickerVc && _pushPhotoPickerVc) // 直接push
    {
        IJSPhotoPickerController *vc = [[IJSPhotoPickerController alloc] init];
        self.photoVc = vc;
        vc.columnNumber = self.columnNumber; //列数
        __weak typeof(self) weakSelf = self;
        __weak typeof(vc) weakVc = vc;
        [[IJSImageManager shareManager] getCameraRollAlbumContentImage:_allowPickingImage contentVideo:_allowPickingVideo completion:^(IJSAlbumModel *model) {
            weakVc.albumModel = model;
            [weakSelf pushViewController:vc animated:YES];
            _didPushPhotoPickerVc = YES;
        }];
    }
}
/// 跳转到相册列表页
- (void)goAlbumViewController
{
    IJSAlbumPickerController *vc = [[IJSAlbumPickerController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 点击方法
/*-----------------------------------get set 方法-------------------------------------------------------*/
#pragma mark set方法
- (void)setAllowPickingImage:(BOOL)allowPickingImage
{
    _allowPickingImage = allowPickingImage;
}
- (void)setAllowPickingVideo:(BOOL)allowPickingVideo
{
    _allowPickingVideo = allowPickingVideo;
}
-(void)setIsHiddenEdit:(BOOL)isHiddenEdit
{
    _isHiddenEdit = isHiddenEdit;
}
- (void)setMinPhotoWidthSelectable:(NSInteger)minPhotoWidthSelectable
{
    _minPhotoWidthSelectable = minPhotoWidthSelectable;
    [IJSImageManager shareManager].minPhotoWidthSelectable = minPhotoWidthSelectable;
}

- (void)setMinPhotoHeightSelectable:(NSInteger)minPhotoHeightSelectable
{
    _minPhotoHeightSelectable = minPhotoHeightSelectable;
    [IJSImageManager shareManager].minPhotoHeightSelectable = minPhotoHeightSelectable;
}
- (void)setNetworkAccessAllowed:(BOOL)networkAccessAllowed
{
    _networkAccessAllowed = networkAccessAllowed;
    [IJSImageManager shareManager].networkAccessAllowed = networkAccessAllowed;
}

// 设置屏幕默认的宽度
- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth
{
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800)
    {
        _photoPreviewMaxWidth = 800;
    }
    else if (photoPreviewMaxWidth < 500)
    {
        _photoPreviewMaxWidth = 500;
    }
    [IJSImageManager shareManager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}
// 设置最大的列数
- (void)setMaxImagesCount:(NSInteger)maxImagesCount
{
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1)
    {
    }
}
/// 是否选择原图
- (void)setAllowPickingOriginalPhoto:(BOOL)allowPickingOriginalPhoto
{
    _allowPickingOriginalPhoto = allowPickingOriginalPhoto;
    [IJSImageManager shareManager].allowPickingOriginalPhoto = allowPickingOriginalPhoto;
}
/// 贴图数组
- (void)setMapImageArr:(NSMutableArray<IJSMapViewModel *> *)mapImageArr
{
    _mapImageArr = mapImageArr;
}

// 给相册控制和图片管理者设置列数计算图片高度
- (void)setColumnNumber:(NSInteger)columnNumber
{
    _columnNumber = columnNumber;
    if (columnNumber <= 2)
    {
        _columnNumber = 2;
    }
    else if (columnNumber >= 6)
    {
        _columnNumber = 6;
    }
    IJSAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
    albumPickerVc.columnNumber = _columnNumber;
    [IJSImageManager shareManager].columnNumber = _columnNumber;
}

- (void)setMinVideoCut:(NSInteger)minVideoCut
{
    _minVideoCut = minVideoCut;
}
- (void)setMaxVideoCut:(NSInteger)maxVideoCut
{
    _maxVideoCut = maxVideoCut;
}
#pragma mark 初始化设置UI
/*-----------------------------------------------------初始化默认设置-------------------------------*/
/// 设置默认的数据
-(void)setupDefaultData
{
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 750; // 图片预览器默认的宽度
    // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
    _allowPickingOriginalPhoto = NO;
    _allowPickingVideo = YES;
    _allowPickingImage = YES;
    _isHiddenEdit = NO;
    _sortAscendingByModificationDate = YES; //时间排序
    _networkAccessAllowed = NO;
}
// 默认的外观，你可以在这个方法后重置
- (void)_createrUI
{
    self.navigationBar.barTintColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configNaviTitleAppearance]; // 中间的文字
    [self configBarButtonItemAppearance];  //左右两边
}
// 导航条中间文字的颜色
- (void)configNaviTitleAppearance
{
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    self.navigationBar.titleTextAttributes = textAttrs;
   
}
 ///  设置导航条左右两边的按钮
- (void)configBarButtonItemAppearance
{
    UIBarButtonItem *barItem;
    if (iOS9Later)
    {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[IJSImagePickerController class]]];
    }
    else
    {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[IJSImagePickerController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] =[UIFont systemFontOfSize:17];
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}
/// 警告
- (void)showAlertWithTitle:(NSString *)title
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
