//
//  AliPlayerPictureInPictureDelegate.h
//  AliyunPlayer
//
//  Created by alibaba on 2022/7/4.
//  Copyright © 2022 com.alibaba.AliyunPlayer. All rights reserved.

#ifndef AliPlayerPictureInPictureDelegate_h
#define AliPlayerPictureInPictureDelegate_h

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

@protocol AliPlayerPictureInPictureDelegate <NSObject>

@optional

/**
 @brief 画中画将要启动
 @param pictureInPictureController 画中画控制器
 */
/****
 @brief picture in picture will start
 @param pictureInPictureController picture in picture controller
 */
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController * _Nullable)pictureInPictureController;

/**
 * @brief 画中画已经启动
 * @param pictureInPictureController 画中画控制器
 */
/****
 @brief picture in picture start already
 @param pictureInPictureController picture in picture controller
 */
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController * _Nullable)pictureInPictureController;

/**
 @brief 画中画准备停止
 @param pictureInPictureController 画中画控制器
 */
/****
 @brief picture in picture will stop
 @param pictureInPictureController picture in picture controller
 */
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController * _Nullable)pictureInPictureController;

/**
 @brief 画中画已经停止
 @param pictureInPictureController 画中画控制器
 */
/****
 @brief picture in picture stop already
 @param pictureInPictureController picture in picture controller
 */
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController * _Nullable)pictureInPictureController;

/**
 @brief 画中画打开失败
 @param pictureInPictureController 画中画控制器
 */
/****
 @brief picture in picture start failed
 @param pictureInPictureController picture in picture controller
 @param error error type
 */
- (void)pictureInPictureController:(AVPictureInPictureController * _Nullable)pictureInPictureController failedToStartPictureInPictureWithError:(NSError * _Nullable)error;

/**
 @brief 在画中画停止前告诉代理恢复用户接口
 @param pictureInPictureController 画中画控制器
 @param completionHandler 调用并传值YES以允许系统结束恢复播放器用户接口
 */
/****
 @brief Tells the delegate to restore the user interface before Picture in Picture stops.
 @param pictureInPictureController picture in picture controller
 @param completionHandlerYou must call the completion handler with a value of YES to allow the system to finish restoring your player user interface.
 */
- (void)pictureInPictureController:(AVPictureInPictureController * _Nullable)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^_Nullable)(BOOL restored))completionHandler;

/**
 @brief 画中画窗口尺寸变化
 @param pictureInPictureController 画中画控制器
 @param newRenderSize 新的窗口尺寸
 */
/****
 @brief picture in picture stop already
 @param pictureInPictureController picture in picture controller
 @param newRenderSize new render size
 */

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController didTransitionToRenderSize:(CMVideoDimensions)newRenderSize;

/**
 @brief 点击画中画暂停按钮
 @param pictureInPictureController 画中画控制器
 @param playing 是否正在播放
 */
/****
 @brief picture in picture stop already
 @param pictureInPictureController picture in picture controller
 @param playing is playing or not
 */
- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing;

/**
 @brief 点击快进或快退按钮
 @param pictureInPictureController 画中画控制器
 @param skipInterval 快进快退的事件间隔
 @param completionHandler 一定要调用的闭包，表示跳转操作完成
 */
/****
 @brief Informs delegate that the user has requested skipping forward or backward by the time indicated by the interval.
 @param pictureInPictureController picture in picture controller
 @param skipInterval The interval by which to skip playback.
 @param completionHandler A closure that must be invoked to indicate that the skip operation has completed.
 */
- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController skipByInterval:(CMTime)skipInterval completionHandler:(nonnull void (^)(void))completionHandler;

/**
 @brief 将暂停/播放状态反映到UI上
 @param pictureInPictureController 画中画控制器
 @return 暂停/播放
 */
/****
 @brief Allows delegate to indicate whether the playback UI should reflect a playing or paused state
 @param pictureInPictureController picture in picture controller
 @return play/pause
 */
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController;

/**
 @brief 通知画中画控制起当前可播放的时间范围
 @param pictureInPictureController 画中画控制器
 @return 当前可播放的时间范围
 */
/****
 @brief Allows delegate to inform Picture in Picture controller of the current playable time range.
 @param pictureInPictureController picture in picture controller
 @return current playable time range
 */
- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController layerTime:(CMTime)layerTime;

/**
 @brief 画中画是否启动
 @param pictureInPictureController 画中画控制器
 @param isEnable 画中画是否启动
 */
/****
 @brief pictureInPicture is enable or not
 @param pictureInPictureController picture in picture controller
 @param isEnable is enable or not
 */
- (void)pictureInPictureControllerIsPictureInPictureEnable:(nullable AVPictureInPictureController *)pictureInPictureController isEnable:(BOOL)isEnable;

@end



#endif /* AliPlayerPictureInPictureDelegate_h */
