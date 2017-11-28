//
//  UIImage+Size.m
//  LLKit
//
//  Created by 冯文林 on 16/8/12.
//  Copyright © 2016年 LLSky. All rights reserved.
//

#import "UIImage+Size.h"

@implementation UIImage (Size)

+ (NSData *)compressImageDataWithImage:(UIImage *)img
{
    UIImage *pixelCompression = [self compressPixelWithImage:img withWidthPixelLimit:1100];
    NSData *qualityCompression = UIImageJPEGRepresentation(pixelCompression, 0);
    
    return qualityCompression;
}

+ (UIImage*)imageNamed:(NSString *)imgName scaleThatFill:(CGSize)size
{
    UIImage *img = [UIImage imageNamed:imgName];
    return [self image:img scaleThatFill:size];
}

#pragma mark - UIImage(private)

+ (UIImage *)compressPixelWithImage:(UIImage *)originImg withWidthPixelLimit:(CGFloat)limit
{
    CGFloat imageW = originImg.size.width;
    CGFloat imageH = originImg.size.height;
    
    CGFloat ratio = 0;
    if (imageW > limit || imageH > limit) {
        if (imageW > imageH) {
            ratio = limit/imageW;
            imageW = limit;
            imageH *= ratio;
        }else {
            ratio = limit/imageH;
            imageH = limit;
            imageW *= ratio;
        }
    }
    
    UIImage *compression = [self image:originImg scaleThatFill:CGSizeMake(imageW, imageH)];
    return compression;
}

+ (UIImage *)image:(UIImage *)img scaleThatFill:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *)image:(UIImage *)img aspectThatFill:(CGSize)size
{
    CGFloat wRatio = size.width/img.size.width;
    CGFloat hRatio = size.height/img.size.height;
    CGFloat realRatio = wRatio>=hRatio?wRatio:hRatio;
    
    CGFloat contextW = realRatio*img.size.width;
    CGFloat contextH = realRatio*img.size.height;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);

    // 裁剪，UIGraphicsGetImageFromCurrentImageContext()返回context大小，包括了被cut的部分
    //    CGMutablePathRef path = CGPathCreateMutable();
    //    CGPathAddRect(path, NULL, (CGRect){contextW/2-size.width/2, contextH/2-size.height/2, size});
    //    CGContextAddPath(UIGraphicsGetCurrentContext(), path);
    //    CGContextClip(UIGraphicsGetCurrentContext());
    
    [img drawInRect:CGRectMake(-(contextW/2-size.width/2), -(contextH/2-size.height/2), contextW, contextH)];
    
    UIImage *aspectedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return aspectedImage;
}

@end
