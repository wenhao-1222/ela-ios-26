//
//  MainHeightVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/10.
//

import Foundation
import UIKit
import DGCharts

class MainHeightVM: UIView {
    
    let selfHeight = kFitWidth(271)
    
    var tapBlock:(()->())?
    var addBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : FeedBackView = {
        let vi = FeedBackView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(271)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(selfTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.text = "身体维度"
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var addButton : UIButton = {
        let btn = UIButton()
//        btn.setImage(UIImage.init(named: "main_add_data_button"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.setBackgroundImage(UIImage.init(named: "main_add_data_button"), for: .normal)
        
        return btn
    }()
    lazy var tapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(addTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var lineChartView : LineChartView = {
        let line = LineChartView(frame: CGRect.init(x: kFitWidth(14), y: kFitWidth(34), width: kFitWidth(313), height: kFitWidth(217)))
        line.doubleTapToZoomEnabled = false
        line.scaleXEnabled = false
        line.scaleYEnabled = false
        line.chartDescription.text = ""
//        line.legend.enabled = false
        line.legend.form = .circle
        line.legend.verticalAlignment = .top
        line.legend.neededHeight = kFitWidth(50)
        line.legend.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        line.legend.font = .systemFont(ofSize: 12, weight: .regular)
        line.legend.xEntrySpace = kFitWidth(14)
//        line.legend.yEntrySpace = kFitWidth(1)
        line.legend.drawInside = false
        line.legend.yOffset = kFitWidth(14)
        
        line.delegate = self
        line.dragEnabled = true
        line.highlightPerTapEnabled = false
        
        line.noDataText = "暂无数据"
        line.noDataTextColor = .COLOR_GRAY_BLACK_65
        line.rightAxis.enabled = false
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(selfTapAction))
        line.addGestureRecognizer(tap)
        
        return line
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()
}

extension MainHeightVM{
    @objc func selfTapAction(){
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    @objc func addTapAction(){
        if self.addBlock != nil{
            self.addBlock!()
        }
    }
}

extension MainHeightVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(addButton)
        whiteView.addSubview(tapView)
        whiteView.addShadow()
        
        whiteView.addSubview(lineChartView)
        whiteView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: whiteView.frame.width*0.5, y: whiteView.frame.height*0.5)
        
        initLineChartParam()
        
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        addButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(24))
        }
    }
}

extension MainHeightVM:ChartViewDelegate{
    func setDataSourceArray(dataArray:NSArray) {
        var yDataArrayYao = [ChartDataEntry]()
        var yDataArrayTun = [ChartDataEntry]()
        var yDataArrayBi = [ChartDataEntry]()
        
        var xStringArray = [String]()
//        noDataView.isHidden = dataArray.count > 0 ? true : false
        
        if dataArray.count > 0 {
            for i in 0..<dataArray.count{
                let dict = dataArray[i]as? NSDictionary ?? [:]
                
                var timeString = dict["ctime"]as? String ?? ""
                timeString = timeString.replacingOccurrences(of: "-", with: "/")
                timeString = timeString.mc_cutToSuffix(from: 5)
                xStringArray.append(timeString)
                if dict.doubleValueForKey(key: "waistline") > 0 {
                    let entry = ChartDataEntry.init(x: Double(i), y: Double(dict.doubleValueForKey(key: "waistline")))
                    yDataArrayYao.append(entry)
                }
                if dict.doubleValueForKey(key: "hips") > 0 {
                    let entry = ChartDataEntry.init(x: Double(i), y: Double(dict.doubleValueForKey(key: "hips")))
                    yDataArrayTun.append(entry)
                }
                if dict.doubleValueForKey(key: "armcircumference") > 0 {
                    let entry = ChartDataEntry.init(x: Double(i), y: Double(dict.doubleValueForKey(key: "armcircumference")))
                    yDataArrayBi.append(entry)
                }
            }
            
            var sets = [LineChartDataSet]()
            let dataArrays = [yDataArrayYao,yDataArrayTun,yDataArrayBi]
            let colors = [UIColor.COLOR_DIMENSION_YAO,UIColor.COLOR_DIMENSION_TUN,UIColor.COLOR_DIMENSION_BI]
            let labels = ["腰围","臀围","手臂"]
            for i in 0..<colors.count{
                let set = LineChartDataSet.init(entries: dataArrays[i], label: labels[i])
                set.colors = [colors[i]]
                set.drawCirclesEnabled = true
                set.lineWidth = 2.0;
                set.circleColors = [colors[i]]
                set.circleRadius = kFitWidth(2)
                set.drawCircleHoleEnabled = false
                set.drawValuesEnabled = false
                set.drawHorizontalHighlightIndicatorEnabled = false
                set.drawVerticalHighlightIndicatorEnabled = false
                set.valueFormatter = IntValueFormatter()
                
                sets.append(set)
            }
            let data = LineChartData.init(dataSets: sets)
            lineChartView.data = data
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter.init(values: xStringArray)
    //        lineChartView.animate(xAxisDuration: 0.7, yAxisDuration: 0.7, easingOption: .linear)
            
            if lineChartView.data?.entryCount ?? 0 > 3 {
                lineChartView.setVisibleXRangeMaximum(4)
            }
            
    //         获取最右边的Entry的xIndex   滑动到最右边
            if xStringArray.count > 5 {
                lineChartView.moveViewToX(Double(xStringArray.count - 1))
            }
            lineChartView.xAxis.axisMaximum = Double(xStringArray.count - 1) + 0.1
            lineChartView.leftAxis.labelCount = 5
            lineChartView.leftAxis.resetCustomAxisMin()
            lineChartView.leftAxis.resetCustomAxisMax()
//            lineChartView.leftAxis.granularity = 1
            lineChartView.leftAxis.drawZeroLineEnabled = false
//            lineChartView.leftAxis.granularityEnabled = true
            let center = (lineChartView.chartYMax + lineChartView.chartYMin)*0.5
            let gap = (lineChartView.chartYMax - lineChartView.chartYMin)*0.5
            if lineChartView.chartYMax-lineChartView.chartYMin >= 5 {
                lineChartView.leftAxis.granularity = (lineChartView.chartYMax-lineChartView.chartYMin + 4)/5
                lineChartView.leftAxis.axisMinimum = center - gap - 2//lineChartView.chartYMin
                lineChartView.leftAxis.axisMaximum = center + gap + 2//lineChartView.chartYMax
            }else{
                lineChartView.leftAxis.granularity = 1
                lineChartView.leftAxis.axisMinimum = center - 2.5
                lineChartView.leftAxis.axisMaximum = center + 2.5
            }
            DLLog(message: "\(lineChartView.chartYMin)  -   \(lineChartView.chartYMax)")
//            lineChartView.leftAxis.labelCount = 5
//            lineChartView.leftAxis.axisMinLabels = 5
//            lineChartView.leftAxis.axisMaxLabels = 5
        }else{
            xStringArray.append("")
            let entry = ChartDataEntry.init(x: Double(0), y: Double(50))
            yDataArrayYao.append(entry)
            
            let set = LineChartDataSet.init(entries: yDataArrayYao, label: "");
            set.colors = [.clear]
            set.drawCirclesEnabled = true;
            set.circleColors = [.clear]
            set.circleRadius = kFitWidth(2)
            set.drawCircleHoleEnabled = false
            set.drawValuesEnabled = false
            set.drawHorizontalHighlightIndicatorEnabled = false
            set.drawVerticalHighlightIndicatorEnabled = false
            set.valueFormatter = IntValueFormatter()
            
            let data = LineChartData.init(dataSets: [set])
            
            lineChartView.data = data
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter.init(values: xStringArray)
            lineChartView.xAxis.axisMaximum = Double(xStringArray.count - 1) + 0.1
            lineChartView.setVisibleXRangeMaximum(1)
            lineChartView.moveViewToX(Double(0))
            lineChartView.leftAxis.labelCount = 3
            lineChartView.leftAxis.axisMinimum = 0
            lineChartView.leftAxis.axisMaximum = 100
            lineChartView.leftAxis.granularity = 50
            lineChartView.leftAxis.granularityEnabled = true
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLLog(message: "\(entry)")
    }
    func initLineChartParam() {
        let leftYAxis = lineChartView.leftAxis
        leftYAxis.labelCount = 5
//        leftYAxis.forceLabelsEnabled = true
        leftYAxis.granularityEnabled = true
        leftYAxis.drawZeroLineEnabled = false
        leftYAxis.axisLineColor = .clear
//        leftYAxis.axisMinimum = 0
        leftYAxis.valueFormatter = IntAxisFormatter()
        
        let xAxis = lineChartView.xAxis
        xAxis.granularityEnabled = true
        xAxis.labelPosition = .bottom
//        xAxis.labelCount = 5
        xAxis.drawAxisLineEnabled = false
        xAxis.axisLineColor = .clear
//        xAxis.forceLabelsEnabled = true
        xAxis.axisMinimum = -0.1
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.labelFont = .systemFont(ofSize: 12, weight: .regular)
        xAxis.labelTextColor = .COLOR_GRAY_BLACK_65
        lineChartView.setVisibleXRangeMaximum(5)
//        lineChartView.setVisibleXRange(minXRange: 0, maxXRange: 5)
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.dragYEnabled = false
    }
}
