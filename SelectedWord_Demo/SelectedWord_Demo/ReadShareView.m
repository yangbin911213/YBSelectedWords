//
//  ReadShareView.m
//  SelectedWord_Demo
//
//  Created by yangbin on 2017/7/17.
//  Copyright © 2017年 yangbin. All rights reserved.
//

#import "ReadShareView.h"
#import "ReadConfig.h"
#import "ReadParser.h"

#define titleTopMargen  20
#define titleLeftMargen 20

@interface ReadShareView ()

@property (nonatomic, strong) UIScrollView *mScrollView;
@property (nonatomic, strong) UIView *mContentView;

@end

@implementation ReadShareView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.mContentView];
        [self addSubview:self.mScrollView];
        
    }
    return self;
}


- (void)createShareImage:(NSString *)content {
    
    // 计算分享文字高度
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSDictionary *attribute = [ReadParser parserAttribute:[ReadConfig shareInstance]];
    [attributedString setAttributes:attribute range:NSMakeRange(0, content.length)];
    CGRect titleRect = [attributedString boundingRectWithSize:CGSizeMake(self.frame.size.width - 15 * 2 - titleTopMargen * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGRect imageRect = CGRectMake(titleRect.origin.x, titleRect.origin.y, self.mScrollView.frame.size.width, titleRect.size.height + 150);
    
    // 设置scrollview的contentSize
    [self.mScrollView setContentSize:imageRect.size];
    
    // 生成画布
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageRect.size.width, imageRect.size.height), NO, 0.0);
    // 创建上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 绘制背景颜色
    CGContextSetFillColorWithColor(context, [[UIColor yellowColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, imageRect.size.width, imageRect.size.height));
    // 沿着路径绘制
    CGContextDrawPath(context, kCGPathFill);
    
    // 划线
    // 改变划线的颜色
    CGContextSetStrokeColorWithColor(context, [UIColor cyanColor].CGColor);
    CGContextSetLineWidth(context, 3.0);//线的宽度
    // 方法一：
//    CGContextSetLineCap(context, kCGLineCapRound);
//    CGContextSetLineJoin(context, kCGLineJoinRound);
//    CGContextMoveToPoint(context, 10, 50);
//    CGContextAddLineToPoint(context, 100, 50);
//    CGContextDrawPath(context, kCGPathStroke);
    // 方法二：
    CGPoint aPoints[2];
    aPoints[0] = CGPointMake(titleLeftMargen, titleRect.size.height + 30 + titleTopMargen);
    aPoints[1] = CGPointMake(imageRect.size.width - titleLeftMargen, titleRect.size.height + 30 + titleTopMargen);
    CGContextAddLines(context, aPoints, 2);
    CGContextDrawPath(context, kCGPathStroke);
    
    // 绘制下方图片
    CGFloat versionSize = 57;
    
    UIImage *image = [self qrImageForString:@"12345678" imageSize:versionSize];
    
    [image drawInRect:CGRectMake(imageRect.size.width/2.0 - versionSize/2.0, aPoints[1].y + 30, versionSize, versionSize)];
    
    // 绘制分享文字
    [content drawInRect:CGRectMake(titleTopMargen, titleLeftMargen, titleRect.size.width, titleRect.size.height) withAttributes:[ReadParser parserAttribute:[ReadConfig shareInstance]]];
    
    // 生成图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:newImage];
    imageView.backgroundColor = [UIColor blueColor];
    [self.mScrollView addSubview:imageView];
    
}

// 二维码的生成
- (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)imageSize {
    
   /* 二维码一共有40个尺寸。官方叫版本Version。Version 1是21 x 21的矩阵，Version 2是 25 x 25的矩阵，Version 3是29的尺寸，每增加一个version，就会增加4的尺寸，公式是：(V-1)4 + 21（V是版本号） 最高Version 40，(40-1)4+21 = 177，所以最高是177 x 177 的正方形
    */
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"]; // 通过kvo方式给一个字符串，生成二维码
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];  // 设置二维码的纠错水平，越高纠错水品越高，可以污损的范围越大
    
    CIImage *outPutImage = [filter outputImage]; // 拿到二维码图片
    
    return [self createNonInterpolatedUIImageFormCIImage:outPutImage size:imageSize];
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image size:(CGFloat)size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    // 创建一个DeviceGray颜色空间
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
//    CGBitmapContextCreate(<#void * _Nullable data#>, <#size_t width#>, <#size_t height#>, <#size_t bitsPerComponent#>, <#size_t bytesPerRow#>, <#CGColorSpaceRef  _Nullable space#>, <#uint32_t bitmapInfo#>)
    // width: 图片宽度像素
    // height: 图片高度像素
    // bitsPerComponent：每个颜色的比特值，例如在rgba-32模式下为8
    // bitmapInfo：指定的位图应该包含一个alpha通道
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    
    // 创建CoreGraphics image
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef); CGImageRelease(bitmapImage);
    UIImage *outputImage = [UIImage imageWithCGImage:scaledImage];
    
    return outputImage;
}


- (UIScrollView *)mScrollView {
    
    if (!_mScrollView) {
        _mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 30, self.frame.size.width - 15 * 2, 250)];
    }
    return _mScrollView;
}

- (UIView *)mContentView {
    
    if (!_mContentView) {
        _mContentView = [[UIView alloc] initWithFrame:self.bounds];
        _mContentView.backgroundColor = [UIColor blackColor];
        _mContentView.alpha = 0.3;
    }
    return _mContentView;
}


@end
