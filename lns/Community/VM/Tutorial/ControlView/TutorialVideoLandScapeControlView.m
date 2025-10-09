//
//  TutorialVideoLandScapeControlView.m
//  lns
//
//  Created by Elavatine on 2024/12/25.
//

#import "TutorialVideoLandScapeControlView.h"
#import "UIView+ZFFrame.h"
#import "ZFUtilities.h"
#if __has_include(<ZFPlayer/ZFPlayer.h>)
#import <ZFPlayer/ZFPlayer.h>
#else
#import "ZFPlayer.h"
#endif

@interface TutorialVideoLandScapeControlView () <ZFSliderViewDelegate>
/// 顶部工具栏
@property (nonatomic, strong) UIView *topToolView;
/// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 底部工具栏
@property (nonatomic, strong) UIView *bottomToolView;
/// 播放或暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseBtn;
/// 全屏按钮
@property (nonatomic, strong) UIButton *fullScreenBtn;
/// 播放的当前时间
@property (nonatomic, strong) UILabel *currentTimeLabel;
/// 滑杆
@property (nonatomic, strong) ZFSliderView *slider;
/// 视频总时间
@property (nonatomic, strong) UILabel *totalTimeLabel;
/// 锁定屏幕按钮
@property (nonatomic, strong) UIButton *lockBtn;

@property (nonatomic, strong) UILabel *systemTimeLabel;

@property (nonatomic, assign) BOOL isShow;

@end

@implementation TutorialVideoLandScapeControlView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topToolView];
//        [self.topToolView addSubview:self.systemTimeLabel];
        [self.topToolView addSubview:self.backBtn];
//        [self.topToolView addSubview:self.shareVideoBtn];
        [self.topToolView addSubview:self.titleLabel];
        [self addSubview:self.bottomToolView];
        [self addSubview:self.playOrPauseBtn];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.totalTimeLabel];
        [self.bottomToolView addSubview:self.fullScreenBtn];
        [self.bottomToolView addSubview:self.nextBtn];
        [self.bottomToolView addSubview:self.rateBtn];
        
        [self addSubview:self.lockBtn];
        [self addSubview:self.tenSecondBakcBtn];
        [self addSubview:self.tenSecondForwardBtn];
        
        // 设置子控件的响应事件
        [self makeSubViewsAction];
        [self resetControlView];
//        [self calculateSystemTime];
        /// statusBarFrame changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutControllerViews) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    CGFloat min_margin = 9;
    
    UIEdgeInsets insets = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
    CGFloat topSafeAreaHeight = insets.top;
    CGFloat bottomSafeAreaHeight = insets.bottom;
    
    CGFloat tabbarH = bottomSafeAreaHeight > 0 ? 44 : 0;
    
    min_x = topSafeAreaHeight;
    min_y = 0;
    min_w = min_view_w ;//- topSafeAreaHeight - bottomSafeAreaHeight - tabbarH;
    min_h = iPhoneX ? 110 : 80;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
//    UIApplication.shared.statusBarFrame.height
//    [UIApplication sharedApplication].statusBarFrame.size.height
//    min_x = [UIApplication sharedApplication].statusBarFrame.size.height + 10;
    //(iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 44: 15;
//    if (@available(iOS 13.0, *)) {
//        min_y = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 10 : (iPhoneX ? 40 : 20);
//    } else {
//        min_y = (iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 10: (iPhoneX ? 40 : 20);
//    }
    min_x = 25;
    min_w = 40;
    min_h = 40;
    self.backBtn.frame = CGRectMake(min_x, 10, min_w, min_h);
    
    min_x = min_view_w - 24 - 16;
    min_y = 0;
    min_w = 20;
    min_h = 20;
    self.shareVideoBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.shareVideoBtn.zf_centerY = self.backBtn.zf_centerY;
    
    min_w = 100;
    min_h = 30;
    min_x = self.topToolView.zf_width - min_w - min_margin;
//    min_y = 0;
    min_x = (min_view_w - min_w) * 0.5;
    self.systemTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.systemTimeLabel.zf_centerY = self.backBtn.zf_centerY;
    
    min_x = self.backBtn.zf_right + 5;
    min_y = 0;
    min_w = min_view_w - min_x - 15 ;
    min_h = 30;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.titleLabel.zf_centerY = self.backBtn.zf_centerY;
    
    min_h = bottomSafeAreaHeight + 90;//iPhoneX ? 120 : 90;
    min_x = topSafeAreaHeight;
    min_y = min_view_h - min_h;
    min_w = self.topToolView.zf_width;//min_view_w - topSafeAreaHeight - bottomSafeAreaHeight - tabbarH;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = (iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 44: 15;
    min_y = 32;
    min_w = 70;
    min_h = 70;
    self.playOrPauseBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = [UIApplication sharedApplication].statusBarFrame.size.height + 15;//self.playOrPauseBtn.zf_right + 4;
    min_y = 10;
    min_w = 140;
    min_h = 30;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.currentTimeLabel.zf_left = self.backBtn.zf_left+10;
    
    min_w = 46;
    min_h = min_w;
    min_x = self.bottomToolView.zf_width - min_w - min_margin*3;
    min_y = 5;
    self.fullScreenBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
//    self.fullScreenBtn.zf_centerY = self.currentTimeLabel.zf_centerY;
    self.currentTimeLabel.zf_centerY = self.fullScreenBtn.zf_centerY;
    
    min_w = 40;
    min_h = min_w;
    min_x = self.fullScreenBtn.zf_left - min_w*1.5 - 4;
    min_y = 0;
    self.rateBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.rateBtn.zf_centerY = self.fullScreenBtn.zf_centerY;
    
    min_w = 44;
    min_h = min_w;
    min_x = self.rateBtn.zf_left - min_w*1.5 - 4;
    min_y = 0;
    self.nextBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.nextBtn.zf_centerY = self.fullScreenBtn.zf_centerY;
    
    min_w = 62;
    min_x = self.bottomToolView.zf_width - min_w - ((iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 44: min_margin);
//    min_x = self.bottomToolView.zf_width - min_w - 4;
    min_y = 0;
    min_h = 30;
    self.totalTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.totalTimeLabel.zf_centerY = self.playOrPauseBtn.zf_centerY;
    
    min_x = iPhoneX ? 50 : 10;//self.currentTimeLabel.zf_left;
    min_y = 0;
    min_w = self.bottomToolView.zf_width - min_x * 2;//self.totalTimeLabel.zf_right - min_x;
    min_h = 30;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.slider.zf_centerY = self.playOrPauseBtn.zf_centerY;
//    self.slider.zf_right = self.fullScreenBtn.zf_right;
//    self.slider.zf_left = self.currentTimeLabel.zf_left;
    
    min_x = (iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 50: 18;
    min_y = 0;
    min_w = 40;
    min_h = 40;
    self.lockBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.lockBtn.zf_centerY = self.zf_centerY;
    
    self.playOrPauseBtn.center = self.center;
    
    min_w = 70;
    min_h = 70;
    self.tenSecondBakcBtn.frame = CGRectMake(min_x - min_w*2, min_y, min_w, min_h);
    self.tenSecondBakcBtn.zf_centerY = self.playOrPauseBtn.zf_centerY;
    self.tenSecondBakcBtn.zf_centerX = self.playOrPauseBtn.zf_centerX - min_w*2;
    
    self.tenSecondForwardBtn.frame = CGRectMake(0, 0, min_w, min_h);
    self.tenSecondForwardBtn.zf_centerY = self.playOrPauseBtn.zf_centerY;
    self.tenSecondForwardBtn.zf_centerX = self.playOrPauseBtn.zf_centerX + min_w*2;
    
    if (!self.isShow) {
        self.topToolView.zf_y = -self.topToolView.zf_height;
        self.bottomToolView.zf_y = self.zf_height;
        self.playOrPauseBtn.alpha = 0;
        self.tenSecondBakcBtn.alpha = 0;
        self.tenSecondForwardBtn.alpha = 0;
    } else {
        if (self.player.isLockedScreen) {
            self.topToolView.zf_y = -self.topToolView.zf_height;
            self.bottomToolView.zf_y = self.zf_height;
            self.playOrPauseBtn.alpha = 0;
            self.tenSecondBakcBtn.alpha = 0;
            self.tenSecondForwardBtn.alpha = 0;
        } else {
            self.topToolView.zf_y = 0;
            self.bottomToolView.zf_y = self.zf_height - self.bottomToolView.zf_height;
            self.playOrPauseBtn.alpha = 1;
            self.tenSecondBakcBtn.alpha = 1;
            self.tenSecondForwardBtn.alpha = 1;
        }
    }
}

- (void)makeSubViewsAction {
    [self.backBtn addTarget:self action:@selector(backBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareVideoBtn addTarget:self action:@selector(shareBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn addTarget:self action:@selector(playPauseButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.lockBtn addTarget:self action:@selector(lockButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rateBtn addTarget:self action:@selector(rateButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextBtn addTarget:self action:@selector(nextButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tenSecondBakcBtn addTarget:self action:@selector(tenSecondsBackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tenSecondForwardBtn addTarget:self action:@selector(tenSecondsForwardAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - action
- (void)shareBtnClickAction:(UIButton *)sender {
    if (self.shareBtnClickCallback) {
        self.shareBtnClickCallback();
    }
}

-(void)calculateSystemTime{
    if (!self.player.isFullScreen){
        return;
    }
    // 获取当前日期和时间
    NSDate *currentDate = [NSDate date];

    // 将日期和时间格式化为字符串（可选）
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    self.systemTimeLabel.text = dateString;
//    NSLog(@"当前时间: %@", dateString);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self calculateSystemTime];
    });
}

- (void)layoutControllerViews {
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void)backBtnClickAction:(UIButton *)sender {
    self.lockBtn.selected = NO;
    self.player.lockedScreen = NO;
    if (self.player.orientationObserver.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"tutorialExitFullScreen" object:nil];
        [self.player enterFullScreen:NO animated:YES];
    }
    if (self.backBtnClickCallback) {
        self.backBtnClickCallback();
    }
}

- (void)playPauseButtonClickAction:(UIButton *)sender {
    [self playOrPause];
}

- (void)fullScreenButtonClickAction:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"tutorialExitFullScreen" object:nil];
    [self.player enterFullScreen:NO animated:YES];
}

- (void)rateButtonClickAction:(UIButton *)sender {
    if (self.rateTapBlock) self.rateTapBlock();
}
- (void)nextButtonClickAction:(UIButton *)sender {
//    if (self.nextVideoTapBlock) self.nextVideoTapBlock();
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"nextTutorialVideo" object:nil];
}

-(void)tenSecondsBackAction{
    NSLog(@"tenSecondsBackAction");
    if (self.tenSecondBackTapBlock) self.tenSecondBackTapBlock();
    NSTimeInterval time = (self.player.currentTime - 10) > 0 ? (self.player.currentTime - 10) : 0;
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"tenSecondsBackAction 10s");
    }];
    if (self.seekToPlay) {
        [self.player.currentPlayerManager play];
    }
}

-(void)tenSecondsForwardAction{
    NSLog(@"tenSecondsForwardAction");
    if (self.tenSecondForwardTapBlock) self.tenSecondForwardTapBlock();
    NSTimeInterval time = (self.player.currentTime + 10) > self.player.totalTime ? self.player.totalTime : (self.player.currentTime + 10);
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"tenSecondsForwardAction 10s");
    }];
    if (self.seekToPlay) {
        [self.player.currentPlayerManager play];
    }
}

/// 根据当前播放状态取反
- (void)playOrPause {
//    self.playOrPauseBtn.selected = !self.playOrPauseBtn.isSelected;
//    self.playOrPauseBtn.isSelected? [self.player.currentPlayerManager play]: [self.player.currentPlayerManager pause];
    if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlayStopped){
//        [self.player.currentPlayerManager replay];
        @weakify(self)
        [self.player seekToTime:0 completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                [self.player.currentPlayerManager play];
                self.playOrPauseBtn.selected = YES;
                self.player.currentPlayerManager.rate = 1.0;
                if (self.pauseManualTapBlock){
                    self.pauseManualTapBlock(false);
                }
                if (self.rePlayBlock){
                    self.rePlayBlock();
                }
            }
        }];
    }else{
        self.playOrPauseBtn.selected = !self.playOrPauseBtn.isSelected;
        if (self.playOrPauseBtn.isSelected){
            [self.player.currentPlayerManager play];
            if (self.pauseManualTapBlock){
                self.pauseManualTapBlock(false);
            }
        }else{
            [self.player.currentPlayerManager pause];
            if (self.pauseManualTapBlock){
                self.pauseManualTapBlock(true);
            }
        }
//        self.playOrPauseBtn.isSelected? [self.player.currentPlayerManager play]: [self.player.currentPlayerManager pause];
    }
}

- (void)playBtnSelectedState:(BOOL)selected {
    self.playOrPauseBtn.selected = selected;
}

- (void)lockButtonClickAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.player.lockedScreen = sender.selected;
}

#pragma mark - ZFSliderViewDelegate

- (void)sliderTouchBegan:(float)value {
    self.slider.isdragging = YES;
    [self controlStatusRefresh];
}

- (void)sliderTouchEnded:(float)value {
    if (self.player.totalTime > 0) {
        self.slider.isdragging = YES;
        if (self.sliderValueChanging) self.sliderValueChanging(value, self.slider.isForward);
        @weakify(self)
        [self.player seekToTime:self.player.totalTime*value completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                self.slider.isdragging = NO;
                [self controlStatusRefresh];
                if (self.sliderValueChanged) self.sliderValueChanged(value);
                if (self.seekToPlay) {
                    [self.player.currentPlayerManager play];
                }
            }
        }];
    } else {
        self.slider.isdragging = NO;
        self.slider.value = 0;
        [self controlStatusRefresh];
    }
}

- (void)sliderValueChanged:(float)value {
    if (self.player.totalTime == 0) {
        self.slider.value = 0;
        return;
    }
    self.slider.isdragging = YES;
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentTimeString,self.totalTimeLabel.text];
    if (self.sliderValueChanging) self.sliderValueChanging(value,self.slider.isForward);
}

- (void)sliderTapped:(float)value {
    [self sliderTouchEnded:value];
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
//    self.currentTimeLabel.text = currentTimeString;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentTimeString,self.totalTimeLabel.text];
}

-(void)controlStatusRefresh{
    if (self.slider.isdragging){
//        [UIView animateWithDuration:0.3 animations:^{
////            self.isShow                      = NO;
////            self.player.statusBarHidden      = NO;
//            self.playOrPauseBtn.alpha        = 0;
//            self.tenSecondBakcBtn.alpha      = 0;
//            self.tenSecondForwardBtn.alpha   = 0;
//            self.topToolView.alpha           = 0;
//            self.backBtn.alpha               = 0;
//            self.shareVideoBtn.alpha         = 0;
////            self.bottomToolView.alpha        = 0;
//            CGPoint topToolCenter = self.topToolView.center;
//            self.topToolView.center = CGPointMake(topToolCenter.x, -self.topToolView.zf_height*1.5);
////            self.bottomToolView.center = CGPointMake(topToolCenter.x, self.zf_height+self.topToolView.zf_height*0.5);
//    //        self.topToolView.zf_y            = -self.topToolView.zf_height;
//    //        self.bottomToolView.zf_y         = self.zf_height;
//            self.nextBtn.alpha = 0;
//            self.rateBtn.alpha = 0;
//            self.fullScreenBtn.alpha = 0;
//            self.backgroundColor             = [UIColor clearColor];
//        }];
    }else{
//        self.nextBtn.alpha = 1;
//        self.rateBtn.alpha = 1;
//        self.backBtn.alpha = 1;
//        self.fullScreenBtn.alpha = 1;
//        [self hideControlView];
        
        if (self.sliderChangedTapBlock != nil){
            self.sliderChangedTapBlock();
        }
//        [UIView animateWithDuration:0.3 animations:^{
////            self.isShow                      = NO;
////            self.player.statusBarHidden      = NO;
//            self.playOrPauseBtn.alpha        = 0;
//            self.tenSecondBakcBtn.alpha      = 0;
//            self.tenSecondForwardBtn.alpha   = 0;
//            self.topToolView.alpha           = 0;
//            self.backBtn.alpha               = 0;
//            self.shareVideoBtn.alpha         = 0;
////            self.bottomToolView.alpha        = 0;
//            CGPoint topToolCenter = self.topToolView.center;
//            self.topToolView.center = CGPointMake(topToolCenter.x, -self.topToolView.zf_height*1.5);
////            self.bottomToolView.center = CGPointMake(topToolCenter.x, self.zf_height+self.topToolView.zf_height*0.5);
//    //        self.topToolView.zf_y            = -self.topToolView.zf_height;
//    //        self.bottomToolView.zf_y         = self.zf_height;
//            self.nextBtn.alpha = 0;
//            self.rateBtn.alpha = 0;
//            self.fullScreenBtn.alpha = 0;
//            self.backgroundColor             = [UIColor clearColor];
//        }];
    }
}
#pragma mark - public method

/// 重置ControlView
- (void)resetControlView {
    self.slider.value                = 0;
    self.slider.bufferValue          = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.playOrPauseBtn.selected     = YES;
    self.titleLabel.text             = @"";
    self.topToolView.alpha           = 1;
    self.bottomToolView.alpha        = 1;
    self.isShow                      = NO;
}

- (void)showControlView {
    self.lockBtn.alpha               = 1;
    self.isShow                      = YES;
//    [self calculateSystemTime];
    self.lockBtn.zf_left             = iPhoneX ? 50: 18;
    self.player.statusBarHidden      = NO;
    self.backgroundColor             = [UIColor colorWithWhite:0 alpha:0.5];
    [UIView animateWithDuration:0.1 animations:^{
        if (self.player.isLockedScreen) {
            self.topToolView.zf_y        = -self.topToolView.zf_height;
            self.bottomToolView.zf_y     = self.zf_height;
        } else {
            self.topToolView.zf_y        = 0;
            self.bottomToolView.zf_y     = self.zf_height - self.bottomToolView.zf_height;
        }
        if (self.player.isLockedScreen) {
            self.topToolView.alpha       = 0;
            self.bottomToolView.alpha    = 0;
            self.playOrPauseBtn.alpha        = 0;
            self.tenSecondBakcBtn.alpha      = 0;
            self.tenSecondForwardBtn.alpha   = 0;
        } else {
            self.topToolView.alpha       = 1;
            self.bottomToolView.alpha    = 1;
            self.playOrPauseBtn.alpha        = 1;
            self.tenSecondBakcBtn.alpha      = 1;
            self.tenSecondForwardBtn.alpha   = 1;
        }
    }];
}

- (void)hideControlView {
    self.isShow                      = NO;
    self.lockBtn.zf_left             = iPhoneX ? -82: -47;
    self.player.statusBarHidden      = YES;
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.topToolView.zf_y            = -self.topToolView.zf_height;
        self.bottomToolView.zf_y         = self.zf_height;
        self.topToolView.alpha           = 0;
        self.bottomToolView.alpha        = 0;
        self.lockBtn.alpha               = 0;
        self.playOrPauseBtn.alpha        = 0;
        self.tenSecondBakcBtn.alpha      = 0;
        self.tenSecondForwardBtn.alpha   = 0;
        } completion:^(BOOL finished) {
            
        }];
//    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
////        self.backgroundColor         = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//        self.topToolView.zf_y            = -self.topToolView.zf_height;
//        self.bottomToolView.zf_y         = self.zf_height;
//        self.topToolView.alpha           = 0;
//        self.bottomToolView.alpha        = 0;
//        self.lockBtn.alpha               = 0;
//        self.playOrPauseBtn.alpha        = 0;
//        self.tenSecondBakcBtn.alpha      = 0;
//        self.tenSecondForwardBtn.alpha   = 0;
//    }];
}

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPlayerGestureType)type touch:(nonnull UITouch *)touch {
    CGRect sliderRect = [self.bottomToolView convertRect:self.slider.frame toView:self];
    if (CGRectContainsPoint(sliderRect, point)) {
        return NO;
    }
    if (self.player.isLockedScreen && type != ZFPlayerGestureTypeSingleTap) { // 锁定屏幕方向后只相应tap手势
        return NO;
    }
    return YES;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size {
//    self.lockBtn.hidden = self.player.orientationObserver.fullScreenMode == ZFFullScreenModePortrait;
    self.lockBtn.hidden = YES;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (!self.slider.isdragging) {
        NSString *currentTimeString = [ZFUtilities convertTimeSecond:currentTime];
//        self.currentTimeLabel.text = currentTimeString;
        NSString *totalTimeString = [ZFUtilities convertTimeSecond:totalTime];
        self.totalTimeLabel.text = totalTimeString;
        
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentTimeString,totalTimeString];
        self.slider.value = videoPlayer.progress;
    }
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    self.slider.bufferValue = videoPlayer.bufferProgress;
}

- (void)showTitle:(NSString *)title fullScreenMode:(ZFFullScreenMode)fullScreenMode {
    self.titleLabel.text = title;
    self.player.orientationObserver.fullScreenMode = fullScreenMode;
//    self.lockBtn.hidden = fullScreenMode == ZFFullScreenModePortrait;
    self.lockBtn.hidden = YES;
}

/// 调节播放进度slider和当前时间更新
- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString {
    self.slider.value = value;
//    self.currentTimeLabel.text = timeString;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",timeString,self.totalTimeLabel.text];
    self.slider.isdragging = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.slider.sliderBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

/// 滑杆结束滑动
- (void)sliderChangeEnded {
    self.slider.isdragging = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.slider.sliderBtn.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - getter
- (UILabel *)systemTimeLabel{
    if (!_systemTimeLabel) {
        _systemTimeLabel = [[UILabel alloc] init];
        _systemTimeLabel.textColor = [UIColor whiteColor];
        _systemTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _systemTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _systemTimeLabel;
}
- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
        UIImage *image = ZFPlayer_Image(@"ZFPlayer_top_shadow");
        _topToolView.layer.contents = (id)image.CGImage;
    }
    return _topToolView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_backBtn setImage:ZFPlayer_Image(@"ZFPlayer_back_full") forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"back_arrow_white_icon_max"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] init];
        UIImage *image = ZFPlayer_Image(@"ZFPlayer_bottom_shadow");
        _bottomToolView.layer.contents = (id)image.CGImage;
    }
    return _bottomToolView;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_playOrPauseBtn setImage:ZFPlayer_Image(@"ZFPlayer_play") forState:UIControlStateNormal];
//        [_playOrPauseBtn setImage:ZFPlayer_Image(@"ZFPlayer_pause") forState:UIControlStateSelected];
//        [_playOrPauseBtn setImage:ZFPlayer_Image(@"new_allPlay_54x54_") forState:UIControlStateNormal];
//        [_playOrPauseBtn setImage:ZFPlayer_Image(@"new_allPause_54x54_") forState:UIControlStateSelected];
        [_playOrPauseBtn setImage:ZFPlayer_Image(@"new_allPlay_70x70_") forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:ZFPlayer_Image(@"new_allPause_70x70_") forState:UIControlStateSelected];
    }
    return _playOrPauseBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _currentTimeLabel;
}

- (ZFSliderView *)slider {
    if (!_slider) {
        _slider = [[ZFSliderView alloc] init];
//        _slider.hidden = true;
        _slider.delegate = self;
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        _slider.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _slider.minimumTrackTintColor = [UIColor colorWithRed:0.0f green:122.0/255.0f blue:1.0f alpha:1];//[UIColor whiteColor];
        [_slider setThumbImage:ZFPlayer_Image(@"ZFPlayer_slider") forState:UIControlStateNormal];
        _slider.sliderHeight = 2;
    }
    return _slider;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.hidden = YES;
        
    }
    return _totalTimeLabel;
}

- (UIButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:ZFPlayer_Image(@"ZFPlayer_unlock-nor") forState:UIControlStateNormal];
        [_lockBtn setImage:ZFPlayer_Image(@"ZFPlayer_lock-nor") forState:UIControlStateSelected];
        _lockBtn.hidden = true;
    }
    return _lockBtn;
}

- (UIButton *)nextBtn{
    if (!_nextBtn){
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setImage:[UIImage imageNamed:@"tutorial_next_icon"] forState:UIControlStateNormal];
//        [_nextBtn setImage:ZFPlayer_Image(@"tutorial_next_icon") forState:UIControlStateNormal];
    }
    return _nextBtn;
}
- (UIButton *)rateBtn{
    if (!_rateBtn){
        _rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rateBtn setTitle:@"1.0x" forState:UIControlStateNormal];
        _rateBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    }
    return _rateBtn;
}
- (UIButton *)tenSecondBakcBtn{
    if (!_tenSecondBakcBtn){
        _tenSecondBakcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tenSecondBakcBtn setImage:[UIImage imageNamed:@"tutorial_back_10_seconds"] forState:UIControlStateNormal];
        [_tenSecondBakcBtn setImage:[UIImage imageNamed:@"tutorial_back_10_seconds_highlight"] forState:UIControlStateHighlighted];
        _tenSecondBakcBtn.layer.cornerRadius = 35;
        _tenSecondBakcBtn.clipsToBounds = true;
        _tenSecondBakcBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    }
    return _tenSecondBakcBtn;
}
- (UIButton *)tenSecondForwardBtn{
    if (!_tenSecondForwardBtn){
        _tenSecondForwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tenSecondForwardBtn setImage:[UIImage imageNamed:@"tutorial_forward_10_seconds"] forState:UIControlStateNormal];
        [_tenSecondForwardBtn setImage:[UIImage imageNamed:@"tutorial_forward_10_seconds_highlight"] forState:UIControlStateHighlighted];
        
        _tenSecondForwardBtn.layer.cornerRadius = 35;
        _tenSecondForwardBtn.clipsToBounds = true;
        _tenSecondForwardBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    }
    return _tenSecondForwardBtn;
}
- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_fullScreenBtn setImage:ZFPlayer_Image(@"ZFPlayer_fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"tutorial_mini_screen_icon"] forState:UIControlStateNormal];
    }
    return _fullScreenBtn;
}
- (UIButton *)shareVideoBtn{
    if (!_shareVideoBtn) {
        _shareVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareVideoBtn setImage:[UIImage imageNamed:@"tutorial_share_icon"] forState:UIControlStateNormal];
    }
    return _shareVideoBtn;
}
@end
