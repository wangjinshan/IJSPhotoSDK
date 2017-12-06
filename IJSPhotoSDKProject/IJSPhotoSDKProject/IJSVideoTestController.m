//
//  IJSVideoTestController.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoTestController.h"
#import "IJSExtension.h"
#import "IJSVideoManager.h"

@interface IJSVideoTestController ()
@property (nonatomic, strong) AVPlayer *player; // 播放器
@end

@implementation IJSVideoTestController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:self.avasset];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];

    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = CGRectMake(0, 0, self.view.js_width, self.view.js_height);
    playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.view.layer addSublayer:playerLayer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.player play];
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
