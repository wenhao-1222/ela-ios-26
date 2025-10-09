//
// Created by yiliang on 2023/6/20.
//

#ifndef AVPPRELOADCONFIG_H
#define AVPPRELOADCONFIG_H

#import <Foundation/Foundation.h>

OBJC_EXPORT
@interface AVPPreloadConfig : NSObject

/**
 @brief 预加载时长 默认1000毫秒，单位毫秒
 */
/****
 @brief The maximum preload duration. Default: 1000 milliseconds, Unit: millisecond.
 */
@property (nonatomic, assign) int preloadDuration;

@end


#endif //SOURCE_AVPPRELOADCONFIG_H
