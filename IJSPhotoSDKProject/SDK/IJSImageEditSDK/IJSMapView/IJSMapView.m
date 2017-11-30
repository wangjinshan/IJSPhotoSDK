//
//  IJSMapView.m
//  IJSMapView
//
//  Created by shange on 2017/9/10.
//  Copyright © 2017年 shange. All rights reserved.
//

#import "IJSMapView.h"
#import "IJSExtension.h"
#import <IJSFoundation/IJSFoundation.h>
#import "IJSMapViewThumbCell.h"
#import "IJSMapViewMapCell.h"
#import "IJSMapViewCollectionViewLayout.h"
#import "IJSMapViewUIMacro.h"

@interface IJSMapView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray<IJSMapViewModel *> *modelArr; // 所有的数据
@property (nonatomic, weak) UICollectionView *thumbCollectionView;         //概括ui
@property (nonatomic, weak) UICollectionView *mapCollection;               // 贴图
@property (nonatomic, weak) UIPageControl *pageControl;                    // 贴图小点
@property (nonatomic, weak) UIScrollView *backScrollView;                  // 滚动图
@property (nonatomic, assign) NSInteger pageNumber;                        // 需要的页数
@property (nonatomic, strong) NSMutableArray *imageArr;                    // 图片总的数据
@end

@implementation IJSMapView

- (instancetype)initWithFrame:(CGRect)frame imageData:(NSMutableArray<IJSMapViewModel *> *)imageData
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imageArr = [NSMutableArray array];
        self.backgroundColor = [IJSFColor colorWithR:240 G:240 B:240 alpha:1];
        self.modelArr = imageData;
        [self _setupUI];
    }
    return self;
}
/// UI
- (void)_setupUI
{
    //计算需要的页数 处理数据
    [self _setupNeedPageNumber:0];
    // 设置数据
    IJSMapViewModel *model = self.modelArr.firstObject;
    self.imageArr = model.imageDataArr;

    // 两个collectionView
    [self _setupCollection];
    // 取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancelButton.frame = CGRectMake(self.js_width - IJSMapViewThumbH, self.js_height - IJSMapViewThumbH, IJSMapViewThumbH, IJSMapViewThumbH);
    [cancelButton setImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:nil grandson:nil imageName:@"chexiao@2x" imageType:@"png"] forState:UIControlStateNormal];
    [self addSubview:cancelButton];
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    // 小点
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, IJSMapViewMapH, self.js_width, IJSMapViewPageH)];
    pageControl.backgroundColor = [IJSFColor colorWithR:240 G:240 B:240 alpha:1];
    pageControl.numberOfPages = self.pageNumber;
    pageControl.pageIndicatorTintColor = [UIColor blueColor];
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    pageControl.currentPage = 0;
    [self addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)_setupCollection
{
    //中间的collectionview
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(IJSMapViewThumbH, IJSMapViewThumbH);
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    UICollectionView *thumbCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.js_height - IJSMapViewThumbH, self.js_width - IJSMapViewThumbH - 5, IJSMapViewThumbH) collectionViewLayout:layout];
    thumbCollectionView.backgroundColor = [UIColor whiteColor];
    thumbCollectionView.alwaysBounceHorizontal = YES;
    thumbCollectionView.showsVerticalScrollIndicator = NO;
    thumbCollectionView.showsHorizontalScrollIndicator = NO;
    thumbCollectionView.pagingEnabled = YES;
    [self addSubview:thumbCollectionView];
    thumbCollectionView.dataSource = self;
    thumbCollectionView.delegate = self;
    self.thumbCollectionView = thumbCollectionView;
    [thumbCollectionView registerClass:[IJSMapViewThumbCell class] forCellWithReuseIdentifier:CellID];

    //贴图的collection
    IJSMapViewCollectionViewLayout *mapLayout = [[IJSMapViewCollectionViewLayout alloc] init];
    mapLayout.itemSize = CGSizeMake(IJSMapViewMapItemW, IJSMapViewMapItemH);
    mapLayout.minimumLineSpacing = IJSMapViewMapItemMarginTop;
    mapLayout.minimumInteritemSpacing = IJSMapViewMapItemMarginLeft;
    mapLayout.sectionInset = UIEdgeInsetsMake(IJSMapViewMapItemMarginTop, IJSMapViewMapItemMarginLeft, IJSMapViewMapItemMarginTop, IJSMapViewMapItemMarginLeft); //上下左右边距

    UICollectionView *mapCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.js_width, IJSMapViewMapH) collectionViewLayout:mapLayout];
    mapCollection.contentOffset = CGPointMake(self.js_width, 0);
    mapCollection.pagingEnabled = YES;
    mapCollection.backgroundColor = [IJSFColor colorWithR:240 G:240 B:240 alpha:1];
    mapCollection.alwaysBounceHorizontal = YES;
    mapCollection.showsVerticalScrollIndicator = NO;
    mapCollection.showsHorizontalScrollIndicator = NO;
    mapCollection.pagingEnabled = YES;
    [self addSubview:mapCollection];
    mapCollection.dataSource = self;
    mapCollection.delegate = self;
    self.mapCollection = mapCollection;
    [mapCollection registerClass:[IJSMapViewMapCell class] forCellWithReuseIdentifier:MapCell];
}

/*-----------------------------------collection-------------------------------------------------------*/
#pragma mark collectionview delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.mapCollection)
    {
        return self.imageArr.count;
    }
    else if (collectionView == self.thumbCollectionView)
    {
        return self.modelArr.count;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.mapCollection)
    {
        IJSMapViewMapCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MapCell forIndexPath:indexPath];
        cell.itemImage = [UIImage imageWithContentsOfFile:self.imageArr[indexPath.row]];
        return cell;
    }
    else
    {
        IJSMapViewThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
        cell.imageModel = self.modelArr[indexPath.row];
        return cell;
    }
    return nil;
}
#pragma mark 点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.mapCollection)
    {
        if (self.didClickItemCallBack)
        {
            self.didClickItemCallBack(indexPath.row, [UIImage imageWithContentsOfFile:self.imageArr[indexPath.row]]);
        }
    }
    else
    {
        [self.modelArr enumerateObjectsUsingBlock:^(IJSMapViewModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (indexPath.row == idx)
            {
                obj.isDidClick = YES;
            }
            else
            {
                obj.isDidClick = NO;
            }
        }];
        // 设置数据
        [self _setupNeedPageNumber:indexPath.row];
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = self.pageNumber;
        [self.mapCollection setContentOffset:CGPointMake(0, 0)]; // 偏移量清0

        IJSMapViewModel *model = self.modelArr[indexPath.row];
        self.imageArr = model.imageDataArr;
        [collectionView reloadData];
        [self.mapCollection reloadData];
    }
}
//拖拽---最准确的计算方法
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.pageControl.currentPage = targetContentOffset->x / self.js_width;
}

#pragma mark - 取消按钮
- (void)cancelButtonAction:(UIButton *)button
{
    if (self.cancelCallBack)
    {
        self.cancelCallBack();
    }
}

#pragma mark - 重新计算需要page的个数
- (void)_setupNeedPageNumber:(long)index
{
    if (self.modelArr[index].imageDataArr.count / 8 == 0)
    {
        self.pageNumber = self.modelArr[index].imageDataArr.count / 8;
    }
    else
    {
        self.pageNumber = self.modelArr[index].imageDataArr.count / 8 + 1;
    }
}

@end
