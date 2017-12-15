//
//  IJSImageConst.h
//  IJSImageEditSDK
//
//  Created by shan on 2017/7/12.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#ifndef IJSImageConst_h
#define IJSImageConst_h

#define IJSLOG @"金山原创"

#define IJSImageEditScreenWidth [[UIScreen mainScreen] bounds].size.width
#define IJSImageEditScreenHeight [[UIScreen mainScreen] bounds].size.height

#define buttonSzieWidth 30
#define ToolBarMarginLeft ([[UIScreen mainScreen] bounds].size.width - buttonSzieWidth * 5) / 6
#define ToolBarMarginBottom 44
#define IJSINavigationHeight 64

#define ColorButtonViewHeight 30     // 背景搞
#define ColorButtonViewMarginLeft 30 // 左边距
//#define ColorButtonViewSpace 20    // button间距
#define ColorButtonViewMarginBottom 120                                                //下边距
#define ColorButtonViewWidth 60                                                        // 工具条宽度
#define ColorButtonViewButtonSpace (JSScreenWidth - 2 * ColorButtonViewMarginLeft) / 8 // button之间的间隙
#define ColorButtonViewButtonWidth 20                                                  //button的宽度

#define IJSIMapViewCellHeight 80
#define IJSIMapViewHeight 90
#define IJSMapViewCellMargin 2
#define IJSMapViewCellInteritemSpacing 2

#define IJSIMapViewExportViewButtonHeight 20
#define IJSIMapViewExportViewImageHeight 100
#define IJSIMapViewExportViewImageMarginLeft 10
#define IJSIMapViewExportViewImageSquareWidth 5

#define miniVideoZoomScale 1
#define maxVideoZoomScale 3

#define IJSIImputTextMarginTop 64
#define IJSIImputTextMarginLeft 10

#define IJSImageMosaicButtonHeight 30

#define IJSImageMosaicLevel 30

#define IJSVideotrimViewHeight IJSImageEditScreenHeight * 0.13
#define IJSVideoRulerHeight IJSVideotrimViewHeight * 0.3 // 刻度尺的高度

#define IJSVideoEditNavigationHeight 44

#define IJSVideoSecondCuttrimViewHeight IJSImageEditScreenHeight * 0.20

#endif /* IJSImageConst_h */

// http://www.cnblogs.com/vicstudio/p/3358358.html
// http://www.jianshu.com/p/e4bebae1b36f
//
