//
//  IJSVideoManager.m
//  IJSPhotoSDKProject
//
//  Created by shange on 2017/8/15.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "IJSVideoManager.h"
#import "IJSExtension.h"

static IJSVideoManager *manager;

@interface IJSVideoManager ()

@end

@implementation IJSVideoManager

//单利
+ (instancetype)shareManager
{
    manager = [[self alloc] init];
    return manager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:zone] init];
    });
    return manager;
}
- (id)copyWithZone:(NSZone *)zone
{
    return manager;
}
- (id)mutableCopyWithZone:(NSZone *)zone
{
    return manager;
}
#pragma mark 裁剪视频
/// 裁剪视频
+ (void)cutVideoAndExportVideoWithVideoAsset:(AVAsset *)videoAsset startTime:(CGFloat)startTime endTime:(CGFloat)endTime completion:(void (^)(NSURL *outputPath, NSError *error, IJSVideoState state))completion
{
     NSError *error;
    //1 创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    // 2 设置采集区域
    NSRange videoRange = NSMakeRange(startTime, (endTime - startTime)); // 开始位置, 裁剪的长度
    CMTime startT = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale); //截取长度videoDuration
    CMTimeRange timeRange = CMTimeRangeMake(startT, videoDuration);

    // 3 - 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    /*TimeRange截取的范围长度   ofTrack来源  atTime插放在视频的时间位置*/
    [videoTrack insertTimeRange:timeRange
                        ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count > 0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil
                         atTime:kCMTimeZero
                          error:&error];

    //3.2 - 添加原有音频
    //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:timeRange
                        ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil
                         atTime:kCMTimeZero
                          error:&error];

    // 3 - 导出视频 - 返回数字包含了 AVAssetExportPreset1280x720多个这样的数组
    AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];

    [self _getExportVideoWithAvAssset:mixComposition videoComposition:videoComposition audioMix:nil timeRange:timeRange completion:completion cut:YES];
}

#pragma mark 裁剪视频导出路径
/// 裁剪视频导出路径
+ (void)exportVideoWithVideoAsset:(AVAsset *)videoAsset startTime:(CGFloat)startTime endTime:(CGFloat)endTime completion:(void (^)(NSURL *outputPath, NSError *error, IJSVideoState state))completion
{
    // 设置裁剪时间
    CMTime start = CMTimeMakeWithSeconds(startTime, videoAsset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(endTime - startTime, videoAsset.duration.timescale);
    CMTimeRange timeRange = CMTimeRangeMake(start, duration);
    //获取优化后的视频转向信息
    AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];

    [self _getExportVideoWithAvAssset:videoAsset videoComposition:videoComposition audioMix:nil timeRange:timeRange completion:completion cut:NO];
}
#pragma mark 获取视频的

+ (UIImage *)getScreenShotImageFromAvasset:(AVAsset *)avasset time:(CGFloat)time
{
    UIImage *shotImage;
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:avasset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime cmtime = CMTimeMakeWithSeconds(time, avasset.duration.timescale);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [generator copyCGImageAtTime:cmtime actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}
/// 获取优化后的视频转向信息
+ (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset
{
    //1,可以用来对视频进行操作,用来生成video的组合指令，包含多段instruction
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    // 视频转向
    int degrees = [self degressFromVideoFileWithAsset:videoAsset];
    CGAffineTransform translateToCenter;
    CGAffineTransform mixedTransform;
    videoComposition.frameDuration = CMTimeMake(1, 30);

    NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
    // 一个指令，决定一个timeRange内每个轨道的状态，包含多个layerInstruction
    AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
    // 在一个指令的时间范围内，某个轨道的状态
    AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    if (degrees == 90) // UIImageOrientationRight
    {
        // 顺时针旋转90°
        translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    }
    else if (degrees == 180) // UIImageOrientationDown
    {
        // 顺时针旋转180°
        translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    }
    else if (degrees == 270) // UIImageOrientationLeft
    {
        // 顺时针旋转270°
        translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2 * 3.0);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    }
    // 方向是 0 不做处理

    roateInstruction.layerInstructions = @[roateLayerInstruction];
    videoComposition.instructions = @[roateInstruction]; // 加入视频方向信息

    return videoComposition;
}

/// 获取视频角度
+ (int)degressFromVideoFileWithAsset:(AVAsset *)asset
{
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo]; //获取轨道资源
    if ([tracks count] > 0)
    {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform; // 处理形变的类型
        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            //     x = -y / y = x  逆时针旋转 90 度
            degress = 90; //UIImageOrientationRight
        }
        else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)
        {
            //     x = y / y = -x    逆时针旋转 270 度
            degress = 270; // UIImageOrientationLeft
        }
        else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            //   x = y / y = y         向右 ------ 旋转0度
            degress = 0; //UIImageOrientationUp
        }
        else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            // LandscapeLeft     x = -x / y = -y   逆时针旋转180
            degress = 180; //UIImageOrientationDown
        }
    }
    return degress;
    /*
     [a b   0]
     [c d    0]
     [tx ty   1]
     x = ax + cy + tx
     y = bx + dy + ty
     其中tx---x轴方向--平移,ty---y轴方向平移;a--x轴方向缩放,d--y轴缩放;abcd共同控制旋转
     */
}

#pragma mark 添加水印
/// 添加水印的方法
+ (void)addWatermarkForVideoAsset:(AVAsset *)videoAsset waterImage:(UIImage *)waterImage describe:(NSString *)describe completion:(void (^)(NSURL *outputPath, NSError *error, IJSVideoState state))completion;
{
    //拿到视频和音频资源

    AVAssetTrack *assetVideoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];
    AVAssetTrack *assetAudioTrack = [videoAsset tracksWithMediaType:AVMediaTypeAudio][0];

    AVMutableComposition *mixComposition = [AVMutableComposition composition];

    //往AVMutableComposition对象添加视频资源，同时设置视频资源的时间段和插入点
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [videoAsset duration])
                                   ofTrack:assetVideoTrack
                                    atTime:kCMTimeZero
                                     error:nil];

    //往AVMutableComposition对象添加音频资源，同时设置音频资源的时间段和插入点
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [videoAsset duration])
                                   ofTrack:assetAudioTrack
                                    atTime:kCMTimeZero
                                     error:nil];

    // 创建视频组合器对象 AVMutableVideoComposition 并设置frame和渲染宽高
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    videoComposition.renderSize = assetVideoTrack.naturalSize;

    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);

    AVAssetTrack *videoTrack = [mixComposition tracksWithMediaType:AVMediaTypeVideo][0];

    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    passThroughInstruction.layerInstructions = @[passThroughLayer];
    videoComposition.instructions = @[passThroughInstruction];

    //创建水印图层Layer并设置frame和水印的位置，并将水印加入视频组合器中
    // 总的layer,----承载layer
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height); // 视频的尺寸
    // 视频的layer----
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height);
    [parentLayer addSublayer:videoLayer];
    // 水印层
    CALayer *watermarkLayer = [CALayer layer];
    watermarkLayer.contents = (id) waterImage.CGImage;
    watermarkLayer.bounds = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height);
    watermarkLayer.position = CGPointMake(videoComposition.renderSize.width * 0.5, videoComposition.renderSize.height * 0.5);
    [parentLayer addSublayer:watermarkLayer];
    // 加文字
    UIFont *font = [UIFont systemFontOfSize:30.0];
    CATextLayer *subTextLayer = [[CATextLayer alloc] init];
    [subTextLayer setFontSize:30];
    [subTextLayer setString:describe];
    [subTextLayer setAlignmentMode:kCAAlignmentCenter];
    [subTextLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
    subTextLayer.masksToBounds = YES;
    subTextLayer.cornerRadius = 23.0f;
    [subTextLayer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor];
    CGSize textSize = [describe sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    [subTextLayer setFrame:CGRectMake(50, 50, textSize.width + 20, textSize.height + 10)];
    [watermarkLayer addSublayer:subTextLayer];

    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];

    // 7  导出视频
    NSURL *outputURL = [self _getExportVideoPathForType:@"mp4"]; // 创建输出的路径
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];

    //设置AVAssetExportSession的AVVideoComposition对象，AVAudioMix对象，视频导出路径，视频导出格式
    exportSession.videoComposition = videoComposition;
    exportSession.audioMix = nil;
    exportSession.outputURL = outputURL;

    NSArray *supportedTypeArray = exportSession.supportedFileTypes;
    if ([supportedTypeArray containsObject:AVFileTypeMPEG4])
    {
        exportSession.outputFileType = AVFileTypeMPEG4;
    }
    else
    {
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    }

    //输出文件是否网络优化
    exportSession.shouldOptimizeForNetworkUse = YES;

    //异步导出
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {

        dispatch_async(dispatch_get_main_queue(), ^{
            switch (exportSession.status)
            {
                case AVAssetExportSessionStatusUnknown:
                {
                    if (completion)
                    {
                        completion(nil, exportSession.error, IJSExportSessionStatusUnknown);
                    }
                    break;
                }
                case AVAssetExportSessionStatusWaiting:
                {
                    if (completion)
                    {
                        completion(nil, exportSession.error, IJSExportSessionStatusWaiting);
                    }
                    break;
                }
                case AVAssetExportSessionStatusExporting:
                {
                    if (completion)
                    {
                        completion(nil, exportSession.error, IJSExportSessionStatusExporting);
                        break;
                    }
                }
                case AVAssetExportSessionStatusCompleted:
                {
                    if (completion)
                    {
                        completion(outputURL, nil, IJSExportSessionStatusCompleted);
                    }
                    break;
                }
                case AVAssetExportSessionStatusFailed:
                {
                    if (completion)
                    {
                        completion(nil, exportSession.error, IJSExportSessionStatusFailed);
                    }
                    break;
                }
                default:
                    break;
            }
        });
    }];
}

///获取视频的大小
+ (CGSize)getVideSizeFromAvasset:(AVAsset *)videoAsset
{
    CGSize videoSize = CGSizeZero;
    NSArray *tracksArr = videoAsset.tracks;
    for (AVAssetTrack *track in tracksArr)
    {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo])
        {
            videoSize = track.naturalSize;
            break;
        }
    }
    return videoSize;
}

/*------------------------------------内部私有方法-------------------------------*/
/// 设置导出对象
+ (void)_getExportVideoWithAvAssset:(AVAsset *)videoAsset videoComposition:(AVVideoComposition *)videoComposition audioMix:(AVAudioMix *)audioMix timeRange:(CMTimeRange)timeRange completion:(void (^)(NSURL *outputPath, NSError *error, IJSVideoState state))completion cut:(BOOL)isCut
{
    NSURL *outputURL = [self _getExportVideoPathForType:@"mp4"]; // 创建输出的路径
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
            initWithAsset:videoAsset
               presetName:AVAssetExportPresetHighestQuality]; //AVAssetExportPresetPassthrough可能返回没有处理过的视频
        if (!isCut)
        {
            exportSession.timeRange = timeRange; //截取时间---直接导出的方法只能从0开始
        }
        if (videoComposition.renderSize.width)
        {                                                      // 注意方向是 0 不要做处理否则会导出失败
            exportSession.videoComposition = videoComposition; // 修正视频转向
        }
        exportSession.audioMix = audioMix;
        exportSession.outputURL = outputURL;             // 输出URL
        exportSession.shouldOptimizeForNetworkUse = YES; // 优化网络
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        NSArray *supportedTypeArray = exportSession.supportedFileTypes; //支持的格式
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4])        //MP4
        {
            exportSession.outputFileType = AVFileTypeMPEG4;
        }
        else if (supportedTypeArray.count == 0)
        {
            NSError *error = [NSError ijsPhotoSDKVideoActionDescription:@"视频类型暂不支持导出"];
            if (completion)
            {
                completion(nil, error, IJSExportSessionStatusFailed);
            }
            return;
        }
        else
        {
            exportSession.outputFileType = [supportedTypeArray objectAtIndex:0];
        }

        // 开始异步导出视频
        __block NSError *error;

        [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (exportSession.status)
                {
                    case AVAssetExportSessionStatusUnknown:
                    {
                        error = [NSError ijsPhotoSDKVideoActionDescription:@"AVAssetExportSessionStatusUnknown"];
                        if (completion)
                        {
                            completion(nil, error, IJSExportSessionStatusUnknown);
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusWaiting:
                    {
                        error = [NSError ijsPhotoSDKVideoActionDescription:@"AVAssetExportSessionStatusWaiting"];
                        if (completion)
                        {
                            completion(nil, error, IJSExportSessionStatusWaiting);
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusExporting:
                    {
                        error = [NSError ijsPhotoSDKVideoActionDescription:@"AVAssetExportSessionStatusExporting"];
                        if (completion)
                        {
                            completion(nil, error, IJSExportSessionStatusExporting);
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusCompleted:
                    {
                        if (completion)
                        {
                            completion(outputURL, nil, IJSExportSessionStatusCompleted);
                        }
                        break;
                    }
                    case AVAssetExportSessionStatusFailed:
                    {
                        error = [NSError ijsPhotoSDKVideoActionDescription:[NSString stringWithFormat:@"导出失败:%@", exportSession.error]];
                        if (completion)
                        {
                            completion(nil, error, IJSExportSessionStatusFailed);
                        }
                        break;
                    }
                    default:
                        break;
                }
            });
        }];
    }
}

/// 创建视频路径
+ (NSURL *)_getExportVideoPathForType:(NSString *)type
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *tmpPath =[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    // NSHomeDirectory()：应用程序目录， @"tmp/temp"：在tmp文件夹下创建temp 文件夹
    NSString *filePath=[tmpPath stringByAppendingPathComponent:@"IJSImageEditSDK"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {        // 在 tmp 目录下创建一个 temp 目录
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
  
    NSString *outputPath =[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/output-%@.%@",[formater stringFromDate:[NSDate date]],type]];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    return outputURL;
}

/// 获取视频裁剪完成保存的文件路径
+(void)cleanAllVideoAndImage
{
    NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp/IJSImageEditSDK"];
   NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}
///获取视频保存路径
+(NSString *)getAllVideoPathAndImagePath
{
    return  [NSHomeDirectory() stringByAppendingString:@"/tmp/IJSImageEditSDK"];
}

/// 视频保存沙盒路径
+(void)saveImageToSandBoxImage:(UIImage *)image completion:(void (^)(NSURL *outputPath, NSError *error))completion
{
    NSURL *outputPath =[self _getExportVideoPathForType:@"png"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        if (data)
        {
            BOOL isRight = [data writeToURL:outputPath atomically:YES];
            if (isRight)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion)
                    {
                        completion(outputPath,nil);
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion)
                    {
                        NSError *error = [NSError ijsPhotoSDKImageActionDescription:@"图片写入失败"];
                        completion(outputPath,error);
                    }
                });
            }
        }
    });
}













@end
