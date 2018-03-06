# IJSPhotoSDK
ios多图选择,高仿微信发朋友圈的功能

### 进来第一件事不是应该是点赞吗?  点  点   点    哈哈哈

# 合作 QQ: 1096452045   

# 简书地址: http://www.jianshu.com/u/874b526fa570

#    IJSPhotoSDK  集成文档

### 项目介绍:
主要模仿微信的发朋友圈多图选择,修改图片等功能
主要实现功能如下:

```
1, 照片选取预览,有相册UI 预览UI 详情UI 可以创建相册等
2, 预览UI 详情UI 可以通过3DTouch的方式进行查看
3, 可以删除照片 收藏照片
4, 可以通过点击播放 Video gif  livephoto等资源
5,  预览详情支持 单击 双击 缩合等手势处理照片查看
6, 支持国际化配置
7, 新增视频处理包括,裁剪,涂鸦,水印,贴图等等

```
### 项目演示

![](http://upload-images.jianshu.io/upload_images/2845360-c9e82e70ba22cf47.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)
![](http://upload-images.jianshu.io/upload_images/2845360-dfe6586d71e9af56.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)
![](http://upload-images.jianshu.io/upload_images/2845360-b58cd58f7f3d4749.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)
![](http://upload-images.jianshu.io/upload_images/2845360-84e41608527d6ff0.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)
![](http://upload-images.jianshu.io/upload_images/2845360-e8d134cca999dd7b.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)
![](http://upload-images.jianshu.io/upload_images/2845360-01d4de8f1e86c544.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](http://upload-images.jianshu.io/upload_images/2845360-6f63125cb3207256.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)
![](http://upload-images.jianshu.io/upload_images/2845360-2415f1e7467133fb.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](http://upload-images.jianshu.io/upload_images/2845360-0b0d573e480ed8e3.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](http://upload-images.jianshu.io/upload_images/2845360-82c00d5157e2442a.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 手动拖入的方式
git下载地址:  https://github.com/wangjinshan/IJSPhotoSDK 

### 项目目录介绍:
目录: 

```
SDK:  1, IJSPhotoSDK: 主要处理Photokit的api封装,用于相册UI展示和选择
      2, IJSImageEditSDK 主要用于对获取到的图片和视频资源进行裁剪涂鸦等等操作
      3, Resources 存放必要的资源库,如果拆分sdk 这个资源还是需要依赖上
         //以下两个是pod的项目可以pod 语句加入
         // pod search IJSFoundation
         // pod search IJSUExtension
      4,IJSFoundation 主要是公共库的方法,常用方法的整合 
      5,IJSUExtension 是开源 IJSUI的扩展,主要是系统的Category
        
```
#### 1, 下载sdk并把里面的SDK文件夹直接拖入到项目中去
#### 2, 在项目的点击事件中实现如下代码
#### 简洁版本


```
1, 引入头文件
#import "IJSImagePickerController.h"
2, 按钮中实现下面代码
IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:3 columnNumber:4];
    //可选  可以通过代理的回调去获取数据
    [imageVc loadTheSelectedData:^(NSArray<UIImage *> *photos, NSArray<NSURL *> *avPlayers, NSArray<PHAsset *> *assets, NSArray<NSDictionary *> *infos, IJSPExportSourceType sourceType, NSError *error) {
        NSLog(@"%@",photos);
        NSLog(@"%@",avPlayers);
    }];
    [self presentViewController:imageVc animated:YES completion:nil];

```
#### 稍微定制版
```
1,导入头文件
//必须
#import "IJSImagePickerController.h"
// 可选
#import "IJSMapViewModel.h"
#import <IJSFoundation/IJSFoundation.h>
#import <Photos/Photos.h>



2, 设置回调的数据
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
大功告成就是这么简单
额外注意点:
1, 国际化: 
Xcode--PROJECT---info --- Localizations---Chinese(Simplified)
2, 在项目的plist文件中添加两个字段
Privacy - Photo Library Usage Description ----允许应用访问相机权限
3, View controller-based status bar appearance 改成 NO  设置电池状态

``` 
###  cocoapods 集成方式

```
pod 'IJSPhotoSDK'
项目中的头文件
#import <IJSImagePickerController.h>
```
最低版本支持是 0.1.0开始
集成步骤和手动拖入的集成一样不再赘述
集成已经完成


### 项目头文件介绍

```
IJSPhotoSDK
// 控制器
1, IJSImagePickerController.h 导航栏控制器，通过改变该控制器的一些属性来达到你想要的效果,开放的外部接口
里面的所有属性都是用来控制选取属性的 比如可以设置 maxImagesCount = 9 最大选取个数等
2,  IJSAlbumPickerController 相册列表控制器 
3,  IJSPhotoPickerController 图片选择控制器,默认是4列显示 
4 , IJSPhotoPreviewController  照片预览控制器
5,  IJS3DTouchController   3DTouch控制器
6,  IJSImageManager   照片管理类 所有的照片处理api都在里面可以直接调用
7, IJSPImageEditManager  图片处理管理器 在开发中......
// 资源
1,  IJSAlbumModel 相册模型
2,  IJSAssetModel  照片模型

IJSImageEditSDK
1, IJSImageManagerController 作为统一的接口
2, IJSImageEditController 图片裁剪控制器
3, IJSVideoCutController  视频裁剪
4, IJSVideoEditController 视频编辑
5,IJSVideoManager 视频处理api
6, TOCropViewController  图片尺寸裁剪

```

### 后期维护方向

1, 组装SDK: 
 1.1 图片视频的滤镜处理
 1.2 自定义相机
 1.3 二维码api增加

2, 拆分SDK

      2.1, 照片预览器 IJSPhotoSDK
      2.2, 图片视频裁剪器 IJSImageEditSDK
      2.3, 视频图片滤镜处理 IJSFilterSDK
      2.4  自定义相机 IJSCameraSDK
      2.5, 二维码 IJSQRCodeSDK


```
重要更新:

1.0.1 : 完善一些细节
1.0.0 : 全面适配 iPhone X
0.1.4 : 全面适配iPhone X
1,修复缩略图界面刷新闪屏问题 2, 修复gif播放背景尺寸不够时候的白屏问题 3, 修复选多张图预览角标不整齐的问题
4修复编辑gif后预览界面不显示修改后的图,5, 新增清理保存沙河路径下的所有视频的api 6,修复一些小细节的bug

```


```
SDK 拆分说明

1,代码拆分 SDK 分 IJSPhotoSDK IJSEditSDK 如果不需要编辑图片或者视频的功能可以直接删除 IJSEditSDK然后剩下的项目哪儿报错就注释掉哪儿的代码就就可以不影响项目的使用,

2,IJSPhoto.bundle 资源 Expression 文件夹属于表情包资源如果需要换成自己的可以随意替换,不需要注意名字,
   Expression文件夹之外的资源属于项目依赖图,如果替换需要同名
   
```
<hr>

# IJSEditSDK 使用文档

地址: https://github.com/wangjinshan/IJSEditSDK

IJSEditSDK主要是处理图片和视频的框架,主要包括 视频处理包括,裁剪,涂鸦,水印,贴图等等

使用:

如果需要贴图请先设置贴图数据,如果不设置就使用内部自带的

```
#import <IJSFoundation/IJSFoundation.h>
#import "IJSEditSDK.h"

// 设置贴图数据
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
    NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
    [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
        IJSMapViewModel *model = [[IJSMapViewModel alloc] initWithImageDataModel:filePath];
        [self.mapDataArr addObject:model];
    }];
    
```

### 处理图片

```
  __weak typeof (self) weakSelf = self;
    UIImage *image =[UIImage imageNamed:@"8"]; //资源
    IJSImageManagerController *vc =[[IJSImageManagerController alloc]initWithEditImage:image];
    // 回调数据
    [vc loadImageOnCompleteResult:^(UIImage *image, NSURL *outputPath, NSError *error) {
        weakSelf.backImageView.image = image;
    }];
    vc.mapImageArr = self.mapDataArr;
    [self presentViewController:vc animated:YES completion:nil];
    
```

### 裁剪视频


```
 IJSVideoCutController *vc =[[IJSVideoCutController alloc] init];
   NSString *str =  [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
//    http://dvideo.spriteapp.cn/video/2017/1210/5a2d27ea6e697_wpd.mp4
    NSURL *inputPath= [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", str]];  //注意本地视频需要加头
//     NSURL *inputPath= [NSURL URLWithString:@"http://dvideo.spriteapp.cn/video/2017/1210/5a2d27ea6e697_wpd.mp4"];  //注意本地视频需要加头
    vc.canEdit = NO;   //裁剪完了不会进入编辑界面
    vc.inputPath = inputPath;
    vc.didFinishCutVideoCallBack = ^(IJSVideoManagerController *controller, NSURL *outputPath, NSError *error, IJSVideoState state) {
        NSLog(@"%@",controller);
        NSLog(@"%@",outputPath);
        NSLog(@"%@",error);
        NSLog(@"%lu",(unsigned long)state);
    };
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];

```

### 视频编辑

```
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
    vc.delegate = self;  // 可以通过代理方法返回数据
    [self.navigationController pushViewController:vc animated:YES];
    
//    [self presentViewController:vc animated:YES completion:nil];

```

#####代理方法可以不写

```
-(void)didFinishCutVideoWithController:(IJSVideoManagerController *)controller outputPath:(NSURL *)outputPath error:(NSError *)error state:(IJSVideoState)state
{
            IJSVideoTestController *testVc = [[IJSVideoTestController alloc] init];
            AVAsset *avaseet = [AVAsset assetWithURL:outputPath];
            testVc.avasset = avaseet;
            [self presentViewController:testVc animated:YES completion:nil];
}
-(void)didFinishCutVideoWithController:(IJSVideoManagerController *)controller outputPath:(NSURL *)outputPath error:(NSError *)error state:(IJSVideoState)state
{
            IJSVideoTestController *testVc = [[IJSVideoTestController alloc] init];
            AVAsset *avaseet = [AVAsset assetWithURL:outputPath];
            testVc.avasset = avaseet;
            [self presentViewController:testVc animated:YES completion:nil];
}
```
### cocopods 集成方法


```
pod 'IJSEditSDK'
```
代码部分和上面一样

<hr>

###IJSNavigation 使用说明


```
直接将 UINavigationController+IJSNavigationController 文件 拖到自己的项目什么都不需要做

 self.noPopAction = YES;  // 这个界面不想要全屏手势了
 或者直接设置
 self.navigationController.recognizerLength = 0;
 
 
```

<hr>

### IJSTagListView 使用说明
   
项目演示:
![](https://upload-images.jianshu.io/upload_images/2845360-f3f12cb59805664d.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/300)

![](https://upload-images.jianshu.io/upload_images/2845360-6434602a198ff8bd.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/300)

#####简单实用:

```
-(void)_setupUI
{
    // 创建标签列表
    IJSTagListView *tagListView = [[IJSTagListView alloc] init];
    tagListView.delegate = self;
    
    /*----------------属性列表设置 可以不设置-----------------*/
    // 设置标签颜色
//    tagListView.tagColor = [UIColor whiteColor];
//    tagListView.isSort = YES;  // 设置成YES 就是可以拖拽
//    tagListView.tagMargin = 10;  // 左边距
//    tagListView.backgroundColor = [UIColor redColor];
    // 设置标签删除图片
//        tagListView.tagDeleteimage =[UIImage imageNamed:@"sns_icon_22"];
//        tagListView.tagDelegateImageHeight = 30;
    
    //    tagListView.isFitTagListViewHeight = NO;
    //    tagListView.tagListViewHeight = 600;
    
//    tagListView.frame = CGRectMake(10, 200, self.view.frame.size.width - 20, 0);   // 高度可以不设置自动会更新
//    tagListView.borderColor = [UIColor yellowColor];
//    tagListView.borderWidth = 5;
//    tagListView.tagButtonMargin = 5;
    
    //    tagListView.tagClass = [UIButton class];
//    tagListView.tagCornerRadius = 5;
    //    tagListView.tagSize =CGSizeMake(80, 80);   // 如果设置此属性则规律排版
//    tagListView.tagFont =[UIFont systemFontOfSize:17];
    /*---------------------属性列表设置----------------------------*/
    [self.tagListArr enumerateObjectsUsingBlock:^(IJSYiTagsListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 设置标签背景色
        if (idx == 0)
        {
            tagListView.tagBackgroundColor = [UIColor redColor];
        }
        [tagListView addTag:obj.themeName];
        
    }];
    [self.scrollView addSubview:tagListView];

    // 点击标签，就会调用,点击标签，删除标签
    __weak typeof (self) weakSelf = self;
    __block typeof (tagListView) weaktagListView = tagListView;
    /// 点击方法
    tagListView.clickTagBlock = ^(NSString *tag){
        [weaktagListView deleteTag:tag];  // 删除
        
        IJSTagListView *selectList =[[IJSTagListView alloc]initWithFrame:CGRectMake(10, 20,  self.view.bounds.size.width -20, 0)];
        if (self.lastTagStrng)
        {
            [selectList deleteTag:self.lastTagStrng];
        }
        selectList.tagColor = [UIColor whiteColor];
        selectList.tagBackgroundColor =[UIColor greenColor];
        selectList.tagFont = [UIFont systemFontOfSize:15];
        [selectList addTag:tag];
        [weakSelf.scrollView addSubview:selectList];
        self.lastTagStrng = tag;
    };
    
}
#pragma mark -----------------------taglist delegate-  可以不写-----------------------------
-(void)didTapCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
    //    NSLog(@"---tap-------%@",text);
}
-(void)movingCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
    //    NSLog(@"---moving-----------%@",text);
}

-(void)endMoveCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
    //    NSLog(@"------end-------%@",text);
}

```

<hr>

后续实用的小demo 也会在此处更新欢迎关注


