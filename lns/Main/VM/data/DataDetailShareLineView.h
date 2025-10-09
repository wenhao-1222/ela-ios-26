//
//  DataDetailShareLineView.h
//  lns
//
//  Created by LNS2 on 2024/4/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataDetailShareLineView : UIView

@property (nonatomic,strong)NSArray *dataArray;

@property (nonatomic,strong)NSString *keyString;
@property (nonatomic,strong)NSString *unitString;

-(void)setDataArray:(NSArray * _Nonnull)dataArray andKey:(NSString*)key;
@end

NS_ASSUME_NONNULL_END
