//
//  RITLPhotosConfiguration.m
//  RITLPhotoDemo
//
//  Created by YueWen on 2018/5/17.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import "RITLPhotosConfiguration.h"


@implementation RITLPhotosConfiguration

- (instancetype)init
{
    if (self = [super init]) {

        self.maxCount = 9;
        self.videoMaxSeconds = 15 * 60;
        self.containVideo = false;
        self.hiddenGroupAllVideo = false;
        self.hiddenGroupWhenNoPhotos = false;
        self.onlyVideo = false;
    }
    
    return self;
}


+ (instancetype)defaultConfiguration
{
    static __weak RITLPhotosConfiguration *instance;
    RITLPhotosConfiguration *strongInstance = instance;
    @synchronized(self){
        if (strongInstance == nil) {
            strongInstance = self.new;
            instance = strongInstance;
        }
    }
    return strongInstance;
}


- (NSInteger)maxCount
{
    return MAX(0,_maxCount);
}


- (void)dealloc
{
    NSLog(@"[%@] is dealloc",NSStringFromClass(self.class));
}

@end
