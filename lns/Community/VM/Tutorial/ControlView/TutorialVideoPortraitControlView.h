//
//  TutorialVideoPortraitControlView.h
//  lns
//
//  Created by Elavatine on 2024/12/24.
//

#import <UIKit/UIKit.h>
#import "ZFSliderView.h"
#if __has_include(<ZFPlayer/ZFPlayerController.h>)
#import <ZFPlayer/ZFPlayerController.h>
#else
#import "ZFPlayerController.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TutorialVideoPortraitControlView : UIView

/// 返回按钮
@property (nonatomic, strong, readonly) UIButton *backBtn;
/// 底部工具栏
@property (nonatomic, strong, readonly) UIView *bottomToolView;

/// 顶部工具栏
@property (nonatomic, strong, readonly) UIView *topToolView;

/// 标题
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/// 播放或暂停按钮
@property (nonatomic, strong, readonly) UIButton *playOrPauseBtn;

/// 播放的当前时间
@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;

/// 滑杆
@property (nonatomic, strong, readonly) ZFSliderView *slider;

/// 视频总时间
@property (nonatomic, strong, readonly) UILabel *totalTimeLabel;

/// 全屏按钮
@property (nonatomic, strong, readonly) UIButton *fullScreenBtn;
//
@property (nonatomic, assign) BOOL isCalSafeArea;
///下一个视频按钮
@property (nonatomic, strong) UIButton *nextBtn;
///播放倍速按钮
@property (nonatomic, strong) UIButton *rateBtn;
//后退10秒
@property (nonatomic,strong) UIButton *tenSecondBakcBtn;
//前进10秒
@property (nonatomic,strong) UIButton *tenSecondForwardBtn;
//分享按钮
@property (nonatomic,strong) UIButton *shareVideoBtn;

/// 播放器
@property (nonatomic, weak) ZFPlayerController *player;

/// 返回按钮点击回调
@property (nonatomic, copy) void(^backBtnClickCallback)(void);
/// 分享
@property (nonatomic, copy) void(^shareBtnClickCallback)(void);
/// slider滑动中
@property (nonatomic, copy, nullable) void(^sliderValueChanging)(CGFloat value,BOOL forward);

/// slider滑动结束
@property (nonatomic, copy, nullable) void(^sliderValueChanged)(CGFloat value);
/// 设置倍速
@property (nonatomic, copy, nullable) void(^rateTapBlock)(void);
///重新播放
@property (nonatomic, copy, nullable) void(^rePlayBlock)(void);
///下一个视频
@property (nonatomic, copy, nullable) void(^nextVideoTapBlock)(void);
///后退10秒
@property (nonatomic, copy, nullable) void(^tenSecondBackTapBlock)(void);
///前进10秒
@property (nonatomic, copy, nullable) void(^tenSecondForwardTapBlock)(void);
//拖动进度条
@property (nonatomic, copy, nullable) void(^sliderChangedTapBlock)(void);
//手动暂停
@property (nonatomic, copy, nullable) void(^pauseManualTapBlock)(BOOL);
/// 如果是暂停状态，seek完是否播放，默认YES
@property (nonatomic, assign) BOOL seekToPlay;

/// 重置控制层
- (void)resetControlView;

/// 显示控制层
- (void)showControlView;

/// 隐藏控制层
- (void)hideControlView;

/// 设置播放时间
- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

/// 设置缓冲时间
- (void)videoPlayer:(ZFPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime;

/// 是否响应该手势
- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPlayerGestureType)type touch:(nonnull UITouch *)touch;

/// 标题和全屏模式
- (void)showTitle:(NSString *_Nullable)title fullScreenMode:(ZFFullScreenMode)fullScreenMode;

/// 根据当前播放状态取反
- (void)playOrPause;

/// 播放按钮状态
- (void)playBtnSelectedState:(BOOL)selected;

/// 调节播放进度slider和当前时间更新
- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString;

/// 滑杆结束滑动
- (void)sliderChangeEnded;
//课程详情封面   只保留播放按钮
-(void)updateUIForCourseCover;

@end

NS_ASSUME_NONNULL_END
