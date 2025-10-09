
#import "AVPDef.h"
#import <Foundation/Foundation.h>


@protocol AliMediaLoaderStatusDelegate <NSObject>
@optional

/**
 @brief 错误回调
 @param url 加载url
 @param code 错误码，-300表示同一个url已经加载过，-301表示地缓存未打开，预加载失败
 @param msg 错误描述
 */
/****
 @brief Error callback
 @param url  the load URL
 @param code Error code，-300 means the same url has been loaded, -301 means the cache is not open, preload failed
 @param msg Error description
*/
- (void)onError:(NSString *)url code:(int64_t)code msg:(NSString *)msg __attribute__((deprecated("This method is deprecated. Use `onErrorV2` instead.")));

/**
 @brief 错误回调V2
 @param url 加载url
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
/****
 @brief Error callback V2
 @param url  the load URL
 @param errorModel Player error description, refer to AliVcPlayerErrorModel
*/
- (void)onErrorV2:(NSString *)url errorModel:(AVPErrorModel *)errorModel;

/**
 @brief 完成回调
 @param url 加载url
 */
/****
 @brief Completed callback
 @param URL the load URL
*/
- (void)onCompleted:(NSString *)url;

/**
 @brief 取消回调
 @param url 加载url
 */
/****
 @brief  the Canceled  callback
 @param URL the load URL
*/
- (void)onCanceled:(NSString *)url;

@end


OBJC_EXPORT
@interface AliMediaLoader : NSObject

+ (instancetype)shareInstance;

/**
 @brief  开始加载文件。异步加载。可以同时加载多个。若是多码率HLS，默认加载最低档位，可以选择支持指定档位的预加载方法。
 @param url  视频文件地址
 @param duration 加载的时长大小.单位：毫秒
 */
/****
 @brief Start load. Asynchronous loading. You can load more than one at a time. If preload multi-bitrate HLS stream, lowest stream is default, you can use another preload function which support specify bandwidth.
 @param url Video file url
 @param duration Load duration. Unit: millisecond
*/
- (void)load:(NSString *)url duration:(int64_t)duration;

/**
 @brief  开始加载文件。异步加载。可以同时加载多个。
 @param url  视频文件地址
 @param duration 加载的时长大小.单位：毫秒
 @param defaultBandWidth 加载多码率HLS时默认的码率，将会选择与之最接近的档位，单位:bps
 */
/****
 @brief Start load. Asynchronous loading. You can load more than one at a time.
 @param url Video file url
 @param duration Load duration. Unit: millisecond
 @param defaultBandWidth Load default bitrate for multi-bitrate HLS stream，the nearest stream will be selected. Unit:bps
*/
- (void)load:(NSString *)url duration:(int64_t)duration defaultBandWidth:(int)defaultBandWidth;


/**
 @brief  开始加载文件。异步加载。可以同时加载多个。
 @param url  视频文件地址
 @param duration 加载的时长大小.单位：毫秒
 @param defaultBandWidth 加载多码率HLS时默认的清晰度对应的宽和高的乘积，将会选择与之最接近的清晰度
 *                          例如当传入值为1920 * 1080 = 2073600，那么会预加载宽高分别为1920和1080这一档位
 */
/****
 @brief Start load. Asynchronous loading. You can load more than one at a time.
 @param url Video file url
 @param duration Load duration. Unit: millisecond
 @param Load default resolution corresponding to the product of width and height when loading multi-bitrate HLS streams.
 *                          The resolution closest to this value will be selected.
 *                          For example, if the value 1920 * 1080 = 2073600 is provided, the resolution closest to the width of 1920 and height of 1080 will be preloaded.
*/
- (void)load:(NSString *)url duration:(int64_t)duration defaultResolutionProduct:(int64_t)defaultResolutionProduct;
/**
  @brief 取消加载。注意：不会删除已经下载的文件。
  @param url 视频文件地址 。为nil或者空，则取消全部。
 */
/****
 @brief Cancel load. Note: Downloaded files will not be deleted.
 @param url Video file url. Nil or null, cancel all.
*/
- (void)cancel:(NSString *)url;

/**
 @brief 暂停加载。
  @param url 视频文件地址。 为nil或者空，则暂停全部。
 */
/****
 @brief pause load.
 @param url Video file url. Nil or null, pause all.
*/
- (void)pause:(NSString *)url;

/**
 @brief 恢复加载。
 @param url 视频文件地址。 为nil或者空，则恢复全部。
 */
/****
 @brief Resume load.
 @param url Video file url. Nil or null, resume all.
*/
- (void)resume:(NSString *)url;

/**
 @brief 设置状态代理，参考AliMediaLoaderStatusDelegate
 @see AliMediaLoaderStatusDelegate
 */
/****
 @brief, set the status Delegate
 @see AliMediaLoaderStatusDelegate
*/
- (void)setAliMediaLoaderStatusDelegate:(id<AliMediaLoaderStatusDelegate>)delegate;
@end
