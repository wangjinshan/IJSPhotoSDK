//
//  IJSTagListView.m
//  yidaojia
//
//  Created by 山神 on 2018/1/28.
//  Copyright © 2018年 山神. All rights reserved.
//

#import "IJSTagListView.h"

CGFloat const imageViewWHIJS = 20;

@interface IJSTagListView ()
{
    NSMutableArray *_tagStringArray;
}

@property (nonatomic, strong) NSMutableDictionary *tagsDic;
@property (nonatomic, strong) NSMutableArray *tagButtonsArray; // 用户保存已经添加的 tag
/**
 *  需要移动的矩阵
 */
@property (nonatomic, assign) CGRect moveFinalRect;  // 记录当前拖动按钮中心点符合的那个tag
@property (nonatomic, assign) CGPoint oriCenter;   // 拖动标签的原始中心数据
@property(nonatomic,assign) CGFloat titleMarinLeft;  // 文字的起点

@end


@implementation IJSTagListView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}

#pragma mark -----------------------初始化设置------------------------------
- (void)setup
{
    self.tagMargin = 10;
    self.tagColor = [UIColor redColor];
    self.tagButtonMargin = 5;

    self.tagCornerRadius = 5;
    self.borderWidth = 0;
    self.borderColor = self.tagColor;
    self.tagListCols = 4;
    self.scaleTagInSort = 1.2;
    self.isFitTagListViewHeight = YES;
    self.tagFont = [UIFont systemFontOfSize:13];
    self.tagDelegateImageHeight = imageViewWHIJS;
    self.clipsToBounds = YES;
    self.titleMarinLeft = self.tagButtonMargin + self.borderWidth; // 初始化认为边框为 0
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

#pragma mark - 操作标签方法
#pragma mark -----------------------添加多个标签------------------------------
- (void)addTags:(NSArray *)tagStrs
{
    if (self.frame.size.width == 0)
    {
        @throw [NSException exceptionWithName:@"IJSTagListError" reason:@"先设置标签列表的frame" userInfo:nil];
    }
    
    for (NSString *tagStr in tagStrs)
    {
        [self addTag:tagStr];
    }
}
#pragma mark -----------------------添加单个标签------------------------------
- (void)addTag:(NSString *)tagStr
{
    for (NSString *key in [self.tagsDic allKeys]) {
        if ([tagStr isEqualToString:key]) {
            return ;
        }
    }
    
    Class tagClass = self.tagClass?_tagClass : [IJSTagButton class];
    
    // 创建标签按钮
    IJSTagButton *tagButton = [tagClass buttonWithType:UIButtonTypeCustom];
   
    tagButton.layer.cornerRadius = self.tagCornerRadius;
    tagButton.layer.borderWidth = self.borderWidth;
    tagButton.layer.borderColor = self.borderColor.CGColor;
    tagButton.clipsToBounds = YES;
    tagButton.tag = self.tagButtonsArray.count;
    if (self.tagButtonsArray.count == 0)
    {
        tagButton.tag = 0;
    }
    [tagButton setImage:self.tagDeleteimage forState:UIControlStateNormal];
    [tagButton setTitle:tagStr forState:UIControlStateNormal];
    [tagButton setTitleColor:self.tagColor forState:UIControlStateNormal];
    [tagButton setBackgroundColor:self.tagBackgroundColor];
    [tagButton setBackgroundImage:self.tagBackgroundImage forState:UIControlStateNormal];
    tagButton.titleLabel.font = self.tagFont;
    [tagButton addTarget:self action:@selector(clickTag:) forControlEvents:UIControlEventTouchUpInside];
    tagButton.titleLabel.lineBreakMode = 0;  // 自动换行
    
     self.titleMarinLeft = self.tagButtonMargin + self.borderWidth;
    if ([tagButton isKindOfClass:[IJSTagButton class]])
    {
        tagButton.tagDelegateImageHeight = self.tagDelegateImageHeight; // 图片的高度
        tagButton.margin = self.titleMarinLeft;
    }
    if (self.isSort)
    {
        // 添加拖动手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [tagButton addGestureRecognizer:pan];
    }
    [self addSubview:tagButton];
    
    // 保存到数组
    [self.tagButtonsArray addObject:tagButton];
    
    // 保存到字典
    if (tagStr)
    {
        [self.tagsDic setObject:tagButton forKey:tagStr];
        [self.tagStringArray addObject:tagStr];
    }
    
    [self _updateTagButtonFrame:tagButton.tag];  //更新坐标
    
    // 更新自己的高度
    if (self.isFitTagListViewHeight)
    {
        CGRect frame = self.frame;
        frame.size.height = self.tagListViewHeight;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = frame;
        }];
    }
}

#pragma mark -----------------------点击标签------------------------------
- (void)clickTag:(UIButton *)button
{
    if (self.clickTagBlock)
    {
        self.clickTagBlock(button.currentTitle);
    }
    if ([self.delegate respondsToSelector:@selector(didTapCurrentTagWith:currentButton:currentTagText:)])
    {
        [self.delegate didTapCurrentTagWith:self currentButton:button currentTagText:button.titleLabel.text];
    }
}

#pragma mark -----------------------拖动标签------------------------------
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    // 获取偏移量
    CGPoint transP = [pan translationInView:self];
    
    UIButton *currentButton = (UIButton *)pan.view;
    // 开始
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        self.oriCenter = currentButton.center;
        [UIView animateWithDuration: 0.3 animations:^{
            currentButton.transform = CGAffineTransformMakeScale(self.scaleTagInSort, self.scaleTagInSort);
        }];
    }
    
    CGPoint center = currentButton.center;
    center.x += transP.x;
    center.y += transP.y;
    currentButton.center = center;
    
    NSInteger insertedIndex = 0;
    
    // 改变
    if (pan.state == UIGestureRecognizerStateChanged)
    {
        // 获取当前按钮中心点在哪个按钮上 返回符合中心点的按钮
        UIButton *insertedButton = [self _buttonCenterInButtons:currentButton];
        
        if (insertedButton)
        { // 插入到当前按钮的位置
            
            insertedIndex = insertedButton.tag;   // 获取插入的角标
            
            NSInteger currentIndex = currentButton.tag;    // 获取当前角标
            
            self.moveFinalRect = insertedButton.frame;
            
            // 排序
            // 移除之前的按钮
            [self.tagButtonsArray removeObject:currentButton];
            [self.tagButtonsArray insertObject:currentButton atIndex:insertedIndex];
            
            [self.tagStringArray removeObject:currentButton.currentTitle];
            [self.tagStringArray insertObject:currentButton.currentTitle atIndex:insertedIndex];
            
            // 更新tag
            [self _updateTag];
            
            if (currentIndex > insertedIndex)
            { // 往前插
                // 更新之后标签frame
                [UIView animateWithDuration:0.25 animations:^{
                    [self _updateLaterTagButtonFrame:insertedIndex + 1];
                }];
                
            }
            else
            { // 往后插
                // 更新之前标签frame
                [UIView animateWithDuration:0.25 animations:^{
                    [self _updateBeforeTagButtonFrame:insertedIndex];
                }];
            }
        }
        if ([self.delegate respondsToSelector:@selector(movingCurrentTagWith:currentButton:currentTagText:)])
        {
            [self.delegate movingCurrentTagWith:self currentButton:currentButton currentTagText:currentButton.titleLabel.text];
        }
    }
    
    // 结束
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.25 animations:^{
            currentButton.transform = CGAffineTransformIdentity;
            if (self.moveFinalRect.size.width <= 0)
            {  // 左右拖动超出了界限
                currentButton.center = self.oriCenter;
            }
            else
            {   // 和拖动位置的中心点对调
                currentButton.frame = self.moveFinalRect;
            }
        } completion:^(BOOL finished) {
            self.moveFinalRect = CGRectZero;
        }];
        /// 重新布局一下UI
       
        [self.tagButtonsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= insertedIndex)
            {
                 [self _updateTagButtonFrame:idx];
            }
            // 更新自己的高度
            if (self.isFitTagListViewHeight)
            {
                CGRect frame = self.frame;
                frame.size.height = self.tagListViewHeight;
                [UIView animateWithDuration:0.25 animations:^{
                    self.frame = frame;
                }];
            }
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(endMoveCurrentTagWith:currentButton:currentTagText:)])
            {
                [self.delegate endMoveCurrentTagWith:self currentButton:currentButton currentTagText:currentButton.titleLabel.text];
            }
        });
    }
    [pan setTranslation:CGPointZero inView:self];  // 结束时候 复位一下
}
#pragma mark -----------------------删除标签------------------------------
/// 删除单个标签
- (void)deleteTag:(NSString *)tagStr
{
    IJSTagButton *button = self.tagsDic[tagStr];   // 获取对应的标题按钮
    [button removeFromSuperview];      // 移除按钮
    [self.tagButtonsArray removeObject:button];     // 移除数组
    [self.tagsDic removeObjectForKey:tagStr];       // 移除字典
    [self.tagStringArray removeObject:tagStr];    // 移除数组
    [self _updateTag];      // 更新tag
    // 更新后面按钮的frame
    [UIView animateWithDuration:0.25 animations:^{
        [self _updateLaterTagButtonFrame:button.tag];
    }];
    // 更新自己的frame
    if (self.isFitTagListViewHeight) {
        CGRect frame = self.frame;
        frame.size.height = self.tagListViewHeight;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = frame;
        }];
    }
}

#pragma mark -----------------------私有方法------------------------------
// 更新标签
- (void)_updateTag
{
    NSInteger count = self.tagButtonsArray.count;
    for (int i = 0; i < count; i++)
    {
        UIButton *tagButton = self.tagButtonsArray[i];
        tagButton.tag = i;
    }
}

// 更新之前按钮
- (void)_updateBeforeTagButtonFrame:(NSInteger)beforeI
{
    for (int i = 0; i < beforeI; i++)
    {    // 更新按钮
        [self _updateTagButtonFrame:i ];
    }
}

// 更新以后按钮
- (void)_updateLaterTagButtonFrame:(NSInteger)laterI
{
    NSInteger count = self.tagButtonsArray.count;
    
    for (NSInteger i = laterI; i < count; i++)
    {  // 更新按钮
        [self _updateTagButtonFrame:i ];
    }
}
#pragma mark -----------------------更新尺寸统一的入口------------------------------
- (void)_updateTagButtonFrame:(NSInteger)i
{
    NSInteger previousButtonIndex = i - 1;     // 获取上一个按钮
    UIButton *previousButton;            // 定义上一个按钮
    if (previousButtonIndex >= 0)      // 过滤上一个角标
    {
        previousButton = self.tagButtonsArray[previousButtonIndex];
    }
    
    IJSTagButton *currentButton = self.tagButtonsArray[i];   // 获取当前按钮
    
    if (self.tagSize.width == 0)    // 判断是否设置标签的尺寸
    { // 没有设置标签尺寸  // 自适应标签尺寸
        [self _setupTagButtonCustomFrame:currentButton preButton:previousButton];  // 设置标签按钮frame（自适应）
    }
    else
    { // 设置了标签的大小按规律排布
        [self _setupTagButtonRegularFrame:currentButton];  // 计算标签按钮frame（regular）
    }
}

// 计算标签按钮frame（按规律排布）
- (void)_setupTagButtonRegularFrame:(UIButton *)tagButton
{
    // 获取角标
    NSInteger i = tagButton.tag;
    NSInteger col = i % self.tagListCols; // 列数
    NSInteger row = i / self.tagListCols;  // 行数
    CGFloat btnW = _tagSize.width;
    CGFloat btnH = _tagSize.height;

    NSInteger margin = (self.bounds.size.width - self.tagListCols * btnW - 2 * self.tagMargin) / (self.tagListCols - 1);  // 间距
    CGFloat btnX = self.tagMargin + col * (btnW + margin) ;
    CGFloat btnY = self.tagMargin + row * (btnH + margin);
    tagButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
}

// 设置标签按钮frame（自适应）
- (void)_setupTagButtonCustomFrame:(UIButton *)tagButton preButton:(UIButton *)preButton
{
    // 设置按钮的位置
    self.titleMarinLeft = self.tagButtonMargin + self.borderWidth;
    CGFloat buttonX = CGRectGetMaxX(preButton.frame) + self.tagMargin;   // 等于上一个按钮的最大X + 间距
    CGFloat buttonY = preButton? preButton.frame.origin.y : self.tagMargin;     // 等于上一个按钮的Y值,如果没有就是标签间距
    // 获取按钮宽度
    NSMutableDictionary *dic =[NSMutableDictionary dictionary];
    dic[NSFontAttributeName] = self.tagFont;   // 字号
    CGFloat freeTitleW = [tagButton.titleLabel.text sizeWithAttributes:dic].width;  // 不限制宽度的时候的长度
    CGFloat freeTitleH = [tagButton.titleLabel.text sizeWithAttributes:dic].height;  // 不限制宽度单行的文字的高度
    
    CGFloat buttonW;
    
    if (self.tagDeleteimage)
    {
        if (freeTitleW <= self.bounds.size.width - 2 * self.titleMarinLeft - self.tagDelegateImageHeight)
        {
            buttonW = 2 *self.titleMarinLeft + freeTitleW + self.tagDelegateImageHeight;
        }
        else
        {
            buttonW = self.bounds.size.width - 2 * self.tagMargin;
        }
    }
    else
    { //  没有删除符号的情况下
        if (freeTitleW <= self.bounds.size.width - 2 * self.titleMarinLeft)
        {
            buttonW = freeTitleW + 2 * self.titleMarinLeft ;
        }
        else
        {
            buttonW = self.bounds.size.width - 2 * self.tagMargin;
        }
    }
    // 获取按钮高度
    CGFloat buttonH ;
    if (self.tagDeleteimage)
    {
        if (freeTitleW <= self.bounds.size.width - 2 * self.titleMarinLeft - self.tagDelegateImageHeight)
        {
            CGFloat height = self.tagDelegateImageHeight > freeTitleH ? self.tagDelegateImageHeight : freeTitleH;
            buttonH = height + 2 * self.titleMarinLeft;
        }
        else
        {
            CGSize size = [self _sizeWithText:tagButton.titleLabel.text font:self.tagFont maxSize:CGSizeMake(self.bounds.size.width - 2 * self.tagMargin - self.tagDelegateImageHeight, MAXFLOAT)];
            buttonH =  2 * self.titleMarinLeft + size.height;
        }
    }
    else
    { // 没有删除符号
        if (freeTitleW <= self.bounds.size.width - 2 * self.titleMarinLeft)
        {
            buttonH = freeTitleH + 2 * self.titleMarinLeft;
        }
        else
        {
            CGSize size = [self _sizeWithText:tagButton.titleLabel.text font:self.tagFont maxSize:CGSizeMake(self.bounds.size.width - 2 * self.tagMargin, MAXFLOAT)];
            buttonH =  2 * self.titleMarinLeft + size.height;
        }
        
    }
    // 判断当前按钮是否足够显示
    CGFloat rightWidth = self.bounds.size.width - buttonX;
    
    if (rightWidth < buttonW)
    {
        // 不够显示，显示到下一行
        buttonX = self.tagMargin;
        buttonY = CGRectGetMaxY(preButton.frame) + self.tagMargin;
    }
    
    tagButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    
}

// 看下当前按钮中心点在哪个按钮上
- (UIButton *)_buttonCenterInButtons:(UIButton *)curButton
{
    for (UIButton *button in self.tagButtonsArray)
    {
        if (curButton == button)
        {
            continue;
        }
        if (CGRectContainsPoint(button.frame, curButton.center))  // 判断 curButton.center  在不在 button.frame
        {
            return button;
        }
    }
    return nil;
}

/// 计算文字的高度
- (CGSize)_sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};   // CGSizeMake(MAXFLOAT, MAXFLOAT)
    return [text boundingRectWithSize:maxSize
                              options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:attrs context:nil].size;
}
/*-------------------------------------------------------------------------懒加载区域-------------------------------*/
#pragma mark -----------------------懒加载------------------------------
- (NSMutableArray *)tagStringArray
{
    if (_tagStringArray == nil)
    {
        _tagStringArray = [NSMutableArray array];
    }
    return _tagStringArray;
}
- (NSMutableArray *)tagButtonsArray
{
    if (_tagButtonsArray == nil)
    {
        _tagButtonsArray = [NSMutableArray array];
    }
    return _tagButtonsArray;
}

- (NSMutableDictionary *)tagsDic
{
    if (_tagsDic == nil)
    {
        _tagsDic = [NSMutableDictionary dictionary];
    }
    return _tagsDic;
}

- (void)setScaleTagInSort:(CGFloat)scaleTagInSort
{
    _scaleTagInSort = scaleTagInSort;
    if (_scaleTagInSort < 1)
    {
        @throw [NSException exceptionWithName:@"IJSTagListViewError" reason:@"属性 scaleTagInSort 缩放比例必须大于1" userInfo:nil];
    }
}

- (CGFloat)tagListViewHeight
{
    if (self.tagButtonsArray.count <= 0)
    {
        return 0;
    }
    return CGRectGetMaxY([(UIButton *)self.tagButtonsArray.lastObject frame]) + self.tagMargin;
}

-(void)setTagDelegateImageHeight:(CGFloat)tagDelegateImageHeight
{
    _tagDelegateImageHeight = tagDelegateImageHeight;
}

-(void)setIsFitTagListViewHeight:(BOOL)isFitTagListViewHeight
{
    _isFitTagListViewHeight = isFitTagListViewHeight;
}

-(void)setTagClass:(Class)tagClass
{
    _tagClass = tagClass;
}
-(void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    self.titleMarinLeft += _borderWidth;
}
-(void)setTagButtonMargin:(CGFloat)tagButtonMargin
{
    _tagButtonMargin = tagButtonMargin;
    self.titleMarinLeft += _tagButtonMargin;
}
-(void)setTagListCols:(NSInteger)tagListCols
{
    _tagListCols = tagListCols;
}

@end


/*-------------------------------------------------------------------------自定义的标签类----------------------------------------------------------------------------------------------*/
#pragma mark -----------------------自定义的标签类------------------------------

extern CGFloat const imageViewWHIJS; // 去获取其他文件的常亮值,比如此处是  IJSTagListView 的 20

@implementation IJSTagButton

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self =[super initWithCoder:aDecoder];
    if (self)
    {
        self.tagDelegateImageHeight = imageViewWHIJS;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
   
    CGFloat btnW = self.bounds.size.width;
    CGFloat btnH = self.bounds.size.height;
    if (self.imageView.frame.size.width <= 0)
    {
        self.tagDelegateImageHeight = 0;
    }
    CGFloat imageX = btnW - 2 * self.margin - self.tagDelegateImageHeight;

    self.titleLabel.frame = CGRectMake(self.margin, self.margin, imageX, btnH - 2 * self.margin);
    
    if (self.imageView.frame.size.width <= 0)
    {
        return;
    }
    self.imageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 2, btnH * 0.5 - self.tagDelegateImageHeight * 0.5, self.tagDelegateImageHeight, self.tagDelegateImageHeight);
}

- (void)setHighlighted:(BOOL)highlighted {}

-(void)setTagDelegateImageHeight:(CGFloat)tagDelegateImageHeight
{
    _tagDelegateImageHeight = tagDelegateImageHeight;
}


@end

















