//
//  IJSMapViewCollectionViewLayout.h
//  IJSMapView
//
//  Created by shange on 2017/9/11.
//  Copyright © 2017年 shange. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自定义 layout
 */
@interface IJSMapViewCollectionViewLayout : UICollectionViewLayout

/**
 行间距
 */
@property (nonatomic) CGFloat minimumLineSpacing;

/**
 列间距
 */
@property (nonatomic) CGFloat minimumInteritemSpacing;

/**
 item 大小
 */
@property (nonatomic) CGSize itemSize;

/**
 内容上下左右边距
 */
@property (nonatomic) UIEdgeInsets sectionInset;

/**
 初始化方法

 @return 自己
 */
- (instancetype)init;

@end
