//
//  IJSMapViewCollectionViewLayout.m
//  IJSMapView
//
//  Created by shange on 2017/9/11.
//  Copyright © 2017年 shange. All rights reserved.
//

#import "IJSMapViewCollectionViewLayout.h"
#import "IJSExtension.h"
#import "IJSMapViewUIMacro.h"

@interface IJSMapViewCollectionViewLayout ()

@property (nonatomic, assign) int line;        // 行数
@property (nonatomic, assign) int item;        // 列数
@property (nonatomic, assign) long pageNumber; // 页数
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSMutableArray *leftArray;
@property (nonatomic, strong) NSMutableDictionary *heigthDic;
@property (nonatomic, strong) NSMutableArray *attributes;
@property (nonatomic, strong) NSMutableArray *indexPathsToAnimate;
@property (nonatomic, assign) CGFloat itemSpacing; // 列间距
@property (nonatomic, assign) CGFloat lineSpacing; // 行间距

@end

@implementation IJSMapViewCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.leftArray = [NSMutableArray new];
        self.heigthDic = [NSMutableDictionary new];
        self.attributes = [NSMutableArray new];
        self.pageNumber = 1;
        self.line = 2;
        self.item = 1;
        self.itemSpacing = 10;
        self.lineSpacing = 10;
    }
    return self;
}
/*1,首先我们需要建立一个layout类继承自UICollectionViewLayout,不继承自UICollectionViewFlowLayout,因为 UICollectionViewFlowLayout已经写好了逻辑，我们不清楚他是怎么写的，避免出问题，还是完全自定义 在prepareLayout中计算行间距列间距，这个方法是每次要布局时都会调用，你可以在这里面设置默认参数*/
- (void)prepareLayout
{
    [super prepareLayout]; //需调用父类方法
    CGFloat itemWidth = self.itemSize.width - 1;
    CGFloat itemHeight = self.itemSize.height - 1;

    CGFloat width = self.collectionView.frame.size.width;
    CGFloat height = self.collectionView.frame.size.height;

    CGFloat contentWidth = (width - self.sectionInset.left - self.sectionInset.right); //内容宽
    if (contentWidth >= (2 * itemWidth + self.minimumInteritemSpacing))
    {                                                                                           //如果列数大于2
        int tempLine = (contentWidth - itemWidth) / (itemWidth + self.minimumInteritemSpacing); //内容宽去除第一个item 然后计算剩余个数
        self.item = tempLine + 1;                                                               //加回来第一个
        self.itemSpacing = self.minimumInteritemSpacing;
    }
    else
    { //如果列数为一行
        self.itemSpacing = 0;
    }

    CGFloat contentHeight = (height - self.sectionInset.top - self.sectionInset.bottom);
    if (contentHeight >= (2 * itemHeight + self.minimumLineSpacing))
    { //如果行数大于2行
        int m = (contentHeight - itemHeight) / (itemHeight + self.minimumLineSpacing);
        self.line = m + 1;
        self.lineSpacing = self.minimumLineSpacing;
    }
    else
    { //如果行数数为一行
        self.lineSpacing = 0;
    }

    int itemNumber = 0;
    itemNumber = itemNumber + (int) [self.collectionView numberOfItemsInSection:0]; //获取资源个数
    self.pageNumber = (itemNumber - 1) / (self.line * self.item) + 1;
}

//2 确定collectionView的所有内容的尺寸。
- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.bounds.size.width * self.pageNumber, self.collectionView.bounds.size.height);
}
/*重写layoutAttributesForItemAtIndexPath：方法，这个方法返回的是cell的attribute，意思是cell的属性信息，包括位置大小形变等等。你可以在这里自定义cell的排序算法，随便怎么排列都行，但要有规律，不然重排会出问题*/
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGRect frame;
    frame.size = self.itemSize;
    long onePagenumber = self.line * self.item; //下面计算每个cell的frame   可以自己定义
    long lineNumber = 0;                        // 行数
    long page = 0;                              // 页码
    if (indexPath.item >= onePagenumber)
    {
        page = indexPath.item / onePagenumber; //计算页数不同时的左间距
        lineNumber = (indexPath.item % onePagenumber) / self.item;
    }
    else
    {
        lineNumber = indexPath.item / self.item;
    }
    long lineIndex = indexPath.item % self.item;
    frame.origin = CGPointMake(lineIndex * self.itemSize.width + (lineIndex) *self.itemSpacing + self.sectionInset.left + (indexPath.section + page) * self.collectionView.frame.size.width, lineNumber * self.itemSize.height + (lineNumber) *self.lineSpacing + self.sectionInset.top);

    attribute.frame = frame;
    return attribute;
}

/*3, 重写layoutAttributesForElementsInRect: 这个方法返回可见范围内的全部cell的attribute，cell的实时属性是由这个方法给的，意思就是说，例如你想cell移到屏幕中央时变大，就在这里写，然后替换原数组的attribute，返回array就行了*/
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *tmpAttributes = [NSMutableArray new];
    for (int j = 0; j < self.collectionView.numberOfSections; j++)
    {
        NSInteger count = [self.collectionView numberOfItemsInSection:j];
        for (NSInteger i = 0; i < count; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:j];
            [tmpAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    self.attributes = tmpAttributes;
    return self.attributes;
}
/*
 在需要更新layout时，需要给当前layout发送
 1)-invalidateLayout， 该消息会立即返回，并且预约在下一个loop的时候刷新当前layout
 2)-prepareLayout，
 3)依次再调用-collectionViewContentSize和-layoutAttributesForElementsInRect来生成更新后的布局
 */
// cell的对准方格方法
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    //proposedContentOffset是没有对齐到网格时本来应该停下的位置
    CGFloat offsetY = MAXFLOAT;
    CGFloat offsetX = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + self.itemSize.width / 2;
    CGFloat verticalCenter = proposedContentOffset.y + self.itemSize.height / 2;
    CGRect targetRect = CGRectMake(0, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];

    //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    CGPoint offPoint = proposedContentOffset;
    for (UICollectionViewLayoutAttributes *layoutAttributes in array)
    {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        CGFloat itemVerticalCenter = layoutAttributes.center.y;
        if (ABS(itemHorizontalCenter - horizontalCenter) && (ABS(offsetX) > ABS(itemHorizontalCenter - horizontalCenter)))
        {
            offsetX = itemHorizontalCenter - horizontalCenter;
            offPoint = CGPointMake(itemHorizontalCenter, itemVerticalCenter);
        }
        if (ABS(itemVerticalCenter - verticalCenter) && (ABS(offsetY) > ABS(itemVerticalCenter - verticalCenter)))
        {
            offsetY = itemHorizontalCenter - horizontalCenter;
            offPoint = CGPointMake(itemHorizontalCenter, itemVerticalCenter);
        }
    }
    return offPoint;
}

- (BOOL)ShouldinvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

@end
