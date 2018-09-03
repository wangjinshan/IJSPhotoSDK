//
//  IJSTagListView.h
//  yidaojia
//
//  Created by 山神 on 2018/1/28.
//  Copyright © 2018年 山神. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 IJSTagList高度会自动跟随标题计算，默认标签会自动计算宽度
 */
@protocol IJSTagListViewDelegate;
@interface IJSTagListView : UIView

/**
 标签删除图片, 在 添加标签之前设置
 */
@property (nonatomic, strong) UIImage *tagDeleteimage;

/**
 删除图片的高度,按照正方形计算,默认是20  建议大于 20 
 */
@property(nonatomic,assign) CGFloat tagDelegateImageHeight;

/**
 标签间距,和距离左，上间距,默认10
 */
@property (nonatomic, assign) CGFloat tagMargin;

/**
 标签颜色，默认红色
 */
@property (nonatomic, strong) UIColor *tagColor;

/**
 标签背景颜色
 */
@property (nonatomic, strong) UIColor *tagBackgroundColor;

/**
 标签背景图片
 */
@property (nonatomic, strong) UIImage *tagBackgroundImage;

/**
 标签字体，默认13
 */
@property (nonatomic, assign) UIFont *tagFont;


/**
 *  标签圆角半径,默认为5
 */
@property (nonatomic, assign) CGFloat tagCornerRadius;

/**
 标签列表的高度,设置 isFitTagListViewHeight = NO生效,并且需要设置本类的宽度
 */
@property (nonatomic, assign) CGFloat tagListViewHeight;

/**
 是否需要自定义tagListView高度，默认为Yes,建议不做更改选择默认就可以
 */
@property (nonatomic, assign) BOOL isFitTagListViewHeight;

/**
 标签按钮内容间距，标签内容距离左上下右间距，默认5, 如果想设置变宽 borderWidth 需要先设置 borderWidth, 再设置 tagButtonMargin属性
 */
@property (nonatomic, assign) CGFloat tagButtonMargin;

/**
 边框宽度,默认是 0  需要配合tagButtonMargin使用 注意顺序
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 边框颜色
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 获取所有标签里面的内容
 */
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *tagStringArray;

/**
 添加的标签数组, uitbutton
 */
@property (nonatomic, strong,readonly) NSMutableArray *tagButtonsArray;

/**
 通过拖拽的方式进行排序,默认是NO,不能拖拽
 */
@property (nonatomic, assign) BOOL isSort;
/**
 在拖动排序的时候，放大标签的比例，必须大于1,默认是 1.2
 */
@property (nonatomic, assign) CGFloat scaleTagInSort;

/*--------------------------自定义标签按钮--------------------------------------*/
/**
 必须是按钮类需要在添加按钮方法之前设置好再添加
 */
@property (nonatomic, assign) Class tagClass;

/**
 固定tag的尺寸
 */
@property (nonatomic, assign) CGSize tagSize;

/*------------------------标签列表总列数 默认4列-------------------------------*/
/**
 固定标签时候,展示的列数
 */
@property (nonatomic, assign) NSInteger tagListCols;

/**
 添加标签
 
 @param tagStr 标签文字,不能为空
 */
- (void)addTag:(NSString *)tagStr;

/**
 添加多个标签
 
 @param tagStrs 标签数组，数组存放（NSString *）
 */
- (void)addTags:(NSArray *)tagStrs;

/**
 删除标签
 
 @param tagStr 标签文字
 */
- (void)deleteTag:(NSString *)tagStr;

/**
 点击标签，执行Block
 */
@property (nonatomic, strong) void(^clickTagBlock)(NSString *tag);

/**
 代理属性
 */
@property(nonatomic,weak) id<IJSTagListViewDelegate> delegate;  

@end

@protocol IJSTagListViewDelegate <NSObject>

@required

@optional

/**
 点击当前的tag button时候调用

 @param view 本类
 @param currentButton 当前点击的tag
 @param text 点击的tag的内容文字
 */
-(void)didTapCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text;

/**
 正在移动当前的标签

 @param view 本类
 @param currentButton 当前的tag
 @param text 当前tag的文字
 */
-(void)movingCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text;


/**
 移动结束

 @param view 本类
 @param currentButton 当前的tag
 @param text 当前tag的文字
 */
-(void)endMoveCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text;


@end


/*-------------------------------------------------------------------------自定义的标签类----------------------------------------------------------------------------------------------*/
#pragma mark -----------------------自定义的标签------------------------------

@interface IJSTagButton : UIButton

/**
 边距
 */
@property (nonatomic, assign) CGFloat margin;

/**
 删除图片的高度
 */
@property(nonatomic,assign) CGFloat tagDelegateImageHeight;

@end




