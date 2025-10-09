//
//  TutorialVideoPortraitControlView.m
//  lns
//
//  Created by Elavatine on 2024/12/24.
//

#import "TutorialVideoPortraitControlView.h"
#import "UIView+ZFFrame.h"
#import "ZFUtilities.h"
#if __has_include(<ZFPlayer/ZFPlayer.h>)
#import <ZFPlayer/ZFPlayer.h>
#else
#import "ZFPlayer.h"
#endif

@interface TutorialVideoPortraitControlView () <ZFSliderViewDelegate>
/// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;
/// 底部工具栏
@property (nonatomic, strong) UIView *bottomToolView;
/// 顶部工具栏
@property (nonatomic, strong) UIView *topToolView;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 播放或暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseBtn;
/// 播放的当前时间
@property (nonatomic, strong) UILabel *currentTimeLabel;
/// 滑杆
@property (nonatomic, strong) ZFSliderView *slider;
/// 视频总时间
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UILabel *timeGapLabel;
/// 全屏按钮
@property (nonatomic, strong) UIButton *fullScreenBtn;
///下一个视频按钮
//@property (nonatomic, strong) UIButton *nextBtn;
///播放倍速按钮
//@property (nonatomic, strong) UIButton *rateBtn;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic,strong) UIView *shareTapView;

@property (nonatomic,strong) UIView *nextTapView;

@property (nonatomic,strong) UIView *rateTapView;

@property (nonatomic,strong) UIView *fullTapView;

@end

@implementation TutorialVideoPortraitControlView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 添加子控件
        [self addSubview:self.topToolView];
        [self addSubview:self.bottomToolView];
        [self addSubview:self.playOrPauseBtn];
        [self addSubview:self.tenSecondBakcBtn];
        [self addSubview:self.tenSecondForwardBtn];
        [self.topToolView addSubview:self.titleLabel];
        [self addSubview:self.backBtn];
        [self addSubview:self.shareVideoBtn];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.timeGapLabel];
        [self.bottomToolView addSubview:self.totalTimeLabel];
        [self.bottomToolView addSubview:self.fullScreenBtn];
        [self.bottomToolView addSubview:self.nextBtn];
        [self.bottomToolView addSubview:self.rateBtn];
        [self.topToolView addSubview:self.shareTapView];
        [self.bottomToolView addSubview:self.nextTapView];
        [self.bottomToolView addSubview:self.rateTapView];
        [self.bottomToolView addSubview:self.fullTapView];
        
        
        // 设置子控件的响应事件
        [self makeSubViewsAction];
        
        [self resetControlView];
        self.clipsToBounds = YES;
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
    CGFloat topSafe = self.isCalSafeArea ? insets.top : 0;
    CGFloat bottomSafe = self.isCalSafeArea ? insets.bottom : 0;
    
    min_x = 0;
    min_y = topSafe;
    min_w = min_view_w;
    min_h = 40;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 15;
    min_y = topSafe + 5;
    min_w = min_view_w - min_x - 15;
    min_h = 30;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
//    min_x = (iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 44: 15;
//    if (@available(iOS 13.0, *)) {
//        min_y = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 10 : (iPhoneX ? 40 : 20);
//    } else {
//        min_y = (iPhoneX && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? 10: (iPhoneX ? 40 : 20);
//    }
    min_x = 0;
    min_y = topSafe;
    min_w = 60;
    min_h = 60;
    self.backBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = min_view_w - 24 - 16;
    min_y = topSafe;
    min_w = 44;
    min_h = 44;
    self.shareVideoBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.shareVideoBtn.zf_centerY = self.backBtn.zf_centerY;
    
    self.shareTapView.frame = CGRectMake(0, 0, 60, 60);
    self.shareTapView.zf_centerX = self.shareVideoBtn.zf_centerX;
    self.shareTapView.zf_centerY = self.shareVideoBtn.zf_centerY;
    
//    UIEdgeInsets insets = UIEdgeInsetsZero;
//    if (@available(iOS 11.0, *)) {
//        insets = [UIApplication sharedApplication].delegate.window.safeAreaInsets;
//    }

    min_h = 66;
    min_x = 0;
    min_y = min_view_h - min_h- bottomSafe - 10;
    min_w = min_view_w;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = 54;
    min_h = min_w;
    self.playOrPauseBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.playOrPauseBtn.center = self.center;
    
    self.tenSecondBakcBtn.frame = CGRectMake(min_x - min_w*2, min_y, min_w, min_h);
    self.tenSecondBakcBtn.zf_centerY = self.playOrPauseBtn.zf_centerY;
    self.tenSecondBakcBtn.zf_centerX = self.playOrPauseBtn.zf_centerX - min_w*2;
    
    self.tenSecondForwardBtn.frame = CGRectMake(0, 0, min_w, min_h);
    self.tenSecondForwardBtn.zf_centerY = self.playOrPauseBtn.zf_centerY;
    self.tenSecondForwardBtn.zf_centerX = self.playOrPauseBtn.zf_centerX + min_w*2;
    
    min_x = min_margin;
    min_w = 140;//62;
    min_h = 28;
    min_y = 30;//(self.bottomToolView.zf_height - min_h)/2;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 36;
    min_h = min_w;
    min_x = self.bottomToolView.zf_width - min_w - min_margin;
    min_y = 0;
    self.fullScreenBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.fullScreenBtn.zf_centerY = 15;//self.currentTimeLabel.zf_centerY;
    
    self.fullTapView.frame = CGRectMake(min_x, min_y, 50, 50);
    self.fullTapView.zf_centerX = self.fullScreenBtn.zf_centerX;
    self.fullTapView.zf_centerY = self.fullScreenBtn.zf_centerY;
    
    min_w = 40;
    min_h = min_w;
    min_x = self.fullScreenBtn.zf_left - min_w*1.2 - 4;
    min_y = 0;
    self.rateBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.rateBtn.zf_centerY = self.fullScreenBtn.zf_centerY;
    
    self.rateTapView.frame = CGRectMake(min_x, min_y, 50, 50);
    self.rateTapView.zf_centerX = self.rateBtn.zf_centerX;
    self.rateTapView.zf_centerY = self.rateBtn.zf_centerY;
    min_w = 44;
    min_h = min_w;
    min_x = self.rateBtn.zf_left - min_w*1.2 - 4;
    min_y = 0;
    self.nextBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.nextBtn.zf_centerY = self.fullScreenBtn.zf_centerY;
    
    self.nextTapView.frame = CGRectMake(min_x, min_y, 50, 50);
    self.nextTapView.zf_centerX = self.nextBtn.zf_centerX;
    self.nextTapView.zf_centerY = self.nextBtn.zf_centerY;
    
    self.currentTimeLabel.zf_centerY = self.fullScreenBtn.zf_centerY;
    
    min_w = 62;
    min_h = 28;
    min_x = self.bottomToolView.zf_width - min_w - 4;
    min_y = 0;
    self.totalTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.totalTimeLabel.zf_centerY = self.currentTimeLabel.zf_centerY;
    self.totalTimeLabel.zf_x = self.currentTimeLabel.zf_right + 5;
    
    self.timeGapLabel.frame = CGRectMake(0, 0, 10, 28);
    self.timeGapLabel.zf_centerY = self.currentTimeLabel.zf_centerY;
    self.timeGapLabel.zf_centerX = self.currentTimeLabel.zf_right;
    
    min_x = 9;//self.currentTimeLabel.zf_x;//self.currentTimeLabel.zf_right + 4;
    min_y = 0;
    min_w = self.bottomToolView.zf_width - min_x*2;//self.fullScreenBtn.zf_right - self.currentTimeLabel.zf_left;//self.totalTimeLabel.zf_left - min_x - 4;
    min_h = 30;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
//    self.slider.zf_centerY = self.currentTimeLabel.zf_centerY;
//    self.slider.zf_top = self.fullScreenBtn.zf_bottom + 2;
    self.slider.zf_bottom = self.bottomToolView.zf_height - 5;
    
    if (!self.isShow) {
//        self.topToolView.zf_y = -self.topToolView.zf_height;
//        self.bottomToolView.zf_y = self.zf_height;
//        self.playOrPauseBtn.alpha = 0;
//        self.tenSecondBakcBtn.alpha = 0;
//        self.tenSecondForwardBtn.alpha = 0;
        self.topToolView.zf_y = topSafe - self.topToolView.zf_height;
            self.bottomToolView.zf_y = self.zf_height + bottomSafe-30;
            self.playOrPauseBtn.alpha = 0;
            self.tenSecondBakcBtn.alpha = 0;
            self.tenSecondForwardBtn.alpha = 0;
    } else {
//        self.topToolView.zf_y = 0;
//        self.bottomToolView.zf_y = self.zf_height - self.bottomToolView.zf_height-5;
        self.topToolView.zf_y = topSafe;
                self.bottomToolView.zf_y = self.zf_height - self.bottomToolView.zf_height - bottomSafe - 40;
        self.playOrPauseBtn.alpha = 1;
        self.tenSecondBakcBtn.alpha = 1;
        self.tenSecondForwardBtn.alpha = 1;
    }
}

- (void)makeSubViewsAction {
    [self.backBtn addTarget:self action:@selector(backBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareVideoBtn addTarget:self action:@selector(shareBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn addTarget:self action:@selector(playPauseButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rateBtn addTarget:self action:@selector(rateButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextBtn addTarget:self action:@selector(nextButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tenSecondBakcBtn addTarget:self action:@selector(tenSecondsBackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tenSecondForwardBtn addTarget:self action:@selector(tenSecondsForwardAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *shareGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareBtnClickAction:)];
    UITapGestureRecognizer *nextGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nextButtonClickAction:)];
    UITapGestureRecognizer *rateGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rateButtonClickAction:)];
    UITapGestureRecognizer *fullGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fullScreenButtonClickAction:)];
    
    [self.shareTapView addGestureRecognizer:shareGes];
    [self.nextTapView addGestureRecognizer:nextGes];
    [self.rateTapView addGestureRecognizer:rateGes];
    [self.fullTapView addGestureRecognizer:fullGes];
}

#pragma mark - action
- (void)shareBtnClickAction:(UIButton *)sender {
    if (self.shareBtnClickCallback) {
        self.shareBtnClickCallback();
    }
}


- (void)backBtnClickAction:(UIButton *)sender {
    if (self.backBtnClickCallback) {
        self.backBtnClickCallback();
    }
}

- (void)playPauseButtonClickAction:(UIButton *)sender {
    [self playOrPause];
}

- (void)fullScreenButtonClickAction:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"tutorialEnterFullScreen" object:nil];
    [self.player enterFullScreen:YES animated:YES];
}

- (void)rateButtonClickAction:(UIButton *)sender {
    if (self.rateTapBlock) self.rateTapBlock();
}
- (void)nextButtonClickAction:(UIButton *)sender {
//    if (self.nextVideoTapBlock) self.nextVideoTapBlock();
    NSLog(@"nextButtonClickAction -- nextTutorialVideo");
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
    if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlayStopped){
//        [self.player.currentPlayerManager replay];
        @weakify(self)
        [self.player seekToTime:0 completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                [self.player.currentPlayerManager play];
                self.player.currentPlayerManager.rate = 1.0;
                self.playOrPauseBtn.selected = YES;
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

#pragma mark - ZFSliderViewDelegate

- (void)sliderTouchBegan:(float)value {
    self.slider.isdragging = YES;
    [self controlStatusRefresh];
}

- (void)sliderTouchEnded:(float)value {
    if (self.player.totalTime > 0) {
        self.slider.isdragging = YES;
//        if (self.sliderValueChanging) self.sliderValueChanging(value, self.slider.isForward);
        @weakify(self)
        [self.player seekToTime:self.player.totalTime*value completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                if (self.seekToPlay) {
                    [self.player.currentPlayerManager play];
                }
                self.slider.isdragging = NO;
                [self controlStatusRefresh];
                if (self.sliderValueChanged) self.sliderValueChanged(value);
            }
        }];
        if (self.seekToPlay) {
            [self.player.currentPlayerManager play];
        }
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
//    self.currentTimeLabel.text = currentTimeString;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentTimeString,self.totalTimeLabel.text];
    if (self.sliderValueChanging) self.sliderValueChanging(value,self.slider.isForward);
}

- (void)sliderTapped:(float)value {
    [self sliderTouchEnded:value];
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
//    self.currentTimeLabel.text = currentTimeString;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentTimeString,self.totalTimeLabel.text];
}

-(void)updateUIForCourseCover{
    [self.topToolView setHidden:true];
    [self.bottomToolView setHidden:true];
    [self.tenSecondBakcBtn setHidden:true];
    [self.tenSecondForwardBtn setHidden:true];
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
////            self.shareTapView.hidden = YES;
////            self.nextTapView.hidden = YES;
////            self.rateTapView.hidden = YES;
////            self.fullTapView.hidden = YES;
//            self.backgroundColor             = [UIColor clearColor];
//        }];
    }else{
        if (self.sliderChangedTapBlock != nil){
            self.sliderChangedTapBlock();
        }
//        self.nextBtn.alpha = 1;
//        self.rateBtn.alpha = 1;
//        self.fullScreenBtn.alpha = 1;
////        self.shareTapView.hidden = NO;
////        self.nextTapView.hidden = NO;
////        self.rateTapView.hidden = NO;
////        self.fullTapView.hidden = NO;
//        [self hideControlView];
        
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
////            self.shareTapView.hidden = YES;
////            self.nextTapView.hidden = YES;
////            self.rateTapView.hidden = YES;
////            self.fullTapView.hidden = YES;
//            self.backgroundColor             = [UIColor clearColor];
//        }];
    }
}

#pragma mark - public method

/** 重置ControlView */
- (void)resetControlView {
    self.bottomToolView.alpha        = 1;
    self.slider.value                = 0;
    self.slider.bufferValue          = 0;
    self.currentTimeLabel.text       = @"00:00 / 00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.playOrPauseBtn.selected     = YES;
    self.titleLabel.text             = @"";
}

- (void)showControlView {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        insets = [UIApplication sharedApplication].delegate.window.safeAreaInsets;
    }
    self.backgroundColor             = [UIColor colorWithWhite:0 alpha:0.4];
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.topToolView.alpha           = 1;
        self.backBtn.alpha               = 1;
        self.shareVideoBtn.alpha         = 1;
        self.bottomToolView.alpha        = 1;
        self.isShow                      = YES;
        self.playOrPauseBtn.alpha        = 1;
        self.tenSecondBakcBtn.alpha      = 1;
        self.tenSecondForwardBtn.alpha   = 1;
        self.player.statusBarHidden      = NO;
//        self.shareTapView.hidden = NO;
//        self.nextTapView.hidden = NO;
//        self.rateTapView.hidden = NO;
//        self.fullTapView.hidden = NO;
        CGPoint topToolCenter = self.topToolView.center;
        
        self.topToolView.center = CGPointMake(topToolCenter.x, self.topToolView.zf_height*0.5);
        if (self.isCalSafeArea) {
            self.bottomToolView.center = CGPointMake(topToolCenter.x, self.zf_height-self.topToolView.zf_height*0.5-5-insets.bottom);
        }else{
            self.bottomToolView.center = CGPointMake(topToolCenter.x, self.zf_height-self.topToolView.zf_height*0.5-5);
        }
    } completion:^(BOOL finished) {
        
    }];
//    [UIView animateWithDuration:0.2 animations:^{
////        self.topToolView.zf_y            = 0;
////        self.bottomToolView.zf_y         = self.zf_height - self.bottomToolView.zf_height;
//        self.topToolView.alpha           = 1;
//        self.backBtn.alpha               = 1;
//        self.shareVideoBtn.alpha         = 1;
//        self.bottomToolView.alpha        = 1;
//        self.isShow                      = YES;
//        self.playOrPauseBtn.alpha        = 1;
//        self.tenSecondBakcBtn.alpha      = 1;
//        self.tenSecondForwardBtn.alpha   = 1;
//        self.player.statusBarHidden      = NO;
////        self.shareTapView.hidden = NO;
////        self.nextTapView.hidden = NO;
////        self.rateTapView.hidden = NO;
////        self.fullTapView.hidden = NO;
//        CGPoint topToolCenter = self.topToolView.center;
//        self.topToolView.center = CGPointMake(topToolCenter.x, self.topToolView.zf_height*0.5);
//        self.bottomToolView.center = CGPointMake(topToolCenter.x, self.zf_height-self.topToolView.zf_height*0.5-5);
//    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.backgroundColor             = [UIColor colorWithWhite:0 alpha:0.4];
//    });
}

- (void)hideControlView {
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.isShow                      = NO;
        self.player.statusBarHidden      = NO;
    //    self.backgroundColor             = [UIColor clearColor];
        self.playOrPauseBtn.alpha        = 0;
        self.tenSecondBakcBtn.alpha      = 0;
        self.tenSecondForwardBtn.alpha   = 0;
        self.topToolView.alpha           = 0;
        self.backBtn.alpha               = 0;
        self.shareVideoBtn.alpha         = 0;
        self.bottomToolView.alpha        = 0;
//        self.shareTapView.hidden = YES;
//        self.nextTapView.hidden = YES;
//        self.rateTapView.hidden = YES;
//        self.fullTapView.hidden = YES;
        CGPoint topToolCenter = self.topToolView.center;
        self.topToolView.center = CGPointMake(topToolCenter.x, -self.topToolView.zf_height*1.5);
        self.bottomToolView.center = CGPointMake(topToolCenter.x, self.zf_height+self.topToolView.zf_height*0.5);
//        self.backgroundColor             = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        
    }];
//    [UIView animateWithDuration:0.2 animations:^{
//        self.isShow                      = NO;
//        self.player.statusBarHidden      = NO;
//    //    self.backgroundColor             = [UIColor clearColor];
//        self.playOrPauseBtn.alpha        = 0;
//        self.tenSecondBakcBtn.alpha      = 0;
//        self.tenSecondForwardBtn.alpha   = 0;
//        self.topToolView.alpha           = 0;
//        self.backBtn.alpha               = 0;
//        self.shareVideoBtn.alpha         = 0;
//        self.bottomToolView.alpha        = 0;
////        self.shareTapView.hidden = YES;
////        self.nextTapView.hidden = YES;
////        self.rateTapView.hidden = YES;
////        self.fullTapView.hidden = YES;
//        CGPoint topToolCenter = self.topToolView.center;
//        self.topToolView.center = CGPointMake(topToolCenter.x, -self.topToolView.zf_height*1.5);
//        self.bottomToolView.center = CGPointMake(topToolCenter.x, self.zf_height+self.topToolView.zf_height*0.5);
//        self.backgroundColor             = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//    }];
}

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPlayerGestureType)type touch:(nonnull UITouch *)touch {
    CGRect sliderRect = [self.bottomToolView convertRect:self.slider.frame toView:self];
    if (CGRectContainsPoint(sliderRect, point)) {
        return NO;
    }
    return YES;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (!self.slider.isdragging) {
        NSString *currentTimeString = [ZFUtilities convertTimeSecond:currentTime];
        NSString *totalTimeString = [ZFUtilities convertTimeSecond:totalTime];
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentTimeString,totalTimeString];
        self.totalTimeLabel.text = totalTimeString;//[NSString stringWithFormat:@"/%@",totalTimeString];
        self.slider.value = videoPlayer.progress;
    }
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    self.slider.bufferValue = videoPlayer.bufferProgress;
}

- (void)showTitle:(NSString *)title fullScreenMode:(ZFFullScreenMode)fullScreenMode {
    self.titleLabel.text = title;
    self.player.orientationObserver.fullScreenMode = fullScreenMode;
}

/// 调节播放进度slider和当前时间更新
- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString {
    self.slider.value = value;
    self.currentTimeLabel.text = timeString;
    self.slider.isdragging = YES;
//    [self controlStatusRefresh];
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

- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
        UIImage *image = ZFPlayer_Image(@"ZFPlayer_top_shadow");
        _topToolView.layer.contents = (id)image.CGImage;
    }
    return _topToolView;
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
        [_playOrPauseBtn setImage:ZFPlayer_Image(@"new_allPlay_54x54_") forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:ZFPlayer_Image(@"new_allPause_54x54_") forState:UIControlStateSelected];
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
        _slider.delegate = self;
//        _slider.loadingTintColor = [UIColor colorWithRed:0.0f green:122.0/255.0f blue:1.0f alpha:1];
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        _slider.bufferTrackTintColor  = [UIColor clearColor];//[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _slider.minimumTrackTintColor = [UIColor colorWithRed:0.0f green:122.0/255.0f blue:1.0f alpha:1];//[UIColor whiteColor];
        [_slider setThumbImage:ZFPlayer_Image(@"ZFPlayer_slider") forState:UIControlStateNormal];
        _slider.sliderHeight = 2;
    }//007AFF
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

- (UILabel *)timeGapLabel{
    if (!_timeGapLabel) {
        _timeGapLabel = [[UILabel alloc]init];
        _timeGapLabel.textColor = [UIColor whiteColor];
        _timeGapLabel.text = @"/";
        _timeGapLabel.hidden = YES;
        _timeGapLabel.font = [UIFont systemFontOfSize:14];
    }
    return _timeGapLabel;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:ZFPlayer_Image(@"ZFPlayer_fullscreen") forState:UIControlStateNormal];
    }
    return _fullScreenBtn;
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
        _tenSecondBakcBtn.layer.cornerRadius = 27;
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
        
        _tenSecondForwardBtn.layer.cornerRadius = 27;
        _tenSecondForwardBtn.clipsToBounds = true;
        _tenSecondForwardBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    }
    return _tenSecondForwardBtn;
}
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_backBtn setImage:ZFPlayer_Image(@"ZFPlayer_back_full") forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"back_arrow_white_icon_max"] forState:UIControlStateNormal];
    }
    return _backBtn;
}
- (UIButton *)shareVideoBtn{
    if (!_shareVideoBtn) {
        _shareVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareVideoBtn setImage:[UIImage imageNamed:@"tutorial_share_icon"] forState:UIControlStateNormal];
    }
    return _shareVideoBtn;
}

- (UIView *)shareTapView{
    if (_shareTapView){
        _shareTapView = [[UIView alloc]init];
        _shareTapView.backgroundColor = [UIColor clearColor];
//        _shareTapView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.55];//[UIColor clearColor];
        [_shareTapView setUserInteractionEnabled:YES];
    }
    return _shareTapView;
}
- (UIView *)nextTapView{
    if (_nextTapView){
        _nextTapView = [[UIView alloc]init];
//        _nextTapView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.55];//[UIColor clearColor];
        _nextTapView.backgroundColor = [UIColor clearColor];
        [_nextTapView setUserInteractionEnabled:YES];
    }
    return _nextTapView;
}
- (UIView *)rateTapView{
    if (_rateTapView){
        _rateTapView = [[UIView alloc]init];
        _rateTapView.backgroundColor = [UIColor clearColor];
//        _rateTapView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.55];//[UIColor clearColor];
        [_rateTapView setUserInteractionEnabled:YES];
    }
    return _rateTapView;
}
- (UIView *)fullTapView{
    if (_fullTapView){
        _fullTapView = [[UIView alloc]init];
        _fullTapView.backgroundColor = [UIColor clearColor];
//        _fullTapView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.55];
        [_fullTapView setUserInteractionEnabled:YES];
    }
    return _fullTapView;
}
@end

