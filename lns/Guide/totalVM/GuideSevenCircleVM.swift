//
//  GuideSevenCircleVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/11.
//


import Foundation
import UIKit

class GuideSevenCircleVM: UIView {
    
    var selfWidth = kFitWidth(75)
    var selfHeight = kFitWidth(75)
    
    var currentNum = Int(0)
    var sportNum = Int(0)
    var currentNumFloat = Double(0)
    var totalNum = Int(0)
    
    var circleColor = UIColor.COLOR_CALORI
    var circleFillColor = WHColor_RGB(r: 28, g: 70, b: 140)
    
    private var shapeLayer = CAShapeLayer()
    // 创建CAShapeLayer
    let circleLayer = CAShapeLayer()
//    private var circlePath: UIBezierPath?
    private var endAngle: CGFloat = 0
    // 创建一个UIBezierPath对象
    private var arcPath = UIBezierPath()
    
    private var shapeLayerFill = CAShapeLayer()
    private var shapeLayerFillShadow = CAShapeLayer()
    private var arcPathFill = UIBezierPath()
    private var arcPathFillShadow = UIBezierPath()
    
    var naturalPathBottom = UIBezierPath()
    var naturalPath = UIBezierPath()
    var pathTemp = UIBezierPath()
    var pathTempSport = UIBezierPath()
    var pathTempFill = UIBezierPath()
    let naturalShapeLayer = CAShapeLayer()
    let naturalShapeLayerBottom = CAShapeLayer()
    let naturalShapeLayerSecond = CAShapeLayer()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.1)
        self.isUserInteractionEnabled = true
        self.totalNum = 0
        self.currentNum = 0
        self.currentNumFloat = 0
        selfWidth = frame.size.width
        selfHeight = frame.size.height
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var currentNumberLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%d"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 22)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var totalNumberLabel : UILabel = {
        let lab = UILabel()
        lab.text = "/0"
        lab.font = UIFont().DDInFontRegular(fontSize: 17)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension GuideSevenCircleVM{
    override func draw(_ rect: CGRect) {
        drawCircleByPath()
    }
    //MARK: 纯路径绘制圆环
    func drawCircleByPath() {
        let gap = kFitWidth(0.4)
        var num = self.currentNum//self.totalNum-self.currentNum
        if num < 0 {
            num = 0
        }
        var totalNum = self.totalNum > 0 ? self.totalNum : 1
        let percent = CGFloat(num)/CGFloat(totalNum)
        
        //线宽度
        let lineWidth: CGFloat = kFitWidth(6)
        //半径
        let radius = selfWidth*0.5
        //中心点x
        let centerX = self.bounds.size.width / 2.0
        //中心点y
        let centerY = centerX
        //弧度起点
        let startAngle = CGFloat(-0.5*Double.pi)
        //弧度终点
        let endAngle = CGFloat(percent * Double.pi*2) - 0.5 * Double.pi
        let endAngleBottom = CGFloat(1 * Double.pi*2) - 0.5 * Double.pi
        
        naturalPathBottom = UIBezierPath()
        // 添加一个圆弧到路径
        naturalPathBottom.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngleBottom, clockwise: true)
        naturalShapeLayerBottom.path = naturalPathBottom.cgPath
        
        if percent > 0 {
            naturalShapeLayer.strokeColor = circleColor.cgColor
            naturalShapeLayer.fillColor = circleColor.cgColor
        }else{
            naturalShapeLayer.strokeColor = UIColor.clear.cgColor // 弧线颜色
            naturalShapeLayer.fillColor = UIColor.clear.cgColor // 无填充色
        }
        
        naturalPath = UIBezierPath()
        pathTemp = UIBezierPath()
        naturalPath.move(to: CGPoint.init(x: centerX+gap, y: centerY-radius-lineWidth*0.5))
        naturalPath.addLine(to: CGPoint.init(x: centerX+gap, y: centerY-radius+lineWidth*0.5))
        
        naturalPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius-lineWidth*0.5, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        pathTemp.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let firstPoint = naturalPath.currentPoint
        let endPoint = pathTemp.currentPoint
        
        let circleCenter = CGPoint.init(x: (firstPoint.x+endPoint.x)*0.5, y: (firstPoint.y+endPoint.y)*0.5)
        
        naturalPath.addArc(withCenter: circleCenter, radius: lineWidth*0.5, startAngle:  endAngle+Double.pi, endAngle: endAngle, clockwise: false)
        naturalPath.addLine(to: endPoint)
        naturalPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        naturalPath.addLine(to: CGPoint.init(x: centerX+gap, y: centerY-radius-lineWidth*0.5))
        
        naturalShapeLayer.path = naturalPath.cgPath
        
        /**
                  以下为超出摄入时的圆环
         */
        var fillPercent = percent - 1 > 0 ? percent - 1 : 0
        
        if fillPercent >= 1 {
            fillPercent = 1
        }
        
        if fillPercent <= 0{
            shapeLayerFill.isHidden = true
            shapeLayerFillShadow.isHidden = true
            shapeLayerFill.strokeColor = UIColor.clear.cgColor
            shapeLayerFill.fillColor = UIColor.clear.cgColor
            return
        }else{
            shapeLayerFill.isHidden = false
            shapeLayerFillShadow.isHidden = false
            shapeLayerFill.strokeColor = circleFillColor.cgColor
            shapeLayerFill.fillColor = circleFillColor.cgColor
        }
        
        let endAngleFill = CGFloat(fillPercent * Double.pi*2) - 0.5 * Double.pi
        // 添加一个圆弧到路径
        arcPathFill = UIBezierPath()
        pathTempFill = UIBezierPath()
        arcPathFillShadow = UIBezierPath()
        
        arcPathFill.move(to: CGPoint.init(x: centerX+gap, y: centerY-radius-lineWidth*0.5))
        arcPathFill.addLine(to: CGPoint.init(x: centerX+gap, y: centerY-radius+lineWidth*0.5))
        
        arcPathFill.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius-lineWidth*0.5, startAngle: startAngle, endAngle: endAngleFill, clockwise: true)
        pathTempFill.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: startAngle, endAngle: endAngleFill, clockwise: true)
        naturalShapeLayerSecond.path = pathTempFill.cgPath
        
        let firstPointFill = arcPathFill.currentPoint
        let endPointFill = pathTempFill.currentPoint
        
        let circleCenterFill = CGPoint.init(x: (firstPointFill.x+endPointFill.x)*0.5, y: (firstPointFill.y+endPointFill.y)*0.5)
        arcPathFill.addArc(withCenter: circleCenterFill, radius: lineWidth*0.5, startAngle:  endAngleFill+Double.pi, endAngle: endAngleFill, clockwise: false)
        arcPathFill.addLine(to: endPointFill)
        arcPathFill.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: endAngleFill, endAngle: startAngle, clockwise: false)
        arcPathFill.addLine(to: CGPoint.init(x: centerX+gap, y: centerY-radius-lineWidth*0.5))
        
        shapeLayerFill.path = arcPathFill.cgPath
        
        arcPathFillShadow.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngleFill, clockwise: true)
        shapeLayerFillShadow.path = arcPathFillShadow.cgPath
    }
    func initLayerByPath() {
        self.layer.addSublayer(naturalShapeLayerBottom)
        self.layer.addSublayer(naturalShapeLayer)
        self.layer.addSublayer(shapeLayerFill)
        self.layer.addSublayer(shapeLayerFillShadow)
        
        naturalShapeLayerBottom.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor // 弧线颜色
        naturalShapeLayerBottom.fillColor = nil // 无填充色
        naturalShapeLayerBottom.lineWidth = kFitWidth(4) // 线宽
        
        naturalShapeLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        naturalShapeLayer.fillColor = UIColor.THEME.cgColor // 无填充色
        naturalShapeLayer.lineWidth = kFitWidth(0.2) // 线宽
        
        shapeLayerFill.strokeColor = circleFillColor.cgColor
        shapeLayerFill.fillColor = circleFillColor.cgColor
        shapeLayerFill.lineWidth = kFitWidth(0.2) // 线宽
        
        shapeLayerFillShadow.strokeColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.55).cgColor // 弧线颜色
        shapeLayerFillShadow.lineDashPhase = kFitWidth(2)
        shapeLayerFillShadow.fillColor = nil // 无填充色
        shapeLayerFillShadow.lineWidth = kFitWidth(6) // 线宽
        shapeLayerFillShadow.lineDashPattern = [4,4]
    }
    func setData(currentNumber:Int) {
        self.currentNum = currentNumber
        
        self.currentNumberLabel.text = "\(currentNum)"
        self.totalNumberLabel.text = "\(totalNum)"
        if QuestinonaireMsgModel.shared.caloriesNumber.floatValue > 0 {
            self.totalNum = QuestinonaireMsgModel.shared.caloriesNumber.intValue
        }else{
            let dict = NutritionDefaultModel.shared.getTodayGoal()
            self.totalNum = dict.stringValueForKey(key: "calories").intValue
        }
        self.totalNumberLabel.text = "/\(totalNum)"
        
        setNeedsDisplay()
    }
    
    func initUI() {
        initLayerByPath()
        addSubview(currentNumberLabel)
        addSubview(totalNumberLabel)
        
        setConstrait()
    }
    func setConstrait() {
        currentNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(selfHeight-kFitWidth(10))
            make.top.equalTo(kFitWidth(17))
        }
        totalNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(selfHeight-kFitWidth(10))
//            make.top.equalTo(currentNumberLabel.snp.bottom).offset(kFitWidth(1))
            make.top.equalTo(kFitWidth(41))
        }
    }
}
