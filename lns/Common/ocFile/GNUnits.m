//
//  GNUnits.m
//  GoldenManager
//
//  Created by 文 on 2018/6/13.
//  Copyright © 2018年 sanpu. All rights reserved.
//


#import "GNUnits.h"
#import <CommonCrypto/CommonDigest.h>
UIImage *createNonInterpolatedUIImageFormCIImage(CIImage *image,CGFloat size);

BOOL isTelephoneNumber(NSString *phoneNumber)
{
    // 虽然正则也可以做到,但是直接检验长度更有效率.下同
    if ([phoneNumber length] != 11) {
        return NO;
    }
    // 130-139  150-153,155-159  180-189  145,147  170,171,173,176,177,178
    //    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(14[57])|(17[013678]))\\d{8}$";
    NSString *phoneRegex = @"^1[0-9]{10}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phoneNumber];
    
}

BOOL isIdCardNumber (NSString * idCard)
{
    NSString *pattern = @("^[0-9]{15}$)|([0-9]{17}([0-9]|X)$");
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:idCard];
    return isMatch;
}

BOOL isNullString(NSString *string)
{
    if ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"])
    {
        return YES;
        
    } else {
        return NO;
    }
    
    
    
}


NSString *md5String(NSString *string)
{
    const char *cStr =[string UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    
    return[NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
    
}

NSString *md5StringForPrivate(NSString *string)
{
    NSString *md5_suffix = @"_dengsilinming";
    NSString *encrypt = [NSString stringWithFormat:@"%@%@",string,md5_suffix];
    NSString *md5 = md5String(encrypt).lowercaseString;
    return md5;
    
}

NSDate *dateFromString(NSString * dateString){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}

NSString *stringFromDate(NSDate *date){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

NSString *stringFromCurrentDate(NSDate *date){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}


NSString *generateRandomStringWithLength(int length)
{
    static NSMutableArray *symbols = nil;
    if (symbols == nil) {
        symbols = [[NSMutableArray alloc] init];
        for (int i = '0'; i <= '9'; i++) {
            [symbols addObject:[NSString stringWithFormat:@"%c", i]];
        }
        for (int i = 'A'; i <= 'Z'; i++) {
            [symbols addObject:[NSString stringWithFormat:@"%c", i]];
        }
        for (int i = 'a'; i <'z'; i++) {
            [symbols addObject:[NSString stringWithFormat:@"%c", i]];
        }
    }
    
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        int j = arc4random() % symbols.count;
        [resultString appendString:symbols[j]];
    }
    
    return resultString;
}

UIImage* convertViewToImage(UIView*view){
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return image;
}

UIImage *generateQRCode(NSString *urlString)
{
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 恢复滤镜的默认属性
    [filter setDefaults];
    // 2、设置数据
    // 将字符串转换成
    NSData *infoData = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    // 通过KVC设置滤镜inputMessage数据
    [filter setValue:infoData forKeyPath:@"inputMessage"];
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    return createNonInterpolatedUIImageFormCIImage(outputImage, 200);
}

UIImage *generateQRCodeWithLogo(NSString *urlString,CGSize size)
{
    //    NSArray *filters = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    //    NSLog(@"%@",filters);
    
    //二维码过滤器
    CIFilter *qrImageFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //设置过滤器默认属性 (老油条)
    [qrImageFilter setDefaults];
    
    //将字符串转换成 NSdata (虽然二维码本质上是 字符串,但是这里需要转换,不转换就崩溃)
    NSData *qrImageData = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    
    //    //我们可以打印,看过滤器的 输入属性.这样我们才知道给谁赋值
    //    NSLog(@"%@",qrImageFilter.inputKeys);
    /*
     inputMessage,        //二维码输入信息
     inputCorrectionLevel //二维码错误的等级,就是容错率
     */
    
    
    //设置过滤器的 输入值  ,KVC赋值
    [qrImageFilter setValue:qrImageData forKey:@"inputMessage"];
    
    //取出图片
    CIImage *qrImage = [qrImageFilter outputImage];
    
    //但是图片 发现有的小 (27,27),我们需要放大..我们进去CIImage 内部看属性
//    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(50*HeightScale, 50*HeightScale)];
    
    //转成 UI的 类型
    UIImage *qrUIImage = [UIImage imageWithCIImage:qrImage];
    
    
    //----------------给 二维码 中间增加一个 自定义图片----------------
    //开启绘图,获取图形上下文  (上下文的大小,就是二维码的大小)
    UIGraphicsBeginImageContext(qrUIImage.size);
    
    //把二维码图片画上去. (这里是以,图形上下文,左上角为 (0,0)点)
    [qrUIImage drawInRect:CGRectMake(0, 0, qrUIImage.size.width, qrUIImage.size.height)];
    
    
    //再把小图片画上去
//    UIImage *sImage = IMAGENAMED(@"xingixang");
    

    
    CGFloat sImageW = 50;
    CGFloat sImageH= sImageW;
    CGFloat sImageX = (size.width - sImageW) * 0.5;
    CGFloat sImgaeY = (size.height - sImageH) * 0.5;
    
//    [sImage drawInRect:CGRectMake(sImageX, sImgaeY, sImageW, sImageH)];
    
    //获取当前画得的这张图片
    UIImage *finalyImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return finalyImage;
}

UIImage *createNonInterpolatedUIImageFormCIImage(CIImage *image,CGFloat size)
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

NSString *currentOfDatetime()
{
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    NSDate *curDate = [NSDate date];        //获取当前日期
    [formater setDateFormat:@"yyyy-MM-dd"]; //这里去掉 具体时间 保留日期
    NSString * curTime = [formater stringFromDate:curDate];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formater setTimeZone:timeZone];
    return curTime;
}

@implementation GMUnits
+(UIImage*)getSubImage:(CGRect)rect andImage:(UIImage *)image
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}
+(UIImage *)cropImageFrom:(UIView *)aView inRect:(CGRect)rect
{
    CGSize cropImageSize = rect.size;
    UIGraphicsBeginImageContext(cropImageSize);
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(resizedContext, -(rect.origin.x), -(rect.origin.y));
    [aView.layer renderInContext:resizedContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

UIImage *createImageWithColor(UIColor *color)
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 5.0f, 5.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
/**
 *  图片压缩到指定大小
 *  @param targetSize  目标图片的大小
 *  @param sourceImage 源图片
 *  @return 目标图片
 */
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withSourceImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

NSString *maskCardNumber(NSString *originalCardNumber)
{
    NSRange middleRange = NSMakeRange(0, originalCardNumber.length - 4);
    return [originalCardNumber stringByReplacingCharactersInRange:middleRange withString:@"**** **** **** "];
}

NSString *maskPhoneNumber(NSString *phoneNumber)
{
    if (!phoneNumber || phoneNumber.length == 0) {
        return @"";
    }
    NSRange middleRange = NSMakeRange(3, phoneNumber.length - 7);
    return [phoneNumber stringByReplacingCharactersInRange:middleRange withString:@"****"];
}

NSString *maskAccountName(NSString *originalName)
{
    if (originalName.length <2 ) {
        return originalName;
    }
    NSRange middleRange = NSMakeRange(0, originalName.length - 1);
    return [originalName stringByReplacingCharactersInRange:middleRange withString:@"*"];
}

/** 直接传入精度丢失有问题的Double类型*/
NSString *decimalNumberWithDouble(double conversionValue){
    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}
+ (void)callPhoneStr:(NSString*)phoneStr  withVC:(UIViewController *)selfvc
{
    NSString *str2 = [[UIDevice currentDevice] systemVersion];
    
    if ([str2 compare:@"10.2" options:NSNumericSearch] == NSOrderedDescending || [str2 compare:@"10.2" options:NSNumericSearch] == NSOrderedSame)
    {
        NSLog(@">=10.2");
        NSString* PhoneStr = [NSString stringWithFormat:@"tel://%@",phoneStr];
        if ([PhoneStr hasPrefix:@"sms:"] || [PhoneStr hasPrefix:@"tel:"]) {
            UIApplication * app = [UIApplication sharedApplication];
            if ([app canOpenURL:[NSURL URLWithString:PhoneStr]]) {
                [app openURL:[NSURL URLWithString:PhoneStr]];
            }
        }
    }else {
        NSMutableString* str1 = [[NSMutableString alloc]initWithString:phoneStr];// 存在堆区，可变字符串
        if (phoneStr.length == 10) {
            [str1 insertString:@"-"atIndex:3];// 把一个字符串插入另一个字符串中的某一个位置
            [str1 insertString:@"-"atIndex:7];// 把一个字符串插入另一个字符串中的某一个位置
        }else {
            [str1 insertString:@"-"atIndex:3];// 把一个字符串插入另一个字符串中的某一个位置
            [str1 insertString:@"-"atIndex:8];// 把一个字符串插入另一个字符串中的某一个位置
        }
        NSString * str = [NSString stringWithFormat:@"是否拨打电话\n%@",str1];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:str message: nil preferredStyle:UIAlertControllerStyleAlert];
        // 设置popover指向的item
        alert.popoverPresentationController.barButtonItem = selfvc.navigationItem.leftBarButtonItem;
        // 添加按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"点击了呼叫按钮10.2下");
            NSString* PhoneStr = [NSString stringWithFormat:@"tel://%@",phoneStr];
            if ([PhoneStr hasPrefix:@"sms:"] || [PhoneStr hasPrefix:@"tel:"]) {
                UIApplication * app = [UIApplication sharedApplication];
                if ([app canOpenURL:[NSURL URLWithString:PhoneStr]]) {
                    [app openURL:[NSURL URLWithString:PhoneStr]];
                }
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"点击了取消按钮");
        }]];
        [selfvc presentViewController:alert animated:YES completion:nil];
    }
    
}


@end

