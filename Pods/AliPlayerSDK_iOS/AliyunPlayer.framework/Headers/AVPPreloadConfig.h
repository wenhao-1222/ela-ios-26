//
// Created by yiliang on 2023/6/20.
//

#ifndef AVPPRELOADCONFIG_H
#define AVPPRELOADCONFIG_H
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AVPPreloadOptionType) {
    AVPPreloadOptionTypeNone = 0,
    AVPPreloadOptionTypeResolution,
    AVPPreloadOptionTypeBandWidth,
    AVPPreloadOptionTypeQuality
};

OBJC_EXPORT
@interface AVPPreloadConfig : NSObject

@property (nonatomic, assign) int preloadDuration;

@property (nonatomic, assign) AVPPreloadOptionType preloadOptionType;
@property (nonatomic, assign) int optionIntValue;
@property (nonatomic, strong) NSString *optionStringValue;

- (instancetype)init;
/**
 * 使用指定时长构造预加载配置
 * Construct preload configuration with specified duration
 *
 * @param duration 预加载时长，单位毫秒
 *               Preload duration, unit in milliseconds
 */
- (instancetype)initWithDuration:(int)duration;

/**
 * 获取预加载时长
 * Get preload duration
 *
 * @return 预加载时长，单位毫秒
 *         Preload duration, unit in milliseconds
 */
- (int)getDuration;

/**
 * 设置预加载时长
 * Set preload duration
 *
 * @param duration 预加载时长，单位毫秒
 *               Preload duration, unit in milliseconds
 */
- (void)setDuration:(int)duration;

/**
 * 多码率流下设置预加载分辨率
 * Set the preload resolution for multi-bitrate stream
 *
 * @param resolutionProduct 分辨率乘积
 *                        Resolution product
 */
- (void)setDefaultResolution:(int)resolution;

/**
 * 获取预加载分辨率
 * Get preload resolution
 *
 * @return 分辨率乘积
 *         Resolution product
 */
- (int)getDefaultResolution;

/**
 * 多码率流下设置预加载码率
 * Set the preload bitrate for multi-bitrate stream
 *
 * @param bandWidth 码率
 *                Bitrate
 */
- (void)setDefaultBandWidth:(int)bandWidth;

/**
 * 获取预加载码率
 * Get preload bitrate
 *
 * @return 码率
 *         Bitrate
 */
- (int)getDefaultBandWidth;

/**
 * 多码率流下设置预加载质量
 * Set the preload quality for multi-bitrate stream
 *
 * @param quality 质量
 *              Quality
 */
- (void)setDefaultQuality:(NSString *)quality;

/**
 * 获取预加载质量
 * Get preload quality
 *
 * @return 质量
 *         Quality
 */
- (NSString *)getDefaultQuality;

/**
 * 获取默认预加载选项类型
 * Get default preload option type
 *
 * @return 预加载选项类型
 *         Preload option type
 */
- (AVPPreloadOptionType)getDefaultType;

@end

#endif //SOURCE_AVPPRELOADCONFIG_H
