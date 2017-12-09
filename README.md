# IJSPhotoSDK
ios多图选择,高仿微信发朋友圈的功能

# 外包合作 QQ: 1096452045   

#简书地址: http://www.jianshu.com/u/874b526fa570

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

```
1,导入头文件
//必须
#import "IJSImagePickerController.h"
// 可选
#import "IJSMapViewModel.h"
#import <IJSFoundation/IJSFoundation.h>
#import <Photos/Photos.h>
2, 设置回调的数据,以下二者选一个
  2.1,签订协议
    <IJSImagePickerControllerDelegate>
  2.2,获取用户选择的图片等资源可以通过 block 也可以通过代理方法
如下:
// 1 block 方法
- (IBAction)_selectImageActin:(id)sender
{
    __weak typeof(self) weakSelf = self;
    IJSImagePickerController *imageVc = [[IJSImagePickerController alloc] initWithMaxImagesCount:3 delegate:self];
    // 可选写不写
    imageVc.minImagesCount = 1; // 图片最小选择要求,可以不设置
    imageVc.minVideoCut = 4;   //视频最小裁剪尺寸 可选(默认是4秒)
    //可选  可以通过代理的回调去获取数据
    imageVc.didFinishUserPickingImageHandle = ^(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, BOOL isSelectOriginalPhoto, IJSPExportSourceType sourceType) {
        if (sourceType == IJSPImageType)
        {
            weakSelf.imageArr = [NSMutableArray arrayWithArray:photos];
            [weakSelf.myTableview reloadData];
        }
        else
        {
            NSLog(@"%@",avPlayers);
        }
    };
    /*
     1,贴图资源可以不传,不穿则读取SDK内存的资源,可以找到 JSPhotoSDK.bundle Expression文件 把自己的资源放到里面不需要管文件名字sdk自己会便利
     2, 如果是外部动态添加资源选择下面添加的方式 需要传 IJSMapViewModel 的数组
     */
//    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
//    NSString *filePath =[bundlePath stringByAppendingString:@"/Expression"];
//    [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
//        IJSMapViewModel *model =[[IJSMapViewModel alloc]initWithImageDataModel:filePath];
//        [self.mapDataArr addObject:model];
//        imageVc.mapImageArr  = self.mapDataArr;
//    }];
      [self presentViewController:imageVc animated:YES completion:nil];
}
 //  不想在block中做,可以选择代理方法 
#pragma mark - 代理方法
-(void)imagePickerController:(IJSImagePickerController *)picker isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto didFinishPickingPhotos:(NSArray<UIImage *> *)photos assets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos avPlayers:(NSArray *)avPlayers sourceType:(IJSPExportSourceType)sourceType
{
    if (sourceType == IJSPVideoType)
    {
        IJSVideoTestController *testVc =[[IJSVideoTestController alloc] init];
        AVAsset *avaseet = [AVAsset assetWithURL:avPlayers.firstObject];
        testVc.avasset = avaseet;
        [self presentViewController:testVc animated:YES completion:nil];
    }
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

重要更新:
1.0.0 : 全面适配 iPhone X
0.1.4 : 全面适配iPhone X
1,修复缩略图界面刷新闪屏问题 2, 修复gif播放背景尺寸不够时候的白屏问题 3, 修复选多张图预览角标不整齐的问题
4修复编辑gif后预览界面不显示修改后的图,5, 新增清理保存沙河路径下的所有视频的api 6,修复一些小细节的bug





