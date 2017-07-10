//
//  IJSUConst.h
//  IJSExtensionProject
//
//  Created by shan on 2017/7/9.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#ifndef IJSUConst_h
#define IJSUConst_h

#define JSScreenWidth  [[UIScreen mainScreen]bounds].size.width
#define JSScreenHeight  [[UIScreen mainScreen]bounds].size.height

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

#endif /* IJSUConst_h */
