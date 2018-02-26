//
//  IJSSelectedCell.h
//  IJSDemo
//
//  Created by shan on 2017/8/10.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IJSAssetModel;

@interface IJSSelectedCell : UICollectionViewCell

/* 选中的数据 */
@property (nonatomic, weak) IJSAssetModel *selectedModel;
/* 刷新UI的block */
@property (nonatomic, copy) void (^didClickButton)(BOOL isSelected);
/* 记录一下第一次进来的时候的index */
@property (nonatomic, assign) NSInteger pushSelectedIndex;

/* 参数说明 */
@property (nonatomic, weak) UIImageView *backImageView;

@end
