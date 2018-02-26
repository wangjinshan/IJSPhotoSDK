//
//  UIImage+IJSUImage.m
//  IJSE
//
//  Created by shan on 2017/6/30.
//  Copyright © 2017年 shanshen. All rights reserved.
//

#import "UIImage+IJSUImage.h"
#define CTImageEditPreviewFrame \
    (CGRect) { 0, 60, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 167 }
#define bitsPerComponent (8)
#define bitsPerPixel (32)
#define bytesPerRow (4)

@implementation UIImage (IJSUImage)

// 在周边加一个边框为1的透明像素
- (UIImage *)imageAntialias
{
    if (self)
    {
        CGFloat border = 1.0f;
        CGRect rect = CGRectMake(border, border, self.size.width - 2 * border, self.size.height - 2 * border);
        UIImage *img = nil;
        UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
        [self drawInRect:CGRectMake(-1, -1, self.size.width, self.size.height)];
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIGraphicsBeginImageContext(self.size);
        [img drawInRect:rect];
        UIImage *antiImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return antiImage;
    }
    return nil;
}
// 返回一张圆形图
+ (UIImage *)imageCircleFromOriginImage:(UIImage *)originImage
{
    // 2,裁剪图片,--> 图形上下文可以进行图片裁剪生成新图
    // 1 开启图形上下文    // 上下文值/设置透明/比例因素: 当前点与像素的比例,写0自动适配
    UIGraphicsBeginImageContextWithOptions(originImage.size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, originImage.size.width, originImage.size.height)]; // 2, 描述裁剪区域
    [path addClip];                                                                                                                 // 3, 设置裁剪区域
    [originImage drawAtPoint:CGPointZero];                                                                                          // 4, 画图
    originImage = UIGraphicsGetImageFromCurrentImageContext();                                                                      // 5, 取出图片
    UIGraphicsEndImageContext();                                                                                                    // 6, 关闭上下文
    [originImage imageAntialias];                                                                                                   // 抗锯齿

    return originImage;
}

// 根据图片的名字返回需要的圆形图片
+ (UIImage *)imageCircleFromImageName:(NSString *)imageName
{
    return [UIImage imageCircleFromOriginImage:[UIImage imageNamed:imageName]];
}

//图片旋转角度
- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    //定义一个执行旋转的CGAffineTransform结构体
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    //对图片的原始区域执行旋转，获取旋转后的区域
    CGRect rotateRect = CGRectApplyAffineTransform(CGRectMake(0, 0, self.size.width, self.size.height), t);
    //获取图片旋转后的大小
    CGSize rotatedSize = rotateRect.size;
    //创建绘制位图的上下文
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //指定坐标变换，将坐标中心平移到图片中心
    CGContextTranslateCTM(ctx, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
    //执行坐标变换，旋转过radians弧度
    CGContextRotateCTM(ctx, radians);
    //    CALayer *layer = [CALayer layer];

    //执行坐标变换，执行缩放
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //绘制图片
    CGContextDrawImage(ctx, CGRectMake(-self.size.width / 2.0, -self.size.height / 2.0, self.size.width, self.size.height), self.CGImage);
    //获取绘制后生成的新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// 根据全图获取一张高斯模糊图
- (UIImage *)getImageFilterForGaussianBlur:(int)blurNumber
{
    CGFloat blur = blurNumber * self.size.width / [UIScreen mainScreen].bounds.size.width;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                                                @"inputRadius", @(blur),
                                                nil];
    CIImage *outputImage = filter.outputImage;
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    if (cgImage)
    {
        CGImageRelease(cgImage);
    }
    return image;
}

+ (CGRect)getViewBoundWith:(UIImage *)image
{
    CGSize toSize = image.size;
    CGSize size = CTImageEditPreviewFrame.size;

    if (size.width >= toSize.width && size.height >= toSize.height)
    { //宽度大于要显示的区域
        return CGRectMake(0, 0, toSize.width, toSize.height);
    }
    else if (size.width < toSize.width && size.height >= toSize.height)
    { //宽度小于要显示区域，,太长截取
        CGSize resultSize = CGSizeMake(size.width, toSize.height * size.width / toSize.width);
        return CGRectMake(0, 0, resultSize.width, resultSize.height);
    }
    else if (size.width >= toSize.width && size.height < toSize.height)
    {
        CGSize resultSize = CGSizeMake(toSize.width * size.height / toSize.height, size.height);
        return CGRectMake(0, 0, resultSize.width, resultSize.height);
    }
    else
    {
        CGFloat scaleW = toSize.width / size.width;
        CGFloat scaleH = toSize.height / size.height;
        CGSize resultSize;
        if (scaleW > scaleH)
        {
            resultSize = CGSizeMake(size.width, toSize.height / scaleW);
        }
        else
        {
            resultSize = CGSizeMake(toSize.width / scaleH, size.height);
        }
        return CGRectMake(0, 0, resultSize.width, resultSize.height);
    }
}

+ (UIImage *)getImageWithOldImage:(UIImage *)image
{
    CGSize resultSize = image.size;
    UIGraphicsBeginImageContext(resultSize);
    [image drawInRect:CGRectMake(0, 0, resultSize.width, resultSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return scaledImage;
}

+ (UIImage *)getScaleImageWith:(UIImage *)image
{
    CGSize toSize = image.size;
    CGSize size = CTImageEditPreviewFrame.size;
    size.width = size.width * [UIScreen mainScreen].scale;
    size.height = size.height * [UIScreen mainScreen].scale;

    if (size.width >= toSize.width && size.height >= toSize.height)
    { //宽度大于要显示的区域
        return image;
    }
    else if (size.width < toSize.width && size.height >= toSize.height)
    { //宽度小于要显示区域，,太长截取
        CGSize resultSize = CGSizeMake(size.width, toSize.height * size.width / toSize.width);
        UIGraphicsBeginImageContext(resultSize);
        [image drawInRect:CGRectMake(0, 0, resultSize.width, resultSize.height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return scaledImage;
    }
    else if (size.width >= toSize.width && size.height < toSize.height)
    {
        CGSize resultSize = CGSizeMake(toSize.width * size.height / toSize.height, size.height);
        UIGraphicsBeginImageContext(resultSize);
        [image drawInRect:CGRectMake(0, 0, resultSize.width, resultSize.height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return scaledImage;
    }
    else
    {
        CGFloat scaleW = toSize.width / size.width;
        CGFloat scaleH = toSize.height / size.height;
        CGSize resultSize;
        if (scaleW > scaleH)
        {
            resultSize = CGSizeMake(size.width, toSize.height / scaleW);
        }
        else
        {
            resultSize = CGSizeMake(toSize.width / scaleH, size.height);
        }
        UIGraphicsBeginImageContext(resultSize);
        [image drawInRect:CGRectMake(0, 0, resultSize.width, resultSize.height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return scaledImage;
    }
}

+ (UIImage *)getRotationWithImage:(UIImage *)image withOrientation:(UIDeviceOrientation)orientation
{
    UIImage *newImage;

    switch (orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
        {
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:
        {
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
            break;
        }
        default:
        {
            newImage = image;
            break;
        }
    }
    return newImage;
}

+ (UIImage *)getUnrotationWithImage:(UIImage *)image withOrientation:(UIDeviceOrientation)orientation
{
    UIImage *newImage;

    switch (orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
        {
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeft];
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:
        {
            newImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationDown];
            break;
        }
        default:
        {
            newImage = image;
            break;
        }
    }
    return newImage;
}

static inline CGFloat IJSDegreesToRadians(CGFloat degrees)
{
    return M_PI * (degrees / 180.0);
}

//  旋转图片
+ (UIImage *)rotatedByDegrees:(CGFloat)degrees withImage:(UIImage *)image
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(IJSDegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 2.0f);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);

    //   // Rotate the image context
    CGContextRotateCTM(bitmap, IJSDegreesToRadians(degrees));

    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)rotatedWithImage:(UIImage *)image
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(IJSDegreesToRadians(90));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, image.scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);

    //   // Rotate the image context
    CGContextRotateCTM(bitmap, IJSDegreesToRadians(90));

    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (CGSize)getCutViewSizeWith:(CGSize)bSize
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    CGFloat scaleW = screenSize.width / bSize.width;
    CGFloat scaleH = screenSize.height / bSize.height;
    if (scaleH < scaleW && scaleH < 1)
    {
        return CGSizeMake(bSize.width * scaleH, screenSize.height);
    }
    else if (scaleW <= scaleH && scaleW < 1)
    {
        return CGSizeMake(screenSize.width, bSize.height * scaleW);
    }
    else
    {
        return bSize;
    }
}

+ (CGSize)getCutImageViewSizeWith:(CGSize)bSize cutViewSize:(CGSize)cSize
{
    CGFloat scaleW = cSize.width / bSize.width;
    CGFloat scaleH = cSize.height / bSize.height;

    if (scaleH > scaleW)
    {
        return CGSizeMake(bSize.width * scaleH, cSize.height);
    }
    else
    {
        return CGSizeMake(cSize.width, bSize.height * scaleW);
    }
}

/*
 * 转换成马赛克,level代表一个点转为多少level*level的正方形
 */
- (UIImage *)getMosaicImageFromOrginImageBlockLevel:(NSUInteger)level
{
    // self == OrginImage
    //1,获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); // 创建颜色空间,需要释放内存
                                                                //    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGImageRef imgRef = self.CGImage;                           // 图片转换
    CGFloat width = CGImageGetWidth(imgRef);                    //图片宽
    CGFloat height = CGImageGetHeight(imgRef);                  //高

    // 2, 创建图片上下文(解析图片信息，绘制图片 开辟内存空间，这块空间用于处理马赛克图片
    /*
     参数4:代表每一个像素点,每一个分量大小(8位 2的8次 =255) (图形学中,一个像素点有ARGB组成,每一个颜色就分别代表一个分量,每一个分量大小: 8位 = 1字节)
     参数5:代表每一行的大小(图片由像素组成)
     计算:
     1, 计算一个像素点大小 = ARGB = 4 * 8 = 32位 = 4 字节
     2, 每一行大小 = 4字节 * width
     */
    CGContextRef context = CGBitmapContextCreate(nil, //数据源
                                                 width,
                                                 height,
                                                 bitsPerComponent,                // 通常是8
                                                 width * bytesPerRow,             //每一行的像素点占用的字节数(4)，每个像素点的ARGB四个通道各占8个bit
                                                 colorSpace,                      // 颜色空间
                                                 kCGImageAlphaPremultipliedLast); //是否需要透明度
    // 3, 根据图片上下文绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);

    // 4, 获取图片的指针(像素数组)
    unsigned char *bitmapData = CGBitmapContextGetData(context);
    //5, 核心算法 图片打码,加入马赛克,这里把BitmapData进行马赛克转换,让一个像素点替换为和它相同的矩形区域(正方形，圆形都可以)
    unsigned char pixel[bytesPerRow] = {0}; // 像素点默认是4个通道,默认值是0
    NSUInteger index, preIndex;             // 从左到右 上到下

    for (NSUInteger i = 0; i < height - 1; i++) // 行
    {
        for (NSUInteger j = 0; j < width - 1; j++) // 列
        {
            index = i * width + j;  // 获取当前像素点坐标
            if (i % level == 0)     // 新矩形开始(马赛克矩形第一行)
            {                       //行向所有被整除的坐标
                if (j % level == 0) // 第一个像素点 (马赛克矩形第一行第一个像素点)
                {                   //列向所有被整除的坐标 比如 3 * 3 (00 03 06 09.........)
                    /*
                     拷贝数据,例如 将马赛克矩阵第一行第一列像素点的值取出来替换后面的像素点的值
                     参数1: 目标数据----> pixels(像素点)
                     参数2: 原始数据----> bitmapPixels(图片像素数组)
                     参数3: 长度
                     指针位移方式获取像素点数据
                     像素点: 分量组成,指针位移,移动分量----> 4个字节 = 一个像素
                     */
                    memcpy(pixel, bitmapData + bytesPerRow * index, bytesPerRow); //给我们的像素点赋值
                }
                else
                {
                    // 在第二个满足马赛克矩阵的坐标之前的所有的坐标
                    memcpy(bitmapData + bytesPerRow * index, pixel, bytesPerRow);
                }
            }
            else
            {                                   // 行向没有被整除的其他的坐标
                preIndex = (i - 1) * width + j; //获取当前行上一行的坐标
                memcpy(bitmapData + bytesPerRow * index, bitmapData + bytesPerRow * preIndex, bytesPerRow);
            }
        }
    }

    // 6, 获取图片数据集合
    NSInteger dataLength = width * height * bytesPerRow;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);

    //7, 创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              bitsPerComponent,           //表示每一个像素点，每一个分量的大小 8
                                              bitsPerPixel,               //每一个像素点的大小  4 * 8 = 32
                                              width * bytesPerRow,        //每一行内存大小
                                              colorSpace,                 //颜色空间
                                              kCGBitmapByteOrderDefault,  //位图信息
                                              provider,                   //数据源（数据集合）
                                              NULL,                       //数据解码器
                                              NO,                         // 是否抗锯齿
                                              kCGRenderingIntentDefault); //渲染器

    // 8 创建输出马赛克图片（填充颜色）
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       bitsPerComponent,
                                                       width * bytesPerRow,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);

    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef); //  //绘制图片
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);                    // //创建图片
    UIImage *resultImage = nil;
    if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
    {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    }
    else
    {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if (colorSpace)
    {
        CGColorSpaceRelease(colorSpace);
    }
    if (resultImageRef)
    {
        CFRelease(resultImageRef);
    }
    if (mosaicImageRef)
    {
        CFRelease(mosaicImageRef);
    }
    if (provider)
    {
        CGDataProviderRelease(provider);
    }
    if (context)
    {
        CGContextRelease(context);
    }
    if (outputContext)
    {
        CGContextRelease(outputContext);
    }
    return resultImage;
}

// coreimage 获取马赛克图
- (UIImage *)getMosaicImageFromOrginImageFromCoreImagePixelSize:(int)pixel
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:self];
    //生成马赛克
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    //马赛克像素大小
    [filter setValue:@(pixel) forKey:kCIInputScaleKey];
    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];

    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outImage fromRect:[outImage extent]];
    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return showImage;
}

- (UIImage *)getImageWithOldImage
{
    CGSize resultSize = self.size;
    UIGraphicsBeginImageContext(resultSize);
    [self drawInRect:CGRectMake(0, 0, resultSize.width, resultSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
