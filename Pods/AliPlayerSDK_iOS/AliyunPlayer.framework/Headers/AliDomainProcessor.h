#import "AVPDef.h"
#import <Foundation/Foundation.h>


OBJC_EXPORT
@interface AliDomainProcessor : NSObject

+ (instancetype)shareInstance;

/**
 * 开始httpdns预解析。
 *
 * @param domain  视频url对应的域名，如，url:https://cn.aliyun.com，对应的域名:cn.aliyun.com
 */
/****
 * Start httpdns pre resolve.
 *
 * @param domain domain of video url. for example, url:https://cn.aliyun.com, correspond domain:cn.aliyun.com
 */
- (void)addPreResolveDomain:(NSString *)domain;


/**
 * 添加增强型httpdns域名。
 * 和如下接口 配合使用
 * @see [AliPlayerGloabalSetting enableEnhancedHttpDns:NSString]
 * @param domain  视频url对应的域名，如，url:https://cn.aliyun.com，对应的域名:cn.aliyun.com
 */
/****
 * add enhanced httpdns domain.
 * Used in conjunction with the interface as follow
 * @see [AliPlayerGloabalSetting enableEnhancedHttpDns:NSString]
 * @param domain domain of video url. for example, url:https://cn.aliyun.com, correspond domain:cn.aliyun.com
 */
- (void)addEnhancedHttpDnsDomain:(NSString *)domain DEPRECATED_MSG_ATTRIBUTE("don't need use this API, we use httpdns to resolve domain default if domain belong to ali cdn");

@end
