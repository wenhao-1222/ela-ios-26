//
//  JournalShareMsgDashVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/6.
//

class JournalShareMsgDashVM: UIView {
    
    let selfHeight = kFitWidth(40)
    let selfWidth = SCREEN_WIDHT-kFitWidth(84)
    let circleRadius = kFitWidth(5.5)
    
    let lineLayer = CAShapeLayer()
    var linePath = UIBezierPath()
    let dashLineLayer = CAShapeLayer()
    var dashLinePath = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(42), y: frame.origin.y, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        self.drawLayer()
    }
}

extension JournalShareMsgDashVM{
    func initUI() {
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(dashLineLayer)
        
        lineLayer.allowsEdgeAntialiasing = true
        lineLayer.strokeColor = UIColor.white.cgColor // 弧线颜色
        lineLayer.fillColor = UIColor.white.cgColor // 填充色
        lineLayer.lineWidth = kFitWidth(0.5) // 线宽
        
        dashLineLayer.allowsEdgeAntialiasing = true
        dashLineLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor // 弧线颜色
        dashLineLayer.fillColor = nil // 无填充色
        dashLineLayer.lineWidth = kFitWidth(1) // 线宽
        dashLineLayer.lineDashPhase = kFitWidth(0)
        dashLineLayer.lineDashPattern = [2,2]
    }
    
    func drawLayer() {
        linePath = UIBezierPath()
        linePath.move(to: CGPoint.init(x: 0, y: 0))
        linePath.addLine(to: CGPoint.init(x: 0, y: selfHeight*0.5-circleRadius))
        linePath.addArc(withCenter: CGPoint(x: 0, y: selfHeight*0.5), radius: circleRadius, startAngle: -Double.pi*0.5, endAngle: Double.pi*0.5, clockwise: true)
        linePath.addLine(to: CGPoint.init(x: 0, y: selfHeight))
        linePath.addLine(to: CGPoint.init(x:selfWidth , y: selfHeight))
        linePath.addLine(to: CGPoint.init(x:selfWidth , y: selfHeight*0.5+circleRadius))
        linePath.addArc(withCenter: CGPoint(x: selfWidth, y: selfHeight*0.5), radius: circleRadius, startAngle: Double.pi*0.5, endAngle: -Double.pi*0.5, clockwise: true)
        linePath.addLine(to: CGPoint.init(x: selfWidth, y: 0))
        linePath.addLine(to: CGPoint.init(x: 0, y: 0))
        
        lineLayer.path = linePath.cgPath
        
        dashLinePath = UIBezierPath()
        dashLinePath.move(to: CGPoint.init(x: kFitWidth(16), y: selfHeight*0.5))
        dashLinePath.addLine(to: CGPoint.init(x: selfWidth-kFitWidth(16), y: selfHeight*0.5))
        
        dashLineLayer.path = dashLinePath.cgPath
    }
}
