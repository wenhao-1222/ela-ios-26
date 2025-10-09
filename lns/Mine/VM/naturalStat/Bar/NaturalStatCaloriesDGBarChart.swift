//
//  NaturalStatCaloriesDGBarChart.swift
//  lns
//
//  Created by LNS2 on 2024/9/11.
//

import Foundation
import DGCharts

class NaturalStatCaloriesDGBarChart: UIView {
    
    let selfHeight = kFitWidth(268)//294
    let whiteViewWidth = SCREEN_WIDHT-kFitWidth(16)
    
    var dataSourceArray = NSArray()
    /// 当前选中的柱状索引
    private var selectedIndex: Int?
    
//    let markVm = NaturalBarMarkView.init(frame: .zero)
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var whiteBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: 0, width: whiteViewWidth, height: selfHeight))
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
    lazy var barChartView: BarChartView = {
        let vi = BarChartView.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(46), width: whiteViewWidth, height: selfHeight-kFitWidth(50)))
//        let vi = BarChartView.init(frame: CGRect.init(x: kFitWidth(49), y: kFitWidth(36), width: kFitWidth(294), height: selfHeight-kFitWidth(36)))
        vi.delegate = self
        vi.alpha = 0
        vi.backgroundColor = .clear//WHColor_ARC()
        vi.scaleYEnabled = false
        vi.dragYEnabled = false
        vi.doubleTapToZoomEnabled = false
        vi.chartDescription.text = ""
        vi.legend.enabled = false
        vi.noDataText = "暂无数据"
        
        return vi
    }()
    lazy var customMarkView: NaturalStatCaloriesBarMarkView = {
        let vi = NaturalStatCaloriesBarMarkView.init(frame:  CGRect.init(x: kFitWidth(0), y: kFitWidth(16), width: whiteViewWidth, height: selfHeight-kFitWidth(16)))
        vi.isHidden = true
        return vi
    }()
}

extension NaturalStatCaloriesDGBarChart{
    func setDataSource(dataArray:NSArray,dateType:String) {
        self.dataSourceArray = dataArray
        customMarkView.isHidden = true
        DLLog(message: "\(dataArray)")
        var caloriesDataArray = [BarChartDataEntry]()
        var xLabelArray = [String]()
        let colors = [UIColor.THEME]
        
        var dataSetMax: Double = 0
        let groupSpace = 0.1
        let barSpace = 0.0
        //柱子宽度（(barSpace + barWidth) * 系列数 + groupSpace = 1.00 -> interval per "group"）
        let barWidth = 0.9

        var dataSets = [BarChartDataSet]()
        var caloriesset = BarChartDataSet()
        
        for i in 0..<dataArray.count {
            let dict = dataArray[i]as? NSDictionary ?? [:]
            
            var xAxisLabel = "0"
            if let sdate = dict["sdate"]{
                let sdateStr = dict.stringValueForKey(key: "sdate")
                xAxisLabel = "\(sdateStr.mc_cutToSuffix(from: sdateStr.count-2))日"//日
            }else{
                let monthStr = dict.stringValueForKey(key: "month")
                xAxisLabel = "\(monthStr)月"//月
            }
            xLabelArray.append(xAxisLabel)
            
            let caloriesValue = dict.doubleValueForKey(key: "calories")
            
            dataSetMax = max(caloriesValue, dataSetMax)
            
            caloriesDataArray.append(BarChartDataEntry(x: Double(i), y: caloriesValue))
            
            caloriesset = BarChartDataSet(entries: caloriesDataArray, label: "")
            caloriesset.setColor(colors[0])
        }
        caloriesset.drawValuesEnabled = false
        caloriesset.valueFormatter = IntValueFormatter()
        caloriesset.highlightColor = .clear
        
        dataSets.append(caloriesset)
        
        let data = BarChartData(dataSets: dataSets)
        data.barWidth = barWidth
        data.groupBars(fromX: -0.5, groupSpace: groupSpace, barSpace: barSpace)

        UIView.animate(withDuration: 0.25, animations: {
            self.barChartView.alpha = 1
        })
        
        barChartView.data = data
        
//        barChartView.leftAxis.labelCount = 5
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter.init(values: xLabelArray)//BarValueFormatter()
//        barChartView.animate(yAxisDuration: 0.3)
        barChartView.resetZoom()
        barChartView.resetViewPortOffsets()
        barChartView.xAxis.labelCount = 7
//        barChartView.leftAxis.spaceBottom = 0.2
//        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = dataSetMax > 0 ? dataSetMax : 2000
        
        if dataSetMax == 0 {
            barChartView.leftAxis.granularity = 500
        }else{
//            barChartView.leftAxis.granularityEnabled = false
            barChartView.leftAxis.granularity = dataSetMax/5
        }
        
        if dateType == "6"{
            barChartView.setVisibleXRangeMinimum(6)
        }else if dateType == "7"{
            barChartView.setVisibleXRangeMinimum(12)
            barChartView.xAxis.labelCount = 12
        }else{
            let count = min(7,dataSourceArray.count)
            barChartView.setVisibleXRangeMinimum(Double(count))
        }
        barChartView.notifyDataSetChanged()
//        barChartView.animate(xAxisDuration: 0.8, easingOption: .easeInOutSine)
        // 仅对 Y 轴执行动画，避免柱状图逐个显示
        barChartView.animate(yAxisDuration: 0.45,easingOption: .easeInOutSine)
//
//        barChartView.animate(xAxisDuration: 0.3, easingOption: .linear)
//        barChartView.animate(yAxisDuration: 0.3,easingOption: .linear)
    }
}

extension NaturalStatCaloriesDGBarChart{
    func initUI() {
        addSubview(whiteBgView)
        whiteBgView.addSubview(titleLabel)
        whiteBgView.addSubview(unitLabel)
        whiteBgView.addSubview(barChartView)
        whiteBgView.addSubview(customMarkView)
        
        whiteBgView.addShadow(opacity: 0.05)
        initBarChartParam()
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
    
    func initBarChartParam() {
        barChartView.rightAxis.enabled = false
        let leftYAxis = barChartView.leftAxis
        leftYAxis.labelCount = 5
//        leftYAxis.forceLabelsEnabled = true
        leftYAxis.granularityEnabled = true
        leftYAxis.drawZeroLineEnabled = false
        leftYAxis.axisLineColor = .clear
//        leftYAxis.axisMinimum = 0
        leftYAxis.valueFormatter = IntAxisFormatter()
        leftYAxis.minWidth = kFitWidth(49)
        leftYAxis.spaceTop = 0.15
        leftYAxis.granularityEnabled = true
        leftYAxis.spaceBottom = 0.2
        leftYAxis.axisMinimum = 0
        
        let xAxis = barChartView.xAxis
        xAxis.granularityEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelCount = 7
        xAxis.drawAxisLineEnabled = false
        xAxis.axisLineColor = .clear
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .medium)
        xAxis.labelTextColor = .COLOR_GRAY_BLACK_65
        xAxis.labelCount = 7
    }
}

extension NaturalStatCaloriesDGBarChart:ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLLog(message: "\(chartView.description)")
        DLLog(message: "index:\(entry.x)")
        let index = Int(entry.x.rounded())
        if selectedIndex == index && customMarkView.isHidden == false {
//            customMarkView.isHidden = true
            hiddenCustomMarkView()
            selectedIndex = nil
            chartView.highlightValue(nil)
            return
        }

        if index < self.dataSourceArray.count {
            let ligh = Highlight(x: Double(Int(entry.x.rounded())), y: entry.y, dataSetIndex: 1)
            chartView.highlightValue(ligh)

            customMarkView.isHidden = false
            customMarkView.alpha = 0
            let markViewCenter = customMarkView.center
            customMarkView.center = CGPoint.init(x: highlight.xPx, y: markViewCenter.y)
            
            customMarkView.updateUI(dict: self.dataSourceArray[index]as? NSDictionary ?? [:])
            UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
                self.customMarkView.alpha = 1
                
            }
            selectedIndex = index
        }
    }
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
//        customMarkView.isHidden = true
        hiddenCustomMarkView()
        selectedIndex = nil
    }
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        customMarkView.isHidden = true
        hiddenCustomMarkView()
        selectedIndex = nil
    }
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
        hiddenCustomMarkView()
        selectedIndex = nil
    }
    func hiddenCustomMarkView(){
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.customMarkView.alpha = 0
        }completion: { _ in
            self.customMarkView.isHidden = true
        }
    }
}

class BarValueFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        return "\(value)日"
    }
}
