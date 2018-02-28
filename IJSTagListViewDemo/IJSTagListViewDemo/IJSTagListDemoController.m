
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
    }
}

-(void)_setupUI
{
    // 创建标签列表
    IJSTagListView *tagListView = [[IJSTagListView alloc] init];
    tagListView.delegate = self;
    
    /*----------------属性列表设置 可以不设置-----------------*/
    // 设置标签颜色
//    tagListView.tagColor = [UIColor whiteColor];
//    tagListView.isSort = YES;  // 设置成YES 就是可以拖拽
//    tagListView.tagMargin = 10;  // 左边距
//    tagListView.backgroundColor = [UIColor redColor];
    // 设置标签删除图片
//        tagListView.tagDeleteimage =[UIImage imageNamed:@"sns_icon_22"];
//        tagListView.tagDelegateImageHeight = 30;
    
    //    tagListView.isFitTagListViewHeight = NO;
    //    tagListView.tagListViewHeight = 600;
    
//    tagListView.frame = CGRectMake(10, 200, self.view.frame.size.width - 20, 0);   // 高度可以不设置自动会更新
//    tagListView.borderColor = [UIColor yellowColor];
//    tagListView.borderWidth = 5;
//    tagListView.tagButtonMargin = 5;
    
    //    tagListView.tagClass = [UIButton class];
//    tagListView.tagCornerRadius = 5;
    //    tagListView.tagSize =CGSizeMake(80, 80);   // 如果设置此属性则规律排版
//    tagListView.tagFont =[UIFont systemFontOfSize:17];
    /*---------------------属性列表设置----------------------------*/
    [self.tagListArr enumerateObjectsUsingBlock:^(IJSYiTagsListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 设置标签背景色
        if (idx == 0)
        {
            tagListView.tagBackgroundColor = [UIColor redColor];
        }
        [tagListView addTag:obj.themeName];
        
    }];
    [self.scrollView addSubview:tagListView];

    // 点击标签，就会调用,点击标签，删除标签
    __weak typeof (self) weakSelf = self;
    __block typeof (tagListView) weaktagListView = tagListView;
    /// 点击方法
    tagListView.clickTagBlock = ^(NSString *tag){
        [weaktagListView deleteTag:tag];  // 删除
        
        IJSTagListView *selectList =[[IJSTagListView alloc]initWithFrame:CGRectMake(10, 20,  self.view.bounds.size.width -20, 0)];
        if (self.lastTagStrng)
        {
            [selectList deleteTag:self.lastTagStrng];
        }
        selectList.tagColor = [UIColor whiteColor];
        selectList.tagBackgroundColor =[UIColor greenColor];
        selectList.tagFont = [UIFont systemFontOfSize:15];
        [selectList addTag:tag];
        [weakSelf.scrollView addSubview:selectList];
        self.lastTagStrng = tag;
    };
    
}
#pragma mark -----------------------taglist delegate-  可以不写-----------------------------
-(void)didTapCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
    //    NSLog(@"---tap-------%@",text);
}
-(void)movingCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
    //    NSLog(@"---moving-----------%@",text);
}

-(void)endMoveCurrentTagWith:(IJSTagListView *)view currentButton:(UIButton *)currentButton currentTagText:(NSString *)text
{
    //    NSLog(@"------end-------%@",text);
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




















- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}



@end
