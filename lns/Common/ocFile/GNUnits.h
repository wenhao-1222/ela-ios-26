//
//  GNUnits.h
//  GoldenManager
//
//  Created by 文 on 2018/6/13.
//  Copyright © 2018年 sanpu. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
BOOL isTelephoneNumber(NSString *phoneNumber);
BOOL isIdCardNumber (NSString * idCard);
BOOL isNullString(NSString *string);
NSString *md5String(NSString *string);
NSString *md5StringForPrivate(NSString *string);
NSString *stringFromDate(NSDate *date);
NSDate *dateFromString(NSString * dateString);
NSString *stringFromCurrentDate(NSDate *date);

NSString *urlAppend(NSDictionary *param);
NSString *funName(NSString *urlString);
NSString *sortArraryToString(NSArray *arrary);

NSDictionary *signDictory();

UIImage* convertViewToImage(UIView*v);  // UIView 转换成UIImage
UIImage *createImageWithColor(UIColor *color);

UIImage *generateQRCode(NSString *urlString); // 生成二维码

UIImage *generateQRCodeWithLogo(NSString *urlString,CGSize size);

NSString *bankImage(NSString *code);

// 银行卡号改成**** **** **** 1234的形式.
NSString *maskCardNumber(NSString *originalCardNumber);
NSString *maskPhoneNumber(NSString *phoneNumber);
NSString *maskAccountName(NSString *originalName);

UIImage *decodeImage(NSString *base64String);

/** 直接传入精度丢失有问题的Double类型*/
NSString *decimalNumberWithDouble(double conversionValue);


// 获取当前时间 yyyy-MM-dd
NSString *currentOfDatetime();
@interface GMUnits : NSObject
+(UIImage*)getSubImage:(CGRect)rect andImage:(UIImage *)image;
+(UIImage *)cropImageFrom:(UIView *)aView inRect:(CGRect)rect;
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withSourceImage:(UIImage *)sourceImage;
+ (void)callPhoneStr:(NSString*)phoneStr  withVC:(UIViewController *)selfvc;

@end
