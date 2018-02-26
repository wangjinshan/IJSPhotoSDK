//
//  UINavigationController+IJSNavigationController.m
//  TZScrollViewPopGesture
//
//  Created by 山神 on 2018/2/2.
//  Copyright © 2018年 山神. All rights reserved.
//

#import "UINavigationController+IJSNavigationController.h"


#import <objc/runtime.h>

@implementation UINavigationController (IJSNavigationController)

+ (void)load
{
    Method originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(_nvViewWillAppear:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

-(void)_nvViewWillAppear:(BOOL)animated
{
    [self _nvViewWillAppear:animated];  // 先去调用一下viewWillAppear 方法
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.view addGestureRecognizer:self.popPanGestureRecognizer];

    });
}

#pragma mark -----------------------set get方法------------------------------

#pragma mark - UIGestureRecognizerDelegate
///开始进行手势识别时调用的方法是否接收一个手势触摸事件默认为YES返回NO为不接收用处：可以在控件指定的位置使用手势识别
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([[self valueForKey:@"_isTransitioning"] boolValue])
    {
        return NO;
    }
    if ([self.navigationController.transitionCoordinator isAnimated])
    {
        return NO;
    }
    if (self.childViewControllers.count <= 1)
    {
        return NO;
    }
   
    // 侧滑手势触发位置
    CGPoint location = [gestureRecognizer locationInView:self.view];
    CGPoint offSet = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL res = (0 < offSet.x && location.x <= self.recognizerLength);
    
    return res;
}

/// 只有当系统侧滑手势失败了，才去触发ScrollView的滑动 这个方法返回YES，第一个和第二个互斥时，第二个会失效
/**
 第一个手势是  <UIPanGestureRecognizer: 0x7fdd5d70ac90; state = Possible; view = <UILayoutContainerView 0x7fdd5d50ff20>; target= <(action=handleNavigationTransition:, target=<_UINavigationInteractiveTransition 0x7fdd5d40fd60>)>>
 第二个手势是  <UIScrollViewPanGestureRecognizer: 0x7fdd5d425840; state = Possible; delaysTouchesEnded = NO; view = <UIScrollView 0x7fdd5d8ec000>; target= <(action=handlePan:, target=<UIScrollView 0x7fdd5d8ec000>)>>
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
///是否允许接收手指的触摸点
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.childViewControllers.count > 1; // 只有非跟控制器才需要触发手势
}

#pragma mark -----------------------set  get------------------------------
-(CGFloat)recognizerLength
{
    CGFloat rec = [objc_getAssociatedObject(self, _cmd) floatValue];
    if (!rec)
    {
        rec = 100;
    }
    return rec;
}

-(void)setRecognizerLength:(CGFloat)recognizerLength
{
    objc_setAssociatedObject(self, @selector(recognizerLength), @(recognizerLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

-(UIPanGestureRecognizer *)popPanGestureRecognizer
{
    UIPanGestureRecognizer *pan = objc_getAssociatedObject(self, _cmd);
    if (!pan)
    {
        // 侧滑返回手势 手势触发的时候，让target执行action
        id target = self.interactivePopGestureRecognizer.delegate;
        SEL action = NSSelectorFromString(@"handleNavigationTransition:");
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:action];
        pan.maximumNumberOfTouches = 1;
        pan.delegate = self;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        objc_setAssociatedObject(self, _cmd, pan, OBJC_ASSOCIATION_ASSIGN);
    }
    return pan;
}


///是否支持多手势触发，返回YES，则可以多个手势一起触发方法，返回NO则为互斥是否允许多个手势识别器共同识别，一个控件的手势识别后是否阻断手势识别继续向下传播，默认返回NO；如果为YES，响应者链上层对象触发手势识别后，如果下层对象也添加了手势并成功识别也会继续执行，否则上层对象识别后则不再继续传播  Simultaneously 同时
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return NO;
//}
/// 这个方法返回YES，第一个手势和第二个互斥时，第一个会失效
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return NO;
//}

@end


/**
 对当面的view处理
 */
@implementation UIViewController (IJSNPopViewController)

+(void)load
{
    Method originalViewWillAppearM = class_getInstanceMethod(self, @selector(viewWillAppear:));
    Method swizzleViewWillAppearM = class_getInstanceMethod(self, @selector(_vcViewWillAppear:));
    method_exchangeImplementations(originalViewWillAppearM, swizzleViewWillAppearM);
    
    Method originalViewWillDisapperM = class_getInstanceMethod(self, @selector(viewWillDisappear:));
    Method swizzleViewWillDisapperM = class_getInstanceMethod(self, @selector(_vcViewWillDisAppear:));
    method_exchangeImplementations(originalViewWillDisapperM, swizzleViewWillDisapperM);
}

-(void)_vcViewWillAppear:(BOOL)animated
{
    [self _vcViewWillAppear:animated];
    if (self.noPopAction)
    {
        self.navigationController.popPanGestureRecognizer.enabled = NO;
    }
}

-(void)_vcViewWillDisAppear:(BOOL)animated
{
    [self _vcViewWillDisAppear:animated];
    if (self.noPopAction)
    {
        self.navigationController.popPanGestureRecognizer.enabled = YES;
    }
}

-(BOOL)noPopAction
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setNoPopAction:(BOOL)noPopAction
{
    objc_setAssociatedObject(self, @selector(noPopAction), @(noPopAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}











@end

















