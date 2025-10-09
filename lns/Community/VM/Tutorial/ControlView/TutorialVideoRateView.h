//
//  TutorialVideoRateView.h
//  lns
//
//  Created by Elavatine on 2024/12/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TutorialVideoRateView : UIView

//选择倍速回调
@property (nonatomic, copy, nullable) void(^rateValueChanged)(NSString* value);

-(void)resetUI;

-(void)setRate:(NSString*)rate;
@end

NS_ASSUME_NONNULL_END
