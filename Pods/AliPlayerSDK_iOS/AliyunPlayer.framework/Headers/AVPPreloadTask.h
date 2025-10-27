#ifndef PreloadTask_h
#define PreloadTask_h

#import <Foundation/Foundation.h>
#import "AVPDef.h"
#import "AVPSource.h"

@class AVPSource;
@class AVPUrlSource;
@class AVPVidAuthSource;
@class AVPVidStsSource;
@class AVPPreloadConfig;

/**
 * 预加载任务类
 * Preload task class
 */
@interface AVPPreloadTask : NSObject

@property (nonatomic, strong) AVPSource *source;

/**
 * 预加载配置
 * Preload configuration
 */
@property (nonatomic, strong) AVPPreloadConfig *preloadConfig;

/**
 * 使用 VidAuth 类型数据源构造预加载任务
 * Use VidAuth type data source to construct a preload task
 */
- (instancetype)initWithVidAuthSource:(AVPVidAuthSource *)source
                        preloadConfig:(AVPPreloadConfig *)preloadConfig;

/**
 * 使用 VidSts 类型数据源构造预加载任务
 * Use VidSts type data source to construct a preload task
 */
- (instancetype)initWithVidStsSource:(AVPVidStsSource *)source
                       preloadConfig:(AVPPreloadConfig *)preloadConfig;

/**
 * 使用 UrlSource 类型数据源构造预加载任务
 * Use UrlSource type data source to construct a preload task
 */
- (instancetype)initWithUrlSource:(AVPUrlSource *)source
                    preloadConfig:(AVPPreloadConfig *)preloadConfig;

@end


#endif /* PreloadTask_h */
