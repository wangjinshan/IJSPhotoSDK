//
//  IJSMapViewMapCell.m
//  IJSMapView
//
//  Created by shange on 2017/9/11.
//  Copyright © 2017年 shange. All rights reserved.
//

#import "IJSMapViewMapCell.h"
#import "IJSExtension.h"
#import <IJSFoundation/IJSFoundation.h>

@interface IJSMapViewMapCell ()
@property (nonatomic, weak) UIImageView *itemImageView; // 缩略图
@property (nonatomic, weak) UILabel *nameLabel;         // 名字label
@end

@implementation IJSMapViewMapCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.js_width * 0.1, self.js_height * 0.1, self.js_width * 0.8, self.js_height * 0.8)];
        [self addSubview:itemImageView];

        itemImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.itemImageView = itemImageView;

        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.js_width * 0.1, self.js_height * 0.8, self.js_width * 0.8, self.js_width * 0.2)];
        [self addSubview:nameLabel];
        nameLabel.font = [UIFont systemFontOfSize:12];
        self.nameLabel = nameLabel;
    }
    return self;
}

- (void)setItemImage:(UIImage *)itemImage
{
    _itemImage = itemImage;
    self.itemImageView.image = itemImage;
}

- (void)setLabelTitle:(NSString *)labelTitle
{
    _labelTitle = labelTitle;
    self.nameLabel.text = labelTitle;
}

@end
