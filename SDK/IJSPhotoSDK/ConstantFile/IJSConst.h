
//
//  IJSConst.h
//  JSPhotoSDK
//
//  Created by shan on 2017/6/2.
//  Copyright © 2017年 shan. All rights reserved.
//

#ifndef IJSConst_h
#define IJSConst_h

// 导航条的高度
#define NavigationHeight 64
#define TabbarHeight 44     // 工具条的高度
#define ToorHeight 20
#define albumCellHright 60
#define cellMargin 3 // cell 直接的距离

#define JSScreenWidth [[UIScreen mainScreen] bounds].size.width
#define JSScreenHeight [[UIScreen mainScreen] bounds].size.height

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

// 相册界面的常量
#define thumbImageMarginTop 2
#define thumbImageMarginleft 2
#define thumbImageViewWidth 55
#define thumbImageViewHeight 55
#define titleFontSize 17
#define titleMarginLeft 10
#define titleMarginTop 20
#define titleHeight 20
#define numberWidth 50
#define numberHeight 20
#define arrowImageWidth 10
#define arrowImageHeight 10
#define arrowImageMarginTop 20
#define arrowImageMarginRight 20
// 图片缩放比
#define miniZoomScale 1
#define maxZoomScale 2








#endif /* IJSConst_h */
