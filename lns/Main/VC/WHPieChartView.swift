//
//  WHPieChartView.swift
//  lns
//
//  Created by LNS2 on 2024/5/29.
//

import Foundation

struct Point_Model {
    var percent = Float(0)
    var color = UIColor()
    var title = ""
    var weight = Float(0)
}

//弧形
class WHPieChartView : UIView{
    
    // 创建一个UIBezierPath对象
    var arcPathProtein = UIBezierPath()
    var arcPathFat = UIBezierPath()
    var arcPathCarbo = UIBezierPath()
    var arcPath = UIBezierPath()
    
    let shapeLayerProtein = CAShapeLayer()
    let shapeLayerFat = CAShapeLayer()
    let shapeLayerCarbo = CAShapeLayer()
    let shapeLayer = CAShapeLayer()
    
    let lineOneLayer = CAShapeLayer()
    let lineTwoLayer = CAShapeLayer()
    let lineThreeLayer = CAShapeLayer()
    
    let colors:[UIColor] = [UIColor.COLOR_PROTEIN,UIColor.COLOR_FAT,UIColor.COLOR_CARBOHYDRATE]
    let titles:[String] = ["蛋白质","脂肪","碳水化合物"]
    var weight:[Float] = []
    var percents:[Point_Model] = []
    var arcCenterPoint:[CGPoint] = []
    var arcCenterPointOut:[CGPoint] = []
    
    let lineOutWidth:[CGFloat] = [kFitWidth(20),kFitWidth(20),kFitWidth(40)]
    let lableHeight = kFitWidth(40)
    let labelWidht = kFitWidth(100)
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(shapeLayerProtein)
        self.layer.addSublayer(shapeLayerFat)
        self.layer.addSublayer(shapeLayerCarbo)
        
        self.layer.addSublayer(lineOneLayer)
        self.layer.addSublayer(lineTwoLayer)
        self.layer.addSublayer(lineThreeLayer)
        
        
        addSubview(labelOne)
        addSubview(labelTwo)
        addSubview(labelThree)
        addSubview(centerLabel)
        
        centerLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        self.drawCircle()
    }
    lazy var labelOne: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var labelTwo: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var labelThree: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var centerLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        return lab
    }()
}

extension WHPieChartView{
    func setPercents(numer:NSArray) {
        weight.removeAll()
        percents.removeAll()
        
        var total = Float(0)
        for i in 0..<numer.count{
            var num = numer[i]as? Float ?? 0
            weight.append(num)
            
            if i == 1 {
                num = num*9
            }else{
                num = num*4
            }
            total = total + num
        }
        if total == 0 {
            total = 1
        }
        for i in 0..<numer.count{
            var num = numer[i]as? Float ?? 0
            if i == 1 {
                num = num*9
            }else{
                num = num*4
            }
            
            var model = Point_Model()
            model.percent = num/total
            model.color = colors[i]
            model.title = titles[i]
            model.weight = weight[i]
            
            percents.append(model)
        }
        percents.sort { model1, model2 in
            return model1.percent > model2.percent
        }
        
        for model in self.percents {
            DLLog(message: "percentsNum  \(model.title) :\(model.percent) -- \(model.weight)  ")
        }
        self.setNeedsDisplay()
    }
    func setDataPercent(array:[Point_Model])  {
        self.percents = array
        self.setNeedsDisplay()
    }
    func drawCircle() {
        //线宽度
        let lineWidth: CGFloat = kFitWidth(20)
        //半径
        let radius = kFitWidth(50)
        //中心点x
        let centerX = self.bounds.size.width / 2.0
        //中心点y
        let centerY = self.bounds.size.height / 2.0
        //弧度起点
        var startAngle = CGFloat(-0.5*Double.pi)
        let centerPoint = CGPoint.init(x: centerX, y: centerY)
        
        arcPath = UIBezierPath()
        arcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: CGFloat(100 * Double.pi*2) + startAngle , clockwise: true)
        shapeLayer.path = arcPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor// colors[i].cgColor // 弧线颜色
        shapeLayer.fillColor = nil // 无填充色
        shapeLayer.lineWidth = lineWidth // 线宽
        
        arcCenterPoint.removeAll()
        arcCenterPointOut.removeAll()
        for i in 0..<percents.count {
            let model = percents[i]
            DLLog(message: "percent ===  \(model.percent)")
            let endAngle = CGFloat(CGFloat(model.percent) * Double.pi*2) + startAngle
            if i == 0 {
                arcPathProtein = UIBezierPath()
                arcPathProtein.addArc(withCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                
                shapeLayerProtein.path = arcPathProtein.cgPath
                shapeLayerProtein.strokeColor = percents[0].color.cgColor// colors[i].cgColor // 弧线颜色
                shapeLayerProtein.fillColor = nil // 无填充色
                shapeLayerProtein.lineWidth = lineWidth // 线宽
            }else if i == 1 {
                arcPathFat = UIBezierPath()
                arcPathFat.addArc(withCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                
                shapeLayerFat.path = arcPathFat.cgPath
                shapeLayerFat.strokeColor = percents[1].color.cgColor// colors[i].cgColor // 弧线颜色
                shapeLayerFat.fillColor = nil // 无填充色
                shapeLayerFat.lineWidth = lineWidth // 线宽
            }else{
                arcPathCarbo = UIBezierPath()
                arcPathCarbo.addArc(withCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                
                shapeLayerCarbo.path = arcPathCarbo.cgPath
                shapeLayerCarbo.strokeColor = percents[2].color.cgColor// colors[i].cgColor // 弧线颜色
                shapeLayerCarbo.fillColor = nil // 无填充色
                shapeLayerCarbo.lineWidth = lineWidth // 线宽
            }
            arcCenterPoint.append(midpointOfArc(center: centerPoint, radius: radius+lineWidth*0.5, startAngle: startAngle, endAngle: endAngle))
            arcCenterPointOut.append(midpointOfArc(center: centerPoint, radius: radius+lineOutWidth[i], startAngle: startAngle, endAngle: endAngle))
            startAngle = endAngle
        }
        
        drawLine()
    }
    
    func drawLine() {
        for i in 0..<arcCenterPoint.count{
            let path = UIBezierPath()
            path.move(to: arcCenterPoint[i])
            let outLinePoint = arcCenterPointOut[i]
            path.addLine(to: outLinePoint)
            
            DLLog(message: "\(outLinePoint.x)  ---  \(outLinePoint.y)")
            
            if i == 0 {
                path.addLine(to: CGPoint(x: outLinePoint.x+kFitWidth(6), y: outLinePoint.y))
                lineOneLayer.path = path.cgPath
                lineOneLayer.strokeColor = WHColor_16(colorStr: "D9D9D9").cgColor
                lineOneLayer.lineWidth = kFitWidth(1)
                lineOneLayer.fillColor = nil
                
                labelOne.frame = CGRect.init(x: outLinePoint.x+kFitWidth(6), y: outLinePoint.y-lableHeight*0.5, width: labelWidht, height: lableHeight)
                labelOne.attributedText = setLabelContent(model: percents[0])
                
            }else if i == 1 {
                path.addLine(to: CGPoint(x: outLinePoint.x-kFitWidth(3), y: outLinePoint.y))
                lineTwoLayer.path = path.cgPath
                lineTwoLayer.strokeColor = WHColor_16(colorStr: "D9D9D9").cgColor
                lineTwoLayer.lineWidth = kFitWidth(1)
                lineTwoLayer.fillColor = nil
                
                let labelW = WHUtils().getWidthOfString(string: "\(percents[1].title) \(String(format: "%.0f", (percents[1].percent*100).rounded()))%", font: .systemFont(ofSize: 12, weight: .regular), height: kFitWidth(15))
                
                labelTwo.frame = CGRect.init(x: outLinePoint.x-kFitWidth(3) - labelW, y: outLinePoint.y-lableHeight*0.5, width: labelW, height: lableHeight)
                labelTwo.attributedText = setLabelContent(model: percents[1])
            }else if i == 2 {
                path.addLine(to: CGPoint(x: outLinePoint.x+kFitWidth(10), y: outLinePoint.y))
                lineThreeLayer.path = path.cgPath
                lineThreeLayer.strokeColor = WHColor_16(colorStr: "D9D9D9").cgColor
                lineThreeLayer.lineWidth = kFitWidth(1)
                lineThreeLayer.fillColor = nil
                
                labelThree.frame = CGRect.init(x: outLinePoint.x+kFitWidth(10), y: outLinePoint.y-lableHeight*0.5, width: labelWidht, height: lableHeight)
                labelThree.attributedText = setLabelContent(model: percents[2])
            }
        }
    }
    
    func midpointOfArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> CGPoint {
        let arcAngle = endAngle - startAngle
        let midAngle = startAngle + arcAngle / 2
     
        let midX = center.x + radius * cos(midAngle)
        let midY = center.y + radius * sin(midAngle)
     
        return CGPoint(x: midX, y: midY)
    }
    func setLabelContent(model:Point_Model) -> NSAttributedString {
        let titleAttr = NSMutableAttributedString(string: "\(model.title) \(String(format: "%.0f", (model.percent*100).rounded()))%\n")
        let numberAttr = NSMutableAttributedString(string: "\(WHUtils.convertStringToString("\(model.weight)") ?? "0")g")
        
        titleAttr.yy_color = model.color
        numberAttr.yy_color = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)//.COLOR_GRAY_BLACK_65
        
        titleAttr.append(numberAttr)
        
        return titleAttr
    }
}
