//
//  JournalShareSaveFooterVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/6.
//

class JournalShareSaveFooterVM: UIView {
    
    var selfHeight = kFitWidth(42)
    
    let lineLayer = CAShapeLayer()
    var linePath = UIBezierPath()
    var circleRadius = kFitWidth(4.5)
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        lineLayer.strokeColor = UIColor.clear.cgColor
        lineLayer.fillColor = UIColor(named: "color_bg_theme_share")?.cgColor
    }
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: frame.size.height))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        selfHeight = frame.size.height
        circleRadius = (SCREEN_WIDHT-kFitWidth(84))/66
        
        if circleRadius > selfHeight * 0.3 {
            circleRadius = kFitWidth(4.5)
        }
//        if isIpad(){
//            circleRadius = kFitWidth(4.5)
//        }
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        initLayer()
    }
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(42), y: 0, width: SCREEN_WIDHT-kFitWidth(84), height: selfHeight))
        vi.backgroundColor = UIColor(named: "color_share_msg_bg")
        vi.clipsToBounds = true
        
        return vi
    }()
}

extension JournalShareSaveFooterVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.layer.addSublayer(lineLayer)
        
        lineLayer.allowsEdgeAntialiasing = true
        lineLayer.strokeColor = UIColor.clear.cgColor
        lineLayer.fillColor = UIColor(named: "color_bg_theme_share")?.cgColor
        lineLayer.lineWidth = 0
    }
    func initLayer() {
        DLLog(message: "JournalShareFooterVM  initLayer")
        
        lineLayer.strokeColor = UIColor.clear.cgColor
        lineLayer.fillColor = UIColor(named: "color_bg_theme_share")?.cgColor
        linePath = UIBezierPath()
        let width = whiteView.bounds.width > 0 ? whiteView.bounds.width : SCREEN_WIDHT-kFitWidth(84)
        let pixel = 1 / UIScreen.main.scale
        lineLayer.frame = whiteView.bounds
        linePath.move(to: CGPoint.init(x: -pixel, y: selfHeight+pixel))
        linePath.addLine(to: CGPoint.init(x: -pixel, y: selfHeight-circleRadius))
        linePath.addArc(withCenter: CGPoint.init(x: 0, y: selfHeight), radius: circleRadius, startAngle: -Double.pi*0.5, endAngle: 0, clockwise: true)
        
        for i in 0..<1000{
            let firstPointX = circleRadius*CGFloat(i)*3 + circleRadius
            linePath.addLine(to: CGPoint.init(x: firstPointX, y: selfHeight))
            linePath.addArc(withCenter: CGPoint.init(x: firstPointX+circleRadius*2, y: selfHeight), radius: circleRadius, startAngle: -Double.pi, endAngle: 0, clockwise: true)
            
            if firstPointX+circleRadius*2 >= width{
                break
            }
        }
        linePath.addLine(to: CGPoint.init(x: width+pixel, y: selfHeight))
        linePath.addLine(to: CGPoint.init(x: width+pixel, y: selfHeight+pixel))
        linePath.close()
        lineLayer.path = linePath.cgPath
    }
}
