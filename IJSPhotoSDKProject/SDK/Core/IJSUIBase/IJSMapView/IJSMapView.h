//
//  IJSMapView.h
//  IJSMapView
//
//  Created by shange on 2017/9/10.
//  Copyright © 2017年 shange. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IJSMapViewModel;
/**
 贴图数据UI的设置 --- 设计模式是数组嵌套模型的模式 --- 外面的数组表示底部的分类--里面的模型数组表示分类展示的具体数据
 */
@interface IJSMapView : UIView

/**
 默认初始化方法

 @param frame 尺寸
 @param imageData 图片数据,数组嵌套数组的模式
 @return 自己
 */
- (instancetype)initWithFrame:(CGRect)frame imageData:(NSMutableArray<IJSMapViewModel *> *)imageData;

@property (nonatomic, copy) void (^didClickItemCallBack)(NSInteger index, UIImage *indexImage); //点击的下标
@property (nonatomic, copy) void (^cancelCallBack)(void);                                       // 取消按钮

@end
// 375x667    230(总高)  180(贴图)   55(贴图) * 55   45(最小较大小) * 32
