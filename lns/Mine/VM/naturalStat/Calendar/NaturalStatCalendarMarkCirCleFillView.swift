//
//  NaturalStatCalendarMarkCirCleFillView.swift
//  lns
//
//  Created by LNS2 on 2024/9/13.
//

import Foundation

//弧形
class NaturalStatCalendarMarkCirCleFillView : UIView{
    
    var totalValue = 100
    var value = Double(0.00)
    var percent = 0.0
    var circelWidth = kFitWidth(8)
    var radiusWidth = kFitWidth(0)
    
    // 创建一个UIBezierPath对象
    var arcPath = UIBezierPath()
    var leftArcPath = UIBezierPath()
    
    let shapeLayer = CAShapeLayer()
    let leftCoverShapeLayer = CAShapeLayer()
    let shapeLayerShadow = CAShapeLayer()
    
    var editBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
//        drawCircle()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setValue(number:Double,total:Double) {
        self.value = number - total
        if self.value <= 0 {
            self.percent = 0
        }else{
            if total > 0 {
                self.percent = self.value/total
            }else{
                self.percent = self.value/1
            }
        }
        
        if self.percent > 1 {
            self.percent = 1
        }
        
//        DLLog(message: "\(self.percent)")
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        self.drawCircle()
    }
    
    func drawCircle() {
        //线宽度
        let lineWidth: CGFloat = circelWidth//kFitWidth(10) - circelGap
        //半径
        let radius = self.bounds.size.width / 2.0 //- kFitWidth(16) - radiusWidth
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
        // 添加一个圆弧到路径
        arcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
 
        // 创建CAShapeLayer
        shapeLayer.path = arcPath.cgPath
        shapeLayer.allowsEdgeAntialiasing = true
        shapeLayer.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25).cgColor // 弧线颜色
        shapeLayer.fillColor = nil // 无填充色
        shapeLayer.lineWidth = lineWidth // 线宽
        shapeLayer.lineCap = .round
//        shapeLayer.lineJoin = .miter
        
        leftArcPath = UIBezierPath()
        leftArcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY),
                           radius: radius,
                           startAngle: CGFloat(-0.54*Double.pi),
                           endAngle: startAngle, clockwise: true)
        leftCoverShapeLayer.path = leftArcPath.cgPath
        leftCoverShapeLayer.strokeColor = UIColor.THEME.cgColor
        leftCoverShapeLayer.fillColor = nil
        leftCoverShapeLayer.lineWidth = lineWidth
//        leftCoverShapeLayer.lineCap = .square
        
        // 创建CAShapeLayer
        shapeLayerShadow.path = arcPath.cgPath
        shapeLayerShadow.allowsEdgeAntialiasing = true
        shapeLayerShadow.strokeColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.55).cgColor // 弧线颜色
        shapeLayerShadow.fillColor = nil // 无填充色
        shapeLayerShadow.lineDashPhase = kFitWidth(2)
        shapeLayerShadow.lineWidth = lineWidth // 线宽
        shapeLayerShadow.lineDashPattern = [1,4]
 
        // 将CAShapeLayer作为子层添加到视图的layer中
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(shapeLayerShadow)
        self.layer.addSublayer(leftCoverShapeLayer)
        if self.percent > 0.98 || self.percent <= 0{
            leftCoverShapeLayer.strokeColor = UIColor.clear.cgColor
        }
    }
}
