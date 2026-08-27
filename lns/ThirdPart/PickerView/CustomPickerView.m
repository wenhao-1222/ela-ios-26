//
//  CustomPickerView.m
//  eCamera
//
//  Created by wsg on 2017/4/18.
//  Copyright © 2017年 wsg. All rights reserved.
//

#import "CustomPickerView.h"

#define itemHeight 50
@interface CustomPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@end

@implementation CustomPickerView{
    UIPickerView *picker;
    NSArray *dataArray;
    UIView *bgV;
    UIView *bgThemeView;
    UILabel *unitLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfRows = 20;
        [self performSelector:@selector(initPickerView)];
    }
    return self;
}
/**
 *  初始化 选择器
 */
-(void)initPickerView{
    dataArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",
                  @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20",
                  @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30",
                  @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40",
                  @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50",
                  @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60"];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(-M_PI/2);
    rotate = CGAffineTransformScale(rotate, 0.1, 1);
    //旋转 -π/2角度
    self.clipsToBounds = YES;
    picker = [[UIPickerView alloc]initWithFrame:CGRectZero];
    
    [picker setTag: 10086];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = false;
    [picker selectRow:3 inComponent:0 animated:false];
    [picker setBackgroundColor:[UIColor clearColor]];
    
    bgV = [[UIView alloc]initWithFrame:self.bounds];
    
    bgThemeView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, itemHeight, self.frame.size.height-10)];
    bgThemeView.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1];
    bgThemeView.layer.cornerRadius = 4;
    bgThemeView.clipsToBounds = true;
    [bgV addSubview:bgThemeView];
    
    [bgV addSubview:picker];
    bgV.backgroundColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.5 alpha:0.08];
    bgV.layer.cornerRadius = 8;
    bgV.clipsToBounds = true;
    
    [self addSubview:bgV];
    
    [picker setTransform:rotate];
    
    unitLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    unitLabel.text = @"周";
    unitLabel.textAlignment = NSTextAlignmentCenter;
    unitLabel.textColor = [UIColor whiteColor];
    unitLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    [bgV addSubview:unitLabel];
    unitLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 22);
    bgThemeView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!picker || !bgV || !bgThemeView || !unitLabel) {
        return;
    }
    bgV.frame = self.bounds;
    bgThemeView.frame = CGRectMake(0, 5, itemHeight, self.bounds.size.height - 10);
    bgThemeView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    picker.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width - 10);
    picker.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    unitLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 + 22);

    NSInteger selectedRow = MIN(MAX(self.scrollToIndex, 0), self.numberOfRows - 1);
    [picker selectRow:selectedRow inComponent:0 animated:NO];
}

- (void)setNumberOfRows:(NSInteger)numberOfRows {
    _numberOfRows = MAX(1, numberOfRows);
    if (picker) {
        [picker reloadAllComponents];
    }
}

/**
 *  pickerView代理方法
 *
 *  @param component
 *
 *  @return pickerView有多少个元素
 */
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.numberOfRows;
}
/**
 *  pickerView代理方法
 *
 *  @return pickerView 有多少列
 */
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
/**
 *  pickerView代理方法
 *
 *  @param row
 *  @param component
 *  @param view
 *
 *  @return 每个 item 显示的 视图
 */

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    if ([self.delegate performSelector:@selector(pickerViewBeginScroll)]) {
        [self.delegate pickerViewBeginScroll];
    }
    CGAffineTransform rotateItem = CGAffineTransformMakeRotation(M_PI/2);
    rotateItem = CGAffineTransformScale(rotateItem, 1, 10);
    
//    CGFloat width = self.frame.size.height;
    
    UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, itemHeight, 64)];
    itemView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.45 green:0.45 blue:0.5 alpha:0.08];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, itemHeight, 64)];
    
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = [NSString stringWithFormat:@"%ld",(long)row+1];
//    lab.font = [UIFont systemFontOfSize:28 weight:UIFontWeightMedium];
    lab.font = [UIFont fontWithName:@"D-DIN-PRO-Medium" size:28];
    lab.adjustsFontSizeToFitWidth = true;
    lab.numberOfLines = 2;
    lab.lineBreakMode = NSLineBreakByWordWrapping;
//
//    int index = [picker selectedRowInComponent:component];
//    
//    if (row == index) {
//        lab.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1];
//        lab.frame = CGRectMake(0, 0, width-40, 30);
//    } else {
//        lab.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85];
//        lab.frame = CGRectMake(0, 0, width-40, 50);
//    }
//    lab.tag = 901;
    [itemView addSubview:lab];
    itemView.transform = rotateItem;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *view = (UIView *)[pickerView viewForRow:row forComponent:component];
        NSArray *views = view.subviews;
        view.backgroundColor = [UIColor clearColor];
        // 当前选中的 label
        UILabel *selectLabel = (UILabel *)views.firstObject;
//        UILabel *selectLabel = (UILabel *)[pickerView viewForRow:row forComponent:component];
        if (selectLabel) {
            selectLabel.textColor = [UIColor whiteColor];
        }
    });
    return itemView;
}

/**
 *  pickerVie代理方法
 *
 *  @param component
 *
 *  @return 每个item的宽度
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component __TVOS_PROHIBITED{
    return self.frame.size.width;
}
/**
 *  pickerView代理方法
 *
 *  @param component
 *
 *  @return 每个item的高度
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
//    return 48;
    return itemHeight;
}


/**
 *  pickerView滑动到指定位置
 *
 *  @param scrollToIndex 指定位置
 */
-(void)scrollToIndex:(NSInteger)scrollToIndex{
    _scrollToIndex = MIN(MAX(scrollToIndex, 0), self.numberOfRows - 1);
    if (picker) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [picker selectRow:_scrollToIndex inComponent:0 animated:NO];
    }
}
/**
 *  查询当前选择元素Getter方法
 *
 *  @return pickerView当前选择元素 （index：选择位置  name：元素名称）
 */
-(NSDictionary *)selectedItem{
    NSInteger index = [picker selectedRowInComponent:0];
    NSString *contaxt = dataArray[index];
    return @{@"name":contaxt,@"index":[NSString stringWithFormat:@"%ld",index]};
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    UIView *view = [pickerView viewForRow:row forComponent:component];
//    UILabel *label = [view viewWithTag:901];
//    label.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1];
//    
//    CGFloat width = self.frame.size.height;
//    label.frame = CGRectMake(0, 0, width-40, 40);
    
    [self.delegate pickerView:pickerView didSelectRow:row];
}



@end
