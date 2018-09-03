
//
//  IJSTagListDemoController.m
//  IJSTagListViewDemo
//
//  Created by 山神 on 2018/2/28.
//  Copyright © 2018年 山神. All rights reserved.
//

#import "IJSTagListDemoController.h"
#import "IJSTagListView.h"
#import "IJSYiTagsListModel.h"
@interface IJSTagListDemoController ()<IJSTagListViewDelegate>

@property(nonatomic,strong) NSMutableArray *tagListArr;  // 参数说明
@property(nonatomic,weak) UIScrollView *scrollView;  // 参数说明
@property(nonatomic,strong) NSString *lastTagStrng;  //  上一个标签
@property(nonatomic,strong) IJSTagListView *tagListView;  // more的加载
@property(nonatomic,strong) IJSTagListView *selectedView;  // 选中的

@property(nonatomic,strong) NSMutableArray *selectedButtonArr;  // 选中的
@property(nonatomic,strong) NSMutableArray *unselectedButtonArr;  //  没有选中的

@end

@implementation IJSTagListDemoController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.view.backgroundColor =[UIColor whiteColor];
    
    UIScrollView *scrollView =[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
   
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 10);
    scrollView.contentOffset = CGPointMake(0, 0);
   
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    [self _loadData];
    
    [self _setupUI];
    
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}



-(void)_loadData
{
    /// 虚拟
    NSString *path =[[NSBundle mainBundle] pathForResource:@"yiTagsList" ofType:@"json"];
    NSDictionary *dicT =[self jsonToObjcFromJsonPath:path];
    if ([dicT isKindOfClass:[NSDictionary class]])
    {
        for (NSDictionary *dic in dicT[@"data"][@"list"])
        {
            IJSYiTagsListModel *model =[[IJSYiTagsListModel alloc]init];
             [model setValuesForKeysWithDictionary:dic];
    
            if (model)
            {
                [self.tagListArr addObject:model];
            }
        }
        self.unselectedButtonArr = self.tagListArr.mutableCopy;
    }
}

-(void)_setupUI
{
    // 创建标签列表
    self.tagListView = [[IJSTagListView alloc] initWithFrame:self.scrollView.bounds];
    self.tagListView.backgroundColor =[UIColor cyanColor];
    self.tagListView.delegate = self;
    self.tagListView.tagColor = [UIColor redColor];
    self.tagListView.tagBackgroundColor = [UIColor yellowColor];
    
    [self.tagListArr enumerateObjectsUsingBlock:^(IJSYiTagsListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tagListView addTag:obj.themeName];
        
    }];
    [self.scrollView addSubview:self.tagListView];

    // 点击标签，就会调用,点击标签，删除标签
//    __weak typeof (self) weakSelf = self;
    /// 点击方法
//    self.tagListView.clickTagBlock = ^(NSString *tag){
//
//        [weakSelf.selectedView addTag:tag];
//    };

//    self.selectedView.clickTagBlock = ^(NSString *tag) {
//        [weakSelf.selectedView deleteTag:tag];
//    };
    
}

-(IJSTagListView *)selectedView{
    if (!_selectedView) {
        _selectedView = [[IJSTagListView alloc]initWithFrame:CGRectMake(10, 200,  self.view.bounds.size.width -20, 0)];
        _selectedView.tagColor = [UIColor yellowColor];
        _selectedView.tagBackgroundColor =[UIColor greenColor];
        _selectedView.backgroundColor = [UIColor redColor];
        _selectedView.tagFont = [UIFont systemFontOfSize:15];
        [self.scrollView addSubview:_selectedView];
    }
    return _selectedView;
    
}

#pragma mark -----------------------taglist delegate-  可以不写-----------------------------
-(void)didTapCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
  
    if (view == self.tagListView) {
        for (IJSYiTagsListModel *model in self.selectedButtonArr) {
            if ([text isEqualToString:model.themeName]) {
                return;
            }
        }
        
        IJSYiTagsListModel *currentModel = [[IJSYiTagsListModel alloc]init];
        currentModel.themeName = text;
        if (currentModel) {
            [self.selectedButtonArr  addObject:currentModel];
        }
        
        [self.tagListArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj != currentModel) {
                [self.unselectedButtonArr addObject:obj];
            }
        }];
        for (IJSYiTagsListModel *model in self.tagListArr) {
            [self.tagListView deleteTag:model.themeName];
        }
        NSArray *unselectedArr = [self disorderOrder:self.unselectedButtonArr];
        [unselectedArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.tagListView addTag:((IJSYiTagsListModel *)obj).themeName];
        }];
        self.tagListView.tagBackgroundColor = [UIColor redColor];
        [self.selectedButtonArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             [self.tagListView addTag:((IJSYiTagsListModel *)obj).themeName];
        }];
    }
}


-(void)movingCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
    //    NSLog(@"---moving-----------%@",text);
}

-(void)endMoveCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
    //    NSLog(@"------end-------%@",text);
}

- (NSArray *)disorderOrder:(NSArray *)dataArr{
    NSArray *resultArr = @[];
    NSMutableArray *modelArr = [NSMutableArray array];
     [dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [modelArr addObject:((IJSYiTagsListModel *)obj).themeName];
    }];
    resultArr = [modelArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [obj1 compare:obj2];
        } else {
            return [obj2 compare:obj1];
        }
    }];
    NSMutableArray *arr1 =[NSMutableArray array];
    [resultArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        IJSYiTagsListModel *model = [[IJSYiTagsListModel alloc]init];
        model.themeName = obj;
        [arr1 addObject:model];
    }];
    
    return arr1;
}


- (id)jsonToObjcFromJsonPath:(NSString *)jsonPath
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:jsonPath];
    if (data)
    {
        NSError *error = nil;
        id objc = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error)
        {
            NSLog(@"json解析失败：%@", error);
            return nil;
        }
        return objc;
    }
    else
    {
        return nil;
    }
}

#pragma mark 懒加载区域
-(NSMutableArray *)tagListArr
{
    if (_tagListArr == nil)
    {
        _tagListArr =[NSMutableArray array];
    }
    return _tagListArr;
}

-(NSMutableArray *)selectedButtonArr{
    if (_selectedButtonArr == nil) {
        _selectedButtonArr =[NSMutableArray array];
    }
    return _selectedButtonArr;
}

-(NSMutableArray *)unselectedButtonArr{
    if (!_unselectedButtonArr) {
        _unselectedButtonArr =[NSMutableArray array];
    }
    return _unselectedButtonArr;
}







/*----------------属性列表设置 可以不设置-----------------*/
//     设置标签颜色
//    tagListView.tagColor = [UIColor redColor];
//    tagListView.isSort = YES;  // 设置成YES 就是可以拖拽
//    tagListView.tagMargin = 10;  // 左边距
//    tagListView.backgroundColor = [UIColor redColor];
////     设置标签删除图片
//        tagListView.tagDeleteimage =[UIImage imageNamed:@"sns_icon_22"];
//        tagListView.tagDelegateImageHeight = 30;
//
//        tagListView.isFitTagListViewHeight = NO;
//        tagListView.tagListViewHeight = 600;
//
//    tagListView.frame = CGRectMake(10, 200, self.view.frame.size.width - 20, 0);   // 高度可以不设置自动会更新
//    tagListView.borderColor = [UIColor yellowColor];
//    tagListView.borderWidth = 5;
//    tagListView.tagButtonMargin = 5;
//
//        tagListView.tagClass = [UIButton class];
//    tagListView.tagCornerRadius = 5;
//        tagListView.tagSize =CGSizeMake(80, 80);   // 如果设置此属性则规律排版
//    tagListView.tagFont =[UIFont systemFontOfSize:17];
/*---------------------属性列表设置----------------------------*/








- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}



@end
