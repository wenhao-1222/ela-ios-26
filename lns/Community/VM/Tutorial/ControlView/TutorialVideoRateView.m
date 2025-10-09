//
//  TutorialVideoRateView.m
//  lns
//
//  Created by Elavatine on 2024/12/24.
//

#import "TutorialVideoRateView.h"


@interface TutorialVideoRateView ()

@property(nonatomic,strong) UIScrollView *scrollView;

@property(nonatomic,strong) NSArray *rateArray;

@property(nonatomic,strong) NSMutableArray *btnArray;

@property(nonatomic,assign) int selectIndex;

@end

@implementation TutorialVideoRateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
        [self addSubview:self.scrollView];
        
        self.btnArray = [[NSMutableArray alloc]init];
        self.selectIndex = 3;
        [self initUI];
//        [self resetUI];
    }
    return self;
}

-(void)resetUI{
//    self.btnArray = [[NSMutableArray alloc]init];
//    self.selectIndex = 3;
//    [self.scrollView removeFromSuperview];
//    [self addSubview:self.scrollView];
//    for (int i = 0 ; i < self.scrollView.subviews.count; i ++) {
//        UIView *vi = self.scrollView.subviews[i];
//        [vi removeFromSuperview];
//    }
//    [self initUI];
    if (self.selectIndex == 3){
        return;
    }
    self.selectIndex = 3;
    for (int i = 0 ; i < self.btnArray.count; i++) {
        UIButton *btn = self.btnArray[i];
        if (i == self.selectIndex) {
            btn.selected = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        }else{
            btn.selected = NO;
            btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        }
    }
}

-(void)initUI{
    CGFloat btnHeight = 30;
    for (int i = 0; i < self.rateArray.count; i ++) {
        UIButton *btn = [[UIButton alloc]init];
        btn.frame = CGRectMake(0, btnHeight*i, self.bounds.size.width, btnHeight);
        [self.scrollView addSubview:btn];
        
        [btn setTitle:[NSString stringWithFormat:@"%@x",self.rateArray[i]] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        [btn setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.85] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        btn.tag = 3040 + i;
        [btn addTarget:self action:@selector(btnTapAction:) forControlEvents:UIControlEventTouchUpInside];
        if (i == self.selectIndex){
            btn.selected = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        }
        [self.btnArray addObject:btn];
    }
    
//    [self.scrollView setContentSize:CGSizeMake(0, btnHeight*self.rateArray.count)];
//    [self.scrollView setContentOffset:CGPointMake(0, btnHeight*2)];
}

-(void)setRate:(NSString*)rate{
    if (rate.floatValue == 0.75){
        self.selectIndex = 4;
    }else if (rate.floatValue == 1){
        self.selectIndex = 3;
    }else if (rate.floatValue == 1.25){
        self.selectIndex = 2;
    }else if (rate.floatValue == 1.5){
        self.selectIndex = 1;
    }else if (rate.floatValue == 2){
        self.selectIndex = 0;
    }
    for (int i = 0 ; i < self.btnArray.count; i++) {
        UIButton *btn = self.btnArray[i];
        if (i == self.selectIndex) {
            btn.selected = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        }else{
            btn.selected = NO;
            btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        }
    }
}

-(void)btnTapAction:(UIButton*)tapSender{
    if (self.selectIndex == tapSender.tag - 3040) {
        return;
    }
    self.selectIndex = tapSender.tag - 3040;
    for (int i = 0 ; i < self.btnArray.count; i++) {
        UIButton *btn = self.btnArray[i];
        if (i == self.selectIndex) {
            btn.selected = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        }else{
            btn.selected = NO;
            btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        }
    }
//    tapSender.selected = YES;
//    tapSender.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    NSString *rateStr = self.rateArray[self.selectIndex];
    if (self.rateValueChanged) self.rateValueChanged(rateStr);
    self.hidden = YES;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.bounces = NO;
    }
    
    return _scrollView;
}
- (NSArray *)rateArray{
    if (!_rateArray) {
//        _rateArray = [[NSArray alloc]initWithObjects:@"2.0",@"1.5",@"1.25",@"1.0",@"0.75",@"0.5", nil];
        _rateArray = [[NSArray alloc]initWithObjects:@"2.0",@"1.5",@"1.25",@"1.0",@"0.75", nil];
    }
    return _rateArray;
}

@end
