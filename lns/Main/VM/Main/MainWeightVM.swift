//
//  MainWeightVM.swift
//  lns
//  首页-体重数据
//  Created by LNS2 on 2024/4/10.
//

import Foundation
import UIKit
import DGCharts

class MainWeightVM: FeedBackView {
    
    let selfHeight = kFitWidth(241)
    
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
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(0), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(241)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(12)
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(selfTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.text = "体重数据"
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
        let line = LineChartView(frame: CGRect.init(x: kFitWidth(14), y: kFitWidth(44), width: kFitWidth(313), height: kFitWidth(177)))
        line.doubleTapToZoomEnabled = false
        line.chartDescription.text = ""
        line.legend.enabled = false
        line.legend.form = .circle
        line.legend.verticalAlignment = .top
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

extension MainWeightVM{
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

extension MainWeightVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(addButton)
        whiteView.addSubview(tapView)
        whiteView.addSubview(lineChartView)
        
        whiteView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: whiteView.frame.width*0.5, y: whiteView.frame.height*0.5)
        
        initLineChartParam()
        whiteView.addShadow()
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
        tapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(addButton)
            make.width.height.equalTo(kFitWidth(56))
        }
    }
}

extension MainWeightVM{
    func setDataArray(dataArray:NSArray) {        var yDataArray = [ChartDataEntry]()
        var xStringArray = [String]()
        
        let dataSourceArray = NSMutableArray.init(array: dataArray)
        
        if dataSourceArray.count > 0 {
            for i in 0..<dataSourceArray.count{
                let dict = dataSourceArray[i]as? NSDictionary ?? [:]
                
                var timeString = dict["ctime"]as? String ?? ""
                timeString = timeString.replacingOccurrences(of: "-", with: "/")
                timeString = timeString.mc_cutToSuffix(from: 5)
                xStringArray.append(timeString)
                
                let entry = ChartDataEntry.init(x: Double(i), y: Double(dict.doubleValueForKey(key: "weight")))
                yDataArray.append(entry)
            }
            
            let set = LineChartDataSet.init(entries: yDataArray, label: "kg");
            set.colors = [WHColor_16(colorStr: "008858")]
            set.drawCirclesEnabled = true
            set.lineWidth = 2.0;
            set.circleColors = [WHColor_16(colorStr: "008858")]
            set.circleRadius = kFitWidth(2)
            set.drawCircleHoleEnabled = false
            set.drawValuesEnabled = false
            
            set.drawHorizontalHighlightIndicatorEnabled = false
            set.drawVerticalHighlightIndicatorEnabled = false
            set.valueFormatter = IntValueFormatter()
            
            let data = LineChartData.init(dataSets: [set])
            
            lineChartView.data = data
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter.init(values: xStringArray)
            
            if lineChartView.data?.entryCount ?? 0 > 3 {
                lineChartView.setVisibleXRangeMaximum(4)
            }
            
    //         获取最右边的Entry的xIndex   滑动到最右边
            if lineChartView.data?.entryCount ?? 0 > 1 {
                lineChartView.moveViewToX(Double((lineChartView.data?.entryCount ?? 1) - 1))
            }
            if xStringArray.count > 5 {
                lineChartView.moveViewToX(Double(xStringArray.count - 1))
            }
            lineChartView.xAxis.axisMaximum = Double(xStringArray.count - 1) + 0.1
            lineChartView.leftAxis.drawZeroLineEnabled = false
            lineChartView.leftAxis.resetCustomAxisMin()
            lineChartView.leftAxis.resetCustomAxisMax()
            
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
                DLLog(message: "\(lineChartView.chartYMin)  -   \(lineChartView.chartYMax)")
            }
            lineChartView.leftAxis.labelCount = 5
            lineChartView.leftAxis.axisMinLabels = 5
            lineChartView.leftAxis.axisMaxLabels = 5
        }else{
            xStringArray.append("")
            let entry = ChartDataEntry.init(x: Double(0), y: Double(50))
            yDataArray.append(entry)
            
            let set = LineChartDataSet.init(entries: yDataArray, label: "kg");
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
    func initLineChartParam() {
        let leftYAxis = lineChartView.leftAxis
        leftYAxis.labelCount = 5
        leftYAxis.forceLabelsEnabled = true
        leftYAxis.drawZeroLineEnabled = false
        leftYAxis.axisLineColor = .clear
        leftYAxis.granularityEnabled = true
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
    func addLimitLine(_ value:Double, _ desc:String) {
        let limitLine = ChartLimitLine.init(limit: value, label: desc);
        //线
        limitLine.lineWidth = 1;
        limitLine.lineColor = UIColor.red;
        limitLine.lineDashLengths = [2.0,2.0];
        //文字
        limitLine.valueFont = UIFont.systemFont(ofSize: 10.0);
        limitLine.valueTextColor = UIColor.black;
        limitLine.labelPosition = .rightBottom;
        lineChartView.leftAxis.addLimitLine(limitLine);
    }
    
}

extension MainWeightVM:ChartViewDelegate,UIScrollViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLLog(message: "\(entry)")
    }
}
// 自定义Formatter类
class IntAxisFormatter: NSObject, AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // 如果是整数刻度，则直接返回整数字符串
        if value == Double(Int(value)) {
            return "\(Int(value))"
        } else {
            // 如果不是整数刻度，做处理
            return "\(String(format: "%.0f", value))"
        }
    }
}
