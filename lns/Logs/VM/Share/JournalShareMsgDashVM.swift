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
    // 主题变更时（例如从浅色切到深色）同步调整蒙层透明度
//      override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//          super.traitCollectionDidChange(previousTraitCollection)
//          if #available(iOS 13.0, *),
//             previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
//             !isHidden {
//              
//              UIView.animate(withDuration: 0.2) {
////                  if previousTraitCollection?.userInterfaceStyle == .dark{
//                      self.lineLayer.strokeColor = UIColor(named: "color_bg_theme_share")?.cgColor // 弧线颜色
//                      self.lineLayer.fillColor = UIColor(named: "color_bg_theme_share")?.cgColor // 填充色
////                  }else{
////                      self.lineLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
////                      self.lineLayer.fillColor = UIColor.THEME.cgColor // 填充色
////                  }
//              }
//          }
//      }
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
        lineLayer.lineWidth = kFitWidth(0.5) // 线宽
        
        dashLineLayer.allowsEdgeAntialiasing = true
        dashLineLayer.strokeColor = WHColorWithAlpha(colorStr: "0f1214", alpha: 0.2).cgColor // 弧线颜色
//        dashLineLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor // 弧线颜色
        dashLineLayer.fillColor = nil // 无填充色
        dashLineLayer.lineWidth = kFitWidth(1) // 线宽
        dashLineLayer.lineDashPhase = kFitWidth(0)
        dashLineLayer.lineDashPattern = [2,2]
    }
    
    func drawLayer() {
        lineLayer.strokeColor = UIColor(named: "color_share_msg_bg")?.cgColor // 弧线颜色
        lineLayer.fillColor = UIColor(named: "color_share_msg_bg")?.cgColor // 填充色
        linePath = UIBezierPath()
        linePath.move(to: CGPoint.init(x: 0.5, y: 0))
        linePath.addLine(to: CGPoint.init(x: 0.5, y: selfHeight*0.5-circleRadius))
        linePath.addArc(withCenter: CGPoint(x: 0.5, y: selfHeight*0.5), radius: circleRadius, startAngle: -Double.pi*0.5, endAngle: Double.pi*0.5, clockwise: true)
        linePath.addLine(to: CGPoint.init(x: 0.5, y: selfHeight))
        linePath.addLine(to: CGPoint.init(x:selfWidth-0.5 , y: selfHeight))
        linePath.addLine(to: CGPoint.init(x:selfWidth-0.5 , y: selfHeight*0.5+circleRadius))
        linePath.addArc(withCenter: CGPoint(x: selfWidth-0.5, y: selfHeight*0.5), radius: circleRadius, startAngle: Double.pi*0.5, endAngle: -Double.pi*0.5, clockwise: true)
        linePath.addLine(to: CGPoint.init(x: selfWidth-0.5, y: 0))
        linePath.addLine(to: CGPoint.init(x: 0.5, y: 0))
        
        lineLayer.path = linePath.cgPath
        
        dashLinePath = UIBezierPath()
        dashLinePath.move(to: CGPoint.init(x: kFitWidth(16), y: selfHeight*0.5))
        dashLinePath.addLine(to: CGPoint.init(x: selfWidth-kFitWidth(16), y: selfHeight*0.5))
        
        dashLineLayer.path = dashLinePath.cgPath
    }
}
