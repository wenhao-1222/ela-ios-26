//
//  DataMainLineView.h
//  lns
//
//  Created by LNS2 on 2024/6/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataMainLineView : UIView

@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic,strong)NSArray *dataSourceArray;
@property (nonatomic,assign)int minYXAisValue;
@property (nonatomic,assign)int maxYXAisValue;
@property (nonatomic,assign)int yXaisValueGap;
@property (nonatomic,assign)int yXaisNum;//Y轴数量
@property (nonatomic,assign)float chartGap;//图表纵轴  刻度间隙
@property (nonatomic,assign)float extendWidth;

@end

NS_ASSUME_NONNULL_END
