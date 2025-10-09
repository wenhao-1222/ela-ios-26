//
//  QuestionnairePlanFoodsDetailAlertVM.swift
//  lns
//   20   60
//  Created by LNS2 on 2024/4/2.
//

import Foundation
import UIKit
import DGCharts

class QuestionnairePlanFoodsDetailAlertVM: UIView {

    let nameArray = ["蛋白质","脂肪","碳水化合物"]
    let colors: [UIColor] = [.COLOR_PROTEIN,.COLOR_FAT,.COLOR_CARBOHYDRATE]
    var dataArray = NSArray()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.isHidden = true
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
//        self.addGestureRecognizer(tap)
        
        initUI()
        updateUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenView))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(16)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var detailsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "每100g所含营养素比例"
        lab.textAlignment = .center
        
        return lab
    }()
//   fileprivate lazy var pieChartView: PieChartView = {
//       let pieChartView = PieChartView()
//       pieChartView.drawEntryLabelsEnabled = false
//       pieChartView.backgroundColor = .clear
//       
//       //基本样式
//       pieChartView.delegate = self
//       return pieChartView
//   }()
    lazy var pieChartView : WHPieChartView = {
        let vi = WHPieChartView.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(94), width: kFitWidth(340), height: kFitWidth(200)))
        
        return vi
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        
        return vi
    }()
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("我知道了", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
}

extension QuestionnairePlanFoodsDetailAlertVM{
    func showView(dict:NSDictionary) {
        self.isHidden = false
        whiteView.alpha = 0
//        self.alpha = 0
        bgView.alpha = 0
        self.titleLabel.text = dict["fname"]as? String ?? ""
        
        dataArray = [Float(dict.stringValueForKey(key: "protein")) ?? 0.00,
                     Float(dict.stringValueForKey(key: "fat")) ?? 0.00,
                     Float(dict.stringValueForKey(key: "carbohydrate")) ?? 0.00]
        
        pieChartView.setPercents(numer: dataArray)
        
        updateCenterAttr(calories: dict.stringValueForKey(key: "String"))
        
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
            self.bgView.alpha = 0.15
        }
//        UIView.animate(withDuration: 0.4, delay: 0.1,options: .curveLinear) {
//            self.alpha = 1
//        }
    }
    
    @objc func hiddenView() {
//        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
//            self.alpha = 0
//        }
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 0
            self.bgView.alpha = 0
        }completion: { c in
            self.isHidden = true
        }
    }
    @objc func nothingToDo() {
        
    }
    func updateCenterAttr(calories:String)  {
        ////饼状图中心的富文本
        let carNumber = calories
        let attr = NSMutableAttributedString.init(string: carNumber)
        let unitStr = NSMutableAttributedString.init(string: "\n热量")
        attr.yy_font = .systemFont(ofSize: 20, weight: .medium)
        attr.yy_color = .COLOR_GRAY_BLACK_85
        
        unitStr.yy_font = .systemFont(ofSize: 12, weight: .regular)
        unitStr.yy_color = .COLOR_GRAY_BLACK_85
        attr.append(unitStr)
        attr.yy_alignment = .center
        pieChartView.centerLabel.attributedText = attr
//        pieChartView.centerAttributedText = attr
    }
}

extension QuestionnairePlanFoodsDetailAlertVM{
    func updateUI() {
//        setChart(dataPoints: months, values: unitsSold)
    }
}

extension QuestionnairePlanFoodsDetailAlertVM{
    func setChart(dataPoints: [String], values: [Double]) {
//        var dataEntries: [ChartDataEntry] = []
//        
//        for i in 0..<dataPoints.count {
//            let valueText = "\(dataPoints[i])"
//            let valueAttr = NSMutableAttributedString(string: valueText)
//             
//            // 设置富文本样式
//            valueAttr.setAttributes([
//                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
//                NSAttributedString.Key.foregroundColor: colors[i]
//            ], range: NSRange(location: 0, length: valueText.count))
//             
////            let entry = PieChartDataEntry(value: values[i], label: "",data: valueAttr)
//            let entry = PieChartDataEntry(value: values[i], label: "\(dataPoints[i])",data: valueAttr) //设置数据 title和对应的值
//            
//            dataEntries.append(entry)
//        }
//        
//        
//        let pichartDataSet = PieChartDataSet(entries: dataEntries, label: "") //设置表示
//        //设置饼状图字体配置
//        setPieChartDataSetConfig(pichartDataSet: pichartDataSet)
//        
//        let pieChartData = PieChartData(dataSet: pichartDataSet)
//        //设置饼状图字体样式
//        setPieChartDataConfig(pieChartData: pieChartData)
//        pieChartView.data = pieChartData //将配置及数据添加到表中
//        
//        //设置饼状图样式
//        setDrawHoleState()
//        pichartDataSet.colors = colors//设置区块颜色
    }
    //设置饼状图字体配置
      func setPieChartDataSetConfig(pichartDataSet: PieChartDataSet){
//          pichartDataSet.sliceSpace = 1 //相邻区块之间的间距
//          pichartDataSet.selectionShift = 2 //选中区块时, 放大的半径
//          pichartDataSet.xValuePosition = .insideSlice //名称位置
//          pichartDataSet.yValuePosition = .outsideSlice //数据位置
//          //数据与区块之间的用于指示的折线样式
//          pichartDataSet.valueLinePart1OffsetPercentage = 0.5 //折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
//          pichartDataSet.valueLinePart1Length = 0.4 //折线中第一段长度占比
//          pichartDataSet.valueLinePart2Length = 0.7 //折线中第二段长度最大占比
//          pichartDataSet.valueLineWidth = 1 //折线的粗细
//          pichartDataSet.valueLineColor = WHColor_16(colorStr: "D9D9D9") //折线颜色
        
      }
      
      //设置饼状图字体样式
      func setPieChartDataConfig(pieChartData: PieChartData){
//          pieChartData.setValueFormatter(DigitValueFormatter() as! ValueFormatter)//设置百分比
//          
//          pieChartData.setValueTextColor(UIColor.gray) //字体颜色为白色
//          pieChartData.setValueFont(UIFont.systemFont(ofSize: 10))//字体大小
      }
      
      //设置饼状图中心文本
      func setDrawHoleState(){
//          ///饼状图距离边缘的间隙
//          pieChartView.setExtraOffsets(left: kFitWidth(50), top: 0, right: kFitWidth(50), bottom: 0)
//          //拖拽饼状图后是否有惯性效果
//          pieChartView.dragDecelerationEnabled = true
//          //是否显示区块文本
//          pieChartView.drawSlicesUnderHoleEnabled = true
//          //是否根据所提供的数据, 将显示数据转换为百分比格式
//          pieChartView.usePercentValuesEnabled = true
//
//          // 设置饼状图描述
//          pieChartView.chartDescription.enabled = false
////          pieChartView.chartDescription.text = ""
////          pieChartView.chartDescription.font = UIFont.systemFont(ofSize: 10)
////          pieChartView.chartDescription.textColor = UIColor.gray
//          
//          // 设置饼状图图例样式
//          pieChartView.legend.enabled = false//隐藏图例
////          pieChartView.legend.maxSizePercent = 0 //图例在饼状图中的大小占比, 这会影响图例的宽高
////          pieChartView.legend.formToTextSpace = 5 //文本间隔
////          pieChartView.legend.font = .systemFont(ofSize: 12, weight: .regular) //字体大小
////          pieChartView.legend.textColor = UIColor.gray //字体颜色
////          pieChartView.legend.verticalAlignment = .bottom //图例在饼状图中的位置
////          pieChartView.legend.form = .circle //图示样式: 方形、线条、圆形
////          pieChartView.legend.formSize = 0 //图示大小
////          pieChartView.legend.orientation = .horizontal
////          pieChartView.legend.horizontalAlignment = .center
//          pieChartView.holeRadiusPercent = 0.667 //空心半径占比
//  //        pieChartView.centerText = "平均库龄" //饼状图中心的文本
//
//          pieChartView.setNeedsDisplay()
      }
    
}

extension QuestionnairePlanFoodsDetailAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(detailsLabel)
        whiteView.addSubview(pieChartView)
        whiteView.addSubview(lineView)
        whiteView.addSubview(confirmBtn)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(340))
            make.height.equalTo(kFitWidth(360))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.top.equalTo(kFitWidth(23))
            make.height.equalTo(kFitWidth(20))
        }
        detailsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(54))
        }
//        pieChartView.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(92))
//            make.width.equalTo(kFitWidth(320))
//            make.height.equalTo(kFitWidth(200))
//        }
        lineView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.bottom.equalTo(kFitWidth(-48))
        }
        confirmBtn.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
        }
    }
    
}

extension QuestionnairePlanFoodsDetailAlertVM:ChartViewDelegate{
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
}

//        pieChartData.setValueFormatter(DigitValueFormatter() //设置百分比
//转化为带%
class DigitValueFormatter: NSObject, ValueFormatter {
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let pieEntry = entry as! PieChartDataEntry
        
        let valueWithoutDecimalPart = String(format: "%@%.0f%%\n%.1fg",pieEntry.label ?? "" ,value,entry.y)
        DLLog(message: "pieEntry:\(pieEntry)   -- value:\(value)")
        
        let step = NSMutableAttributedString.init(string: String(format: "%@%.0f%%\n",pieEntry.label ?? "" ,value))
        let totalStep = NSMutableAttributedString.init(string: String(format: "%.1fg",entry.y))
        
        let colors: [UIColor] = [.COLOR_PROTEIN,.COLOR_FAT,.COLOR_CARBOHYDRATE]
        step.yy_color = colors[dataSetIndex]
        
        step.append(totalStep)
        step.yy_font = .systemFont(ofSize: 12, weight: .regular)
        
        return step.string
    }
}

