//
//  NaturalStatCaloriesBarChartView.swift
//  lns
//  统计-- 卡路里柱状图
//  Created by LNS2 on 2024/9/9.
//

import Foundation

class NaturalStatCaloriesBarChartView: UIView {
    
    let selfHeight = kFitWidth(268)
    let whiteWidth = SCREEN_WIDHT-kFitWidth(16)
    
    var dataSourceArray = NSArray()
    var barGap = kFitWidth(10)
    
    var maxValue = kFitWidth(1)
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
//        self.clipsToBounds = true
        
        initUI()
    }
    lazy var whiteBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: 0, width: whiteWidth, height: selfHeight))
        vi.layer.cornerRadius = kFitWidth(12)
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .bold)
        lab.text = "卡路里"
        
        return lab
    }()
    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "单位：千卡"
        
        return lab
    }()
    lazy var yAxisView: NaturalStatCaloriesBarChartYAxisView = {
        let vm = NaturalStatCaloriesBarChartYAxisView.init(frame: .zero)
        return vm
    }()
    //柱状图 底部scrollView
    lazy var barChartViewScrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: kFitWidth(49), y: kFitWidth(36), width: whiteWidth-kFitWidth(49)-kFitWidth(16), height: selfHeight-kFitWidth(36)-kFitWidth(32)))
        scro.backgroundColor = .clear
        return scro
    }()
    //柱状图  x轴scrollView
    lazy var barChartViewXAxisScrollView: UIScrollView = {
        let scro = UIScrollView.init(frame: CGRect.init(x: kFitWidth(39), y: selfHeight-kFitWidth(32), width: whiteWidth-kFitWidth(39)-kFitWidth(6), height: kFitWidth(32)))
        scro.backgroundColor = .clear
        return scro
    }()
}

extension NaturalStatCaloriesBarChartView{
    func updateUI() {
        maxValue = self.getMaxValue()
        self.updateYAxis()
        
        for vi in self.barChartViewScrollView.subviews{
            vi.removeFromSuperview()
        }
        for vi in self.barChartViewXAxisScrollView.subviews{
            vi.removeFromSuperview()
        }
        var barViewWidth = (whiteWidth-kFitWidth(49)-kFitWidth(16) - CGFloat((self.dataSourceArray.count - 1)) * barGap)/CGFloat(self.dataSourceArray.count)
        if self.dataSourceArray.count > 14 {
            barGap = kFitWidth(2)
        }else if self.dataSourceArray.count == 12{
            barGap = kFitWidth(5)
        }else{
            barGap = kFitWidth(10)
        }
        barViewWidth = (whiteWidth-kFitWidth(49)-kFitWidth(16) - CGFloat((self.dataSourceArray.count - 1)) * barGap)/CGFloat(self.dataSourceArray.count)
        
        for i in 0..<self.dataSourceArray.count{
            let vm = NaturalStatCaloriesBarItemView.init(frame: CGRect.init(x: (barViewWidth + barGap)*CGFloat(i), y: 0, width: barViewWidth, height: 0))
            
            barChartViewScrollView.addSubview(vm)
            let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
            vm.updateUI(dict: dict, maxValue: maxValue)
            
            if self.dataSourceArray.count < 15{
                if self.dataSourceArray.count == 12{
                    if i%2 == 0{
                        let xAxisVm = NaturalStatCaloriesBarChartXAxisView.init(frame: CGRect.init(x: vm.frame.minX+kFitWidth(10)-barViewWidth, y: 0, width: barViewWidth*3, height: 0))
                        barChartViewXAxisScrollView.addSubview(xAxisVm)
                        xAxisVm.updateUI(dict: dict)
                    }
                }else{
                    let xAxisVm = NaturalStatCaloriesBarChartXAxisView.init(frame: CGRect.init(x: vm.frame.minX+kFitWidth(10), y: 0, width: barViewWidth, height: 0))
                    barChartViewXAxisScrollView.addSubview(xAxisVm)
                    xAxisVm.updateUI(dict: dict)
                }
            }else if self.dataSourceArray.count < 35 && i%5 == 0{
                let xAxisVm = NaturalStatCaloriesBarChartXAxisView.init(frame: CGRect.init(x: vm.frame.minX-barViewWidth+kFitWidth(10), y: 0, width: barViewWidth*3, height: 0))
                barChartViewXAxisScrollView.addSubview(xAxisVm)
                xAxisVm.updateUI(dict: dict)
            }else if i%5 == 0{
                let xAxisVm = NaturalStatCaloriesBarChartXAxisView.init(frame: CGRect.init(x: vm.frame.minX-barViewWidth+kFitWidth(10), y: 0, width: barViewWidth*3, height: 0))
                barChartViewXAxisScrollView.addSubview(xAxisVm)
                xAxisVm.updateUI(dict: dict)
            }
        }
    }
    
    //MARK: Y轴坐标值确定
    func updateYAxis() {
        let stepValue = self.maxValue*0.25
        let minValue = ceil(stepValue)//向上取整
        yAxisView.updateUI(minValue: Int(minValue))
        self.maxValue = minValue * 4
    }
    
    //MARK: 获取数据的最大值
    func getMaxValue() -> Double {
        var maxValue = Double(0)
        for i in 0..<self.dataSourceArray.count{
            let dict = dataSourceArray[i]as? NSDictionary ?? [:]
            let value = dict.doubleValueForKey(key: "calories")

            if value > maxValue{
                maxValue = value
            }
        }
        
        return maxValue > 0 ? maxValue : 1
    }
}

extension NaturalStatCaloriesBarChartView{
    func initUI() {
        addSubview(whiteBgView)
        whiteBgView.addSubview(titleLabel)
        whiteBgView.addSubview(unitLabel)
        whiteBgView.addSubview(yAxisView)
        whiteBgView.addSubview(barChartViewScrollView)
        whiteBgView.addSubview(barChartViewXAxisScrollView)
        
        whiteBgView.addShadow(opacity: 0.05)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(18))
        }
        unitLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(titleLabel)
        }
    }
}
