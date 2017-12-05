//
//  UIImageView+IJSGif.m
//  IJSPhotoSDKProject
//
//  Created by 山神 on 2017/12/2.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "UIImageView+IJSGif.h"

#import <ImageIO/ImageIO.h>

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#define ARCCompatibleAutorelease(object) object
#else
#define toCF (CFTypeRef)
#define ARCCompatibleAutorelease(object) [object autorelease]
#endif

@implementation UIImageView (IJSGif)

// data 转成 GIf
- (void)showGifImageWithData:(NSData *)data
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval duration = [self durationForGifData:data];
        CGImageSourceRef source = CGImageSourceCreateWithData(toCF data, NULL);
        [self animatedGIFImageSource:source andDuration:duration];
        CFRelease(source);
    });
}
//  url 转成 Gif
- (void)showGifImageWithURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self showGifImageWithData:data];
}

- (void)animatedGIFImageSource:(CGImageSourceRef)source andDuration:(NSTimeInterval)duration
{
    if (!source)
    {
        return;
    }
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    for (size_t i = 0; i < count; ++i)
    {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!cgImage)
        {
            return;
        }
        [images addObject:[UIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setAnimationImages:images];
        [self setAnimationDuration:duration];
        [self startAnimating];
    });
}

- (NSTimeInterval)durationForGifData:(NSData *)data
{
    char graphicControlExtensionStartBytes[] = {0x21, 0xF9, 0x04};
    double duration = 0;
    NSRange dataSearchLeftRange = NSMakeRange(0, data.length);
    while (YES)
    {
        NSRange frameDescriptorRange = [data rangeOfData:[NSData dataWithBytes:graphicControlExtensionStartBytes
                                                                        length:3]
                                                 options:NSDataSearchBackwards
                                                   range:dataSearchLeftRange];
        if (frameDescriptorRange.location != NSNotFound)
        {
            NSData *durationData = [data subdataWithRange:NSMakeRange(frameDescriptorRange.location + 4, 2)];
            unsigned char buffer[2];
            [durationData getBytes:buffer length:data.length];
            double delay = (buffer[0] | buffer[1] << 8);
            duration += delay;
            dataSearchLeftRange = NSMakeRange(0, frameDescriptorRange.location);
        }
        else
        {
            break;
        }
    }
    return duration / 100;
}

















@end
