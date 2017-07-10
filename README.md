# IJSPhotoSDK
ios多图选择,高仿微信发朋友圈的功能
#    IJSPhotoSDK  集成文档

### 项目介绍:
主要模仿微信的发朋友圈多图选择,修改图片等功能
主要实现功能如下:

```
1, 照片选取预览,有相册UI 预览UI 详情UI 可以创建相册等
2, 预览UI 详情UI 可以通过3DTouch的方式进行查看
3, 可以删除照片 收藏照片
4, 可以通过3DTouch或者点击播放 Video gif  livephoto等资源
5,  预览详情支持 单击 双击 缩合等手势处理照片查看
6, 支持国际化配置

```


### 手动拖入的方式
git下载地址:  https://github.com/wangjinshan/IJSPhotoSDK 
#### 1, 下载sdk并把里面的SDK文件夹直接拖入到项目中去
#### 2, 在项目的点击事件中实现如下代码

```
1,导入头文件
#import <IJSImagePickerController.h>
2,签订协议
<IJSImagePickerControllerDelegate>
3,获取用户选择的图片等资源可以通过 block 也可以通过代理方法
如下:
// 1 block 方法
 IJSImagePickerController *vc =[[IJSImagePickerController alloc]initWithMaxImagesCount:9 delegate:self];
    vc.didFinishUserPickingImageHandle = ^(NSArray<UIImage *> *photos, NSArray *avPlayers, NSArray *assets, NSArray<NSDictionary *> *infos, BOOL isSelectOriginalPhoto) {
        NSLog(@"---k---%@",photos.firstObject);
    };
    [self presentViewController:vc animated:YES completion:nil];
// 2 协议方法
 IJSImagePickerController *vc =[[IJSImagePickerController alloc]initWithMaxImagesCount:9 delegate:self];
    [self presentViewController:vc animated:YES completion:nil];
    
-(void)imagePickerController:(IJSImagePickerController *)picker isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto didFinishPickingPhotos:(NSArray<UIImage *> *)photos assets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos avPlayers:(NSArray *)avPlayers
{
    NSLog(@"----w---%@",photos.firstObject);
}
大功告成就是这么简单
额外注意点:
1, 国际化: 
Xcode--PROJECT---info --- Localizations---Chinese(Simplified)
2, 在项目的plist文件中添加两个字段
Privacy - Photo Library Usage Description ----允许应用访问相机权限
View controller-based status bar appearance --NO 改变导航条

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

### 项目目录介绍:
目录: 


```
SDK:  1, IJSPhotoSDK主要存放项目文件和项目资源,
         里面 IJSPhotoSDKFiles 就是项目文件 
         Support 是UI资源

        2, Required 存放必须的两个依赖库 
        IJSFoundation 主要是公共库的方法 
        IJSUExtension 是开源 IJSUI的扩展
    
```
### 项目头文件介绍

```
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

```
###  目前发现的不足:
1, 照片视频暂时不支持编辑....开发中
2, 理论上支持到ios之上 ios7 暂时没测试
3, 删除照片,创建相册 ui 没有更新
