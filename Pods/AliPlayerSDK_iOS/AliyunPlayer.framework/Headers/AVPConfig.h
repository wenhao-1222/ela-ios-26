//
//  AVPConfig.h
//  AliPlayerSDK
//
//  Created by shiping.csp on 2018/11/16.
//  Copyright © 2018 com.alibaba.AliyunPlayer. All rights reserved.
//

#ifndef AVPConfig_h
#define AVPConfig_h

#import <Foundation/Foundation.h>

OBJC_EXPORT
@interface AVPConfig : NSObject

/**
 @brief 直播最大延迟 默认5000毫秒，单位毫秒
 */
/****
 @brief The maximum broadcasting delay. Default: 5000 milliseconds, Unit: millisecond.
 */
@property (nonatomic, assign) int maxDelayTime;

/**
 @brief 卡顿后缓存数据的高水位，当播放器缓存数据大于此值时开始播放，单位毫秒
 */
/****
 @brief The size of data to be cached before the player can be resumed from playback lag. When the size of the data cached by the player reaches this value, the playback is resumed, Unit: millisecond.
 */
@property (nonatomic, assign) int highBufferDuration;

/**
 @brief 开始起播缓存区数据长度，默认500ms，单位毫秒
 */
/****
 @brief The size of the cache data required for starting playback. Default: 500 milliseconds, Unit: millisecond.
 */
@property (nonatomic, assign) int startBufferDuration;

/**
 @brief 播放器最大的缓存数据长度，默认50秒，单位毫秒
 */
/****
 @brief The maximum size of cache data. Default: 50 seconds, Unit: millisecond.
 */
@property (nonatomic, assign) int maxBufferDuration;

/**
 @brief 网络超时时间，默认15秒，单位毫秒
 */
/****
 @brief Network connection timeout time. Default: 15 seconds, Unit: millisecond.
 */
@property (nonatomic, assign) int networkTimeout;

/**
 @brief 网络重试次数，每次间隔networkTimeout，networkRetryCount=0则表示不重试，重试策略app决定，默认值为2
 */
/****
 @brief The maximum network reconnection attempts. Default: 2. networkTimeout specifies the reconnection interval. networkRetryCount=0 indicates that automatic network reconnection is disabled. The reconnection policy varies depending on the app.
 */
@property (nonatomic, assign) int networkRetryCount;

/**
 @brief probe数据大小，默认-1,表示不设置
 */
/****
 @brief The size of the probe data. Default: -1. Value -1 indicates that the probe data size is not specified. */
@property (nonatomic, assign) int maxProbeSize;

/**
 @brief 请求referer
 */
/****
 @brief Request Referer.
 */
@property (nonatomic, copy) NSString *referer;

/**
 @brief user Agent
 */
/****
 @brief UserAgent.
 */
@property (nonatomic, copy) NSString *userAgent;

/**
 @brief httpProxy代理
 */
/****
 @brief HTTP proxy.
 */
@property (nonatomic, copy) NSString *httpProxy;

/**
 @brief 调用stop停止后是否显示最后一帧图像，YES代表清除显示，黑屏，默认为NO
 */
/****
 @brief Whether to clear the last frame when the player is stopped. Set to YES to clear the last frame and a black view is displayed. Default: NO.
 */
@property (nonatomic, assign) BOOL clearShowWhenStop;

/**
 @brief 添加自定义header
 */
/****
 @brief Add a custom header.
 */
@property (nonatomic, strong) NSMutableArray *httpHeaders;

/**
 @brief 是否启用SEI
 */
/****
 @brief Enable or disable SEI.
 */
@property (nonatomic, assign) BOOL enableSEI;

/**
 @brief 当通过GlobalSettings API打开本地缓存功能后，此处可设置当前播放器实例是否允许被缓存，默认允许。
 */
/****
 @brief When local cached is enabled in GlobalSettings API, this config can be used to enable or disable local cache in current player instance, by default is ON.
 */
@property(nonatomic, assign) BOOL enableLocalCache;

/* set the video format for renderFrame callback
 * vtb decoder only, equal to OSType, not be supported by other decoder
  * support 420v 420f y420 BGRA
* */
@property (nonatomic, assign) int pixelBufferOutputFormat;
/**
 @brief  HLS直播时，起播分片位置。
 */
/****
 @brief  The start playing index of fragments, when HLS is live.
 */
@property(nonatomic, assign) int liveStartIndex;
/**
 @brief 禁用Audio.
 */
/****
 @brief Disable audio track.
 */
@property (nonatomic, assign) BOOL disableAudio;

/**
 @brief 禁用Video
 */
/****
 @brief Disable video track.
 */
@property (nonatomic, assign) BOOL disableVideo;

/**
@brief  进度跟新的频率。包括当前位置和缓冲位置。
 */
/****
@brief Set the frequencies of Progress. Includes the current position and the buffer position.
 */
@property(nonatomic, assign) int positionTimerIntervalMs;

/**
 @brief 设置播放器后向buffer的最大值.
 */
/****
 @brief set the maximum backward buffer duration of the player.
 */
@property(nonatomic, assign) uint64_t mMAXBackwardDuration;


/**
 @brief 优先保证音频播放；在网络带宽不足的情况下，优先保障音频的播放，目前只在dash直播流中有效（视频已经切换到了最低码率）
 */
/****
 @brief prefer audio playback; prefer audio playback when under insufficient network bandwidth. At present, it is only effective in dash live stream (the video has been switched to the lowest bit rate)
 */
@property (nonatomic, assign) BOOL preferAudio;

/**
 @brief 播放器实例是否可以使用http dns进行解析，-1 表示跟随全局设置，0 disable
 */
/****
 @brief whether enable http dns, -1 : as globel setting
 */
@property(nonatomic, assign) int enableHttpDns;

/**
 @brief 播放器实例是否可以使用增强型http dns进行解析，-1 表示跟随全局设置，0 disable
 */
/****
 @brief whether enable enhanced http dns, -1 : as globel setting
 */
@property(nonatomic, assign) int enableEnhancedHttpDns;

/**
 @brief 使用http3进行请求，支持标准：RFC 9114（HTTP3）和RFC 9000（QUIC v1），默认值关。如果http3请求失败，自动降级至普通http，默认关闭
 */
/****
 @brief Use http3 to request, supported standards:RFC 9114(HTTP3) and RFC 9000(QUIC v1), false by default. If request failed, it will automatically downgrade to normal http.
 */
@property(nonatomic, assign) BOOL enableHttp3;

/**
 @brief 用于纯音频或纯视频的RTMP/FLV直播流起播优化策略，当流的header声明只有音频或只有视频时，且实际流的内容跟header声明一致时，此选项打开可以达到快速起播的效果。默认关闭
 */
/****
 @brief  Used to fast stream start when playing pure audio or pure video in RTMP/FLV live stream. If live stream header states only audio or only video and the stream content really contains the same single stream, enable this option can fast start the stream. Default value is false.
 */
@property(nonatomic, assign) BOOL enableStrictFlvHeader;

/**
 @brief 针对打开了点播URL鉴权的媒体资源（HLS协议），开启本地缓存后，可选择不同的鉴权模式：非严格鉴权(false)：鉴权也缓存，若上一次只缓存了部分媒体，下次播放至非缓存部分时，播放器会用缓存的鉴权发起请求，如果URL鉴权设置的有效很短的话，会导致播放异常。严格鉴权(true)：鉴权不缓存，每次起播都进行鉴权，无网络下会导致起播失败。默认值：true (5.5.4.0至6.21.0版本默认值为false，7.0.0及以上版本默认值为true)。
 */
/****
 @brief  For media that enabled URL authorization(HLS protocol), when local cache is enabled, we can choose different auth mode:Non Strict Mode(false): Auth is cached. If last play cached part of the media, and next play to non-cache part, player will use old auth to request, which may fail if the auth timeout configuration in the server is very short. Strict Mode(true): Auth is not cached. Every play will do the auth verification, so when there is no network, media cannot be played. Default is true. (5.5.4.0~6.21.0 default is false, 7.0.0+ default is true)
 */
@property(nonatomic, assign) BOOL enableStrictAuthMode;

/**
 * 允许当前播放器实例进行投屏
 * 你需要集成投屏SDK来完成投屏功能
 * 默认值关
 */
/****
 * Enable projection for current player
 * You need to integrate projection SDK to do this
 * Default is false.
 */
@property(nonatomic, assign) BOOL enableProjection;

/**
 @brief 音频打断模式（如接电话期间），0 表示打断期间暂停播放，打断结束恢复播放；1 表示打断期间依然持续播放。默认值0
 */
/****
 @brief Audio interrupt mode (such as phone call), 0 means pause play during interruption and resume play after interruption; 1 means continue play during interruption period.
 */
@property(nonatomic, assign) int audioInterruptMode;

/**
 @brief 视频渲染类型，0 表示默认渲染器；1 表示混合渲染器。默认值0
 */
/****
 @brief video renderType, 0 means default render; 1 means mixed render.
 */
@property(nonatomic, assign) int videoRenderType;

/**
 * 开始预加载阈值。单位ms
 */
/****
 * start preload limit. Unit: milliseconds.
 */
@property(nonatomic, assign) int startBufferLimit;

/**
 * 停止预加载阈值。单位ms
 */
/****
 * stop preload limit. Unit: milliseconds.
 */
@property(nonatomic, assign) int stopBufferLimit;

/**
  * 调用SelectTrack是否清除buffer，无论是高清晰度还是低清晰度， 0 不清除，1 清除
  */
/****
  * Whether to clear the buffer when calling SelectTrack, no matter it is high-definition or low-definition, 0 is not cleared, and 1 is cleared.
  */
@property(nonatomic, assign) int selectTrackBufferMode;


/**
  * 清晰度切换至AUTO档位时，允许升路的清晰度视频对应的最大像素数量。
  * 例如将值设置为1280 * 720 = 921600，那么最高升路到该对应清晰度，而不会升路到 1920 * 1080。
  * 不同清晰度对应值可以参考 AVPPixelNumber
  */
/****
  * When switching the resolution to AUTO mode, the maximum pixel count corresponding to the allowable resolution upgrade for the video.
  * for example, if the value is set to 1280 * 720 = 921600, then the highest resolution upgrade corresponds to this resolution, and it will not upgrade to 1920 * 1080."
  * Can refer to AVPPixelNumber 
  */
@property(nonatomic, assign) int maxAllowedAbrVideoPixelNumber;

@end

#endif /* AVPConfig_h */
