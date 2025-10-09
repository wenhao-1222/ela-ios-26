//
//  AliVRPlayer.h
//  AliyunPlayer
//
//  Created by tony on 2022/5/31.
//

#import "AliPlayer.h"
#import "AliVRPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AliVRPlayerViewDisplayMode)
{
    AliVRPlayerViewDisplayMode360,
    AliVRPlayerViewDisplayModeGlass
};

typedef NS_OPTIONS(NSUInteger, AliVRPlayerInteractiveOptions)
{
    AliVRPlayerInteractiveOptionsPinch              = 1 << 0,     // Pinch手势，            默认关闭
    AliVRPlayerInteractiveOptionsHorizontal         = 1 << 1,     // 水平方向的滑动，         默认关闭
    AliVRPlayerInteractiveOptionsVerticalEnabled    = 1 << 2,     // 竖直方向的滑动，         默认关闭
    AliVRPlayerInteractiveOptionsDeviceMotion       = 1 << 3,     // 通过手机陀螺仪进行体验，   默认开启
    AliVRPlayerInteractiveOptionsCustomGesture      = 1 << 4,
};

typedef NS_ENUM(NSInteger, AliVRPlayerViewOrientation) {
    AliVRPlayerViewOrientationPortrait,
    AliVRPlayerViewOrientationUpsideDown,
    AliVRPlayerViewOrientationLandscapeLeft,
    AliVRPlayerViewOrientationLandscapeRight,
};

typedef NS_ENUM(NSInteger, AliVRPlayerType) {
    AliVRPlayerTypeSCN,
    AliVRPlayerTypeOpenGL,
};

OBJC_EXPORT
@interface AliVRPlayer : AliPlayer

/**
 @brief 初始化播放器
 */
/**
 @brief Initialize the player.
 */
- (instancetype)init;

/**
 @brief 初始化播放器
 @param traceID 便于跟踪日志，设为"DisableAnalytics"可关闭日志分析系统（不推荐）。
 */
/**
 @brief Initialize the player.
 @param traceID A trace ID for debugging. Set as "DisableAnalytics" to disable report analytics data to server(not recommended).
 */
- (instancetype)init:(NSString*)traceID;

/**
 @brief 设置VR播放器的交互类型为开启或者关闭
 @param option AliVRPlayerInteractiveOptionsPinch、AliVRPlayerInteractiveOptionsVerticalEnabled、AliVRPlayerInteractiveOptionsHorizontal、AliVRPlayerInteractiveOptionsDeviceMotion
 @param enable YES or NO (默认是AliVRPlayerInteractiveOptionsDeviceMotion开启状态，其他的为关闭状态)
 */
/**
 @brief Set VRPlayer Interactive mode
 @param option AliVRPlayerInteractiveOptionsPinch、AliVRPlayerInteractiveOptionsVerticalEnabled、AliVRPlayerInteractiveOptionsHorizontal、AliVRPlayerInteractiveOptionsDeviceMotion
 @param enable YES or NO (Default is AliVRPlayerInteractiveOptionsDeviceMotion YES，others is NO )
 */
- (void)setInteractionOptions:(AliVRPlayerInteractiveOptions)option enabled:(BOOL)enable;

/**
 @brief 设置VR播放器的展示方式
 @param displayMode  AliVRPlayerViewDisplayMode360 or AliVRPlayerViewDisplayModeGlass，默认值为  AliVRPlayerViewDisplayMode360
 */
/**
 @brief Set VRPlayer display mode (AliVRPlayerViewDisplayMode360 or AliVRPlayerViewDisplayModeGlass)
 @param displayMode  AliVRPlayerViewDisplayMode360 or AliVRPlayerViewDisplayModeGlass (Default value is AliVRPlayerViewDisplayMode360)
 */
- (void)setDisplayMode:(AliVRPlayerViewDisplayMode)displayMode;

/**
 @brief 设置VR播放器的放大倍数
 @param scale
 */
/**
 @brief Set VRPlayer view  scale
 @param scale
 */
- (void)setVRSceneScale:(CGFloat)scale;

/**
 @brief 设置VR播放器场景的旋转
 @param rotate 旋转的弧度数
 */
/**
 @brief Set VRPlayer scene  rotate
 @param rotate radians of rotate
 */
- (void)setVRSceneRotate:(CGFloat)rotate;

/**
 @brief 设置VR播放器旋转的角度
 @param x x轴旋转的角度
 @param y y轴旋转的角度
 */
/**
 @brief Set VRPlayer rotate radians with axis
 @param x radians of rotate on x axis
 @param y radians of rotate on y axis
 */
- (void)rotateVRSceneWithX:(CGFloat)x andY:(CGFloat)y;

/**
 @brief 通过手势控制vr播放器的角度
 @param paramSender 滑动手势
 */
/**
 @brief Set VRPlayer rotate radians with axis
 @param paramSender  Pan Gesture
 */
- (void)handlePanGesture:(UIPanGestureRecognizer *)paramSender;

/**
 @brief 设置播放器显示全景图
 @param image 要展示的全景图
 */
/**
 @brief Set VRPlayer display with 360 image
 @param image  360 image
 */
- (void)setVRDisplayContentsWithImage:(UIImage *)image;

/**
 @brief 设置播放器VR处理器类型
 @param vrType VR处理器的类型
 */
/**
 @brief set VR processor type
 @param vrType VR processor type
 */
- (void)setVRPlayerType:(AliVRPlayerType)vrType;

/**
 @brief 设置播放器VR代理，用来接收 回调信息或进行代理操作
 @param delegate VR代理
 */
/**
 @brief set VR delegate, to receive callback information or delegate operation
 @param delegate VR delegate
 */
- (void)setVRDelegate:(id<AliVRPlayerDelegate>)delegate;

/**
 @brief 重设播放器VR的手势角度
 */
/**
 @brief reset VR gesture angle
 */
- (void)resetGestureAngle;

/**
 @brief 设置播放器VR视频背景色
 @param color 背景颜色
 */
/**
 @brief set VR video background color
 @param color background color
 */
- (void)setVideoBackgroundColor:(UIColor *)color;


/**
 @brief 设置缩放
 @param degrees 缩放程度
 */
/**
 @brief set scale
 @param degrees
 */
- (void)setFovDegrees:(CGFloat)degrees;

@end

NS_ASSUME_NONNULL_END
