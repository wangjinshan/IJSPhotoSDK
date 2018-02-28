//
//  IJSMapViewUIMacro.h
//  IJSMapView
//
//  Created by shange on 2017/9/11.
//  Copyright © 2017年 shange. All rights reserved.
//

#ifndef IJSMapViewUIMacro_h
#define IJSMapViewUIMacro_h

#define IJSMapViewHeight (JSScreenHeight * (230.0 / 667))
#define IJSMapViewMapH (JSScreenHeight * (140.0 / 667))
#define IJSMapViewThumbH (JSScreenHeight * (50.0 / 667))
#define IJSMapViewPageH (JSScreenHeight * (40.0 / 667))
#define IJSMapViewMapItemMarginLeft JSScreenWidth *(30.0 / 375)                  // 列间距
#define IJSMapViewMapItemMarginTop JSScreenHeight *(10.0 / 667)                  // 行间距
#define IJSMapViewMapItemW (JSScreenWidth - 5 * IJSMapViewMapItemMarginLeft) / 4 //item 宽度
#define IJSMapViewMapItemH (IJSMapViewMapH - 3 * IJSMapViewMapItemMarginTop) / 2 //item 高度

static NSString *const CellID = @"IJSMapViewThumbCell";
static NSString *const MapCell = @"IJSMapViewMapCell";

#endif /* IJSMapViewUIMacro_h */
