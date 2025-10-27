#import <Foundation/Foundation.h>
#import "AVPDef.h"
@class AVPPreloadTask;

/**
 * 预加载任务状态回调协议，用于监听预加载任务的状态变化。
 */
/**
* Preload task status callback protocol for listening to preload task status changes.
*/
@protocol OnPreloadListener <NSObject>
@optional
/**
 * 预加载任务出错
 *
 * @param taskId     任务ID
 * @param urlOrVid   数据源URL或VID
 * @param errorModel 错误信息模型
 */
/**
* Called when a preload task encounters an error.
*
* @param taskId     Task ID
* @param urlOrVid   Data source URL or VID
* @param errorModel Error information model
*/
- (void)onError:(NSString *)taskId urlOrVid:(NSString *)urlOrVid errorModel:(AVPErrorModel *)errorModel;

/**
 * 预加载任务完成
 *
 * @param taskId   任务ID
 * @param urlOrVid 数据源URL或VID
 */
/**
 * Called when a preload task is completed.
 *
 * @param taskId   Task ID
 * @param urlOrVid Data source URL or VID
 */
- (void)onCompleted:(NSString *)taskId urlOrVid:(NSString *)urlOrVid;

/**
 * 预加载任务取消
 *
 * @param taskId   任务ID
 * @param urlOrVid 数据源URL或VID
 */
/**
* Called when a preload task is canceled.
*
* @param taskId   Task ID
* @param urlOrVid Data source URL or VID
*/
- (void)onCanceled:(NSString *)taskId urlOrVid:(NSString *)urlOrVid;
@end


@interface AliMediaLoaderV2 : NSObject

/**
 * 获取 AliMediaLoaderV2 的单例实例。
 *
 * @return AliMediaLoaderV2 单例对象
 */
/**
* Media preload manager interface, providing task submission, control, and status monitoring capabilities.
*/
+ (instancetype)shareInstance;

/**
 * 添加一个预加载任务，并指定该任务的状态回调监听器。
 *
 * @param preloadTask 预加载任务对象，包含数据源和加载时长等信息
 * @param listener    任务状态回调监听器，任务状态变更时会通过该监听器通知调用方
 * @return 分配的唯一任务ID（taskId），用于后续控制和查询
 */
/**
* Add a preload task and specify the listener for the task status.
*
* @param preloadTask Preload task object containing data source and loading duration information
* @param listener    Task status callback listener, which will notify the caller when the task status changes
* @return Assigned unique task ID (taskId) for subsequent control and query
*/
- (NSString *)addTask:(AVPPreloadTask *)preloadTask listener:(id<OnPreloadListener>)listener;

/**
 * 取消指定任务ID的加载。
 * 注意：不会删除已经下载的文件，仅取消未完成部分的加载。
 *
 * @param taskId 要取消加载的任务ID
 */
/**
* Cancel the loading of the specified task ID.
* Note: The downloaded file will not be deleted, only the loading of the unfinished part will be canceled.
*
* @param taskId ID of the task to be canceled
*/
- (void)cancelTask:(NSString *)taskId;

/**
 * 暂停指定任务ID的加载。
 *
 * @param taskId 要暂停的任务ID
 */
/**
* Pause the loading of the specified task ID.
*
* @param taskId ID of the task to be paused
*/
- (void)pauseTask:(NSString *)taskId;

/**
 * 继续（恢复）指定任务ID的加载。
 *
 * @param taskId 要恢复的任务ID
 */
/**
* Resume (recover) the loading of the specified task ID.
*
* @param taskId ID of the task to be resumed
*/
- (void)resumeTask:(NSString *)taskId;

@end

