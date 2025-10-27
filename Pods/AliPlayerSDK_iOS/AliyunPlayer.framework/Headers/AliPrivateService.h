//
//  AliPrivateService.h
//  AliPrivateService
//
//  Created by shiping.csp on 2018/11/16.
//  Copyright © 2018 com.alibaba.AliyunPlayer. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXPORT
@interface AliPrivateService : NSObject

/**
 @brief 初始化下载秘钥信息
 @param datFile 秘钥文件的路径
 */
/****
 @brief Initialize the credential for downloading resources.
 @param datFile The path of the credential file.
 */
+ (void)initKey:(NSString*)datFile;

/**
 @brief 初始化下载秘钥信息
 @param data 秘钥文件的内容
 */
/****
 @brief Initialize the credential for downloading resources.
 @param data The data of the credential file.
 */
+ (void)initKeyWithData:(NSData*)data;

/**
 @brief  初始化证书服务
 @param key 用户拥有的licenseKey信息
 @param licensePath 本地证书路径
 @param storageDir  下载证书文件夹路径
 */
/****
 @brief Initialize the license service.
 @param key license key that user have
 @param licensePath local license file path
 @param storageDir  download license file folder path
 */
+ (void)initLicenseService;


/**
 * AVPPremiumBizType 枚举类型：定义高级功能类型。
 * @discussion 此枚举包含了不同的业务类型，用于识别高级功能模块。
 */
typedef enum AVPPremiumBizType: NSUInteger {
    BizType_UNKNOW = 0,
    MediaLoader = 1,
    PreRenderOption = 102,
    PremiumAbrStrategy = 103,
    H265Adaptive = 104,
    DashSupport = 105,
    EXTSubtitle = 108,
    H266Support = 109,
} AVPPremiumBizType;

/**
 * OnPremiumLicenseVerifyCallback 函数指针类型：高级功能验证回调。
 * @param type 高级功能类型
 * @param isValid 是否验证通过
 * @param errorMsg 错误信息（验证失败时返回）
 * @discussion 此回调用于验证指定的高级功能是否可用，并返回验证状态和错误信息。
 */
/****
 * OnPremiumLicenseVerifyCallback Function Pointer Type: Premium feature verification callback.
 * @param type Premium feature type.
 * @param isValid Whether the verification passed.
 * @param errorMsg Error message (returned when verification fails).
 * @discussion This callback verifies whether a specific premium feature is accessible and returns the status and error message.
 */
typedef void (*OnPremiumLicenseVerifyCallback)(AVPPremiumBizType type, bool isValid, NSString *errorMsg);


/**
 @brief  设置获取专业版License鉴权回调
 */
/****
 @brief Sets the callback to get the Premium license verification
 */
+ (void)setOnPremiumLicenseVerifyCallback:(OnPremiumLicenseVerifyCallback)callback;




@end

