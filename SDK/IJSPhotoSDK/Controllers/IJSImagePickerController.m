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
@property (nonatomic, strong) NSMutableArray *mapDataArr; // 贴图数据
@end

@implementation IJSImagePickerController

- (void)dealloc
{
    JSLog(@"---IJSImagePickerControllers释放-----")
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.oKButtonTitleColorNormal = [UIColor colorWithRed:(83 / 255.0) green:(179 / 255.0) blue:(17 / 255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83 / 255.0) green:(179 / 255.0) blue:(17 / 255.0) alpha:0.5];
    [self _createrUI];
    [self _setupMapData];
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

/*-----------------------------------初始化方法-------------------------------------------------------*/
#pragma mark 初始化方法
// 默认是4个返回值
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<IJSImagePickerControllerDelegate>)delegate
{
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVc:YES];
}
// 自定义
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<IJSImagePickerControllerDelegate>)delegate
{
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES];
}
// 统一接口
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<IJSImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc
{
    _pushPhotoPickerVc = pushPhotoPickerVc;
    IJSAlbumPickerController *albumPickerVc = [[IJSAlbumPickerController alloc] init];
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc]; // 设置返回的跟控制器
    if (self)
    {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.imagePickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];

        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = NO;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.sortAscendingByModificationDate = YES; //时间排序
        self.networkAccessAllowed = NO;
        self.columnNumber = columnNumber;

        [self configDefaultSetting]; // 初始化信息

        if (![[IJSImageManager shareManager] authorizationStatusAuthorized]) // 没有授权,自定义的界面
        {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.backgroundColor = [UIColor redColor];
            _tipLabel.frame = CGRectMake(8, 120, self.view.js_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
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
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.js_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
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
- (void)configDefaultSetting
{
    //    self.timeout = 15;
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600; // 图片预览器默认的宽度
    self.naviTitleColor = [UIColor whiteColor];
    self.naviTitleFont = [UIFont systemFontOfSize:17];
    self.barItemTextFont = [UIFont systemFontOfSize:15];
    self.barItemTextColor = [UIColor whiteColor];
    self.allowPreview = YES;

    [self configDefaultImageName]; // 初始化图片信息
    [self configDefaultBtnTitle];  // 初始化按钮信息
}
/// 初始化图片信息
- (void)configDefaultImageName
{
    self.takePictureImageName = @"takePicture.png";
    self.photoSelImageName = @"photo_sel_photoPickerVc.png";
    self.photoDefImageName = @"photo_def_photoPickerVc.png";
    self.photoNumberIconImageName = @"photo_number_icon.png";
    self.photoPreviewOriginDefImageName = @"preview_original_def.png";
    self.photoOriginDefImageName = @"photo_original_def.png";
    self.photoOriginSelImageName = @"photo_original_sel.png";
}
/// 初始化按钮信息
- (void)configDefaultBtnTitle
{
    self.doneBtnTitleStr = [NSBundle localizedStringForKey:@"Done"];
    self.cancelBtnTitleStr = [NSBundle localizedStringForKey:@"Cancel"];
    self.previewBtnTitleStr = [NSBundle localizedStringForKey:@"Preview"];
    self.fullImageBtnTitleStr = [NSBundle localizedStringForKey:@"Full image"];
    self.settingBtnTitleStr = [NSBundle localizedStringForKey:@"Setting"];
    self.processHintStr = [NSBundle localizedStringForKey:@"Processing..."];
}
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
    if (iOS8Later)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    else
    {
        NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
        if ([[UIApplication sharedApplication] canOpenURL:privacyUrl])
        {
            [[UIApplication sharedApplication] openURL:privacyUrl];
        }
        else
        {
            NSString *message = [NSBundle localizedStringForKey:@"Can not jump to the privacy settings page, please go to the settings page by self, thank you"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle localizedStringForKey:@"Sorry"] message:message delegate:nil cancelButtonTitle:[NSBundle localizedStringForKey:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
    }
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
        vc.columnNumber = self.columnNumber; //列数
        __weak typeof(self) weakSelf = self;
        __weak typeof(vc) weakVc = vc;
        [[IJSImageManager shareManager] getCameraRollAlbumContentImage:self.allowPickingImage contentVideo:self.allowPickingVideo completion:^(IJSAlbumModel *model) {
            weakVc.albumModel = model;
            [weakSelf pushViewController:vc animated:YES];
            _didPushPhotoPickerVc = YES;
        }];
    }
}

- (void)_createrUI
{
    // 默认的外观，你可以在这个方法后重置
    self.oKButtonTitleColorNormal = [UIColor colorWithRed:(83 / 255.0) green:(179 / 255.0) blue:(17 / 255.0) alpha:1.0];
    self.oKButtonTitleColorDisabled = [UIColor colorWithRed:(83 / 255.0) green:(179 / 255.0) blue:(17 / 255.0) alpha:0.5];
    if (iOS7Later)
    {
        self.navigationBar.barTintColor = [UIColor colorWithRed:(34 / 255.0) green:(34 / 255.0) blue:(34 / 255.0) alpha:1.0];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}
- (void)goAlbumViewController
{
    IJSAlbumPickerController *vc = [[IJSAlbumPickerController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 点击方法
- (void)settingBtnClick
{
}
- (void)observeAuthrizationStatusChange
{
}
#pragma mark - 设置map数据
- (void)_setupMapData
{
    if (self.mapImageArr == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
        NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
        [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
            IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
            [self.mapDataArr addObject:model];
            self.mapImageArr = self.mapDataArr;
        }];
    }
}
/*-----------------------------------get set 方法-------------------------------------------------------*/
#pragma mark set方法
- (void)setNaviBgColor:(UIColor *)naviBgColor
{
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor
{
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
}

- (void)setNaviTitleFont:(UIFont *)naviTitleFont
{
    _naviTitleFont = naviTitleFont;
    [self configNaviTitleAppearance];
}

- (void)setBarItemTextFont:(UIFont *)barItemTextFont
{
    _barItemTextFont = barItemTextFont;
    [self configBarButtonItemAppearance];
}

- (void)setBarItemTextColor:(UIColor *)barItemTextColor
{
    _barItemTextColor = barItemTextColor;
    [self configBarButtonItemAppearance];
}
- (void)setAllowPickingImage:(BOOL)allowPickingImage
{
    _allowPickingImage = allowPickingImage;
}
- (void)setAllowPickingVideo:(BOOL)allowPickingVideo
{
    _allowPickingVideo = allowPickingVideo;
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
        //        _showSelectBtn = YES;
        //        _allowCrop = NO;
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

// 导航条
- (void)configNaviTitleAppearance
{
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    textAttrs[NSFontAttributeName] = self.naviTitleFont;
    self.navigationBar.titleTextAttributes = textAttrs;
}

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
    textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
    textAttrs[NSFontAttributeName] = self.barItemTextFont;
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}
/// 警告
- (void)showAlertWithTitle:(NSString *)title
{
    if (iOS8Later)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:[NSBundle localizedStringForKey:@"OK"] otherButtonTitles:nil, nil] show];
    }
}

#pragma mark 懒加载区域
- (NSMutableArray *)mapDataArr
{
    if (_mapImageArr == nil)
    {
        _mapImageArr = [NSMutableArray array];
    }
    return _mapImageArr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
