//
//  WH_DESUtils.m
//  wh3desUtil
//
//  Created by yong kang on 2017/9/7.
//  Copyright © 2017年 wenh_mouse. All rights reserved.
//

#import "WH_DESUtils.h"
#include <CommonCrypto/CommonCrypto.h>
#import "GTMBase64.h"
#import "NSData+UTF8.h"
#include <iconv.h>
#import "RSA.h"

#define KEY @"78632BBBA614A4B51DFBF915B5912345"
#define DATA_ENCRYPT_KEY @"78632BBBA614A4B51DFBF915B5912345"

@implementation WH_DESUtils

//DES加密
+ (NSArray *) encryptUseDES:(NSString *)plainText{
    NSString *keyStr = KEY;
    NSString *privateKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"privateKey"];
    if (privateKey.length > 0) {
        keyStr = privateKey;
    }
    
    NSString *ciphertext = nil;
    
    NSArray *arr = [WH_DESUtils getStrForEncrypt:plainText];
    plainText = arr[0];
    
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    const void *iv = (const void *)[keyStr UTF8String];
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [keyStr UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          textBytes, dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        
        ciphertext = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    }
    
    ciphertext = [WH_DESUtils hexStringFromString:ciphertext];
    return @[ciphertext,arr[1]];
}

//两位密码长度+真实密码+四位随机校验值
+(NSArray*)getStrForEncrypt:(NSString*)plainText{
    NSString *returnStr = nil;
    int strLength = (int)plainText.length;
    if (strLength > 9) {
        returnStr = [NSString stringWithFormat:@"%d",strLength];
    }else{
        returnStr = [NSString stringWithFormat:@"0%d",strLength];
    }
    
    returnStr = [returnStr stringByAppendingString:plainText];
    
    int num = (arc4random() % 10000);
    NSString *randomNumber = [NSString stringWithFormat:@"%.4d", num];
    returnStr = [returnStr stringByAppendingString:randomNumber];

    return @[returnStr,randomNumber];
}

+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];   
    }   
    return hexStr;   
}

#pragma mark - md5 16位加密 （大写）
+(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//报文DES加密
+ (NSString *) encryptUseDESForData:(NSString *)plainText needLogin:(BOOL)needLogin{
    
    NSString *keyStr = DATA_ENCRYPT_KEY;
    NSString *privateKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"privateKey"];
    if (privateKey.length > 0 && needLogin) {
        keyStr = privateKey;
    }
//    DEBUG_Log(@"加密KEY:%@",keyStr);
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024 * 500];
    memset(buffer, 0, sizeof(char));
    const void *iv = (const void *)[keyStr UTF8String];
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [keyStr UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          textBytes, dataLength,
                                          buffer, 1024 * 500,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    }
    
    return ciphertext;
}

/**
 * 发送验证码加密，用公钥
 */
+ (NSString *) encryptUseDESForSendSMS:(NSString *)plainText{
    
    NSString *keyStr = DATA_ENCRYPT_KEY;

    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    const void *iv = (const void *)[keyStr UTF8String];
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [keyStr UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          textBytes, dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    }
    
    return ciphertext;
}
//
//+ (NSString *) decryptUseDESForData:(NSString *)cipherText{
//    NSString *key = DATA_ENCRYPT_KEY;
//    NSString *privateKey = [[NSUserDefaults standardUserDefaults]objectForKey:WH_PRIVATE_KEY];
//    if (privateKey.length > 0) {
//        key = privateKey;
//    }
//    NSData *keyDate=[key dataUsingEncoding:NSUTF8StringEncoding];
//    //    转换成byte数组
//    Byte *iv = (Byte *)[keyDate bytes];
//
//    NSString *plaintext = nil;
//
//    NSData *dataa = [GTMBase64 decodeData:[cipherText dataUsingEncoding:NSUTF8StringEncoding]];
//    const void *dataIn;
//    size_t dataInLength;
//
//    dataInLength = [dataa length];
//    dataIn = [dataa bytes];
//
//    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写（有效的维护了代码，比如：一个人用int，一个人用long。最好用typedef来定义）
//    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
//    size_t dataOutMoved = 0;
//
//    dataOutAvailable = (dataInLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
//    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
//    memset((void *)dataOut, 0x0, dataOutAvailable);//将已开辟内存空间buffer的首 1 个字节的值设为值 0
//
//    //CCCrypt函数 解密
//    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,//  解密
//                                       kCCAlgorithmDES,//  解密根据哪个标准（des，3des，aes。。。。）
//                                       kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
//                                       [key UTF8String],  //密钥    加密和解密的密钥必须一致
//                                       kCCKeySizeDES,//   DES 密钥的大小（kCCKeySizeDES=8）
//                                       iv, //  可选的初始矢量
//                                       dataIn, // 数据的存储单元
//                                       dataInLength,// 数据的大小
//                                       (void *)dataOut,// 用于返回数据
//                                       dataOutAvailable,
//                                       &dataOutMoved);
//    if(ccStatus == kCCSuccess) {
//        NSData *plaindata = [NSData dataWithBytes:(void *)dataOut length:(NSUInteger)dataOutMoved];
//        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
//    }
//    return plaintext;
//}
//报文DES解密
+ (NSString *) decryptUseDESForData:(NSString *)cipherText needLogin:(BOOL)needLogin{

    NSString *keyStr = DATA_ENCRYPT_KEY;
    NSString *privateKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"privateKey"];
    if (privateKey.length > 0 && needLogin) {
        keyStr = privateKey;
    }
    NSString *plaintext = nil;
    NSData *cipherdata = [GTMBase64 decodeData:[cipherText dataUsingEncoding:NSUTF8StringEncoding]];
    unsigned char buffer[1024 * 600];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
//    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
//    dataOutAvailable = ([cipherdata length] + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    const void *iv = (const void *)[keyStr UTF8String];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [keyStr UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          [cipherdata bytes],
                                          [cipherdata length],
                                          buffer,
                                          1024 * 600,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess){
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
    }
    return plaintext == nil ? @"":plaintext;
}

+ (NSString *) decryptUseDESForDataWithKey:(NSString *)cipherText{
    NSString *keyStr = DATA_ENCRYPT_KEY;
    NSString *plaintext = nil;
    NSData *cipherdata = [GTMBase64 decodeData:[cipherText dataUsingEncoding:NSUTF8StringEncoding]];
    unsigned char buffer[1024 * 4];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    //    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    //    dataOutAvailable = ([cipherdata length] + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    const void *iv = (const void *)[keyStr UTF8String];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          [keyStr UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          [cipherdata bytes],
                                          [cipherdata length],
                                          buffer,
                                          1024 * 4,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess){
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
    }
    return plaintext;
}

//加密时 转成16进制
+(NSString *) parseByte2HexString:(Byte *) bytes  :(int)len{
    
    
    NSString *hexStr = @"";
    
    if(bytes)
    {
        for(int i=0;i<len;i++)
        {
            NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff]; ///16进制数
            if([newHexStr length]==1)
                hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
            else
            {
                hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
            }
            
//            DEBUG_Log(@"%@",hexStr);
        }
    }
    
    return hexStr;
}

//解密时转回data
+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
//    DEBUG_Log(@"hexdata: %@", hexData);
    return hexData;
}

#pragma mark - 将参数排序，得到用来签名的字符串（发送验证码接口使用公钥签名）
+(NSString*)getStringForSign:(NSDictionary*)paramDict needLogin:(BOOL)needLogin{
    NSMutableArray *signArray = [[NSMutableArray alloc]init];
    for (NSString *keyStr in [paramDict allKeys]) {
        NSString *tempStr = [NSString stringWithFormat:@"%@=%@",keyStr,[paramDict objectForKey:keyStr]];
        [signArray addObject:tempStr];
    }
    NSArray *newArrary = [signArray sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *sortString = [[NSMutableString alloc] init];
    for (int i = 0; i < newArrary.count; i ++) {
        [sortString appendString:newArrary[i]];
        [sortString appendString:@"&"];
    }
    
    NSString *keyStr = KEY;
    NSString *privateKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"privateKey"];
    
    if (privateKey.length > 0 && needLogin) {
        keyStr = privateKey;
    }
    [sortString appendString:[NSString stringWithFormat:@"key=%@",keyStr]];
    
    return sortString;
}


+(void)dddd{
    
    NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMCQwDQYJKoZIhvcNAQEBBQADEwAwEAIJALKJfSKyaZGBAgMBAAE=\n-----END PUBLIC KEY-----";
    NSString *privkey = @"-----BEGIN PRIVATE KEY-----\nMFMCAQAwDQYJKoZIhvcNAQEBBQAEPzA9AgEAAgkAsol9IrJpkYECAwEAAQIIIUqS6yAlx5sCBQDYuVPzAgUA0uSFuwIEckGqfwIEPflP3wIEQiYWRA==\n-----END PRIVATE KEY-----";

    NSString *originString = @"hello world!";
    for(int i=0; i<4; i++){
        originString = [originString stringByAppendingFormat:@" %@", originString];
    }
    NSString *encWithPubKey;
    NSString *decWithPrivKey;
    NSString *encWithPrivKey;
    NSString *decWithPublicKey;
    
    NSLog(@"Original string(%d): %@", (int)originString.length, originString);
    
    // Demo: encrypt with public key
    encWithPubKey = [RSA encryptString:originString publicKey:pubkey];
    NSLog(@"Enctypted with public key: %@", encWithPubKey);
    // Demo: decrypt with private key
    decWithPrivKey = [RSA decryptString:encWithPubKey privateKey:privkey];
    NSLog(@"Decrypted with private key: %@", decWithPrivKey);
}


#pragma mark - 图片压缩
+(NSData*)compressImageToData:(UIImage*)img{
    CGFloat perTemp = 0.9;
//    CGFloat per = 1.0;
    int maxSize = 1024;//限制 1M
    
    CGSize imgSize = img.size;
    UIImage *imgTemp = img;
//    NSData *imgData = UIImagePNGRepresentation(imgTemp);
    NSData *imgData = UIImageJPEGRepresentation(imgTemp,1);
//    per = perTemp;
    NSInteger lengthg = [imgData length]/1024;
    NSLog(@"img大小 （前） %ld",(long)lengthg);
    if (lengthg > maxSize) {
        CGFloat compressPer = maxSize*0.01/lengthg*0.01;
        
        if (imgSize.width > 4000){
//            imgTemp = [[UIImage alloc]initWithData:imgData];
            imgTemp = [self compressImageToTargetWidth:3000 Image:imgTemp];
            imgData = UIImageJPEGRepresentation(imgTemp, compressPer);
        }else{
            imgData = UIImageJPEGRepresentation(imgTemp, compressPer);
        }
    }
    return imgData;
}

+(UIImage *)compressImageToTargetWidth:(CGFloat)targetWidth Image:(UIImage*)img{
    
    CGSize imageSize = img.size;
    
    CGFloat width = imageSize.width;
    
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    
    [img drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}


@end
