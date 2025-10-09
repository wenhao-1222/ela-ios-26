//
//  GuideMineCreatePlanAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/1.
//

import Foundation

class GuideMineCreatePlanAlertVM: UIView {
    
    let originY = kFitWidth(152) + statusBarHeight + 44
    
    private let lineLayer = CAShapeLayer()
    private var linePath = UIBezierPath()
    private let lineLayerTrangle = CAShapeLayer()
    private var linePathTrangle = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(doneClick))
//        self.addGestureRecognizer(tap)
        
        let is_guide = UserDefaults.standard.value(forKey: guide_mine_create_plan) as? String ?? ""
        
        if is_guide.count > 0 || Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2025-02-01",formatter: "yyyy-MM-dd"){
            self.isHidden = true
        }
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var createPlanVm : MineTopFuncVM = {
        let vm = MineTopFuncVM.init(frame: CGRect.init(x: kFitWidth(191), y: originY, width: 0, height: 0))
        vm.leftIconImg.setImgLocal(imgName: "mine_func_create_plan")
        vm.textLab.text = "制作计划"
        
        return vm
    }()
    lazy var borderView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_25//WHColor_ARC()
//        vi.layer.cornerRadius = kFitWidth(8)
//        vi.clipsToBounds = true
        return vi
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "点击这里，为自己或别人制作饮食计划"
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = .white
        
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    
    lazy var bottomeTipsLabel: UILabel = {
//        let lab = UILabel.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-WHUtils().getTabbarHeight()-kFitWidth(40), width: SCREEN_WIDHT, height: kFitWidth(20)))
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(120), y: SCREEN_HEIGHT-WHUtils().getTabbarHeight()-kFitWidth(40), width: SCREEN_WIDHT - kFitWidth(240), height: kFitWidth(36)))
//        lab.text = "点击任意位置可关闭"
        lab.text = "我知道啦"
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
        
        return lab
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
}

extension GuideMineCreatePlanAlertVM{
    @objc func doneClick() {
        self.isHidden = true
        UserDefaults.standard.setValue("1", forKey: guide_mine_create_plan)
    }
}
extension GuideMineCreatePlanAlertVM{
    func initUI() {
        addSubview(blurEffectView)
        addSubview(borderView)
        addSubview(createPlanVm)
        addSubview(tipsLabel)
        addSubview(bottomeTipsLabel)
        
        blurEffectView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        borderView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(tipsLabel)
            make.left.top.equalTo(tipsLabel).offset(kFitWidth(-8))
            make.right.bottom.equalTo(tipsLabel).offset(kFitWidth(8))
        }
        
        tipsLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(140))
            make.top.equalTo(createPlanVm.snp.bottom).offset(kFitWidth(105))
            make.right.equalTo(kFitWidth(-20))
        }
        
        initLayer()
        borderView.addDashedBorder(borderColor: .white, dashPattern: [5,5])
    }
    override func draw(_ rect: CGRect) {
        drawArrowDash()
    }
    func initLayer() {
        self.layer.addSublayer(lineLayer)
        self.layer.addSublayer(lineLayerTrangle)
        
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = kFitWidth(1) // 线宽
        lineLayer.lineDashPattern = [5,2]
        
        lineLayerTrangle.strokeColor = UIColor.white.cgColor
        lineLayerTrangle.fillColor = UIColor.white.cgColor
        lineLayerTrangle.lineWidth = kFitWidth(0.2) // 线宽
    }
    func drawArrowDash() {
        let firstPoint = CGPoint.init(x: borderView.frame.midX - borderView.frame.width*0.25, y: borderView.frame.minY)
        let endPoint = CGPoint.init(x: createPlanVm.frame.midX + kFitWidth(20), y: createPlanVm.frame.maxY+kFitWidth(5))
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
