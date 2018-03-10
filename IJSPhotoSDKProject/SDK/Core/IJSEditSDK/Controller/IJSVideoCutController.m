//
//  IJSVideoCutController.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/14.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoCutController.h"

#import <AVFoundation/AVFoundation.h>

#import "IJSVideoTrimView.h"
#import "IJSImageNavigationView.h"
#import "IJSImageConst.h"
#import "IJSVideoManager.h"
#import "IJSVideoEditController.h"

#import <IJSFoundation/IJSFoundation.h>
#import "IJSExtension.h"

@interface IJSVideoCutController () <IJSVideoTrimViewDelegate>
@property (nonatomic, weak) IJSImageNavigationView *navigationView; // 导航条
@property (nonatomic, weak) IJSVideoTrimView *trimView;             // 视频裁剪试图
@property (nonatomic, assign) BOOL isPlaying;                       // 正在播放
@property (nonatomic, assign) CGFloat startTime;                    // 开始时间
@property (nonatomic, assign) CGFloat videoLenght;                  // 视频的长度
@property (nonatomic, assign) CGFloat endTime;                      // 结束时间
@property (nonatomic, weak) UIView *playView;                       // 播放视频的view
@property (nonatomic, weak) UIButton *playButton;                   // 播放按钮
@property (nonatomic, strong) AVPlayer *player;                     // 播放控制
@property (nonatomic, strong) NSTimer *listenPlayerTimer;           // 监听的时间
@property (nonatomic, assign) CGFloat backStartPosition;            // 回到开始位置
@property (nonatomic, assign) BOOL isDoing;                         // 正在处理
@property(nonatomic,strong) AVAsset *avasset;  // 资源
@property(nonatomic,assign) BOOL isCancle;  // 已经取消

@end

@implementation IJSVideoCutController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.isPlaying = YES;
    self.isCancle = NO;
    self.avasset =[AVAsset assetWithURL:self.inputPath];

    [self _setupUI];        // 重置UI
    [self _didclickAction]; //点击事件
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.player pause];
    [self removeListenPlayerTimer];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)loadVideoOnCompleteResult:(void (^)(NSURL *, NSError *))complete
{
    self.completeHandler = complete;
}
-(void)cancelSelectedData:(void(^)(void))cancelHandler
{
    self.cancelHandler = cancelHandler;
}

#pragma mark 设置UI
- (void)_setupUI
{
    // 播放层
    UIView *playView;
    if (IJSGiPhoneX)
    {
        playView= [[UIView alloc] initWithFrame:CGRectMake(0, IJSGStatusBarHeight, JSScreenWidth, JSScreenHeight - IJSGStatusBarHeight - IJSGTabbarSafeBottomMargin)];
    }
    else
    {
      playView= [[UIView alloc] initWithFrame:self.view.bounds];
    }
    playView.backgroundColor = [UIColor blackColor];
    self.playView = playView;
    [self.view addSubview:playView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [playView addGestureRecognizer:tap];
 
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:self.avasset];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = CGRectMake(0, 0, self.playView.js_width, self.playView.js_height);
    playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.playView.layer addSublayer:playerLayer];
    
    // 播放按钮
    UIButton *playButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [playButton setBackgroundImage:[IJSFImageGet loadImageWithBundle:@"JSPhotoSDK" subFile:@"" grandson:@"" imageName:@"MMVideoPreviewPlay@2x" imageType:@"png"] forState:UIControlStateNormal];
    [self.view addSubview:playButton];
    [self.view bringSubviewToFront:playButton];
    playButton.frame = CGRectMake(0, 0, 80, 80);
    playButton.center = self.view.center;
    playButton.userInteractionEnabled = NO;
    self.playButton = playButton;

    // 导航条
    CGFloat top;
    if ([UIApplication sharedApplication].statusBarHidden)
    {
        top = 0;
    }
    else
    {
        top = IJSGStatusBarHeight;
    }
    IJSImageNavigationView *navigationView;
    if (IJSGiPhoneX)
    {
        navigationView =[[IJSImageNavigationView alloc]initWithFrame:CGRectMake(0, top, JSScreenWidth, IJSGNavigationBarHeight)];
    }
    else
    {
        navigationView =[[IJSImageNavigationView alloc]initWithFrame:CGRectMake(0, top, JSScreenWidth, IJSGNavigationBarHeight)];
    }
    navigationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navigationView];
    self.navigationView = navigationView;
    [self.view bringSubviewToFront:navigationView];
    [navigationView.cancleButton setTitle:[NSBundle localizedStringForKey:@"Back"] forState:(UIControlStateNormal)];
    
    // 底部的UI 在数据请求完成再加载
    Float64 duration = CMTimeGetSeconds([self.avasset duration]);
    if (self.maxCutTime >= duration)
    {
        self.maxCutTime = duration;
    }
    if (duration <= self.minCutTime)
    {
        self.minCutTime = duration;
    }

    IJSVideoTrimView *trimView = [[IJSVideoTrimView alloc] initWithFrame:CGRectMake(0, JSScreenHeight - IJSVideotrimViewHeight - IJSGTabbarSafeBottomMargin, JSScreenWidth, IJSVideotrimViewHeight) minCutTime:self.minCutTime ?self.minCutTime: 4 maxCutTime:self.maxCutTime ?self.maxCutTime: 10 assetDuration:duration avAsset:self.avasset];
    trimView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:trimView];
    trimView.delegate = self;
    self.trimView = trimView;
    [trimView getVideoLenghtThenNotifyDelegate]; // 通知代理获取视频开始数据
}

#pragma mark 点击方法
- (void)_didclickAction
{
    __weak typeof(self) weakSelf = self;
    //取消
    self.navigationView.cancleBlock = ^{
        weakSelf.isCancle = YES;
        if (weakSelf.navigationController)
        {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    //完成
    self.navigationView.finishBlock = ^{
        
        if (weakSelf.isDoing)
        {
            return;
        }
        weakSelf.isDoing = YES;
        if (weakSelf.videoLenght == 0)
        {
            weakSelf.videoLenght = weakSelf.maxCutTime;
        }
        if (weakSelf.startTime == 0)
        {
            weakSelf.startTime = 0;
        }
        if (weakSelf.endTime == 0)
        {
            weakSelf.endTime = 60;
        }
        IJSLodingView *lodingView = [IJSLodingView showLodingViewAddedTo:weakSelf.view title:@"正在处理中... ..."];

        [IJSVideoManager cutVideoAndExportVideoWithVideoAsset:weakSelf.avasset startTime:weakSelf.startTime endTime:weakSelf.endTime completion:^(NSURL *outputPath, NSError *error, IJSVideoState state) {
            [lodingView removeFromSuperview];
            if (weakSelf.isCancle)
            {
                return ;
            }
            if (error)
            {
                if (weakSelf.navigationController)
                {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (weakSelf.completeHandler)
                        {
                            weakSelf.completeHandler(outputPath, error);
                        }
                    });
                }
                else
                {
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        if (weakSelf.completeHandler)
                        {
                            weakSelf.completeHandler(outputPath, error);
                        }
                    }];
                }
            }
            else
            {
                if (weakSelf.canEdit)
                {
                    IJSVideoEditController *videoEditVc = [[IJSVideoEditController alloc] init];
                    videoEditVc.inputPath = outputPath;
                    videoEditVc.mapImageArr = weakSelf.mapImageArr;
                    videoEditVc.completeHandler = weakSelf.completeHandler;
                    videoEditVc.cancelHandler = weakSelf.cancelHandler;
                    if (weakSelf.navigationController)
                    {
                        [weakSelf.navigationController pushViewController:videoEditVc animated:YES];
                    }
                    else
                    {
                        [weakSelf presentViewController:videoEditVc animated:YES completion:nil];
                    }
                }
                else
                {
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        if (weakSelf.completeHandler)
                        {
                            weakSelf.completeHandler(outputPath, error);
                        }
                    }];
                }
            }
            weakSelf.isDoing = NO;
        }];
    };
}

#pragma mark 点击事件
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if (self.isPlaying)
    {
        [self.player play];
        self.playButton.hidden = YES;
        [self startListenPlayerTimer];
    }
    else
    {
        [self.player pause];
        self.playButton.hidden = NO;
        [self removeListenPlayerTimer];
    }
    self.isPlaying = !self.isPlaying;
}

#pragma mark 开始定时器
- (void)startListenPlayerTimer
{
    [self removeListenPlayerTimer];
    self.listenPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(listenPlayerTimerResetTimerInCutVc) userInfo:nil repeats:YES];
}
#pragma mark 清空定时器
- (void)removeListenPlayerTimer
{
    if (self.listenPlayerTimer)
    {
        [self.listenPlayerTimer invalidate];
        self.listenPlayerTimer = nil;
    }
}
#pragma mark 监听播放的状态
// 播放中
- (void)listenPlayerTimerResetTimerInCutVc
{
    self.backStartPosition = CMTimeGetSeconds([self.player currentTime]);
    [self.trimView changeTrackerViewOriginX:self.backStartPosition];

    if (self.backStartPosition >= self.endTime)
    {
        self.backStartPosition = self.startTime;
        [self seekVideoToPos:self.startTime];
        [self.trimView changeTrackerViewOriginX:self.startTime];
    }
}
// 播放结束
- (void)seekVideoToPos:(CGFloat)position
{
    self.backStartPosition = position;
    CMTime time = CMTimeMakeWithSeconds(self.backStartPosition, self.player.currentTime.timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
#pragma mark 滑块的代理方法,保存截取的时间数据
- (void)trimView:(IJSVideoTrimView *)trimView startTime:(CGFloat)startTime endTime:(CGFloat)endTime videoLength:(CGFloat)length
{
    if (startTime != self.startTime)
    {
        [self seekVideoToPos:startTime];
    }
    self.startTime = startTime;
    self.videoLenght = length;
    self.endTime = endTime;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}







@end
