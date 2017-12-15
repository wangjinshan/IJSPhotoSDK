//
//  IJSMapViewMapCell.h
//  IJSMapView
//
//  Created by shange on 2017/9/11.
//  Copyright © 2017年 shange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IJSMapViewModel.h"

@interface IJSMapViewMapCell : UICollectionViewCell

@property (nonatomic, weak) UIImage *itemImage;   // 展示数据对象
@property (nonatomic, copy) NSString *labelTitle; // 标题

@end
