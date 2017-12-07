//
//  IJSDExportView.m
//  IJSUExtension
//
//  Created by shan on 2017/8/3.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSDExportView.h"

@interface IJSDExportView ()
@property (nonatomic, weak) UIImageView *backImageView; // 参数说明
@end

@implementation IJSDExportView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _createdUI];
    }
    return self;
}

- (void)_createdUI
{
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:backImageView];
    self.backImageView = backImageView;

    backImageView.userInteractionEnabled = YES;

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [backImageView addGestureRecognizer:pan];

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [backImageView addGestureRecognizer:pinch];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [backImageView addGestureRecognizer:longPress];
}

#pragma mark 手势
// 平移
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint transPoint = [pan translationInView:pan.view];
    pan.view.transform = CGAffineTransformTranslate(pan.view.transform, transPoint.x, transPoint.y);
    [pan setTranslation:CGPointZero inView:pan.view]; // 复位
}
// 缩小
- (void)pinchAction:(UIPinchGestureRecognizer *)pinch
{
    pinch.view.transform = CGAffineTransformScale(pinch.view.transform, pinch.scale, pinch.scale);
    pinch.scale = 1; // 复位
}
// 长按
- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        // 图片闪一下
        [UIView animateWithDuration:0.5 animations:^{
            longPress.view.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                longPress.view.alpha = 1;
            } completion:^(BOOL finished) {
                // 结束就绘制
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                [longPress.view.layer renderInContext:context];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                IJSDrawingModel *model = [[IJSDrawingModel alloc] init];
                model.drawingImage = image;
                model.drawingRect = longPress.view.frame;

                if (self.finishCallBack)
                    self.finishCallBack(model);
                [longPress.view removeFromSuperview];
            }];
        }];
    }
    else if (longPress.state == UIGestureRecognizerStateEnded)
    {
    }
}

- (void)setDrawImage:(UIImage *)drawImage
{
    _drawImage = drawImage;
    _backImageView.image = drawImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
