//
//  GuideSetWeekGoalAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/8/8.
//

import Foundation
import UIKit

class GuideSetWeekGoalAlertVM: UIView {
    
    let hightLightColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.4)
    var timer: Timer?
    var remainSeconds = 3
    var clickBlock:(()->())?
    
    private let lineLayer = CAShapeLayer()
    private var linePath = UIBezierPath()
    private let lineLayerTrangle = CAShapeLayer()
    private var linePathTrangle = UIBezierPath()
    
    var shapeLayerScreen = CAShapeLayer()
    let arcPathScreen = UIBezierPath()
    
    let originX = kFitWidth(8)
    let originY = kFitWidth(8)+statusBarHeight+44 + kFitWidth(58)
    let viewHeight = kFitWidth(158) - kFitWidth(62)
    
    let radius = kFitWidth(8)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
//        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.backgroundColor = .clear
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(doneClick))
//        self.addGestureRecognizer(tap)
        
//        initLayer()
        
        initUI()
//        let is_guide = UserDefaults.standard.value(forKey: guide_goal_week_set) as? String ?? ""
//        
//        if is_guide.count > 0 {
//            self.isHidden = true
//        }
        
//        let is_guide_logs = UserDefaults.standard.value(forKey: guide_logs_plan) as? String ?? ""
        
//        if is_guide_logs.count > 0{
//        if is_guide.count > 0 || Date().judgeMin(firstTime: "2024-12-08", secondTime: UserInfoModel.shared.registDate,formatter: "yyyy-MM-dd"){
//                self.isHidden = true
//            }
//        }else{
//            self.isHidden = true
//        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var goalVm: LogsNaturalGoalVM = {
        let vm = LogsNaturalGoalVM.init(frame: CGRect.init(x: 0, y: statusBarHeight+44, width: 0, height: 0))
        
        return vm
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(170)+statusBarHeight+44+kFitWidth(140), width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(80)))
        //
        lab.text = "告别猜测：\n清晰对比你的每日摄入和增肌/减脂所需的营养目标，助你实现最大化进步"
        lab.textColor = .white
//        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
//        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var tips2Label: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(170)+statusBarHeight+44, width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(20)))
        //（点击此处可对目标进行编辑）
        lab.text = "（点击此处可对目标进行编辑）"
        lab.textColor = .white
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var bottomeTipsLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(120), y: SCREEN_HEIGHT-WHUtils().getTabbarHeight()-kFitWidth(40), width: SCREEN_WIDHT - kFitWidth(240), height: kFitWidth(36)))
//        lab.text = "点击任意位置可关闭"
        lab.text = "3"
        lab.textColor = .white//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        lab.layer.borderWidth = kFitWidth(0.5)
        lab.layer.borderColor = UIColor.white.cgColor
        lab.layer.cornerRadius = kFitWidth(8)
        lab.clipsToBounds = true
        lab.backgroundColor = .COLOR_GRAY_BLACK_25
        
        lab.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(doneClick))
        lab.addGestureRecognizer(tap)
        
//        lab.isHidden = true
        return lab
    }()
    lazy var borderView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_25//WHColor_ARC()
//        vi.layer.cornerRadius = kFitWidth(8)
//        vi.clipsToBounds = true
        return vi
    }()
    lazy var blurEffect: UIBlurEffect = {
        let vi = UIBlurEffect(style:.extraLight)
        return vi
    }()
    lazy var blurEffectView: UIVisualEffectView = {
        let vi = UIVisualEffectView(effect: blurEffect)
        vi.alpha = 0.6//0.73
        return vi
    }()
    lazy var blurEffectViewBottom: UIVisualEffectView = {
        let vi = UIVisualEffectView(effect: blurEffect)
        vi.alpha = 0.6//0.73
        return vi
    }()
}

extension GuideSetWeekGoalAlertVM{
    @objc func doneClick() {
        if self.remainSeconds > 0 {
            return
        }
        self.isHidden = true
        UserDefaults.standard.setValue("1", forKey: guide_goal_week_set)
        if self.clickBlock != nil{
            self.clickBlock!()
        }
    }
    func countDownAction() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            self.bottomeTipsLabel.text = "\(self.remainSeconds) 秒后可关闭"
            self.remainSeconds = self.remainSeconds - 1
            self.bottomeTipsLabel.text = "\(self.remainSeconds)"
            DLLog(message: "GuideSetWeekGoalAlertVM -- countDownAction:\(self.remainSeconds)")
            if self.remainSeconds <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                if UserInfoModel.shared.hidden_survery_button_status == false{
                    self.bottomeTipsLabel.text = "下一步"//"点击任意位置可关闭"
                }else{
                    self.bottomeTipsLabel.text = "我知道啦"
                }
            }
        }
    }
}

extension GuideSetWeekGoalAlertVM{
    func initUI() {
//        addSubview(goalVm)
        addSubview(blurEffectView)
        addSubview(blurEffectViewBottom)
        initLayer()
        addSubview(borderView)
        addSubview(tipsLabel)
        addSubview(tips2Label)
        addSubview(bottomeTipsLabel)
        
        setConstrait()
        borderView.addDashedBorder(borderColor: .white, dashPattern: [5,5])
    }
    func setConstrait() {
        blurEffectView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(originY)
        }
        blurEffectViewBottom.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(originY+viewHeight)
        }
        borderView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(tipsLabel)
            make.left.top.equalTo(tipsLabel).offset(kFitWidth(-8))
            make.right.bottom.equalTo(tipsLabel).offset(kFitWidth(8))
        }
    }
    
    override func draw(_ rect: CGRect) {
        // 添加一个圆弧到路径
        arcPathScreen.move(to: CGPoint.init(x: 0, y: 0))
        arcPathScreen.addLine(to: CGPoint.init(x: originX, y: originY + radius))
        arcPathScreen.addLine(to: CGPoint.init(x: originX, y: originY+viewHeight-radius))
        
        arcPathScreen.addArc(withCenter: CGPoint.init(x: originX+radius, y: originY+viewHeight-radius),
                             radius: radius,
                             startAngle: CGFloat(Double.pi*2*0.5),
                             endAngle: CGFloat(Double.pi*2*0.25),
                             clockwise: false)
        
        arcPathScreen.addLine(to: CGPoint.init(x: SCREEN_WIDHT-kFitWidth(8)-radius, y: originY+viewHeight))
        
        arcPathScreen.addArc(withCenter: CGPoint.init(x: SCREEN_WIDHT-kFitWidth(8)-radius, y: originY+viewHeight-radius),
                             radius: radius,
                             startAngle: CGFloat(Double.pi*2*0.25),
                             endAngle: 0,
                             clockwise: false)
        
        arcPathScreen.addLine(to: CGPoint.init(x: SCREEN_WIDHT-kFitWidth(8), y: originY-radius))
        arcPathScreen.addArc(withCenter: CGPoint.init(x: SCREEN_WIDHT-kFitWidth(8)-radius, y: originY+radius),
                             radius: radius,
                             startAngle: 0,
                             endAngle: CGFloat(-Double.pi*0.5),
                             clockwise: false)
        
        arcPathScreen.addLine(to: CGPoint.init(x: originX+radius, y: originY))
        arcPathScreen.addArc(withCenter: CGPoint.init(x: originX+radius, y: originY+radius),
                             radius: radius,
                             startAngle: CGFloat(-0.5*Double.pi),
                             endAngle: CGFloat(Double.pi),
                             clockwise: false)
        
        arcPathScreen.addLine(to: CGPoint.init(x: 0, y: 0))
        arcPathScreen.addLine(to: CGPoint.init(x: SCREEN_WIDHT, y: 0))
        arcPathScreen.addLine(to: CGPoint.init(x: SCREEN_WIDHT, y: SCREEN_HEIGHT))
        arcPathScreen.addLine(to: CGPoint.init(x: 0, y: SCREEN_HEIGHT))
        arcPathScreen.addLine(to: CGPoint.init(x: 0, y: 0))
        
        shapeLayerScreen.path = arcPathScreen.cgPath
        
//        initUI()
//        initLayer()
        drawArrowDash()
    }
//    override func draw(_ rect: CGRect) {
//        if showNum == "1"{
//            drawArrowDashCreateFoods()
//            showNum = "2"
//        }else{
//            drawArrowDash()
//        }
//    }
    func initLayer() {
        self.layer.addSublayer(shapeLayerScreen)
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(lineLayerTrangle)
        
        shapeLayerScreen.allowsEdgeAntialiasing = true
        shapeLayerScreen.strokeColor = UIColor.clear.cgColor // 弧线颜色
        shapeLayerScreen.fillColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65).cgColor//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.2).cgColor // 无填充色
        shapeLayerScreen.lineWidth = kFitWidth(1) // 线宽
        
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = kFitWidth(1) // 线宽
        lineLayer.lineDashPattern = [5,2]
        
        lineLayerTrangle.strokeColor = UIColor.white.cgColor
        lineLayerTrangle.fillColor = UIColor.white.cgColor
        lineLayerTrangle.lineWidth = kFitWidth(0.2) // 线宽
    }
    func drawArrowDash() {
        let originX = kFitWidth(8)
        let endX = SCREEN_WIDHT-kFitWidth(8)
        let originY = kFitWidth(8)+statusBarHeight+44
        let endY = originY+kFitWidth(158)+kFitWidth(20)
        
        let viewWidth = SCREEN_WIDHT-kFitWidth(16)
        
        let firstPoint = CGPoint.init(x: originX+viewWidth*0.15, y: endY+kFitWidth(112))
        let endPoint = CGPoint.init(x: originX + (endX - originX)*0.5, y: endY+kFitWidth(5))
        let controlPoint1 = CGPoint.init(x: firstPoint.x + (endPoint.x - firstPoint.x)*0.8,
                                         y: firstPoint.y - (firstPoint.y - endPoint.y)*0.1)
        linePath = UIBezierPath()
        linePathTrangle = UIBezierPath()
        
        linePath.move(to: firstPoint)
        linePath.addQuadCurve(to: endPoint, controlPoint: controlPoint1)
        lineLayer.path = linePath.cgPath
        
        let arcPoints = WHUtils().getArrowPoint(fPoint: CGPoint.init(x: endPoint.x-2, y: endPoint.y+15),
                                      tPoint: CGPoint.init(x: endPoint.x, y: endPoint.y+4))
        
        linePathTrangle.move(to: arcPoints.0)
        linePathTrangle.addLine(to: arcPoints.2)
        linePathTrangle.addLine(to: arcPoints.1)
        linePathTrangle.addLine(to: CGPoint.init(x: arcPoints.2.x, y: arcPoints.2.y-2))
        linePathTrangle.addLine(to: arcPoints.0)
        
        let shortenAnimation = CABasicAnimation(keyPath: "strokeEnd")
        shortenAnimation.fromValue = 0.0
        shortenAnimation.toValue = 1.0
        shortenAnimation.duration = 0.7
        shortenAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 添加动画到线段layer
        lineLayer.add(shortenAnimation, forKey: "animationKey")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.lineLayerTrangle.path = self.linePathTrangle.cgPath
            shortenAnimation.duration = 0.3
            self.lineLayerTrangle.add(shortenAnimation, forKey: "animationKey")
        })
    }
}
