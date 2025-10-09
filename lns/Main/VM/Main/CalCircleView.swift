//
//  CalCircleView.swift
//  lns
//
//  Created by LNS2 on 2024/4/10.
//

import Foundation

//弧形
class CalCircleView : UIView{
    
    var totalValue = 100
    var value = Double(0.00)
    var valueSport = Double(0.00)
    var percent = 0.0
    var percentSport = 0.0
    
    // 创建一个UIBezierPath对象
    var arcPath = UIBezierPath()
    var arcPathSecond = UIBezierPath()
    var leftArcPath = UIBezierPath()
    let shapeLayer = CAShapeLayer()
    let shapeLayerSecond = CAShapeLayer()
    let leftCoverShapeLayer = CAShapeLayer()
    let shapeCircleShapeLayer = CAShapeLayer()
    
    var sportArcPath = UIBezierPath()
    var sportCirclePath = UIBezierPath()
    let sportShapeLayer = CAShapeLayer()
    let sportCircleShapeLayer = CAShapeLayer()
    
    
    var circelWidth = kFitWidth(10)
    var radiusWidth = kFitWidth(0)
    
    
    var naturalPath = UIBezierPath()
    var naturalPathSecond = UIBezierPath()
    var sportPath = UIBezierPath()
    var sportPathSecond = UIBezierPath()
    var leftSportCoverPath = UIBezierPath()
    
    let naturalShapeLayer = CAShapeLayer()
    let naturalShapeLayerSecond = CAShapeLayer()
    let sportLayer = CAShapeLayer()
    let sportLayerSecond = CAShapeLayer()
    
    let leftSportCoverLayer = CAShapeLayer()
    
    //线宽度
    var lineWidth: CGFloat = kFitWidth(10)
    //半径
    var radius = kFitWidth(16)
    //中心点x
    var centerX = kFitWidth(0)
    //中心点y
    var centerY = kFitWidth(0)
    let startAngle = CGFloat(-0.5*Double.pi)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(156), height: kFitWidth(156)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        radius = self.bounds.size.width / 2.0 - kFitWidth(16)
        centerX = self.bounds.size.width / 2.0
        centerY = self.bounds.size.height / 2.0
//        drawCircle()
        
//        initLayer()
        initLayerByPath()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "C2DFFF")
        return vi
    }()
    func setValue(number:Double,total:Double) {
        self.value = number//total - number
        if self.value <= 0 {
            self.percent = 0
        }else{
            self.percent = self.value/total
        }
        setNeedsDisplay()
    }
    //MARK: 运动消耗
    func setValueSport(number:Double,sport:Double,total:Double) {
        self.value = number//total - number
        self.valueSport = sport
        if self.value <= 0 {
            self.percent = 0
        }else{
            self.percent = self.value/total
//            let tanValue = lineWidth*0.5/(radius-kFitWidth(5))
//            let angle = atan(tanValue)
//            let percent = angle * (180/Double.pi) / 360
//            if self.percent < percent {
//                self.percent = percent
//            }
        }
        if self.valueSport <= 0 {
            self.percentSport = 0
        }else{
            self.percentSport = self.valueSport/total
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
//        self.drawSportCircle()
//        self.drawCircle()
//        drawCircleSport()
        
        drawCircleByPath()
    }
    //MARK: 纯路径绘制圆环
    func drawCircleByPath() {
        let gap = kFitWidth(0.5)
        naturalPath = UIBezierPath()
        naturalPath.move(to: CGPoint.init(x: centerX+gap, y: centerY-radius-lineWidth*0.5))
        naturalPath.addLine(to: CGPoint.init(x: centerX+gap, y: centerY-radius+lineWidth*0.5))
        
        //弧度终点
        let endAngle = CGFloat((self.percent) * Double.pi*2) - 0.5 * Double.pi
        naturalPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius-lineWidth*0.5, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        naturalShapeLayer.path = naturalPath.cgPath
        
        let pathTemp = UIBezierPath()
        pathTemp.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        naturalShapeLayerSecond.path = pathTemp.cgPath
        
        let firstPoint = naturalPath.currentPoint
        let endPoint = pathTemp.currentPoint
        
        let circleCenter = CGPoint.init(x: (firstPoint.x+endPoint.x)*0.5, y: (firstPoint.y+endPoint.y)*0.5)
        
//        naturalPath.addArc(withCenter: circleCenter, radius: lineWidth*0.5, startAngle:  -0.5 * Double.pi, endAngle: 6*Double.pi, clockwise: true)
        naturalPath.addArc(withCenter: circleCenter, radius: lineWidth*0.5, startAngle:  endAngle+Double.pi, endAngle: endAngle, clockwise: false)
        naturalPath.addLine(to: endPoint)
        naturalPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        naturalPath.addLine(to: CGPoint.init(x: centerX+gap, y: centerY-radius-lineWidth*0.5))
        
        naturalShapeLayer.path = naturalPath.cgPath
        
        sportPath = UIBezierPath()
        sportPath.move(to: CGPoint.init(x: centerX-gap, y: centerY-radius-lineWidth*0.5))
        sportPath.addLine(to: CGPoint.init(x: centerX-gap, y: centerY-radius+lineWidth*0.5))
        //弧度终点
        let sportEndAngle = CGFloat((1-self.percentSport) * Double.pi*2) - 0.5 * Double.pi
        sportPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius-lineWidth*0.5, startAngle: startAngle, endAngle: sportEndAngle, clockwise: false)
        
        sportLayer.path = sportPath.cgPath
        
        let pathTempSport = UIBezierPath()
        pathTempSport.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: startAngle, endAngle: sportEndAngle, clockwise: false)
        naturalShapeLayerSecond.path = pathTempSport.cgPath
        
        let firstPointSport = sportPath.currentPoint
        let endPoinSportt = pathTempSport.currentPoint
        
        let circleCenterSport = CGPoint.init(x: (firstPointSport.x+endPoinSportt.x)*0.5, y: (firstPointSport.y+endPoinSportt.y)*0.5)
        
//        sportPath.addArc(withCenter: circleCenterSport, radius: lineWidth*0.5, startAngle:  -0.5 * Double.pi, endAngle: 6*Double.pi, clockwise: true)
        sportPath.addArc(withCenter: circleCenterSport, radius: lineWidth*0.5, startAngle:  sportEndAngle+Double.pi, endAngle: sportEndAngle, clockwise: true)
        sportPath.addLine(to: endPoinSportt)
        sportPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: sportEndAngle, endAngle: startAngle, clockwise: true)
        sportPath.addLine(to: CGPoint.init(x: centerX-gap, y: centerY-radius-lineWidth*0.5))
        
        sportLayer.path = sportPath.cgPath
        
        if self.percent > 0 {
            naturalShapeLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
            naturalShapeLayer.fillColor = UIColor.THEME.cgColor // 无填充色
        }else{
            naturalShapeLayer.strokeColor = UIColor.clear.cgColor // 弧线颜色
            naturalShapeLayer.fillColor = UIColor.clear.cgColor // 无填充色
//            naturalShapeLayer.strokeColor = WHColor_16(colorStr: "C2DFFF").cgColor // 弧线颜色
//            naturalShapeLayer.fillColor = WHColor_16(colorStr: "C2DFFF").cgColor // 无填充色
        }
        if self.percentSport > 0 {
            sportLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
            sportLayer.fillColor = UIColor.COLOR_SPORT.cgColor // 无填充色
        }else{
            sportLayer.strokeColor = UIColor.clear.cgColor // 弧线颜色
            sportLayer.fillColor = UIColor.clear.cgColor // 无填充色
        }
//        
//        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        strokeAnimation.fromValue = 0
//        strokeAnimation.toValue = 1.0
//        strokeAnimation.duration = 3.0
//        strokeAnimation.repeatCount = 5
//        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        
//        // 添加动画到线段layer
////        sportLayer.add(shortenAnimation, forKey: "animationKey")
//        DispatchQueue.main.asyncAfter(deadline:.now()+0.3, execute: {
//            self.sportLayer.add(strokeAnimation, forKey: "strokeEnd")
//        })
    }
    func initLayerByPath() {
        self.layer.addSublayer(sportLayer)
        self.layer.addSublayer(naturalShapeLayer)
        
        naturalShapeLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        naturalShapeLayer.fillColor = UIColor.THEME.cgColor // 无填充色
        naturalShapeLayer.lineWidth = kFitWidth(0.2) // 线宽
        
        sportLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
        sportLayer.fillColor = UIColor.COLOR_SPORT.cgColor // 无填充色
        sportLayer.lineWidth = kFitWidth(0.2) // 线宽
    }
    //MARK: 2024年11月26日   加入运动消耗后的圆环
    func drawCircleSport() {
        naturalPath = UIBezierPath()
        naturalPathSecond = UIBezierPath()
        sportPath = UIBezierPath()
        sportPathSecond = UIBezierPath()
        //弧度终点
        let endAngle = CGFloat((self.percent) * Double.pi*2) - 0.5 * Double.pi
//        let firstEndAngle = CGFloat((self.percent - 0.13889) * Double.pi*2) - 0.5 * Double.pi
        DLLog(message: "\(startAngle)   --   \(endAngle)")
        naturalPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle+0.06, endAngle: endAngle-0.13889, clockwise: true)
        naturalShapeLayer.path = naturalPath.cgPath
        
        naturalPathSecond.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle+0.06, endAngle: endAngle, clockwise: true)
        naturalShapeLayerSecond.path = naturalPathSecond.cgPath
        
        if self.percentSport > 0 {
            sportLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
            sportLayerSecond.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
            //弧度终点
            let sportEndAngle = 2 * Double.pi - CGFloat((self.percentSport) * Double.pi*2) - 0.5 * Double.pi
            sportPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: sportEndAngle, endAngle: startAngle-0.02, clockwise: true)
            sportLayer.path = sportPath.cgPath
            
            sportPathSecond.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: sportEndAngle-0.13889, endAngle: startAngle-0.02, clockwise: true)
            sportLayerSecond.path = sportPathSecond.cgPath
        }else{
            sportLayer.strokeColor = UIColor.clear.cgColor // 弧线颜色
            sportLayerSecond.strokeColor = UIColor.clear.cgColor // 弧线颜色
        }
        
        
//        if self.percentSport > 0 {
//            leftSportCoverLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
//        }else{
//            leftSportCoverLayer.strokeColor = WHColor_16(colorStr: "C2DFFF").cgColor // 弧线颜色
//        }
//        //弧度终点
//        let sportCoverEndAngle = 2 * Double.pi - CGFloat(0.1 * Double.pi*2) - 0.5 * Double.pi
//        leftSportCoverPath = UIBezierPath()
//        
//        leftSportCoverPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: sportCoverEndAngle, endAngle: startAngle, clockwise: true)
//        leftSportCoverLayer.path = leftSportCoverPath.cgPath
    }
    func initLayer() {
        self.layer.addSublayer(sportLayer)
        self.layer.addSublayer(sportLayerSecond)
        self.layer.addSublayer(naturalShapeLayer)
        self.layer.addSublayer(naturalShapeLayerSecond)
        self.layer.addSublayer(leftSportCoverLayer)
        
        naturalShapeLayer.lineCap = .square
        naturalShapeLayer.allowsEdgeAntialiasing = true
        naturalShapeLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        naturalShapeLayer.fillColor = nil // 无填充色
        naturalShapeLayer.lineWidth = lineWidth // 线宽
        
        naturalShapeLayerSecond.lineCap = .round
        naturalShapeLayerSecond.allowsEdgeAntialiasing = true
        naturalShapeLayerSecond.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        naturalShapeLayerSecond.fillColor = nil // 无填充色
        naturalShapeLayerSecond.lineWidth = lineWidth // 线宽
        
        sportLayer.lineCap = .square
        sportLayer.allowsEdgeAntialiasing = true
        sportLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
        sportLayer.fillColor = nil // 无填充色
        sportLayer.lineWidth = lineWidth // 线宽
        
        sportLayerSecond.lineCap = .round
        sportLayerSecond.allowsEdgeAntialiasing = true
        sportLayerSecond.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
        sportLayerSecond.fillColor = nil // 无填充色
        sportLayerSecond.lineWidth = lineWidth // 线宽
        
        leftSportCoverLayer.lineCap = .square
        leftSportCoverLayer.allowsEdgeAntialiasing = true
        leftSportCoverLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
        leftSportCoverLayer.fillColor = nil // 无填充色
        leftSportCoverLayer.lineWidth = lineWidth // 线宽
        
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(centerY-radius-lineWidth*0.5-kFitWidth(2))
            make.width.equalTo(kFitWidth(5))
            make.height.equalTo(kFitWidth(14))
        }
    }
    func drawCircle() {
        //线宽度
        let lineWidth: CGFloat = circelWidth//kFitWidth(10) - circelGap
        //半径
        let radius = self.bounds.size.width / 2.0 - kFitWidth(16) - radiusWidth
        //中心点x
        let centerX = self.bounds.size.width / 2.0
        //中心点y
        let centerY = self.bounds.size.height / 2.0
        //弧度起点
        let startAngle = CGFloat(-0.5*Double.pi)
        //弧度终点
        let endAngle = CGFloat(self.percent * Double.pi*2) - 0.5 * Double.pi
        
        arcPath = UIBezierPath()
        // 将路径的起点设置为圆弧的起始点
//        arcPath.move(to: CGPoint(x: center.x + radius * cos(startAngle), y: center.y + radius * sin(startAngle)))
 
//        leftArcPath = UIBezierPath()
//        leftArcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY),
//                           radius: radius,
//                           startAngle: CGFloat(-0.35*Double.pi),
//                           endAngle: startAngle, clockwise: true)
//        leftCoverShapeLayer.path = leftArcPath.cgPath
//        leftCoverShapeLayer.strokeColor = WHColor_RGB(r: 194, g: 223, b: 255).cgColor
//        leftCoverShapeLayer.fillColor = nil
//        leftCoverShapeLayer.lineWidth = lineWidth
        
        // 将CAShapeLayer作为子层添加到视图的layer中
        self.layer.addSublayer(shapeLayer)
//        self.layer.addSublayer(leftCoverShapeLayer)
        
//        if self.percent == 0 {
//            leftCoverShapeLayer.strokeColor = UIColor.clear.cgColor
//        }else if self.percent < 0.98{
//            leftCoverShapeLayer.strokeColor = WHColor_RGB(r: 194, g: 223, b: 255).cgColor
//        }else{
//            leftCoverShapeLayer.strokeColor = UIColor.clear.cgColor
//        }
        
//        arcPathSecond = UIBezierPath()
//        if self.percent > 0.08 {
            // 添加一个圆弧到路径
            arcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//            arcPathSecond.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: CGFloat(0.03*Double.pi)+startAngle, endAngle: endAngle, clockwise: true)
//            shapeLayerSecond.strokeColor = UIColor.THEME.cgColor // 弧线颜色
            shapeLayer.lineCap = .square
//            leftCoverShapeLayer.isHidden = true
//        }else {
//            // 添加一个圆弧到路径
//            arcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//            arcPathSecond.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//            shapeLayerSecond.strokeColor = UIColor.clear.cgColor // 弧线颜色
//            shapeLayer.lineCap = .round
//            leftCoverShapeLayer.isHidden = false
//        }
        
           // 创建CAShapeLayer
       shapeLayer.path = arcPath.cgPath
       shapeLayer.allowsEdgeAntialiasing = true
//        shapeLayer.contentsScale = 0.3 //UIScreen.main.scale
       shapeLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
       shapeLayer.fillColor = nil // 无填充色
       shapeLayer.lineWidth = lineWidth // 线宽
        shapeLayer.lineJoin = .round
//        shapeLayerSecond.path = arcPathSecond.cgPath
//        shapeLayerSecond.allowsEdgeAntialiasing = true
//        shapeLayerSecond.fillColor = nil // 无填充色
//        shapeLayerSecond.lineWidth = lineWidth // 线宽
//        shapeLayerSecond.lineCap = .round
//        
//        self.layer.addSublayer(shapeLayerSecond)
        
//        self.layer.addSublayer(shapeCircleShapeLayer)
//        let circlePath = UIBezierPath()
//        circlePath.addArc(withCenter: CGPoint(x: centerX + (radius+lineWidth*0.5) * cos(endAngle), y: centerY + (radius-lineWidth*0.5) * sin(endAngle)), radius: lineWidth*0.5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
//        shapeCircleShapeLayer.path = circlePath.cgPath
//        shapeCircleShapeLayer.strokeColor = UIColor.red.cgColor // 弧线颜色
//        shapeCircleShapeLayer.lineCap = .round
//        shapeCircleShapeLayer.allowsEdgeAntialiasing = true
//        shapeCircleShapeLayer.fillColor = UIColor.red.cgColor // 无填充色
//        shapeCircleShapeLayer.lineWidth = kFitWidth(0.02) // 线宽
    }
    func drawSportCircle() {
        //线宽度
        let lineWidth: CGFloat = circelWidth//kFitWidth(10) - circelGap
        //半径
        let radius = self.bounds.size.width / 2.0 - kFitWidth(16) - radiusWidth
        //中心点x
        let centerX = self.bounds.size.width / 2.0
        //中心点y
        let centerY = self.bounds.size.height / 2.0
        //弧度起点
        let startAngle = CGFloat(-0.5*Double.pi)
        //弧度终点
        let endAngle = CGFloat((1 - self.percentSport) * Double.pi*2) - 0.5 * Double.pi
        
        sportArcPath = UIBezierPath()
        // 添加一个圆弧到路径
        sportArcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        
        sportShapeLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
        sportShapeLayer.lineCap = .round
        sportShapeLayer.path = sportArcPath.cgPath
        sportShapeLayer.allowsEdgeAntialiasing = true
        sportShapeLayer.fillColor = nil // 无填充色
        sportShapeLayer.lineWidth = lineWidth // 线宽
        
        // 在圆弧起点加上小圆
        let smallRadius: CGFloat = lineWidth*0.5
        sportCirclePath = UIBezierPath()
//        sportCirclePath.move(to: CGPoint(x: centerX + smallRadius * cos(startAngle), y: centerY + smallRadius * sin(startAngle)))
        sportCirclePath.addArc(withCenter: CGPoint(x: centerX + radius * cos(endAngle-0.04), y: centerY + radius * sin(endAngle-0.04)), radius: smallRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        sportCircleShapeLayer.path = sportCirclePath.cgPath
        sportCircleShapeLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
        sportCircleShapeLayer.lineCap = .round
        sportCircleShapeLayer.allowsEdgeAntialiasing = true
        sportCircleShapeLayer.fillColor = UIColor.COLOR_SPORT.cgColor // 无填充色
        sportCircleShapeLayer.lineWidth = kFitWidth(0.02) // 线宽
        
        self.layer.addSublayer(sportShapeLayer)
//        self.layer.addSublayer(sportCircleShapeLayer)
    }
}
