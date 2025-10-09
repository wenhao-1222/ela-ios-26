//
// Created by yiliang on 2023/4/12.
//

#ifndef SOURCE_ALIVRPLAYERDELEGATE_H
#define SOURCE_ALIVRPLAYERDELEGATE_H

@protocol AliVRPlayerDelegate <NSObject>

@optional

/**
 @brief vr的运动传感器角度发生改变
 @param sensorAngleX 传感器的水平角度
 */
/****
 @brief vr's motion sensor changed
 @param sensorAngleX sensor horizontal angle
 */
- (void)motionSensorAngleChanged:(CGFloat)sensorAngleX;

/**
 @brief 手势角度发生改变
 @param gestureAngleX 手势的水平角度
 */
/****
 @brief gesture angle changed
 @param gestureAngleX gesture horizontal angle
 */
- (void)gestureAngleChanged:(CGFloat)gestureAngleX;

@end

#endif //SOURCE_ALIVRPLAYERDELEGATE_H
