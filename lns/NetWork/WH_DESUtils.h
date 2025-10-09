//
//  WH_DESUtils.h
//  wh3desUtil
//
//  Created by yong kang on 2017/9/7.
//  Copyright © 2017年 wenh_mouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WH_DESUtils : NSObject


//DES加密
+ (NSArray *) encryptUseDES:(NSString *)plainText;

#pragma mark - md5 16位加密 （大写）
+(NSString *)md5:(NSString *)str;

//报文DES加密
+ (NSString *) encryptUseDESForData:(NSString *)plainText needLogin:(BOOL)needLogin;

/**
 * 发送验证码用公钥加密
 */
+ (NSString *) encryptUseDESForSendSMS:(NSString *)plainText;

//报文DES解密
+ (NSString *) decryptUseDESForData:(NSString *)plainText needLogin:(BOOL)needLogin;

//报文DES解密   公钥
+ (NSString *) decryptUseDESForDataWithKey:(NSString *)cipherText;

+(NSString*)getStringForSign:(NSDictionary*)paramDict needLogin:(BOOL)needLogin;

+ (NSData *)convertHexStrToData:(NSString *)str;

+(NSData*)compressImageToData:(UIImage*)img;

+(void)dddd;
@end
