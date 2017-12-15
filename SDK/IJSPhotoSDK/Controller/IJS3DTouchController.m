//
//  IJS3DTouchController.m
//  JSPhotoSDK
//
//  Created by shan on 2017/6/24.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJS3DTouchController.h"
#import "IJSConst.h"
#import "IJSImageManager.h"
#import "IJSImagePickerController.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"

@interface IJS3DTouchController ()

/* 图片参数 */
@property (nonatomic, weak) UIImageView *backImageView;

@end

@implementation IJS3DTouchController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JSScreenWidth, JSScreenHeight)];
    [[IJSImageManager shareManager] getPhotoWithAsset:self.model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        backImageView.image = photo;
    }];
    [self.view addSubview:backImageView];
    self.backImageView = backImageView;
}

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:[NSBundle localizedStringForKey:@"Delete"] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *_Nonnull action, UIViewController *_Nonnull previewViewController) {
        __weak typeof(self) weakSelf = self;
        [[IJSImageManager shareManager] deleteAssetArr:@[self.model.asset] completion:^(id assetCollection, NSError *error, BOOL isExistedOrIsSuccess) {

            if (!error)
            {
                [weakSelf showAlertWithTitle:@"照片已经从照片库中删除"];
            }
            else
            {
                [weakSelf showAlertWithTitle:@"删除失败"];
            }
        }];
    }];

    UIPreviewAction *collection = [UIPreviewAction actionWithTitle:[NSBundle localizedStringForKey:@"Collection"] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction *_Nonnull action, UIViewController *_Nonnull previewViewController) {
        if (iOS8Later)
        {
            __weak typeof(self) weakSelf = self;
            [[IJSImageManager shareManager] collectedAsset:self.model.asset completion:^(NSError *error, BOOL isExistedOrIsSuccess) {
                if (error)
                {
                    [weakSelf showAlertWithTitle:[NSString stringWithFormat:@"%@", error]];
                }
                else
                {
                    [weakSelf showAlertWithTitle:@"收藏成功,可以到相册界面,查看个人收藏相册"];
                }
            }];
        }
        else
        {
        }
    }];

    //    UIPreviewAction *export = [UIPreviewAction actionWithTitle:[NSBundle localizedStringForKey:@"Export"] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
    //
    //        if (self.model.type== JSAssetModelMediaTypeVideo)
    //        {
    //
    //          [[IJSImageManager shareManager]getVideoOutputPathWithAsset:self.model.asset completion:^(NSString *outputPath) {
    //               [self  showAlertWithTitle:@"导出成功" ];
    //          }];
    //        }else{
    //            [self  showAlertWithTitle:@"功能未开发" ];
    //        }
    //
    //    }];

    //    UIPreviewAction *Edit = [UIPreviewAction actionWithTitle:[NSBundle localizedStringForKey:@"Edit"] style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
    //
    //        [self  showAlertWithTitle:@"功能开发" ];
    //    }];

    NSArray *actions = @[action1, collection];
    return actions;
}

//按住移动or压力值改变时的回调
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray *arrayTouch = [touches allObjects];

    UITouch *touch = (UITouch *) [arrayTouch lastObject];

    if (touch.view == self.view)
    {
        //显示压力值
        //        NSLog(@"%@", [NSString stringWithFormat:@"压力值:%f",touch.force]);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
}

- (void)showAlertWithTitle:(NSString *)title
{
    if (iOS8Later)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
        [[IJSFViewController currentViewController] presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:[NSBundle localizedStringForKey:@"OK"] otherButtonTitles:nil, nil] show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
