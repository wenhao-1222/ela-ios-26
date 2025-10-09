//
//  NaturalStatCPFDGBarChart.swift
//  lns
//  碳水、蛋白质、脂肪 柱状图
//  Created by LNS2 on 2024/9/11.
//

import Foundation
import DGCharts

class NaturalStatCPFDGBarChart: UIView {
    
    let selfHeight = kFitWidth(290)
    let whiteViewWidth = SCREEN_WIDHT-kFitWidth(16)
    
    var dataSourceArray = NSArray()
    /// 当前选中的柱状索引
    private var selectedIndex: Int?
    
    let markVm = NaturalBarCPFMarkView.init(frame: .zero)
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
        lab.text = "营养素"
        
        return lab
    }()
    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.text = "单位：克"
        
        return lab
    }()
    lazy var barChartView: BarChartView = {
        let vi = BarChartView.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(76), width: whiteViewWidth, height: selfHeight-kFitWidth(80)))
//        let vi = BarChartView.init(frame: CGRect.init(x: kFitWidth(49), y: kFitWidth(36), width: kFitWidth(294), height: selfHeight-kFitWidth(36)))
        vi.delegate = self
        vi.backgroundColor = .clear//WHColor_ARC()
        vi.scaleYEnabled = false
        vi.dragYEnabled = false
        vi.doubleTapToZoomEnabled = false
        vi.chartDescription.text = ""
        vi.legend.enabled = false
//        vi.legend.form = .circle
//        vi.legend.verticalAlignment = .top
//        vi.legend.yOffset = kFitWidth(0)
//        vi.legend.xOffset = kFitWidth(-30)
        vi.noDataText = "暂无数据"
        vi.alpha = 0
        
        return vi
    }()
    lazy var legendView: NaturalStatCPFDGBarLegendView = {
        let vi = NaturalStatCPFDGBarLegendView.init(frame: .zero)
        return vi
    }()
    lazy var customMarkView: NaturalStatCPFBarMarkView = {
        let vi = NaturalStatCPFBarMarkView.init(frame:  CGRect.init(x: kFitWidth(0), y: kFitWidth(42), width: whiteViewWidth, height: selfHeight-kFitWidth(42)))
        vi.isHidden = true
        return vi
    }()
}

extension NaturalStatCPFDGBarChart{
    func setDataSource(dataArray:NSArray,dateType:String) {
        self.dataSourceArray = dataArray
        customMarkView.isHidden = true
        DLLog(message: "\(dataArray)")
        var carboDataArray = [BarChartDataEntry]()
        var proteinDataArray = [BarChartDataEntry]()
        var fatDataArray = [BarChartDataEntry]()
        var xLabelArray = [String]()
        let colors = [UIColor.COLOR_CARBOHYDRATE,UIColor.COLOR_PROTEIN,UIColor.COLOR_FAT]
        
        var dataSetMax: Double = 0
        let groupSpace = 0.4
        let barSpace = 0.03
        //柱子宽度（(barSpace + barWidth) * 系列数 + groupSpace = 1.00 -> interval per "group"）
        let barWidth = 0.17

        var dataSets = [BarChartDataSet]()
        var carboset = BarChartDataSet()
        var proteinset = BarChartDataSet()
        var fatset = BarChartDataSet()
        
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
            
            let carboValue = dict.doubleValueForKey(key: "carbohydrate")
            let proteinValue = dict.doubleValueForKey(key: "protein")
            let fatValue = dict.doubleValueForKey(key: "fat")
            
            dataSetMax = max(carboValue, dataSetMax)
            dataSetMax = max(proteinValue, dataSetMax)
            dataSetMax = max(fatValue, dataSetMax)
            
            carboDataArray.append(BarChartDataEntry(x: Double(i), y: carboValue))
            proteinDataArray.append(BarChartDataEntry(x: Double(i), y: proteinValue))
            fatDataArray.append(BarChartDataEntry(x: Double(i), y: fatValue))
            
            carboset = BarChartDataSet(entries: carboDataArray, label: "碳水")
            carboset.setColor(colors[0])
            
            proteinset = BarChartDataSet(entries: proteinDataArray, label: "蛋白质")
            proteinset.setColor(colors[1])
            
            fatset = BarChartDataSet(entries: fatDataArray, label: "脂肪")
            fatset.setColor(colors[2])
        }
        carboset.drawValuesEnabled = false
        carboset.valueFormatter = IntValueFormatter()
        proteinset.drawValuesEnabled = false
        proteinset.valueFormatter = IntValueFormatter()
        fatset.drawValuesEnabled = false
        fatset.valueFormatter = IntValueFormatter()
        
        proteinset.highlightColor = .clear
//        proteinset.highlightLineDashPhase = 0
//        proteinset.highlightLineWidth = kFitWidth(0.5)
//        proteinset.highlightLineDashLengths = [kFitWidth(5),kFitWidth(2)]
        
        dataSets.append(carboset)
        dataSets.append(proteinset)
        dataSets.append(fatset)
        
        let data = BarChartData(dataSets: dataSets)
        data.barWidth = barWidth
        data.groupBars(fromX: -0.5, groupSpace: groupSpace, barSpace: barSpace)

        barChartView.data = data
        UIView.animate(withDuration: 0.25, animations: {
            self.barChartView.alpha = 1
        })
        
        barChartView.leftAxis.labelCount = 5
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter.init(values: xLabelArray)//BarValueFormatter()
//        barChartView.animate(yAxisDuration: 0.3)
        barChartView.resetZoom()
        barChartView.resetViewPortOffsets()
        barChartView.xAxis.labelCount = 7
        
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = dataSetMax > 0 ? dataSetMax : 200
        barChartView.leftAxis.granularityEnabled = true
        
        if dataSetMax == 0 {
            barChartView.leftAxis.granularity = 50
            barChartView.leftAxis.axisRange = 200
        }else{
//            barChartView.leftAxis.granularityEnabled = false
            barChartView.leftAxis.granularity = dataSetMax/5
            barChartView.leftAxis.axisRange = dataSetMax
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
//        barChartView.animate(yAxisDuration: 0.3)
//        barChartView.animate(xAxisDuration: 0.8, easingOption: .easeInOutSine)
        // 仅对 Y 轴执行动画，避免柱状图逐个显示
        barChartView.animate(yAxisDuration: 0.45,easingOption: .easeInOutSine)
        
        markVm.isHidden = true
    }
}

extension NaturalStatCPFDGBarChart{
    func initUI() {
        addSubview(whiteBgView)
        whiteBgView.addSubview(titleLabel)
        whiteBgView.addSubview(unitLabel)
        whiteBgView.addSubview(barChartView)
        whiteBgView.addSubview(legendView)
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
//        barChartView.cha
        let leftYAxis = barChartView.leftAxis
        leftYAxis.labelCount = 5
//        leftYAxis.forceLabelsEnabled = true
        leftYAxis.granularityEnabled = true
        leftYAxis.drawZeroLineEnabled = false
        leftYAxis.axisLineColor = .clear
//        leftYAxis.axisMinimum = 0
        leftYAxis.valueFormatter = IntAxisFormatter()
        leftYAxis.minWidth = kFitWidth(49)
        leftYAxis.spaceTop = 0.2
        
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
//        xAxis.yOffset = kFitWidth(-12)
        
//        markVm.chartView = barChartView
//        barChartView.marker = markVm
    }
}

extension NaturalStatCPFDGBarChart:ChartViewDelegate{
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        selectedIndex = nil
        customMarkView.isHidden = true
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLLog(message: "index:\(entry.x)")
        DLLog(message: "highlight.x:\(highlight.xPx)")
        DLLog(message: "highlight.drawX:\(highlight.drawX)")
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

//        if Int(entry.x) < self.dataSourceArray.count {
////            markVm.isHidden = false
////            let dict = self.dataSourceArray[Int(entry.x)]as? NSDictionary ?? [:]
////            markVm.markCustomView.updateUI(dict: dict)
//            
//            let ligh = Highlight(x: Double(Int(entry.x.rounded())), y: entry.y, dataSetIndex: 1)
//            chartView.highlightValue(ligh)
//            
//            customMarkView.isHidden = false
//            let markViewCenter = customMarkView.center
//            customMarkView.center = CGPoint.init(x: highlight.xPx, y: markViewCenter.y)
//    //        customMarkView.center = CGPoint.init(x: highlight.xPx, y: kFitWidth(42)+customMarkView.frame.height*0.5)
//            
//            customMarkView.updateUI(dict: self.dataSourceArray[Int(entry.x.rounded())]as? NSDictionary ?? [:])
//        }
        
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
//        customMarkView.isHidden = true
        hiddenCustomMarkView()
        selectedIndex = nil
    }
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
//        customMarkView.isHidden = true
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


