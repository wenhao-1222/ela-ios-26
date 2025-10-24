//
//  LogsNaturalGoalCircleVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation
import UIKit

class LogsNaturalGoalCircleVM: UIView {
    
    let selfWidth = kFitWidth(53)
    let selfHeight = kFitWidth(76)
    
    var currentNum = Int(0)
    var sportNum = Int(0)
    var currentNumFloat = Double(0)
    var totalNum = Int(0)
    
    var circleColor = UIColor.COLOR_CARBOHYDRATE
    var circleFillColor = WHColor_RGB(r: 31, g: 64, b: 134)
    
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
    
    
    var percentSport = 0.0
    var sportPath = UIBezierPath()
    let sportLayer = CAShapeLayer()
    
    var naturalPathBottom = UIBezierPath()
    var naturalPath = UIBezierPath()
    var pathTemp = UIBezierPath()
    var pathTempSport = UIBezierPath()
    var pathTempFill = UIBezierPath()
    let naturalShapeLayer = CAShapeLayer()
    let naturalShapeLayerBottom = CAShapeLayer()
    let naturalShapeLayerSecond = CAShapeLayer()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.1)
        self.isUserInteractionEnabled = true
        self.totalNum = 0
        self.currentNum = 0
        self.currentNumFloat = 0
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    lazy var coverImgView: UIImageView = {
//        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(-30), y: 0, width: selfWidth+kFitWidth(60), height: selfWidth))
//        img.setImgLocal(imgName: "logs_circle_cover")
//        return img
//    }()
    lazy var currentNumberLabel : UICountingLabel = {
        let lab = UICountingLabel()
        lab.text = "0"
        lab.format = "%d"
        lab.font = UIFont().DDInFontSemiBold(fontSize: 17)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var negativeLabel: UILabel = {
        let lab = UILabel()
        lab.text = "-"
        lab.textColor = WHColor_16(colorStr: "D54941")
        lab.font = UIFont().DDInFontSemiBold(fontSize: 16)
        lab.isHidden = true
        return lab
    }()
    lazy var totalNumberLabel : UILabel = {
        let lab = UILabel()
//        lab.text = "/0"
        lab.text = nil
        lab.font = UIFont().DDInFontRegular(fontSize: 12)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
//        lab.isHidden = true
//        lab.alpha = 0
        
        return lab
    }()
    lazy var titleLab : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension LogsNaturalGoalCircleVM{
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
        let radius = kFitWidth(26)
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
        if self.percentSport > 0 {
            sportLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
            sportLayer.fillColor = UIColor.COLOR_SPORT.cgColor // 无填充色
        }else{
            sportLayer.strokeColor = UIColor.clear.cgColor // 弧线颜色
            sportLayer.fillColor = UIColor.clear.cgColor // 无填充色
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
        
        sportPath = UIBezierPath()
        pathTempSport = UIBezierPath()
        sportPath.move(to: CGPoint.init(x: centerX-gap, y: centerY-radius-lineWidth*0.5))
        sportPath.addLine(to: CGPoint.init(x: centerX-gap, y: centerY-radius+lineWidth*0.5))
        //弧度终点
        let sportEndAngle = CGFloat((1-self.percentSport) * Double.pi*2) - 0.5 * Double.pi
        sportPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius-lineWidth*0.5, startAngle: startAngle, endAngle: sportEndAngle, clockwise: false)
        pathTempSport.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: startAngle, endAngle: sportEndAngle, clockwise: false)
        
        let firstPointSport = sportPath.currentPoint
        let endPoinSportt = pathTempSport.currentPoint
        
        let circleCenterSport = CGPoint.init(x: (firstPointSport.x+endPoinSportt.x)*0.5, y: (firstPointSport.y+endPoinSportt.y)*0.5)
        
        sportPath.addArc(withCenter: circleCenterSport, radius: lineWidth*0.5, startAngle:  sportEndAngle+Double.pi, endAngle: sportEndAngle, clockwise: true)
        sportPath.addLine(to: endPoinSportt)
        sportPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius+lineWidth*0.5, startAngle: sportEndAngle, endAngle: startAngle, clockwise: true)
        sportPath.addLine(to: CGPoint.init(x: centerX-gap, y: centerY-radius-lineWidth*0.5))
        
        sportLayer.path = sportPath.cgPath
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
        self.layer.addSublayer(sportLayer)
        self.layer.addSublayer(naturalShapeLayer)
        self.layer.addSublayer(shapeLayerFill)
        self.layer.addSublayer(shapeLayerFillShadow)
        
        naturalShapeLayerBottom.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor // 弧线颜色
        naturalShapeLayerBottom.fillColor = nil // 无填充色
        naturalShapeLayerBottom.lineWidth = kFitWidth(4) // 线宽
        
        naturalShapeLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        naturalShapeLayer.fillColor = UIColor.THEME.cgColor // 无填充色
        naturalShapeLayer.lineWidth = kFitWidth(0.2) // 线宽
        
        sportLayer.strokeColor = UIColor.COLOR_SPORT.cgColor // 弧线颜色
        sportLayer.fillColor = UIColor.COLOR_SPORT.cgColor // 无填充色
        sportLayer.lineWidth = kFitWidth(0.2) // 线宽
        
//        shapeLayerFill.allowsEdgeAntialiasing = true
//        shapeLayerFill.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45).cgColor // 弧线颜色
        shapeLayerFill.strokeColor = circleFillColor.cgColor
        shapeLayerFill.fillColor = circleFillColor.cgColor
        shapeLayerFill.lineWidth = kFitWidth(0.2) // 线宽
        
//        shapeLayerFillShadow.allowsEdgeAntialiasing = true
        shapeLayerFillShadow.strokeColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.55).cgColor // 弧线颜色
        shapeLayerFillShadow.lineDashPhase = kFitWidth(2)
        shapeLayerFillShadow.fillColor = nil // 无填充色
        shapeLayerFillShadow.lineWidth = kFitWidth(6) // 线宽
        shapeLayerFillShadow.lineDashPattern = [4,4]
    }
    
    func updateTotalNumber(text: String) {
        if text == "/0g" {return}
        guard totalNumberLabel.text != text || totalNumberLabel.isHidden else { return }
        DLLog(message: "updateTotalNumber:\(totalNumberLabel.text ?? "") --- \(text)")
        totalNumberLabel.text = text

//        if totalNumberLabel.isHidden {
//            totalNumberLabel.isHidden = false
//            UIView.animate(withDuration: 0.2) {
//                self.totalNumberLabel.alpha = 1
//            }
//        }
    }
    func setData(currentNumber:Int,totalNumber:Int) {
        self.currentNum = currentNumber
        self.totalNum = totalNumber
        setNeedsDisplay()
    }
    func setDataSport(currentNumber:Int,sportNumber:Int,totalNumber:Int) {
        self.currentNum = currentNumber
        self.totalNum = totalNumber
        self.sportNum = sportNumber
        
        if self.sportNum <= 0 {
            self.percentSport = 0
        }else{
            self.percentSport = Double(Float(self.sportNum)/Float(totalNumber))
        }
        
        setNeedsDisplay()
    }
    func drawBottomGrayCircle() {
        //线宽度
        let lineWidth: CGFloat = kFitWidth(4)
        //半径
        let radius = kFitWidth(26)
        //中心点x
        let centerX = self.bounds.size.width / 2.0
        //中心点y
        let centerY = centerX
        //弧度起点
        let startAngle = CGFloat(-0.5*Double.pi)
        //弧度终点
        let endAngle = CGFloat(100 * Double.pi*2) - 0.5 * Double.pi
        
        // 创建一个UIBezierPath对象
        let arcPath = UIBezierPath()
        // 添加一个圆弧到路径
        arcPath.addArc(withCenter: CGPoint.init(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
 
        // 创建CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = arcPath.cgPath
        shapeLayer.allowsEdgeAntialiasing = true
        shapeLayer.strokeColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor // 弧线颜色
        shapeLayer.fillColor = nil // 无填充色
        shapeLayer.lineWidth = lineWidth // 线宽
        // 将CAShapeLayer作为子层添加到视图的layer中
        self.layer.addSublayer(shapeLayer)
    }
    func initUI() {
//        drawBottomGrayCircle()
        initLayerByPath()
        addSubview(currentNumberLabel)
//        addSubview(negativeLabel)
        addSubview(totalNumberLabel)
        addSubview(titleLab)
        // 将CAShapeLayer作为子层添加到视图的layer中
//        self.layer.addSublayer(shapeLayer)
//        self.layer.addSublayer(shapeLayerFill)
//        // 将圆添加到图层上
//        self.layer.addSublayer(circleLayer)
//        self.layer.addSublayer(shapeLayerFillShadow)
        setConstrait()
    }
    func setConstrait() {
        currentNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(selfHeight-kFitWidth(10))
            make.top.equalTo(kFitWidth(12))
        }
        totalNumberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(selfHeight-kFitWidth(10))
//            make.top.equalTo(currentNumberLabel.snp.bottom).offset(kFitWidth(1))
            make.top.equalTo(kFitWidth(29))
        }
        titleLab.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
}
