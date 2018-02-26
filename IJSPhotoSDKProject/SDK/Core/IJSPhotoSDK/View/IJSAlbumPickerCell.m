//
//  IJSAlbumPickerCell.m
//  JSPhotoSDK
//
//  Created by shan on 2017/5/29.
//  Copyright © 2017年 shan. All rights reserved.
//

#import "IJSAlbumPickerCell.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"
#import "IJSImageManager.h"
#import "IJSConst.h"
#define ScreenW [[UIScreen mainScreen] bounds].size.width

@interface IJSAlbumPickerCell ()
/* 缩略图 */
@property (nonatomic, weak) UIImageView *thumbImageView;
/* 标题 */
@property (nonatomic, weak) UILabel *titleLable;
/* 总是 */
@property (nonatomic, weak) UILabel *numberLabel;
/* 右边箭头 */
@property (nonatomic, weak) UIImageView *arrowImage;
@end

@implementation IJSAlbumPickerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self _createrUI];
    }
    return self;
}

#pragma mark 私有方法
- (void)_createrUI
{
    // 缩略图
    UIImageView *thumbImageView = [UIImageView new];
    thumbImageView.backgroundColor = [UIColor redColor];
    thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    thumbImageView.clipsToBounds = YES;
    [self.contentView addSubview:thumbImageView];
    self.thumbImageView = thumbImageView;
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.contentView addSubview:titleLabel];
    self.titleLable = titleLabel;
    // 数据
    UILabel *numberLabel = [UILabel new];
    [self.contentView addSubview:numberLabel];
    self.numberLabel = numberLabel;
    // 右边箭头
    UIImageView *arrowImage = [UIImageView new];
    arrowImage.image = [IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"rightArrow@2x" imageType:@"png"];
    [self.contentView addSubview:arrowImage];
    self.arrowImage = arrowImage;
    self.arrowImage.autoresizesSubviews = NO;

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(2, 0, ScreenW - 4, 0.3)];
    line.backgroundColor = [UIColor colorWithRed:203 / 255.0 green:203 / 255.0 blue:203 / 255.0 alpha:1];
    [self.contentView addSubview:line];
}
- (void)layoutSubviews
{
    self.thumbImageView.frame = CGRectMake(thumbImageMarginTop, thumbImageMarginleft, thumbImageViewWidth, thumbImageViewHeight);
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:titleFontSize]};
    CGSize size = [self.titleLable.text sizeWithAttributes:attrs];
    [self.titleLable setFrame:CGRectMake(thumbImageMarginleft + thumbImageViewWidth + titleMarginLeft, titleMarginTop, size.width, titleHeight)];
    self.numberLabel.frame = CGRectMake(self.titleLable.frame.origin.x + self.titleLable.frame.size.width + titleMarginLeft, titleMarginTop, numberWidth, numberHeight);
    self.arrowImage.frame = CGRectMake(self.frame.size.width - arrowImageMarginRight, arrowImageMarginTop, arrowImageWidth, arrowImageHeight);
}

#pragma mark se方法数据
// 设置参数
- (void)setModels:(IJSAlbumModel *)models
{
    _models = models;
    _titleLable.text = models.name;
    _numberLabel.text = [NSString stringWithFormat:@"(%ld)", (long) models.count];
    // 请求封面的照片
    __weak typeof(self) weakSelf = self;
    [[IJSImageManager shareManager] getPostImageWithAlbumModel:models completion:^(UIImage *postImage) {
        weakSelf.thumbImageView.image = postImage;
    }];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
