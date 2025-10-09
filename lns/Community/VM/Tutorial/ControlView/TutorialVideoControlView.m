//
//  TutorialVideoControlView.m
//  lns
//
//  Created by Elavatine on 2024/12/24.
//

#import "TutorialVideoControlView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIView+ZFFrame.h"
#import "ZFSliderView.h"
#import "ZFUtilities.h"
#import "UIImageView+ZFCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZFVolumeBrightnessView.h"
#import "lns-Swift.h"
#if __has_include(<ZFPlayer/ZFPlayer.h>)
#import <ZFPlayer/ZFPlayer.h>
#else
#import "ZFPlayer.h"
#endif

@interface TutorialVideoControlView () <ZFSliderViewDelegate>
/// 竖屏控制层的View
@property (nonatomic, strong) TutorialVideoPortraitControlView *portraitControlView;
/// 横屏控制层的View
@property (nonatomic, strong) TutorialVideoLandScapeControlView *landScapeControlView;

@property (nonatomic, strong) ForumShareVM *landscapShareAlertVm;
/// 加载loading
@property (nonatomic, strong) ZFSpeedLoadingView *activity;
/// 快进快退View
@property (nonatomic, strong) UIView *fastView;
/// 快进快退进度progress
@property (nonatomic, strong) ZFSliderView *fastProgressView;
/// 快进快退时间
@property (nonatomic, strong) UILabel *fastTimeLabel;
/// 快进快退ImageView
@property (nonatomic, strong) UIImageView *fastImageView;
/// 加载失败按钮
@property (nonatomic, strong) UIButton *failBtn;
/// 底部播放进度
@property (nonatomic, strong) ZFSliderView *bottomPgrogress;
/// 封面图
@property (nonatomic, strong) UIImageView *coverImageView;
/// 是否显示了控制层
@property (nonatomic, assign, getter=isShowing) BOOL showing;
/// 是否播放结束
@property (nonatomic, assign, getter=isPlayEnd) BOOL playeEnd;

@property (nonatomic, assign) BOOL controlViewAppeared;

@property (nonatomic, assign) NSTimeInterval sumTime;

@property (nonatomic, strong) dispatch_block_t afterBlock;

@property (nonatomic, strong) ZFSmallFloatControlView *floatControlView;

@property (nonatomic, strong) ZFVolumeBrightnessView *volumeBrightnessView;

@property (nonatomic, strong) UIImageView *bgImgView;

@property (nonatomic, strong) UIView *effectView;

@property (nonatomic, strong) UILabel *doubleRateLabel;//长按两倍速播放提示

@end

@implementation TutorialVideoControlView
@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.oldRate = 1.0;
        [self addAllSubViews];
        self.landScapeControlView.hidden = YES;
        self.floatControlView.hidden = YES;
        self.seekToPlay = YES;
        self.effectViewShow = YES;
        self.controlViewAppeared = NO;
        self.horizontalPanShowControlView = YES;
//        self.autoFadeTimeInterval = 0.25;
        self.autoFadeTimeInterval = 0.5;
        self.tapFadeTimeInterval = 0.25;
        self.autoHiddenTimeInterval = 2.5;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLonePress:)];
        [self addGestureRecognizer:longPress];
        
    }
    return self;
}

//MARK: 长按2倍速播放
-(void)handleLonePress:(UIGestureRecognizer*)ges{
    if (self.player.currentPlayerManager == nil ||
        self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlayFailed ||
        self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlayStopped){
        self.doubleRateLabel.hidden = true;
        return;
    }
    [self hideControlViewWithAnimated:YES isSingleTap:YES];
    if (ges.state == UIGestureRecognizerStateBegan){
        self.oldRate = self.player.currentPlayerManager.rate;
        self.player.currentPlayerManager.rate = 2.0;
        self.doubleRateLabel.hidden = false;
    }else if (ges.state == UIGestureRecognizerStateChanged){
        self.player.currentPlayerManager.rate = 2.0;
        self.doubleRateLabel.hidden = false;
    }else{
        self.player.currentPlayerManager.rate = self.oldRate;
        self.doubleRateLabel.hidden = true;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.zf_width;
    CGFloat min_view_h = self.zf_height;
    UIEdgeInsets insets = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
    CGFloat topSafeAreaHeight = insets.top;
    CGFloat bottomSafeAreaHeight = insets.bottom;
    
    self.portraitControlView.frame = self.bounds;
    self.landScapeControlView.frame = self.bounds;
    self.floatControlView.frame = self.bounds;
    self.coverImageView.frame = self.bounds;
    self.bgImgView.frame = self.bounds;
    self.effectView.frame = self.bounds;
    
//    self.rateView.zf_centerY = min_view_h - 80;
    if (self.player.isFullScreen){
//        46 27 60 4          40
//        min_view_w - 137 - 20 - 30
//        if (bottomSafeAreaHeight > 0){
//            self.rateView.zf_centerX = min_view_w - 50 - bottomSafeAreaHeight - 44;
//        }else{
//            self.rateView.zf_centerX = min_view_w - 140;
//        }
        self.rateView.zf_centerX = min_view_w - 137 + 20;
//        self.rateView.zf_centerX = self.portraitControlView.rateBtn.zf_centerX;
        self.rateView.zf_centerY = min_view_h - 150 - bottomSafeAreaHeight;//min_view_h - 80;
    }else{
        self.rateView.zf_centerX = min_view_w - 70 - bottomSafeAreaHeight;
        self.rateView.zf_centerY = min_view_h - 110 - bottomSafeAreaHeight;//min_view_h - 80;
    }
    
    min_w = 80;
    min_h = 80;
    self.activity.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.activity.zf_centerX = self.zf_centerX;
    self.activity.zf_centerY = self.zf_centerY + 10;
    
    min_w = 150;
    min_h = 30;
    self.failBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.failBtn.center = self.center;
    
    self.doubleRateLabel.frame = CGRectMake(0, 0, 120, 26);
    self.doubleRateLabel.zf_centerX = self.zf_centerX;
    self.doubleRateLabel.zf_centerY = 40;
    
    min_w = 140;
    min_h = 80;
    self.fastView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.fastView.center = self.center;
    
    min_w = 32;
    min_x = (self.fastView.zf_width - min_w) / 2;
    min_y = 5;
    min_h = 32;
    self.fastImageView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = self.fastImageView.zf_bottom + 2;
    min_w = self.fastView.zf_width;
    min_h = 20;
    self.fastTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 12;
    min_y = self.fastTimeLabel.zf_bottom + 5;
    min_w = self.fastView.zf_width - 2 * min_x;
    min_h = 10;
    self.fastProgressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = min_view_h - 1;
    min_w = min_view_w;
    min_h = 1;
    self.bottomPgrogress.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = iPhoneX ? 54 : 30;
    min_w = 170;
    min_h = 35;
    self.volumeBrightnessView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.volumeBrightnessView.zf_centerX = self.zf_centerX;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [self cancelAutoFadeOutControlView];
}

/// 添加所有子控件
- (void)addAllSubViews {
    [self addSubview:self.portraitControlView];
    [self addSubview:self.landScapeControlView];
    [self addSubview:self.floatControlView];
//    [self addSubview:self.activity];
    [self addSubview:self.failBtn];
    [self addSubview:self.fastView];
    [self addSubview:self.doubleRateLabel];
    [self.fastView addSubview:self.fastImageView];
    [self.fastView addSubview:self.fastTimeLabel];
    [self.fastView addSubview:self.fastProgressView];
    [self addSubview:self.bottomPgrogress];
    [self addSubview:self.volumeBrightnessView];
    [self addSubview:self.rateView];
    [self addSubview:self.landscapShareAlertVm];
}

- (void)autoFadeOutControlView {
    self.controlViewAppeared = YES;
    [self cancelAutoFadeOutControlView];
    @weakify(self)
    self.afterBlock = dispatch_block_create(0, ^{
        @strongify(self)
        [self hideControlViewWithAnimated:YES isSingleTap:NO];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoHiddenTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(),self.afterBlock);
}

/// 取消延时隐藏controlView的方法
- (void)cancelAutoFadeOutControlView {
    if (self.afterBlock) {
        dispatch_block_cancel(self.afterBlock);
        self.afterBlock = nil;
    }
}
-(void)setUIForFormDetail{
    
}

/// 隐藏控制层
- (void)hideControlViewWithAnimated:(BOOL)animated isSingleTap:(BOOL)isTap{
    self.controlViewAppeared = NO;
//    [self.portraitControlView setUserInteractionEnabled:NO];
//    if (self.controlViewAppearedCallback) {
//        self.controlViewAppearedCallback(NO);
//    }
    NSTimeInterval fadeTimeInt = isTap ? self.tapFadeTimeInterval : self.autoFadeTimeInterval;
    [UIView animateWithDuration:animated ? fadeTimeInt : 0
                          delay:0
                        options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
        if (self.player.isFullScreen) {
            [self.landScapeControlView hideControlView];
        } else {
            if (!self.player.isSmallFloatViewShow) {
                [self.portraitControlView hideControlView];
            }
        }
    } completion:^(BOOL finished) {
        if (self.player.isFullScreen) {
            self.bottomPgrogress.hidden = YES;
        }else{
            self.bottomPgrogress.hidden = NO;
        }
    }];
//    [UIView animateWithDuration:animated ? fadeTimeInt : 0 animations:^{
//        if (self.player.isFullScreen) {
//            [self.landScapeControlView hideControlView];
//        } else {
//            if (!self.player.isSmallFloatViewShow) {
//                [self.portraitControlView hideControlView];
//            }
//        }
//    } completion:^(BOOL finished) {
//        if (self.player.isFullScreen) {
//            self.bottomPgrogress.hidden = YES;
//        }else{
//            self.bottomPgrogress.hidden = NO;
//        }
//    }];
}

/// 显示控制层
- (void)showControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = YES;
//    [self.portraitControlView setUserInteractionEnabled:NO];
//    if (self.controlViewAppearedCallback) {
//        self.controlViewAppearedCallback(YES);
//    }
//    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    [UIView animateWithDuration:animated ? self.autoFadeTimeInterval : 0 delay:0 options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
        if (self.player.isFullScreen) {
            [self.landScapeControlView showControlView];
        } else {
            if (!self.player.isSmallFloatViewShow) {
                [self.portraitControlView showControlView];
            }
        }
    } completion:^(BOOL finished) {
        self.bottomPgrogress.hidden = YES;
//        [self.portraitControlView setUserInteractionEnabled:YES];
        [self autoFadeOutControlView];
    }];
//    [UIView animateWithDuration:animated ? self.autoFadeTimeInterval : 0 animations:^{
//        if (self.player.isFullScreen) {
//            [self.landScapeControlView showControlView];
//        } else {
//            if (!self.player.isSmallFloatViewShow) {
//                [self.portraitControlView showControlView];
//            }
//        }
//    } completion:^(BOOL finished) {
//        self.bottomPgrogress.hidden = YES;
////        [self.portraitControlView setUserInteractionEnabled:YES];
//        [self autoFadeOutControlView];
//    }];
//    if (self.controlViewAppearedCallback) {
//        self.controlViewAppearedCallback(YES);
//    }
}

- (void)showControlViewWithAnimatedForPlayEnd{
    self.controlViewAppeared = YES;
    if (self.player.isFullScreen) {
        [self.landScapeControlView showControlView];
    } else {
        if (!self.player.isSmallFloatViewShow) {
            [self.portraitControlView showControlView];
        }
    }
    self.bottomPgrogress.hidden = YES;
}

/// 音量改变的通知
- (void)volumeChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *reasonstr = userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    if ([reasonstr isEqualToString:@"ExplicitVolumeChange"]) {
        float volume = [ userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        if (self.player.isFullScreen) {
            [self.volumeBrightnessView updateProgress:volume withVolumeBrightnessType:ZFVolumeBrightnessTypeVolume];
        } else {
            [self.volumeBrightnessView addSystemVolumeView];
        }
    }
}

#pragma mark - Public Method

/// 重置控制层
- (void)resetControlView {
    [self.portraitControlView resetControlView];
    [self.landScapeControlView resetControlView];
    [self cancelAutoFadeOutControlView];
    self.bottomPgrogress.value = 0;
    self.bottomPgrogress.bufferValue = 0;
    self.floatControlView.hidden = YES;
//    self.backgroundColor = [UIColor clearColor];
    self.failBtn.hidden = YES;
    self.rateView.hidden = YES;
    [self.rateView resetUI];
    self.oldRate = 1.0;
    [self.portraitControlView.rateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
    [self.landScapeControlView.rateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
    self.doubleRateLabel.hidden = YES;
    self.volumeBrightnessView.hidden = YES;
    self.portraitControlView.hidden = self.player.isFullScreen;
    self.landScapeControlView.hidden = !self.player.isFullScreen;
    self.player.currentPlayerManager.rate = 1.0;
//    self.player.currentPlayerManager.rate = self.oldRate;
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO isSingleTap:NO];
    }
}

-(void)resetViewForPreview{
    self.portraitControlView.backBtn.hidden = YES;
    self.portraitControlView.shareVideoBtn.hidden = YES;
    self.portraitControlView.nextBtn.hidden = YES;
    self.portraitControlView.rateBtn.hidden = YES;
    self.portraitControlView.fullScreenBtn.hidden = YES;
}

- (void)hiddenCoverImgView{
    self.coverImageView.hidden = YES;
    self.bgImgView.hidden = YES;
}
/// 设置标题、封面、全屏模式
- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl fullScreenMode:(ZFFullScreenMode)fullScreenMode {
    UIImage *placeholder = [ZFUtilities imageWithColor:[UIColor clearColor] size:self.bgImgView.bounds.size];
//    UIImage *placeholder = [ZFUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:self.bgImgView.bounds.size];
    [self showTitle:title coverURLString:coverUrl placeholderImage:placeholder fullScreenMode:fullScreenMode];
}

/// 设置标题、封面、默认占位图、全屏模式
- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl placeholderImage:(UIImage *)placeholder fullScreenMode:(ZFFullScreenMode)fullScreenMode {
    [self resetControlView];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    [self.portraitControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.landScapeControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.coverImageView setImageWithURLString:coverUrl placeholder:placeholder];
    [self.bgImgView setImageWithURLString:coverUrl placeholder:placeholder];
    if (self.prepareShowControlView) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO isSingleTap:NO];
    }
}

/// 设置标题、UIImage封面、全屏模式
- (void)showTitle:(NSString *)title coverImage:(UIImage *)image fullScreenMode:(ZFFullScreenMode)fullScreenMode {
    [self resetControlView];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    [self.portraitControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.landScapeControlView showTitle:title fullScreenMode:fullScreenMode];
    self.coverImageView.image = image;
    self.bgImgView.image = image;
    if (self.prepareShowControlView) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO isSingleTap:NO];
    }
}

#pragma mark - ZFPlayerControlViewDelegate

/// 手势筛选，返回NO不响应该手势
- (BOOL)gestureTriggerCondition:(ZFPlayerGestureControl *)gestureControl gestureType:(ZFPlayerGestureType)gestureType gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer touch:(nonnull UITouch *)touch {
//    if (self.player.isFullScreen == false) {
//        return NO;
//    }
    CGPoint point = [touch locationInView:self];
    if (self.player.isSmallFloatViewShow && !self.player.isFullScreen && gestureType != ZFPlayerGestureTypeSingleTap) {
        return NO;
    }
    if (self.player.isFullScreen) {
        if (!self.customDisablePanMovingDirection) {
            /// 不禁用滑动方向
            self.player.disablePanMovingDirection = ZFPlayerDisablePanMovingDirectionNone;
        }
        return [self.landScapeControlView shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    } else {
        if (!self.customDisablePanMovingDirection) {
            if (self.player.scrollView) {  /// 列表时候禁止上下滑动（防止和列表滑动冲突）
                self.player.disablePanMovingDirection = ZFPlayerDisablePanMovingDirectionVertical;
            } else { /// 不禁用滑动方向
                self.player.disablePanMovingDirection = ZFPlayerDisablePanMovingDirectionNone;
            }
        }
        return [self.portraitControlView shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    }
}

/// 单击手势事件
- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    NSLog(@"gestureSingleTapped  ---  1111");
    if (!self.player) return;
    NSLog(@"gestureSingleTapped  ---  2222");
    self.rateView.hidden = YES;
//    [self showControlViewWithAnimated:YES];
    if (self.player.isSmallFloatViewShow && !self.player.isFullScreen) {
        [self.player enterFullScreen:YES animated:YES];
    } else {
        if (self.controlViewAppeared) {
            NSLog(@"gestureSingleTapped  ---  isShow");
            self.controlViewAppeared = NO;
            [self hideControlViewWithAnimated:YES isSingleTap:YES];
        } else {
            NSLog(@"gestureSingleTapped  ---  isHidden");
//            [self cancelAutoFadeOutControlView];
            /// 显示之前先把控制层复位，先隐藏后显示
            [self hideControlViewWithAnimated:NO  isSingleTap:NO];
            [self showControlViewWithAnimated:YES];
        }
    }
}

/// 双击手势事件
//- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
//    if (self.player.isFullScreen) {
//        [self.landScapeControlView playOrPause];
//    } else {
//        [self.portraitControlView playOrPause];
//    }
//}
//- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
//    if (!self.player) return;
//
//    CGPoint point = [gestureControl.doubleTap locationInView:self];
//    CGFloat midX = self.bounds.size.width * 0.5;
//
//    NSTimeInterval current = self.player.currentTime;
//    NSTimeInterval duration = self.player.totalTime;
//
//    if (point.x < midX) {
//        /// left area - backward 10 seconds
//        NSTimeInterval time = current - 10;
//        if (time < 0) time = 0;
//        [self.player seekToTime:time completionHandler:nil];
//
//        self.portraitControlView.tenSecondBakcBtn.alpha = 1;
//        self.landScapeControlView.tenSecondBakcBtn.alpha = 1;
//        [UIView animateWithDuration:0.3 animations:^{
//            self.portraitControlView.tenSecondBakcBtn.alpha = 0;
//            self.landScapeControlView.tenSecondBakcBtn.alpha = 0;
//        }];
//    } else {
//        /// right area - forward 10 seconds
//        NSTimeInterval time = current + 10;
//        if (time > duration) time = duration;
//        [self.player seekToTime:time completionHandler:nil];
//
//        self.portraitControlView.tenSecondForwardBtn.alpha = 1;
//        self.landScapeControlView.tenSecondForwardBtn.alpha = 1;
//        [UIView animateWithDuration:0.3 animations:^{
//            self.portraitControlView.tenSecondForwardBtn.alpha = 0;
//            self.landScapeControlView.tenSecondForwardBtn.alpha = 0;
//        }];
//    }
//
//    if (self.seekToPlay) {
//        [self.player.currentPlayerManager play];
//    }
//}
/// 开始滑动手势事件
- (void)gestureBeganPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
//    if (direction == ZFPanDirectionH) {
//        self.sumTime = self.player.currentTime;
//    }
    [self hideControlViewWithAnimated:YES isSingleTap:NO];
}

/// 滑动中手势事件
- (void)gestureChangedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location withVelocity:(CGPoint)velocity {
    if (direction == ZFPanDirectionH) {
//        // 每次滑动需要叠加时间
//        self.sumTime += velocity.x / 200;
//        // 需要限定sumTime的范围
//        NSTimeInterval totalMovieDuration = self.player.totalTime;
//        if (totalMovieDuration == 0) return;
//        if (self.sumTime > totalMovieDuration) self.sumTime = totalMovieDuration;
//        if (self.sumTime < 0) self.sumTime = 0;
//        BOOL style = NO;
//        if (velocity.x > 0) style = YES;
//        if (velocity.x < 0) style = NO;
//        if (velocity.x == 0) return;
//        [self sliderValueChangingValue:self.sumTime/totalMovieDuration isForward:style];
    } else if (direction == ZFPanDirectionV) {
        if (location == ZFPanLocationLeft) { /// 调节亮度
            self.player.brightness -= (velocity.y) / 10000;
            [self.volumeBrightnessView updateProgress:self.player.brightness withVolumeBrightnessType:ZFVolumeBrightnessTypeumeBrightness];
        } else if (location == ZFPanLocationRight) { /// 调节声音
            self.player.volume -= (velocity.y) / 10000;
            if (self.player.isFullScreen) {
                [self.volumeBrightnessView updateProgress:self.player.volume withVolumeBrightnessType:ZFVolumeBrightnessTypeVolume];
            }
        }
    }
}

/// 滑动结束手势事件
- (void)gestureEndedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
//    @weakify(self)
//    if (direction == ZFPanDirectionH && self.sumTime >= 0 && self.player.totalTime > 0) {
//        [self.player seekToTime:self.sumTime completionHandler:^(BOOL finished) {
//            if (finished) {
//                @strongify(self)
//                /// 左右滑动调节播放进度
//                [self.portraitControlView sliderChangeEnded];
//                [self.landScapeControlView sliderChangeEnded];
//                self.bottomPgrogress.isdragging = NO;
//                if (self.controlViewAppeared) {
//                    [self autoFadeOutControlView];
//                }
//            }
//        }];
//        if (self.seekToPlay) {
//            [self.player.currentPlayerManager play];
//        }
//        self.sumTime = 0;
//    }
}

/// 捏合手势事件，这里改变了视频的填充模式
- (void)gesturePinched:(ZFPlayerGestureControl *)gestureControl scale:(float)scale {
    if (scale > 1) {
        self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
    } else {
        self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFit;
    }
}

/// 准备播放
- (void)videoPlayer:(ZFPlayerController *)videoPlayer prepareToPlay:(NSURL *)assetURL {
    [self hideControlViewWithAnimated:NO isSingleTap:NO];
}

/// 播放状态改变
- (void)videoPlayer:(ZFPlayerController *)videoPlayer playStateChanged:(ZFPlayerPlaybackState)state {
    if (state == ZFPlayerPlayStatePlaying) {
        [self.portraitControlView playBtnSelectedState:YES];
        [self.landScapeControlView playBtnSelectedState:YES];
        self.failBtn.hidden = YES;
        self.doubleRateLabel.hidden = YES;
        /// 开始播放时候判断是否显示loading
        if (videoPlayer.currentPlayerManager.loadState == ZFPlayerLoadStateStalled && !self.prepareShowLoading) {
//            [self.activity startAnimating];
        } else if ((videoPlayer.currentPlayerManager.loadState == ZFPlayerLoadStateStalled || videoPlayer.currentPlayerManager.loadState == ZFPlayerLoadStatePrepare) && self.prepareShowLoading) {
//            [self.activity startAnimating];
        }
    } else if (state == ZFPlayerPlayStatePaused) {
        [self.portraitControlView playBtnSelectedState:NO];
        [self.landScapeControlView playBtnSelectedState:NO];
        /// 暂停的时候隐藏loading
//        [self.activity stopAnimating];
        self.failBtn.hidden = YES;
        self.doubleRateLabel.hidden = YES;
    } else if (state == ZFPlayerPlayStatePlayFailed) {
        self.failBtn.hidden = NO;
//        [self.activity stopAnimating];
    }
}

/// 加载状态改变
- (void)videoPlayer:(ZFPlayerController *)videoPlayer loadStateChanged:(ZFPlayerLoadState)state {
    if (state == ZFPlayerLoadStatePrepare) {
        self.coverImageView.hidden = NO;
        [self.portraitControlView playBtnSelectedState:videoPlayer.currentPlayerManager.shouldAutoPlay];
        [self.landScapeControlView playBtnSelectedState:videoPlayer.currentPlayerManager.shouldAutoPlay];
    } else if (state == ZFPlayerLoadStatePlaythroughOK || state == ZFPlayerLoadStatePlayable) {
        self.coverImageView.hidden = YES;
        if (self.effectViewShow) {
            self.effectView.hidden = NO;
        } else {
            self.effectView.hidden = YES;
            self.player.currentPlayerManager.view.backgroundColor = [UIColor blackColor];
        }
    }
//    if (state == ZFPlayerLoadStateStalled && videoPlayer.currentPlayerManager.isPlaying && !self.prepareShowLoading) {
//        [self.activity startAnimating];
//    } else if ((state == ZFPlayerLoadStateStalled || state == ZFPlayerLoadStatePrepare) && videoPlayer.currentPlayerManager.isPlaying && self.prepareShowLoading) {
//        [self.activity startAnimating];
//    } else {
//        [self.activity stopAnimating];
//    }
}

/// 播放进度改变回调
- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    [self.portraitControlView videoPlayer:videoPlayer currentTime:currentTime totalTime:totalTime];
    [self.landScapeControlView videoPlayer:videoPlayer currentTime:currentTime totalTime:totalTime];
    if (!self.bottomPgrogress.isdragging) {
        self.bottomPgrogress.value = videoPlayer.progress;
    }
}

/// 缓冲改变回调
- (void)videoPlayer:(ZFPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    [self.portraitControlView videoPlayer:videoPlayer bufferTime:bufferTime];
    [self.landScapeControlView videoPlayer:videoPlayer bufferTime:bufferTime];
    self.bottomPgrogress.bufferValue = videoPlayer.bufferProgress;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size {
    [self.landScapeControlView videoPlayer:videoPlayer presentationSizeChanged:size];
}

/// 视频view即将旋转
- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationWillChange:(ZFOrientationObserver *)observer {
    self.portraitControlView.hidden = observer.isFullScreen;
    self.landScapeControlView.hidden = !observer.isFullScreen;
    if (videoPlayer.isSmallFloatViewShow) {
        self.floatControlView.hidden = observer.isFullScreen;
        self.portraitControlView.hidden = YES;
        if (observer.isFullScreen) {
            self.controlViewAppeared = NO;
            [self cancelAutoFadeOutControlView];
        }
    }
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO isSingleTap:NO];
    }
    
    if (observer.isFullScreen) {
        [self.volumeBrightnessView removeSystemVolumeView];
    } else {
        [self.volumeBrightnessView addSystemVolumeView];
    }
}

/// 视频view已经旋转
- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationDidChanged:(ZFOrientationObserver *)observer {
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO isSingleTap:NO];
    }
}

/// 锁定旋转方向
- (void)lockedVideoPlayer:(ZFPlayerController *)videoPlayer lockedScreen:(BOOL)locked {
    [self showControlViewWithAnimated:YES];
}

/// 列表滑动时视频view已经显示
- (void)playerDidAppearInScrollView:(ZFPlayerController *)videoPlayer {
    if (!self.player.stopWhileNotVisible && !videoPlayer.isFullScreen) {
        self.floatControlView.hidden = YES;
        self.portraitControlView.hidden = NO;
    }
}

/// 列表滑动时视频view已经消失
- (void)playerDidDisappearInScrollView:(ZFPlayerController *)videoPlayer {
    if (!self.player.stopWhileNotVisible && !videoPlayer.isFullScreen) {
        self.floatControlView.hidden = NO;
        self.portraitControlView.hidden = YES;
    }
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer floatViewShow:(BOOL)show {
    self.floatControlView.hidden = !show;
    self.portraitControlView.hidden = show;
}

#pragma mark - Private Method

- (void)sliderValueChangingValue:(CGFloat)value isForward:(BOOL)forward {
    if (self.horizontalPanShowControlView) {
        /// 显示控制层
        [self showControlViewWithAnimated:NO];
        [self cancelAutoFadeOutControlView];
    }
    
    self.fastProgressView.value = value;
    self.fastView.hidden = NO;
    self.fastView.alpha = 1;
    if (forward) {
        self.fastImageView.image = ZFPlayer_Image(@"ZFPlayer_fast_forward");
    } else {
        self.fastImageView.image = ZFPlayer_Image(@"ZFPlayer_fast_backward");
    }
    NSString *draggedTime = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
    NSString *totalTime = [ZFUtilities convertTimeSecond:self.player.totalTime];
    self.fastTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",draggedTime,totalTime];
    /// 更新滑杆
    [self.portraitControlView sliderValueChanged:value currentTimeString:draggedTime];
    [self.landScapeControlView sliderValueChanged:value currentTimeString:draggedTime];
    self.bottomPgrogress.isdragging = YES;
    self.bottomPgrogress.value = value;

//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFastView) object:nil];
//    [self performSelector:@selector(hideFastView) withObject:nil afterDelay:0.1];
    
//    if (self.fastViewAnimated) {
//        [UIView animateWithDuration:0.4 animations:^{
//            self.fastView.transform = CGAffineTransformMakeTranslation(forward?8:-8, 0);
//        }];
//    }
}

/// 隐藏快进视图
- (void)hideFastView {
//    [UIView animateWithDuration:0.4 animations:^{
//        self.fastView.transform = CGAffineTransformIdentity;
//        self.fastView.alpha = 0;
//    } completion:^(BOOL finished) {
//        self.fastView.hidden = YES;
//    }];
}

/// 加载失败
- (void)failBtnClick:(UIButton *)sender {
    [self.player.currentPlayerManager reloadPlayer];
}

#pragma mark - setter

- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;
    self.landScapeControlView.player = player;
    self.portraitControlView.player = player;
    /// 解决播放时候黑屏闪一下问题
    [player.currentPlayerManager.view insertSubview:self.bgImgView atIndex:0];
//    [self.bgImgView addSubview:self.effectView];
    [player.currentPlayerManager.view insertSubview:self.coverImageView atIndex:1];
    self.coverImageView.frame = player.currentPlayerManager.view.bounds;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bgImgView.frame = player.currentPlayerManager.view.bounds;
    self.bgImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.frame = self.bgImgView.bounds;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setSeekToPlay:(BOOL)seekToPlay {
    _seekToPlay = seekToPlay;
    self.portraitControlView.seekToPlay = seekToPlay;
    self.landScapeControlView.seekToPlay = seekToPlay;
}

- (void)setEffectViewShow:(BOOL)effectViewShow {
    _effectViewShow = effectViewShow;
    if (effectViewShow) {
        self.bgImgView.hidden = NO;
    } else {
        self.bgImgView.hidden = YES;
    }
}

#pragma mark - getter

- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.userInteractionEnabled = YES;
        _bgImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bgImgView;
}

- (UIView *)effectView {
    if (!_effectView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        } else {
            UIToolbar *effectView = [[UIToolbar alloc] init];
            effectView.barStyle = UIBarStyleBlackTranslucent;
            _effectView = effectView;
        }
    }
    return _effectView;
}

- (TutorialVideoPortraitControlView *)portraitControlView {
    if (!_portraitControlView) {
        @weakify(self)
        _portraitControlView = [[TutorialVideoPortraitControlView alloc] init];
//        _portraitControlView.playOrPauseBtn.selected = NO;
        [_portraitControlView.player.currentPlayerManager pause];
        _portraitControlView.sliderValueChanging = ^(CGFloat value, BOOL forward) {
            @strongify(self)
            NSString *draggedTime = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
            /// 更新滑杆和时间
            [self.landScapeControlView sliderValueChanged:value currentTimeString:draggedTime];
            self.fastProgressView.value = value;
            self.bottomPgrogress.isdragging = YES;
            self.bottomPgrogress.value = value;
            self.rateView.hidden = YES;
            [self cancelAutoFadeOutControlView];
        };
        _portraitControlView.sliderValueChanged = ^(CGFloat value) {
            @strongify(self)
//            [self hideControlViewWithAnimated:YES];
//            self.controlViewAppeared = true;
            [self.landScapeControlView sliderChangeEnded];
            self.fastProgressView.value = value;
            self.bottomPgrogress.isdragging = NO;
            self.bottomPgrogress.value = value;
            [self autoFadeOutControlView];
//            self.controlViewAppeared = NO;
        };
        _portraitControlView.rateTapBlock = ^() {
            @strongify(self)
//            self.rateView.hidden = NO;
            NSString *value = @"1";
            
            if (self.oldRate == 1){
                value = @"1.25";
            }else if (self.oldRate == 1.25){
                value = @"1.5";
            }else if (self.oldRate == 1.5){
                value = @"2";
            }else if (self.oldRate == 2){
                value = @"0.75";
            }else if (self.oldRate == 0.75){
                value = @"1";
            }
            [self autoFadeOutControlView];
            self.player.currentPlayerManager.rate = value.floatValue;
            self.oldRate = value.floatValue;
            [self.portraitControlView.rateBtn setTitle:[NSString stringWithFormat:@"%@x",value] forState:UIControlStateNormal];
            [self.landScapeControlView.rateBtn setTitle:[NSString stringWithFormat:@"%@x",value] forState:UIControlStateNormal];
            [self.rateView setRate:value];
        };
        _portraitControlView.nextVideoTapBlock = ^() {
//            @strongify(self)
            
        };
        _portraitControlView.backBtnClickCallback = ^() {
            @strongify(self)
            if (self.backBtnClickCallback) {
                self.backBtnClickCallback();
            }
        };
        _portraitControlView.rePlayBlock = ^() {
            @strongify(self)
            self.rateView.hidden = YES;
            [self.rateView resetUI];
            self.oldRate = 1.0;
            [self.portraitControlView.rateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
            [self.landScapeControlView.rateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
            [self autoFadeOutControlView];
        };
        
        _portraitControlView.shareBtnClickCallback = ^{
            @strongify(self)
            NSLog(@"竖屏--分享按钮点击事件");
            if (self.shareBtnClickCallback){
                self.shareBtnClickCallback(YES);
            }
        };
        _portraitControlView.sliderChangedTapBlock = ^{
            @strongify(self)
            NSLog(@"竖屏--分享按钮点击事件");
            [self autoFadeOutControlView];
        };
        _portraitControlView.tenSecondBackTapBlock = ^() {
            @strongify(self)
//            [self cancelAutoFadeOutControlView];
            [self autoFadeOutControlView];
        };
        _portraitControlView.tenSecondForwardTapBlock = ^() {
            @strongify(self)
            [self autoFadeOutControlView];
        };
    }
    return _portraitControlView;
}

- (TutorialVideoLandScapeControlView *)landScapeControlView {
    if (!_landScapeControlView) {
        @weakify(self)
        _landScapeControlView = [[TutorialVideoLandScapeControlView alloc] init];
        _landScapeControlView.sliderValueChanging = ^(CGFloat value, BOOL forward) {
            @strongify(self)
            NSString *draggedTime = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
            /// 更新滑杆和时间
            [self.portraitControlView sliderValueChanged:value currentTimeString:draggedTime];
            self.fastProgressView.value = value;
            self.bottomPgrogress.isdragging = YES;
            self.rateView.hidden = YES;
            self.bottomPgrogress.value = value;
            [self cancelAutoFadeOutControlView];
        };
        _landScapeControlView.sliderChangedTapBlock = ^{
            @strongify(self)
            NSLog(@"竖屏--分享按钮点击事件");
            [self autoFadeOutControlView];
        };
        _landScapeControlView.sliderValueChanged = ^(CGFloat value) {
            @strongify(self)
            [self.portraitControlView sliderChangeEnded];
            self.fastProgressView.value = value;
            self.bottomPgrogress.isdragging = NO;
            self.bottomPgrogress.value = value;
            [self autoFadeOutControlView];
//            self.controlViewAppeared = NO;
        };
        _landScapeControlView.rateTapBlock = ^() {
            @strongify(self)
            self.rateView.hidden = NO;
            [self cancelAutoFadeOutControlView];
        };
        _landScapeControlView.rePlayBlock = ^() {
            @strongify(self)
            self.rateView.hidden = YES;
            [self.rateView resetUI];
            self.oldRate = 1.0;
            [self.portraitControlView.rateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
            [self.landScapeControlView.rateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
            [self autoFadeOutControlView];
        };
        _landScapeControlView.shareBtnClickCallback = ^{
            @strongify(self)
            NSLog(@"横屏--分享");
//            [self.landscapShareAlertVm showViewForTutorialWithTutorialMo:nil];
//            [self.landscapShareAlertVm showViewForTutorialWithTutorialMo:self.tuModel];
//            [self.landscapShareAlertVm showview];
            if (self.shareBtnClickCallback){
                self.shareBtnClickCallback(NO);
            }
        };
        _landScapeControlView.tenSecondBackTapBlock = ^() {
            @strongify(self)
//            [self autoFadeOutControlView];
        };
        _landScapeControlView.tenSecondForwardTapBlock = ^() {
            @strongify(self)
//            [self autoFadeOutControlView];
        };
    }
    return _landScapeControlView;
}

- (ZFSpeedLoadingView *)activity {
    if (!_activity) {
        _activity = [[ZFSpeedLoadingView alloc] init];
        _activity.hidden = YES;
    }
    return _activity;
}

- (UIView *)fastView {
    if (!_fastView) {
        _fastView = [[UIView alloc] init];
        _fastView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _fastView.layer.cornerRadius = 4;
        _fastView.layer.masksToBounds = YES;
        _fastView.hidden = YES;
    }
    return _fastView;
}

- (UIImageView *)fastImageView {
    if (!_fastImageView) {
        _fastImageView = [[UIImageView alloc] init];
    }
    return _fastImageView;
}

- (UILabel *)fastTimeLabel {
    if (!_fastTimeLabel) {
        _fastTimeLabel = [[UILabel alloc] init];
        _fastTimeLabel.textColor = [UIColor whiteColor];
        _fastTimeLabel.textAlignment = NSTextAlignmentCenter;
        _fastTimeLabel.font = [UIFont systemFontOfSize:14.0];
        _fastTimeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _fastTimeLabel;
}

- (ZFSliderView *)fastProgressView {
    if (!_fastProgressView) {
        _fastProgressView = [[ZFSliderView alloc] init];
        _fastProgressView.maximumTrackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        _fastProgressView.minimumTrackTintColor = [UIColor whiteColor];
        _fastProgressView.sliderHeight = 2;
        _fastProgressView.isHideSliderBlock = NO;
    }
    return _fastProgressView;
}

- (UIButton *)failBtn {
    if (!_failBtn) {
        _failBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_failBtn setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failBtn addTarget:self action:@selector(failBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _failBtn.hidden = YES;
    }
    return _failBtn;
}
- (UILabel *)doubleRateLabel{
    if (!_doubleRateLabel){
        _doubleRateLabel = [[UILabel alloc]init];
        _doubleRateLabel.text = @"2.0倍速播放中";
        _doubleRateLabel.textAlignment = NSTextAlignmentCenter;
        _doubleRateLabel.layer.cornerRadius = 4.0;
        _doubleRateLabel.clipsToBounds = YES;
        _doubleRateLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25];
        _doubleRateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.85];
        _doubleRateLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _doubleRateLabel.hidden = YES;
        
    }
    return _doubleRateLabel;
}
- (ZFSliderView *)bottomPgrogress {
    if (!_bottomPgrogress) {
        _bottomPgrogress = [[ZFSliderView alloc] init];
        _bottomPgrogress.maximumTrackTintColor = [UIColor clearColor];
        _bottomPgrogress.minimumTrackTintColor = [UIColor colorWithRed:0.0f green:122.0/255.0f blue:1.0f alpha:1];//[UIColor whiteColor];
        _bottomPgrogress.bufferTrackTintColor  = [UIColor clearColor];//[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bottomPgrogress.sliderHeight = 1;
        _bottomPgrogress.isHideSliderBlock = NO;
    }
    return _bottomPgrogress;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (ZFSmallFloatControlView *)floatControlView {
    if (!_floatControlView) {
        _floatControlView = [[ZFSmallFloatControlView alloc] init];
        @weakify(self)
        _floatControlView.closeClickCallback = ^{
            @strongify(self)
            if (self.player.containerType == ZFPlayerContainerTypeCell) {
                [self.player stopCurrentPlayingCell];
            } else if (self.player.containerType == ZFPlayerContainerTypeView) {
                [self.player stopCurrentPlayingView];
            }
            [self resetControlView];
        };
    }
    return _floatControlView;
}

- (ZFVolumeBrightnessView *)volumeBrightnessView {
    if (!_volumeBrightnessView) {
        _volumeBrightnessView = [[ZFVolumeBrightnessView alloc] init];
        _volumeBrightnessView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _volumeBrightnessView.hidden = YES;
    }
    return _volumeBrightnessView;
}

- (TutorialVideoRateView *)rateView{
    if (!_rateView) {
//        _rateView = [[TutorialVideoRateView alloc]initWithFrame:CGRectMake(0, 0, 60, 100)];
        _rateView = [[TutorialVideoRateView alloc]initWithFrame:CGRectMake(0, 0, 60, 150)];
        _rateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
        _rateView.hidden = true;
        @weakify(self)
        _rateView.rateValueChanged = ^(NSString* value) {
            @strongify(self)
            self.player.currentPlayerManager.rate = value.floatValue;
            self.oldRate = value.floatValue;
            [self.portraitControlView.rateBtn setTitle:[NSString stringWithFormat:@"%@x",value] forState:UIControlStateNormal];
            [self.landScapeControlView.rateBtn setTitle:[NSString stringWithFormat:@"%@x",value] forState:UIControlStateNormal];
            [self hideControlViewWithAnimated:true isSingleTap:NO];
        };
    }
    return _rateView;
}

- (ForumShareVM *)landscapShareAlertVm{
    if (!_landscapShareAlertVm) {
        _landscapShareAlertVm = [[ForumShareVM alloc]initWithFrame:CGRectZero];
    }
    return _landscapShareAlertVm;
}
- (void)setBackBtnClickCallback:(void (^)(void))backBtnClickCallback {
    _backBtnClickCallback = [backBtnClickCallback copy];
//    self.landScapeControlView.backBtnClickCallback = _backBtnClickCallback;
}

@end
