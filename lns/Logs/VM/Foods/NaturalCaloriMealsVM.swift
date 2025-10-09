//
//  NaturalCaloriMealsVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit
import DGCharts

class NaturalCaloriMealsVM: UIView {
    
    var selfHeight = kFitWidth(383)
    
    let nameArray = ["第 1 餐",
                     "第 2 餐",
                     "第 3 餐",
                     "第 4 餐",
                     "第 5 餐",
                     "第 6 餐"]
    let colors: [UIColor] = [WHColor_16(colorStr: "7137BF"),
                             WHColor_16(colorStr: "E37318"),
                             WHColor_16(colorStr: "F5BA18"),
                             WHColor_16(colorStr: "C43695"),
                             WHColor_16(colorStr: "029CD4"),
                             WHColor_16(colorStr: "008858")]
    
    var calculateBlock:(()->())?
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(16), height: kFitWidth(375)))
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor
        vi.layer.borderWidth = kFitWidth(1)
        
        return vi
    }()
    fileprivate lazy var pieChartView: PieChartView = {
        let pieChartView = PieChartView()
        pieChartView.backgroundColor = .clear
        pieChartView.drawEntryLabelsEnabled = false
        
        //基本样式
        pieChartView.delegate = self
        return pieChartView
    }()
    lazy var mealsOneLegendVm: NaturalPieChartLegendITemVM = {
        let vm = NaturalPieChartLegendITemVM.init(frame: CGRect.init(x: kFitWidth(57), y: kFitWidth(227), width: 0, height: 0))
        vm.circleView.backgroundColor = colors[0]
        vm.titleLabel.text = "第 1 餐"
        return vm
    }()
    lazy var mealsTwoLegendVm: NaturalPieChartLegendITemVM = {
        let vm = NaturalPieChartLegendITemVM.init(frame: CGRect.init(x: kFitWidth(192), y: kFitWidth(227), width: 0, height: 0))
        vm.circleView.backgroundColor = colors[1]
        vm.titleLabel.text = "第 2 餐"
        return vm
    }()
    lazy var mealsThreeLegendVm: NaturalPieChartLegendITemVM = {
        let vm = NaturalPieChartLegendITemVM.init(frame: CGRect.init(x: kFitWidth(57), y: self.mealsOneLegendVm.frame.maxY+kFitWidth(16), width: 0, height: 0))
        vm.circleView.backgroundColor = colors[2]
        vm.titleLabel.text = "第 3 餐"
        return vm
    }()
    lazy var mealsFourLegendVm: NaturalPieChartLegendITemVM = {
        let vm = NaturalPieChartLegendITemVM.init(frame: CGRect.init(x: kFitWidth(192), y: self.mealsOneLegendVm.frame.maxY+kFitWidth(16), width: 0, height: 0))
        vm.circleView.backgroundColor = colors[3]
        vm.titleLabel.text = "第 4 餐"
        return vm
    }()
    lazy var mealsFiveLegendVm: NaturalPieChartLegendITemVM = {
        let vm = NaturalPieChartLegendITemVM.init(frame: CGRect.init(x: kFitWidth(57), y: self.mealsThreeLegendVm.frame.maxY+kFitWidth(16), width: 0, height: 0))
        vm.circleView.backgroundColor = colors[4]
        vm.titleLabel.text = "第 5 餐"
        return vm
    }()
    lazy var mealsSixLegendVm: NaturalPieChartLegendITemVM = {
        let vm = NaturalPieChartLegendITemVM.init(frame: CGRect.init(x: kFitWidth(192), y: self.mealsThreeLegendVm.frame.maxY+kFitWidth(16), width: 0, height: 0))
        vm.circleView.backgroundColor = colors[5]
        vm.titleLabel.text = "第 6 餐"
        return vm
    }()
}

extension NaturalCaloriMealsVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(pieChartView)
//        whiteView.addSubview(mealsOneLegendVm)
//        whiteView.addSubview(mealsTwoLegendVm)
//        whiteView.addSubview(mealsThreeLegendVm)
//        whiteView.addSubview(mealsFourLegendVm)
//        whiteView.addSubview(mealsFiveLegendVm)
//        whiteView.addSubview(mealsSixLegendVm)
        
        pieChartView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(28))
            make.width.equalTo(kFitWidth(160))
            make.height.equalTo(kFitWidth(160))
        }
    }
    func setDataSource(dataDict:NSDictionary)  {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let mealsArray = dataDict["foods"]as? NSArray ?? []
            var numArray = NSMutableArray()
            var hasData = false
            for k in 0..<mealsArray.count{
                let foodsArray = mealsArray[k]as? NSArray ?? []
                
                var caloriTotal = Double(0)
                
                for i in 0..<foodsArray.count{
                    let dict = foodsArray[i]as? NSDictionary ?? [:]
                    if dict.stringValueForKey(key: "state") == "1"{
                        var calori = dict.doubleValueForKey(key: "calories")
                        if calori == 0 {
                            calori = Double(dict.stringValueForKey(key: "calories")) ?? 0
                        }
                        caloriTotal = caloriTotal + calori
                        hasData = true
                    }
                    
                }
                numArray.add(caloriTotal)
            }
            
            if hasData == false{
                numArray = [1.0,1.0,1.0,1.0,1.0,1.0]
            }
            
            DispatchQueue.main.async {
                DLLog(message: "numArray:\(numArray)")
                self.setChart(dataPoints: self.nameArray, values: numArray as! [Double])
            }
            
            usleep(300000)
            var totalNum = Double(0)
            
            for i in 0..<numArray.count{
                let numDou = numArray[i] as! Double
                totalNum = totalNum + numDou
            }
            
            var percentArray = NSMutableArray()
            
            if hasData == false{
                percentArray = ["0","0","0","0","0","0"]
                numArray = [0.0,0.0,0.0,0.0,0.0,0.0]
            }else{
                for i in 0..<numArray.count{
                    let numDou = numArray[i] as! Double
                    let percent = numDou/totalNum*100
                    percentArray.add(WHUtils.convertStringToString(String(format: "%.2f", percent)) ?? "0")
                }
            }
            
            
            DispatchQueue.main.async {
                DLLog(message: "numArray:\(numArray)")
//                self.mealsOneLegendVm.detailsLabel.text = "\(WHUtils.convertStringToString(percentArray[0] as! String) ?? "0")%（\(WHUtils.convertStringToString("\(numArray[0])") ?? "0")千卡）"
//                self.mealsTwoLegendVm.detailsLabel.text = "\(WHUtils.convertStringToString(percentArray[1] as! String) ?? "0")%（\(WHUtils.convertStringToString("\(numArray[1])") ?? "0")千卡）"
//                self.mealsThreeLegendVm.detailsLabel.text = "\(WHUtils.convertStringToString(percentArray[2] as! String) ?? "0")%（\(WHUtils.convertStringToString("\(numArray[2])") ?? "0")千卡）"
//                self.mealsFourLegendVm.detailsLabel.text = "\(WHUtils.convertStringToString(percentArray[3] as! String) ?? "0")%（\(WHUtils.convertStringToString("\(numArray[3])") ?? "0")千卡）"
//                self.mealsFiveLegendVm.detailsLabel.text = "\(WHUtils.convertStringToString(percentArray[4] as! String) ?? "0")%（\(WHUtils.convertStringToString("\(numArray[4])") ?? "0")千卡）"
//                self.mealsSixLegendVm.detailsLabel.text = "\(WHUtils.convertStringToString(percentArray[5] as! String) ?? "0")%（\(WHUtils.convertStringToString("\(numArray[5])") ?? "0")千卡）"
                self.updateLegendVM(numArray: numArray,percentArray: percentArray)
            }
        }
    }
    func updateLegendVM(numArray:NSArray,percentArray:NSArray) {
        var num = 0
        var originX = (whiteView.frame.width*0.5 - kFitWidth(135))//kFitWidth(57)//kFitWidth(192)
        
        var originY = kFitWidth(227)
        
        for i in 0..<numArray.count{
            if numArray[i]as? Double ?? 0 > 0 {
                let vm = NaturalPieChartLegendITemVM.init(frame: CGRect.init(x: originX, y: originY, width: 0, height: 0))
                vm.circleView.backgroundColor = colors[i]
                vm.titleLabel.text = "第 \(i+1) 餐"
                vm.detailsLabel.text = "\(WHUtils.convertStringToString(percentArray[i] as! String) ?? "0")%（\(WHUtils.convertStringToString("\((numArray[i]as? Double ?? 0).rounded())") ?? "0")千卡）"
                whiteView.addSubview(vm)
                num = num + 1
                
//                originX = num%2 == 0 ? kFitWidth(57) : kFitWidth(192)q
                originX = num%2 == 0 ? (whiteView.frame.width*0.5 - kFitWidth(135)) : (whiteView.frame.width*0.5 + kFitWidth(10))
                originY = num%2 == 1 ? (originY) : (vm.frame.maxY + kFitWidth(16))
            }
        }
        if num < 2 {
            originY = originY + kFitWidth(46)
        }else if num%2 == 1{
            originY = originY + kFitWidth(46)
        }
        
        selfHeight = originY
        
        if num == 0 {
            self.setChart(dataPoints: ["第 1 餐"], values: [1.0] as! [Double])
            
            let vm = NaturalPieChartLegendITemVM.init(frame: CGRect.init(x: kFitWidth(57), y: kFitWidth(227), width: 0, height: 0))
            vm.circleView.backgroundColor = colors[0]
            vm.titleLabel.text = "第 1 餐"
            vm.detailsLabel.text = "0%（0)千卡"
            whiteView.addSubview(vm)
            selfHeight = kFitWidth(227) + kFitWidth(46)
        }
        
        let frame = self.frame
        self.whiteView.frame = CGRect.init(x: kFitWidth(8), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(16), height: selfHeight)
        
        selfHeight = selfHeight + kFitWidth(8)
        self.frame = CGRect.init(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: self.selfHeight)
        
        if self.calculateBlock != nil{
            self.calculateBlock!()
        }
    }
}

extension NaturalCaloriMealsVM{
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let valueText = "\(dataPoints[i])"
            let valueAttr = NSMutableAttributedString(string: valueText)
             
            // 设置富文本样式
            valueAttr.setAttributes([
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: colors[i]
            ], range: NSRange(location: 0, length: valueText.count))
             
//            let entry = PieChartDataEntry(value: values[i], label: "",data: valueAttr)
            let entry = PieChartDataEntry(value: values[i], label: "\(dataPoints[i])",data: valueAttr) //设置数据 title和对应的值
            
            dataEntries.append(entry)
        }
        
        let pichartDataSet = PieChartDataSet(entries: dataEntries, label: "") //设置表示
        //设置饼状图字体配置
        setPieChartDataSetConfig(pichartDataSet: pichartDataSet)
        
        let pieChartData = PieChartData(dataSet: pichartDataSet)
        //设置饼状图字体样式
        setPieChartDataConfig(pieChartData: pieChartData)
        pieChartView.data = pieChartData //将配置及数据添加到表中
        
        //设置饼状图样式
        setDrawHoleState()
        pichartDataSet.colors = colors//设置区块颜色
    }
    //设置饼状图字体配置
      func setPieChartDataSetConfig(pichartDataSet: PieChartDataSet){
          pichartDataSet.sliceSpace = 1 //相邻区块之间的间距
          pichartDataSet.selectionShift = 2 //选中区块时, 放大的半径
          pichartDataSet.drawValuesEnabled = false
          pichartDataSet.xValuePosition = .insideSlice //名称位置
          pichartDataSet.yValuePosition = .outsideSlice //数据位置
          //数据与区块之间的用于指示的折线样式
          pichartDataSet.valueLinePart1OffsetPercentage = 0.85 //折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
          pichartDataSet.valueLinePart1Length = 0.2 //折线中第一段长度占比
          pichartDataSet.valueLinePart2Length = 0.8 //折线中第二段长度最大占比
          pichartDataSet.valueLineWidth = 1 //折线的粗细
          pichartDataSet.valueLineColor = WHColor_16(colorStr: "D9D9D9") //折线颜色
      }
      
      //设置饼状图字体样式
      func setPieChartDataConfig(pieChartData: PieChartData){
          pieChartData.setValueFormatter(DigitValueForma() as! ValueFormatter)//设置百分比
          pieChartData.setValueTextColor(UIColor.gray) //字体颜色为白色
          pieChartData.setValueFont(UIFont.systemFont(ofSize: 10))//字体大小
      }
      
      
      //设置饼状图中心文本
      func setDrawHoleState(){
          ///饼状图距离边缘的间隙
          pieChartView.setExtraOffsets(left: kFitWidth(0), top: 0, right: kFitWidth(0), bottom: 0)
          //拖拽饼状图后是否有惯性效果
          pieChartView.dragDecelerationEnabled = true
          //是否显示区块文本
          pieChartView.drawSlicesUnderHoleEnabled = false
          //是否根据所提供的数据, 将显示数据转换为百分比格式
          pieChartView.usePercentValuesEnabled = true

          // 设置饼状图描述
          pieChartView.chartDescription.enabled = false
          // 设置饼状图图例样式
          pieChartView.legend.enabled = false//隐藏图例
          pieChartView.holeRadiusPercent = 0.667 //空心半径占比
//          pieChartView.centerText = "今日热量分布" //饼状图中心的文本
//          pieChartView.
          
          let centerAtter = NSMutableAttributedString(string: "今日热量分布")
          centerAtter.yy_font = .systemFont(ofSize: 14, weight: .medium)
          centerAtter.yy_color = .COLOR_GRAY_BLACK_85
          pieChartView.centerAttributedText = centerAtter

          pieChartView.setNeedsDisplay()
      }
    
}

extension NaturalCaloriMealsVM:ChartViewDelegate{
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
}
//转化为带%
class DigitValueForma: NSObject, ValueFormatter {
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let pieEntry = entry as! PieChartDataEntry
        
        let valueWithoutDecimalPart = String(format: "%@%.0f%%\n%.1fg",pieEntry.label ?? "" ,value,entry.y)
//        DLLog(message: "pieEntry:\(pieEntry)")
        
        let step = NSMutableAttributedString.init(string: String(format: "%@%.0f%%\n",pieEntry.label ?? "" ,value))
        let totalStep = NSMutableAttributedString.init(string: String(format: "%.1fg",entry.y))
        
        let colors: [UIColor] = [WHColor_16(colorStr: "7137BF"),
                                 WHColor_16(colorStr: "E37318"),
                                 WHColor_16(colorStr: "F5BA18"),
                                 WHColor_16(colorStr: "C43695"),
                                 WHColor_16(colorStr: "029CD4"),
                                 WHColor_16(colorStr: "008858")]
        step.yy_color = colors[dataSetIndex]
        
        step.append(totalStep)
        step.yy_font = .systemFont(ofSize: 12, weight: .regular)
        
        return step.string
    }
}
