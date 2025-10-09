//
//  DataDetailShareLineView.m
//  lns
//
//  Created by LNS2 on 2024/4/19.
//

#import "DataDetailShareLineView.h"
#import "lns-Swift.h"

#define COLOR_RGBA(r, g, b, a) ([UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a])

@interface DataDetailShareLineView()
{
    float minValue;
    float maxValue;
    int minIndex;
    int maxIndex;
    
    int yMinValue;//y轴最小值
    int yMaxValue;//y轴最大值
    
    NSString *minValueTime;//最大值的日期
    NSString *maxValueTime;//最小值的日期
    
    
    int valueGap;//Y轴label的数字  差额
    CGFloat xGap;//每两个点之间的x间距
    
    float chartHeight;//图表高度
    float chartWidth;
    float topGap;//图表距离顶部的间隙
    float chartGap;//图表纵轴  刻度间隙
}
@end

@implementation DataDetailShareLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        chartWidth = cy_ScreenW-[self kfitWidth:135];
        topGap = [self kfitWidth:(21)];
        chartHeight = frame.size.height - topGap - [self kfitWidth:1];
        chartGap = chartHeight / 5;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setDataArray:(NSArray * _Nonnull)dataArray andKey:(NSString*)key{
    maxValue = 0;
    self.keyString = key;
    self.dataArray = dataArray;
    
//    xGap = [self kfitWidth:240]/(dataArray.count - 1);
    xGap = chartWidth/(dataArray.count - 1);
    
    //取最大最小值
    for (int i = 0; i < self.dataArray.count; i ++) {
        NSDictionary *dict = self.dataArray[i];
        NSLog(@"%@",dict.description);
        
        NSMutableString *valueStr = [NSMutableString stringWithString:[dict valueForKey:self.keyString]];
        NSString *valueString = [valueStr stringByReplacingOccurrencesOfString:@"," withString:@"."];
        float value = [valueString floatValue];
        if (i == 0){
            minValue = [[dict valueForKey:self.keyString] floatValue];
            minIndex = i;
            minValueTime = [dict valueForKey:@"ctime"];
            
            maxValue = [[dict valueForKey:self.keyString] floatValue];
            maxIndex = i;
            maxValueTime = [dict valueForKey:@"ctime"];
        }else if (i == self.dataArray.count - 1){
            maxValueTime = [dict valueForKey:@"ctime"];
        }
        
        if (minValue > value){
            minValue = [[dict valueForKey:self.keyString] floatValue];
            minIndex = i;
//            minValueTime = [dict valueForKey:@"ctime"];
        }
        if (maxValue <= value){
            maxValue = [[dict valueForKey:self.keyString] floatValue];
            maxIndex = i;
//            maxValueTime = [dict valueForKey:@"ctime"];
        }
        
    }
    
    if ((maxValue - minValue) <= 4) {
        valueGap = 1;
        if ((maxValue - minValue) == 4) {
            yMinValue = minValue;
        }else{
            yMinValue = minValue - 1;
        }
    }else{
        valueGap = (maxValue - minValue)/3+1;
        yMinValue = minValue - valueGap;
        
    }
    
    if (yMinValue < 0) {
        yMinValue = 0;
    }
    yMaxValue = yMinValue + valueGap * 4;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    [self drawLine];
    [self drawArea];
}

-(void)drawArea{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat leftGap = [self kfitWidth:48];
    
    CGPoint oldPoint = CGPointMake(leftGap, self.frame.size.height - [self kfitWidth:1]);
    
    int valueArea = yMaxValue - yMinValue;
    CGFloat imgWidth = [self kfitWidth:36];
    
    if (self.dataArray.count == 1){
        NSDictionary *dict = self.dataArray[0];
        NSMutableString *valueStr = [NSMutableString stringWithString:[dict valueForKey:self.keyString]];
        NSString *valueString = [valueStr stringByReplacingOccurrencesOfString:@"," withString:@"."];
        float value = [valueString floatValue];
        
        CGFloat originY = topGap + chartGap + ((yMaxValue - value)*0.1)/(valueArea*0.1)*(chartHeight-chartGap);
        oldPoint = CGPointMake([self kfitWidth:120], originY);
        CGPoint currentPoint = CGPointMake(leftGap+(self.frame.size.width-[self kfitWidth:(24)])*0.5, originY);
        
        oldPoint = currentPoint;
        
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake([self kfitWidth:40]+(self.frame.size.width-[self kfitWidth:(24)] - [self kfitWidth:40])*0.5-imgWidth*0.5, originY-imgWidth*0.5, imgWidth, imgWidth)];
        img.image = [UIImage imageNamed:@"data_share_highlight_circle"];
        [self addSubview:img];
        
//        DataDetailSharePopView *vm = [[DataDetailSharePopView alloc]initWithFrame:CGRectMake([self kfitWidth:40]+(self.frame.size.width-[self kfitWidth:(24)]-[self kfitWidth:40])*0.5 - [self kfitWidth:100], originY+[self kfitWidth:5], 0, 0 )];
//        [self addSubview:vm];
//        [vm updateUIWithNumber:valueStr unit:self.unitString  time:minValueTime fatherViewWidth:[self kfitWidth:(256)] isMax:false circlePoint:CGPointMake([self kfitWidth:40]+(self.frame.size.width-[self kfitWidth:(24)]-[self kfitWidth:40])*0.5, originY)];
        
        DataDetailSharePopView *maxvm = [[DataDetailSharePopView alloc]initWithFrame:CGRectMake([self kfitWidth:40]+(self.frame.size.width-[self kfitWidth:(24)] - [self kfitWidth:40])*0.5, originY, 0, 0 )];
        [self addSubview:maxvm];
        [maxvm updateUIWithNumber:valueStr unit:self.unitString time:maxValueTime fatherViewWidth:[self kfitWidth:(256)] isMax:true circlePoint:CGPointMake([self kfitWidth:40]+(self.frame.size.width-[self kfitWidth:(24)]-[self kfitWidth:40])*0.5, originY)];
        
        CGPathRelease(path);
        
        return;
    }
    DataDetailSharePopView *firstPopView = [[DataDetailSharePopView alloc]init];
    
    for (int i = 0 ; i < self.dataArray.count; i ++) {
        NSDictionary *dict = self.dataArray[i];
        NSMutableString *valueStr = [NSMutableString stringWithString:[dict valueForKey:self.keyString]];
        NSString *valueString = [valueStr stringByReplacingOccurrencesOfString:@"," withString:@"."];
        float value = [valueString floatValue];
//        float value = [[dict valueForKey:self.keyString] floatValue];
        
        CGFloat originY = topGap + chartGap + ((yMaxValue - value)*0.1)/(valueArea*0.1)*(chartHeight-chartGap);
//        NSLog(@"originY:%.2f    ---  %.1f",originY,value);
        if (i == 0) {
            oldPoint = CGPointMake(leftGap, originY);
            CGPathMoveToPoint(path, NULL, oldPoint.x, oldPoint.y);
        }else{
            CGPoint currentPoint = CGPointMake(leftGap+xGap*i, originY);
            
            CGPathAddLineToPoint(path, NULL, currentPoint.x, currentPoint.y);
            
            [self drawLine:context
                startPoint:oldPoint
                  endPoint:currentPoint
                 lineColor:[UIColor whiteColor]
                 lineWidth:2];
            
            oldPoint = currentPoint;
        }
        
        if (i == 0) {
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(leftGap+xGap*i-imgWidth*0.5, originY-imgWidth*0.5, imgWidth, imgWidth)];
            img.image = [UIImage imageNamed:@"data_share_highlight_circle"];
            [self addSubview:img];
            
            DataDetailSharePopView *vm = [[DataDetailSharePopView alloc]initWithFrame:CGRectMake(leftGap+xGap*i - [self kfitWidth:100], originY+[self kfitWidth:5], 0, 0 )];
            [self addSubview:vm];
            [vm updateUIWithNumber:valueStr unit:self.unitString time:minValueTime fatherViewWidth:[self kfitWidth:(256)] isMax:false circlePoint:CGPointMake(leftGap+xGap*i, originY)];
//            [vm updateUIWithNumber:[NSString stringWithFormat:@"%.1f",value] unit:self.unitString time:minValueTime fatherViewWidth:[self kfitWidth:(256)] isMax:false circlePoint:CGPointMake(leftGap+xGap*i, originY)];
            firstPopView = vm;
        }else if (i == self.dataArray.count - 1){
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(leftGap+xGap*i-imgWidth*0.5, originY-imgWidth*0.5, imgWidth, imgWidth)];
            img.image = [UIImage imageNamed:@"data_share_highlight_circle"];
            [self addSubview:img];
            
            DataDetailSharePopView *vm = [[DataDetailSharePopView alloc]initWithFrame:CGRectMake(leftGap+xGap*i - [self kfitWidth:100], originY+[self kfitWidth:5], 0, 0 )];
            [self addSubview:vm];
            [vm updateUIWithNumber:valueStr unit:self.unitString time:maxValueTime fatherViewWidth:[self kfitWidth:(256)] isMax:false circlePoint:CGPointMake(leftGap+xGap*i, originY)];
        }else{
            if (i == minIndex) {
                UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(leftGap+xGap*i-imgWidth*0.5, originY-imgWidth*0.5, imgWidth, imgWidth)];
                img.image = [UIImage imageNamed:@"data_share_highlight_circle"];
                [self insertSubview:img belowSubview:firstPopView];
                
    //            DataDetailSharePopView *vm = [[DataDetailSharePopView alloc]initWithFrame:CGRectMake(leftGap+xGap*i - [self kfitWidth:100], originY+[self kfitWidth:5], 0, 0 )];
    //            [self addSubview:vm];
    //            [vm updateUIWithNumber:[NSString stringWithFormat:@"%.1f",minValue] unit:self.unitString time:minValueTime fatherViewWidth:[self kfitWidth:(256)] isMax:false circlePoint:CGPointMake(leftGap+xGap*i, originY)];
            }
            if (i == maxIndex){
                UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(leftGap+xGap*i-imgWidth*0.5, originY-imgWidth*0.5, imgWidth, imgWidth)];
                img.image = [UIImage imageNamed:@"data_share_highlight_circle"];
//                [self addSubview:img];
                [self insertSubview:img belowSubview:firstPopView];
    //            DataDetailSharePopView *vm = [[DataDetailSharePopView alloc]initWithFrame:CGRectMake(leftGap+xGap*i, originY, 0, 0 )];
    //            [self addSubview:vm];
    //            [vm updateUIWithNumber:[NSString stringWithFormat:@"%.1f",maxValue] unit:self.unitString time:maxValueTime fatherViewWidth:[self kfitWidth:(256)] isMax:true circlePoint:CGPointMake(leftGap+xGap*i, originY)];
            }
        }
    }
    
    CGPathAddLineToPoint(path, NULL, oldPoint.x, self.frame.size.height - [self kfitWidth:1]);
    CGPathAddLineToPoint(path, NULL, leftGap, self.frame.size.height - [self kfitWidth:1]);
    CGPathCloseSubpath(path);
    //绘制渐变
    [self drawLinearGradient:context path:path startColor:COLOR_RGBA(0, 92, 191, 1.0).CGColor endColor:COLOR_RGBA(0, 122, 255, 0).CGColor];
    //注意释放CGMutablePathRef
    CGPathRelease(path);
}

-(void)drawLine{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (int i = 1 ; i < 6 ; i ++){
        CGFloat originY = topGap + chartGap * i;
        
        [self drawLine:context
            startPoint:CGPointMake([self kfitWidth:40], originY)
              endPoint:CGPointMake(self.frame.size.width-[self kfitWidth:(24)], originY)
             lineColor:COLOR_RGBA(255, 255, 255, 0.25)
             lineWidth:1];
        
        NSString *valueString = [NSString stringWithFormat:@"%d",yMinValue+(i-1)*valueGap];
        CGFloat dataWidth = [[NSString stringWithFormat:@"%@", valueString] sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10],NSForegroundColorAttributeName:[UIColor whiteColor]}].width;
        
        [valueString drawInRect:CGRectMake(36-dataWidth, chartHeight-chartGap*(i-1)-10+20, dataWidth, 12) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10],NSForegroundColorAttributeName:COLOR_RGBA(255, 255, 255, 0.25)}];
        
    }
}


- (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width {
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Linecolorspace1);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
//    CGContextAddCurveToPoint(context, (startPoint.x+endPoint.x)/2, startPoint.y, (startPoint.x+endPoint.x)/2, endPoint.y, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(Linecolorspace1);

}
- (void)drawDashLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width {
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetLineWidth(context, width);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGFloat arr[] = {3,1};
    CGContextSetLineDash(context, 0, arr, 2);
    CGContextDrawPath(context, kCGPathStroke);
    
}

- (void)drawLinearGradient:(CGContextRef)context path:(CGPathRef)path startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor{

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGRect pathRect = CGPathGetBoundingBox(path);
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

-(CGFloat)kfitWidth:(CGFloat)width{
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        return width* MIN([UIScreen mainScreen].bounds.size.width/375, [UIScreen mainScreen].bounds.size.height/812);//[UIScreen mainScreen].bounds.size.width/375;
    }else{
        return width*[UIScreen mainScreen].bounds.size.width/375;
    }
}

@end
