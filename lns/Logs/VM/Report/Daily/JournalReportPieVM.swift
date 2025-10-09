//
//  JournalReportPieVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/9.
//

enum PID_TYPE {
    case MEALS
    case CALORIES
}

class JournalReportPieVM: UIView {
    
    let selfHeight = kFitWidth(146)
    
    let maxRadius = kFitWidth(55)//最大值的半径
    let maxLineWidth = kFitWidth(36)//最大值的线宽
    let minRadius = kFitWidth(52)//非最大值的半径
    let minLineWidth = kFitWidth(30)//非最大值的线宽
    
    let circleCenter = CGPoint(x: SCREEN_WIDHT*0.5, y: kFitWidth(146)*0.5)
    
    var dataType = PID_TYPE.CALORIES
    var dataSourceArray = NSArray()
    var maxValue = Float(0)
    
    var mealsDataArray = [ReportCaloriesModel]()
    
    var percentBlock:((Float,Float,Float)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension JournalReportPieVM{
    func updateDataSource(array:NSArray,type:PID_TYPE) {
        self.dataType = type
        if self.dataType == .MEALS{
            self.mealsDataArray = array as! [ReportCaloriesModel]
        }else{
            self.dataSourceArray = array
        }
        
        self.refreshLayer()
    }
}


extension JournalReportPieVM{
    func refreshLayer() {
        if self.layer.sublayers?.count ?? 0 > 0 {
            for i in 0..<(self.layer.sublayers?.count ?? 0) {
                let lay = self.layer.sublayers?[i]
                lay?.removeFromSuperlayer()
//                lay?.isHidden = true
            }
        }
        initBottomLayer()
        maxValue = Float(0)
        switch self.dataType {
        case .CALORIES:
            self.refreshUIForCalories()
            break
        case .MEALS:
            self.refreshUIForMeals()
            break
        }
    }
    func refreshUIForMeals() {
        for model in mealsDataArray{
            let percent = model.percent * 0.01
            if maxValue < percent{
                maxValue = percent
            }
        }
        
        var startAngle = -Double.pi*0.5
        for i in 0..<mealsDataArray.count{
            let model = mealsDataArray[i]
            let circleLayer = CAShapeLayer()
            let circlePath = UIBezierPath()
            let percent = model.percent*0.01
            
            circleLayer.allowsEdgeAntialiasing = true
            circleLayer.fillColor = nil // 无填充色
            circleLayer.strokeColor = model.color.cgColor
            var endAngle = startAngle + Double(percent)*Double.pi*2
            if i == mealsDataArray.count - 1 && i > 0{
                endAngle = -Double.pi*0.5
            }
            self.layer.addSublayer(circleLayer)
            var radius = minRadius
            circleLayer.lineWidth = minLineWidth
            if maxValue > 0 {
                radius = Float(percent) >= maxValue ? maxRadius : minRadius
                circleLayer.lineWidth = Float(percent) >= maxValue ? maxLineWidth : minLineWidth
            }
            
            circlePath.addArc(withCenter: circleCenter,
                              radius: radius,
                              startAngle: startAngle,
                              endAngle: endAngle,
                              clockwise: true)
            circleLayer.path = circlePath.cgPath
            startAngle = endAngle
        }
    }
    ///刷新热量来源分布的UI显示
    func refreshUIForCalories() {
        let carboNum = (dataSourceArray[0] as? Double ?? 0)*4
        let proteinNum = (dataSourceArray[1] as? Double ?? 0)*4
        let fatNum = (dataSourceArray[2] as? Double ?? 0)*9
        var total = carboNum + proteinNum + fatNum
        
        if total == 0 {
            total = 1
        }
        
        DLLog(message: "\(carboNum)   \(proteinNum)    \(fatNum)")
        
        let carboPercent = carboNum/total
        let proteinPercent = proteinNum/total
        let fatPercent = 1 - carboPercent - proteinPercent
        
        var dataPercentArray = [carboPercent,proteinPercent,fatPercent]
        
        var hasData = false
        for i in 0..<dataSourceArray.count{
            let num = dataSourceArray[i]as? Double ?? 0
            if num > 0{
                hasData = true
                break
            }
        }
        for i in 0..<dataPercentArray.count{
            let percent = dataPercentArray[i]
            if Double(maxValue) < percent{
                maxValue = Float(percent)
            }
        }
        if hasData == false {
            self.percentBlock?(0,0,0)
//            maxValue = 0
//            dataPercentArray = [0.3333,0.3333,0.3334]
        }else{
            self.percentBlock?(Float(carboPercent),Float(proteinPercent),Float(fatPercent))
            var startAngle = -Double.pi*0.5
            for i in 0..<dataPercentArray.count{
                let circleLayer = CAShapeLayer()
                let circlePath = UIBezierPath()
                let percent = dataPercentArray[i]
                
                circleLayer.allowsEdgeAntialiasing = true
                circleLayer.fillColor = nil // 无填充色
                
                
                var endAngle = startAngle + percent*Double.pi*2
                if i == 0 {
                    circleLayer.strokeColor = UIColor.COLOR_CARBOHYDRATE.cgColor // 弧线颜色
                }else if i == 1 {
                    circleLayer.strokeColor = UIColor.COLOR_PROTEIN.cgColor // 弧线颜色
                }else if i == 2 {
                    circleLayer.strokeColor = UIColor.COLOR_FAT.cgColor // 弧线颜色
                    endAngle = -Double.pi*0.5
                }
                self.layer.addSublayer(circleLayer)
                var radius = minRadius
                circleLayer.lineWidth = minLineWidth
                if maxValue > 0 {
                    radius = Float(percent) >= maxValue ? maxRadius : minRadius
                    circleLayer.lineWidth = Float(percent) >= maxValue ? maxLineWidth : minLineWidth
                }
                
                circlePath.addArc(withCenter: circleCenter,
                                  radius: radius,
                                  startAngle: startAngle,
                                  endAngle: endAngle,
                                  clockwise: true)
                circleLayer.path = circlePath.cgPath
                startAngle = endAngle
            }
        }
    }
    func initBottomLayer() {
        let circleLayer = CAShapeLayer()
        let circlePath = UIBezierPath()
        
        circleLayer.allowsEdgeAntialiasing = true
        circleLayer.fillColor = nil // 无填充色
        circleLayer.strokeColor = UIColor.COLOR_BG_F5.cgColor
        circleLayer.lineWidth = minLineWidth
        self.layer.addSublayer(circleLayer)
        
        circlePath.addArc(withCenter: circleCenter,
                          radius: minRadius,
                          startAngle: -0.5*Double.pi,
                          endAngle: 1.5*Double.pi,
                          clockwise: true)
        circleLayer.path = circlePath.cgPath
    }
}
