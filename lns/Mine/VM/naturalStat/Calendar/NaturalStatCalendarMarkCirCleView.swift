//
//  NaturalStatCalendarMarkCirCleView.swift
//  lns
//
//  Created by LNS2 on 2024/9/13.
//

import Foundation

//弧形
class NaturalStatCalendarMarkCirCleView : UIView{
    
    var totalValue = 100
    var value = Double(0.00)
    var percent = 0.0
    
    // 创建一个UIBezierPath对象
    var bottomArcPath = UIBezierPath()
    var arcPath = UIBezierPath()
    var arcPathSecond = UIBezierPath()
    var leftArcPath = UIBezierPath()
    
    let bottomShapeLayer = CAShapeLayer()
    let shapeLayer = CAShapeLayer()
    let shapeLayerSecond = CAShapeLayer()
    let leftCoverShapeLayer = CAShapeLayer()
    
    var circelWidth = kFitWidth(6)
    var radiusWidth = kFitWidth(0)
    
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
        self.value = number//total - number
        if self.value <= 0 {
            self.percent = 0
        }else{
            if total > 0{
                self.percent = self.value/total
            }else{
                self.percent = self.value/1
            }
        }
        
//        DLLog(message: "\(self.percent)")
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        self.drawCircle()
    }
    
    func drawCircle() {
        //线宽度
        let lineWidth: CGFloat = circelWidth+kFitWidth(2)//kFitWidth(10) - circelGap
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
        
        bottomArcPath = UIBezierPath()
        bottomArcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle: Double.pi*2, clockwise: true)
        
        arcPath = UIBezierPath()
        // 将路径的起点设置为圆弧的起始点
        leftArcPath = UIBezierPath()
        leftArcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY),
                           radius: radius,
                           startAngle: CGFloat(-0.54*Double.pi),
                           endAngle: startAngle, clockwise: true)
        leftCoverShapeLayer.path = leftArcPath.cgPath
        leftCoverShapeLayer.strokeColor = WHColor_RGB(r: 194, g: 223, b: 255).cgColor
        leftCoverShapeLayer.fillColor = nil
        leftCoverShapeLayer.lineWidth = lineWidth
        
        // 将CAShapeLayer作为子层添加到视图的layer中
        self.layer.addSublayer(bottomShapeLayer)
        self.layer.addSublayer(shapeLayer)
//        self.layer.addSublayer(leftCoverShapeLayer)
        
        if self.percent == 0 {
            leftCoverShapeLayer.strokeColor = UIColor.clear.cgColor
        }else if self.percent < 0.98{
            leftCoverShapeLayer.strokeColor = WHColor_RGB(r: 194, g: 223, b: 255).cgColor
        }else{
            leftCoverShapeLayer.strokeColor = UIColor.clear.cgColor
        }
        
        arcPathSecond = UIBezierPath()
        if self.percent > 0.1 {
            // 添加一个圆弧到路径
            arcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle - CGFloat(0.1*Double.pi), clockwise: true)
            arcPathSecond.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: CGFloat(-0.45*Double.pi), endAngle: endAngle, clockwise: true)
            shapeLayerSecond.strokeColor = UIColor.THEME.cgColor // 弧线颜色
            shapeLayer.lineCap = .square
            leftCoverShapeLayer.isHidden = true
        }else {
            // 添加一个圆弧到路径
            arcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            arcPathSecond.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            shapeLayerSecond.strokeColor = UIColor.clear.cgColor // 弧线颜色
            shapeLayer.lineCap = .round
            leftCoverShapeLayer.isHidden = false
        }
        
        bottomShapeLayer.path = bottomArcPath.cgPath
        bottomShapeLayer.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor // 弧线颜色
        bottomShapeLayer.fillColor = nil // 无填充色
        bottomShapeLayer.lineWidth = circelWidth // 线宽
        
           // 创建CAShapeLayer
       shapeLayer.path = arcPath.cgPath
       shapeLayer.allowsEdgeAntialiasing = true
//        shapeLayer.contentsScale = 0.3 //UIScreen.main.scale
       shapeLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
       shapeLayer.fillColor = nil // 无填充色
       shapeLayer.lineWidth = lineWidth // 线宽
//        shapeLayer.lineJoin = .round
               
        
        shapeLayerSecond.path = arcPathSecond.cgPath
        shapeLayerSecond.allowsEdgeAntialiasing = true
        
        shapeLayerSecond.fillColor = nil // 无填充色
        shapeLayerSecond.lineWidth = lineWidth // 线宽
        shapeLayerSecond.lineCap = .round
        
        self.layer.addSublayer(shapeLayerSecond)
    }
}
