//
//  FoodsMergeNaturalVM.swift
//  lns
//  融合食物--营养素信息
//  Created by Elavatine on 2025/3/14.
//

import DGCharts


class FoodsMergeNaturalVM: UIView {
    
    let selfHeight = kFitWidth(136)
    let nameArray = ["碳水",
                     "蛋白质",
                     "脂肪"]
    let colors: [UIColor] = [.COLOR_CARBOHYDRATE,
                             .COLOR_PROTEIN,
                             .COLOR_FAT]
    
    // 创建CAShapeLayer
    var naturalShapeLayerBottom = CAShapeLayer()
    var naturalPathBottom = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        drawoBottomView()
    }
    
    fileprivate lazy var pieChartView: PieChartView = {
        let pieChartView = PieChartView()
        pieChartView.backgroundColor = .clear
        pieChartView.drawEntryLabelsEnabled = false
        
        //基本样式
        pieChartView.delegate = self
        return pieChartView
    }()
    lazy var carboItemVm: FoodsMergeNaturalItemVM = {
        let vm = FoodsMergeNaturalItemVM.init(frame: CGRect.init(x: kFitWidth(175), y: kFitWidth(21), width: 0, height: 0))
        vm.legenView.backgroundColor = colors[0]
        vm.itemTitleLabel.text = "碳水 0%"
        
        return vm
    }()
    lazy var proteinItemVm: FoodsMergeNaturalItemVM = {
        let vm = FoodsMergeNaturalItemVM.init(frame: CGRect.init(x: kFitWidth(175), y: self.carboItemVm.frame.maxY, width: 0, height: 0))
        vm.legenView.backgroundColor = colors[1]
        vm.itemTitleLabel.text = "蛋白质 0%"
        
        return vm
    }()
    lazy var fatItemVm: FoodsMergeNaturalItemVM = {
        let vm = FoodsMergeNaturalItemVM.init(frame: CGRect.init(x: kFitWidth(175), y: self.proteinItemVm.frame.maxY, width: 0, height: 0))
        vm.legenView.backgroundColor = colors[2]
        vm.itemTitleLabel.text = "脂肪 0%"
        
        return vm
    }()
}

extension FoodsMergeNaturalVM{
    func initUI() {
        self.layer.addSublayer(naturalShapeLayerBottom)
        addSubview(pieChartView)
        addSubview(carboItemVm)
        addSubview(proteinItemVm)
        addSubview(fatItemVm)
        
        setConstrait()
        setDataSource(array: [0,0,0])
        setCaloriesNumber(calories: "0")
        
        naturalShapeLayerBottom.strokeColor = WHColor_16(colorStr: "F7F9FC").cgColor
        naturalShapeLayerBottom.fillColor = nil // 无填充色
        naturalShapeLayerBottom.lineWidth = kFitWidth(25) // 线宽
    }
    func setConstrait() {
        pieChartView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(30))
            make.top.equalTo(kFitWidth(0))
            make.width.equalTo(kFitWidth(120))
            make.height.equalTo(kFitWidth(120))
        }
    }
    func drawoBottomView() {
        //半径
        let radius = kFitWidth(46.5)//kFitWidth(47.5)
        //弧度起点
        let startAngle = CGFloat(0)
        //弧度终点
        let endAngle = CGFloat(Double.pi*2)
        
        naturalPathBottom = UIBezierPath()
        // 添加一个圆弧到路径
        naturalPathBottom.addArc(withCenter: CGPoint.init(x: kFitWidth(30)+kFitWidth(60), y: kFitWidth(60)), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        naturalShapeLayerBottom.path = naturalPathBottom.cgPath
    }
    func setCaloriesNumber(calories:String) {
        let titAttr = NSMutableAttributedString(string: "卡路里\n")
        titAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
        titAttr.yy_color = .COLOR_GRAY_BLACK_45
        
        let centerAtter = NSMutableAttributedString(string: "\(calories)\n")
        centerAtter.yy_font = .systemFont(ofSize: 18, weight: .semibold)
        centerAtter.yy_color = .COLOR_GRAY_BLACK_85
        
        let unitAttr = NSMutableAttributedString(string: "千卡")
        unitAttr.yy_font = .systemFont(ofSize: 11, weight: .regular)
        unitAttr.yy_color = .COLOR_GRAY_BLACK_45
        
        titAttr.append(centerAtter)
        titAttr.append(unitAttr)
        
        titAttr.yy_alignment = .center
        pieChartView.centerAttributedText = titAttr

//        pieChartView.setNeedsDisplay()
    }
}

extension FoodsMergeNaturalVM{
    func setDataSource(array:NSArray)  {
        let carboNum = (array[0] as? Double ?? 0)*4
        let proteinNum = (array[1] as? Double ?? 0)*4
        let fatNum = (array[2] as? Double ?? 0)*9
        
        var total = carboNum + proteinNum + fatNum
        
        if total == 0 {
            total = 1
        }
        
        var carboPercent = carboNum/total * 100
        var proteinPercent = proteinNum/total * 100
        
        let fatPercent = 100 - Int(carboPercent.rounded()) - Int(proteinPercent.rounded())
        
        carboItemVm.itemTitleLabel.text = "碳水 \(Int(carboPercent.rounded()))%"
        proteinItemVm.itemTitleLabel.text = "蛋白质 \(Int(proteinPercent.rounded()))%"
        fatItemVm.itemTitleLabel.text = "脂肪 \(Int(fatPercent))%"
        
        carboItemVm.weightLabel.text = "\(WHUtils.convertStringToString("\(String(format: "%.1f", array[0] as? Double ?? 0))") ?? "")g"
        proteinItemVm.weightLabel.text = "\(WHUtils.convertStringToString("\(String(format: "%.1f", array[1] as? Double ?? 0))") ?? "")g"
        fatItemVm.weightLabel.text = "\(WHUtils.convertStringToString("\(String(format: "%.1f", array[2] as? Double ?? 0))") ?? "")g"
        
        setChart(dataPoints: nameArray, values: [carboNum,proteinNum,fatNum])
    }
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
          pichartDataSet.selectionShift = 0 //选中区块时, 放大的半径
//          pichartDataSet.selectionShift = 2 //选中区块时, 放大的半径
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
          pieChartData.setValueFormatter(DigitValueForma() as ValueFormatter)//设置百分比
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
          pieChartView.holeColor = .clear
          
//          let centerAtter = NSMutableAttributedString(string: "680\n千卡")
//          centerAtter.yy_font = .systemFont(ofSize: 14, weight: .medium)
//          centerAtter.yy_color = .COLOR_GRAY_BLACK_85
//          pieChartView.centerAttributedText = centerAtter

          pieChartView.setNeedsDisplay()
      }
}

extension FoodsMergeNaturalVM:ChartViewDelegate{
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
}
