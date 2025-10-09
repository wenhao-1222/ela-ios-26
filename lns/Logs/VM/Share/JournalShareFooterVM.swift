//
//  JournalShareFooterVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/6.
//

class JournalShareFooterVM: UIView {
    
    var selfHeight = kFitWidth(42)
    
    let lineLayer = CAShapeLayer()
    var linePath = UIBezierPath()
    var circleRadius = kFitWidth(4.5)
    
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
        vi.backgroundColor = .white
        vi.clipsToBounds = true
        
        return vi
    }()
    
}

extension JournalShareFooterVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.layer.addSublayer(lineLayer)
        
        lineLayer.allowsEdgeAntialiasing = true
        lineLayer.strokeColor = UIColor.THEME.cgColor // 弧线颜色
        lineLayer.fillColor = UIColor.THEME.cgColor // 填充色
        lineLayer.lineWidth = kFitWidth(0.5) // 线宽
    }
    func initLayer() {
        DLLog(message: "JournalShareFooterVM  initLayer")
        linePath = UIBezierPath()
        linePath.move(to: CGPoint.init(x: 0, y: selfHeight-circleRadius))
        linePath.addArc(withCenter: CGPoint.init(x: 0, y: selfHeight), radius: circleRadius, startAngle: -Double.pi*0.5, endAngle: 0, clockwise: true)
        
        for i in 0..<1000{
            let firstPointX = circleRadius*CGFloat(i)*3 + circleRadius
            linePath.addLine(to: CGPoint.init(x: firstPointX, y: selfHeight))
            linePath.addArc(withCenter: CGPoint.init(x: firstPointX+circleRadius*2, y: selfHeight), radius: circleRadius, startAngle: -Double.pi, endAngle: 0, clockwise: true)
            
            if firstPointX+circleRadius*2 >= SCREEN_WIDHT-kFitWidth(84){
                break
            }
        }
        linePath.addLine(to: CGPoint.init(x: 0, y: selfHeight))
        lineLayer.path = linePath.cgPath
    }
}
