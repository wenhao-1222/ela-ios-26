//
//  DataMainLineView.m
//  lns
//
//  Created by LNS2 on 2024/6/10.
//

#import "DataMainLineView.h"

#define COLOR_RGBA(r, g, b, a) ([UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a])

@interface DataMainLineView()
{
    float minValue;
    float maxValue;
    
    CGFloat xGap;//每两个点之间的x间距
    CGFloat leftGap;
    CGFloat chartWidth;
    
    float chartHeight;//图表高度
    float topGap;//图表距离顶部的间隙
    
    NSArray *colors;
    NSMutableArray *xLabelCenter;//x轴坐标
    
    int valueNum;
}
@end
@implementation DataMainLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        self.yXaisNum = 5;
        minValue = 0;
        maxValue = 0;
        leftGap = 20;
        xLabelCenter = [[NSMutableArray alloc]init];
        chartWidth = frame.size.width;
        xGap = (frame.size.width - 40)/4;
        topGap = [self kfitWidth:(0)];
        chartHeight = frame.size.height - topGap - [self kfitWidth:36];
        self.chartGap = [self kfitWidth:(40)];//chartHeight / 5;
        colors = [NSArray arrayWithObjects:COLOR_RGBA(245, 175, 23, 1),
                  COLOR_RGBA(2, 148, 199, 1),
                  COLOR_RGBA(184, 51, 140, 1),nil];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setDataSourceArray:(NSArray *)dataSourceArray{
    _dataSourceArray = dataSourceArray;
    CGRect selfFrame = self.frame;
    if (dataSourceArray.count < 5){
        xGap = (chartWidth - 40)/(dataSourceArray.count-1);
        self.frame = CGRectMake(selfFrame.origin.x, selfFrame.origin.y, chartWidth, selfFrame.size.height);
    }else{
        xGap = (chartWidth - 40)/4;
        self.frame = CGRectMake(selfFrame.origin.x, selfFrame.origin.y, xGap*(self.dataSourceArray.count-1)+40, selfFrame.size.height);
    }
    
}

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self dealDataSource];
    if (self.dataArray.count == 1){
        [self calculateYValueGapForWeight];
//        colors = [NSArray arrayWithObjects:COLOR_RGBA(0, 128, 83, 1),nil];
        colors = [NSArray arrayWithObjects:COLOR_RGBA(0, 184, 83, 1),nil];
    }else{
        [self calculateYValueGap];
        colors = [NSArray arrayWithObjects:COLOR_RGBA(255, 219, 37, 1),
                  COLOR_RGBA(56, 151, 255, 1),
                  COLOR_RGBA(196, 54, 149, 1),nil];
//        colors = [NSArray arrayWithObjects:COLOR_RGBA(245, 175, 23, 1),
//                  COLOR_RGBA(2, 148, 199, 1),
//                  COLOR_RGBA(184, 51, 140, 1),nil];
    }
    
    if (valueNum == 0){
        self.yXaisValueGap = 50;
        self.minYXAisValue = 0;
        self.maxYXAisValue = 100;
        if (self.dataArray.count == 1){
            self.chartGap = [self kfitWidth:(60)];
        }else{
            self.chartGap = [self kfitWidth:(80)];
        }
    }else{
        self.chartGap = [self kfitWidth:(40)];
    }
    
    [self setNeedsDisplay];
}

-(void)dealDataSource{
    bool firstValue = true;
    valueNum = 0;
    for (int i = 0; i < self.dataArray.count; i++) {
        NSArray *dataArr = self.dataArray[i];
        for (int j = 0; j < dataArr.count; j ++) {
            NSDictionary *valueDict = [dataArr objectAtIndex:j];
            NSNumber *number = [valueDict valueForKey:@"value"];
            float valueFloat = [number floatValue];
            valueNum = valueNum + 1;
            if (firstValue == true){
                minValue = valueFloat;
                maxValue = valueFloat;
                firstValue = false;
                continue;
            }
            
            if (minValue > valueFloat){
                minValue = valueFloat;
            }
            if (maxValue < valueFloat){
                maxValue = valueFloat;
            }
        }
    }
    self.minYXAisValue = floorf(minValue);//向下取整
    if (firstValue == true){
        self.maxYXAisValue = 100;//向上取整
    }else{
        self.maxYXAisValue = ceilf(maxValue);//向上取整
    }
}

//MARK: 确定Y轴的间隙、最大最小值   身体维度
-(void)calculateYValueGap{
    int minYInt = self.minYXAisValue/10;
    minYInt = minYInt * 10;
    
    if (minYInt <= 0){
        minYInt = 0;
    }
    
    int maxYInt = self.maxYXAisValue/10;
    maxYInt = maxYInt*10+10;
    
    int unitGap = 10;
    if ((maxYInt - minYInt) < (self.yXaisNum-1) * 10){
        unitGap = 10;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 10){
        unitGap = 20;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 20){
        unitGap = 20;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 20){
        unitGap = 30;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 30){
        unitGap = 30;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 30){
        unitGap = 40;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 40){
        unitGap = 40;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 40){
        unitGap = 50;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 50){
        unitGap = 50;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 50){
        unitGap = 100;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 100){
        unitGap = 100;
    }else {
        unitGap = 200;
    }
    self.yXaisValueGap = unitGap;
    self.minYXAisValue = minYInt;
    self.maxYXAisValue = minYInt+(self.yXaisNum-1)*self.yXaisValueGap;
}

//MARK: 确定Y轴的间隙、最大最小值  体重数据
-(void)calculateYValueGapForWeight{
    int minYInt = floorf(self.minYXAisValue) - 1;
    
    if (minYInt <= 0){
        minYInt = 0;
    }
    
    int maxYInt = ceilf(self.maxYXAisValue);
    
    if ((maxYInt - minYInt) > 10) {
        minYInt = minYInt/10;
        minYInt = minYInt * 10;
    }
    
    int unitGap = 1;
    if ((maxYInt - minYInt) < (self.yXaisNum-1) * 1){
        unitGap = 1;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 1){
        unitGap = 2;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 2){
        unitGap = 2;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 2){
        unitGap = 3;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 5){
        unitGap = 5;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 5){
        unitGap = 10;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 10){
        unitGap = 10;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 10){
        unitGap = 20;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 20){
        unitGap = 20;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 20){
        unitGap = 50;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 50){
        unitGap = 50;
    }else if ((maxYInt - minYInt) == (self.yXaisNum-1) * 50){
        unitGap = 100;
    }else if ((maxYInt - minYInt) < (self.yXaisNum-1) * 100){
        unitGap = 100;
    }else {
        unitGap = 200;
    }
    self.yXaisValueGap = unitGap;
    self.minYXAisValue = minYInt;
    self.maxYXAisValue = minYInt+(self.yXaisNum-1)*self.yXaisValueGap;
}
- (void)drawRect:(CGRect)rect{
    [self drawLine];
    if (valueNum > 0){
        [self drawXAisLabel];
        [self drawData];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"lineChartViewComplete" object:nil];
}

-(void)drawData{
    for (int i = 0; i < self.dataArray.count; i++) {
        UIColor *color = colors[i];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        NSArray *dataArr = self.dataArray[i];
        CGPoint oldPoint = CGPointMake(0, 0);
        for (int j = 0; j < dataArr.count; j ++) {
            NSDictionary *valueDict = [dataArr objectAtIndex:j];
            NSNumber *number = [valueDict valueForKey:@"value"];
            float valueFloat = [number floatValue];
            
            NSNumber *xIndex = [valueDict valueForKey:@"xIndex"];
            int xInt = [xIndex intValue];
            
            NSNumber *xCenter = [xLabelCenter objectAtIndex:xInt];
            CGFloat originX = [xCenter floatValue];//leftGap +xGap*xInt;
            CGFloat originY = (self.maxYXAisValue - valueFloat)/(self.maxYXAisValue-self.minYXAisValue)*self.chartGap*(self.yXaisNum-1);
            
            if (j == 0 ){
                oldPoint = CGPointMake(originX, originY);
                CGContextMoveToPoint(context, originX, originY);
            }else{
                [self drawLine:context
                    startPoint:oldPoint
                      endPoint:CGPointMake(originX, originY)
                     lineColor:color
                     lineWidth:2];
                oldPoint = CGPointMake(originX, originY);
            }
            if (j == dataArr.count - 1){
                CGContextAddArc(context, originX, originY, 2, 0, 2*M_PI, 0);
                CGContextSetFillColor(context, CGColorGetComponents(color.CGColor));
                CGContextFillPath(context);
            }
        }
    }
}
-(void)drawXAisLabel{
    [xLabelCenter removeAllObjects];
    CGFloat originY = self.frame.size.height - [self kfitWidth:32];
    if (self.dataSourceArray.count > 1){
        for (int i = 0 ; i < self.dataSourceArray.count; i++) {
            CGFloat originX = leftGap +xGap*i;
            NSString *valueString = [NSString stringWithFormat:@"%@",[self.dataSourceArray objectAtIndex:i]];
            CGFloat dataWidth = [[NSString stringWithFormat:@"%@", valueString] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular],NSForegroundColorAttributeName:[UIColor whiteColor]}].width;
            
            [valueString drawInRect:CGRectMake(originX-dataWidth*0.5, originY, dataWidth, 20) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular],NSForegroundColorAttributeName:COLOR_RGBA(0, 0, 0, 0.65)}];
            [xLabelCenter addObject:@(originX)];
        }
    }else if (self.dataSourceArray.count == 1){
        NSString *valueString = [NSString stringWithFormat:@"%@",[self.dataSourceArray objectAtIndex:0]];
        CGFloat dataWidth = [[NSString stringWithFormat:@"%@", valueString] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular],NSForegroundColorAttributeName:[UIColor whiteColor]}].width;
        
        [valueString drawInRect:CGRectMake(self.frame.size.width*0.5-dataWidth*0.5, originY, dataWidth, 20) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular],NSForegroundColorAttributeName:COLOR_RGBA(0, 0, 0, 0.65)}];
        [xLabelCenter addObject:@(self.frame.size.width*0.5-dataWidth*0.5+10)];
    }
}
-(void)drawLine{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    for (int i = 0 ; i < self.yXaisNum ; i ++){
//        CGFloat originY = topGap + self.chartGap * i;
//        
//        [self drawLine:context
//            startPoint:CGPointMake(0, originY)
//              endPoint:CGPointMake(self.frame.size.width, originY)
//             lineColor:COLOR_RGBA(0, 0, 0, 0.15)
//             lineWidth:1];
////        NSString *valueString = [NSString stringWithFormat:@"%d",maxYXAisValue-yXaisValueGap*i];
////        CGFloat dataWidth = [[NSString stringWithFormat:@"%@", valueString] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular],NSForegroundColorAttributeName:[UIColor whiteColor]}].width;
////        
////        [valueString drawInRect:CGRectMake(36-dataWidth, originY-12, dataWidth, 12) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular],NSForegroundColorAttributeName:COLOR_RGBA(0, 0, 0, 0.65)}];
//    }
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
