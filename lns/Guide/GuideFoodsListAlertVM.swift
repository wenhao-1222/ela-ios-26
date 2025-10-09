//
//  GuideFoodsListAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/8.
//

import Foundation

class GuideFoodsListAlertVM: UIView {
    
    let originY = kFitWidth(152) + statusBarHeight + 44
    
    var searchTapBlock:(()->())?
    var hiddenBlock:(()->())?
    var showNum = ""
    var isShowNodata = false
    
    private let lineLayer = CAShapeLayer()
    private var linePath = UIBezierPath()
    private let lineLayerTrangle = CAShapeLayer()
    private var linePathTrangle = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        showNum = UserDefaults.standard.value(forKey: guide_foods_list_search) as? String ?? ""
        
        if showNum.count > 0 || Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2025-02-01",formatter: "yyyy-MM-dd"){
            self.isHidden = true
        }
        
//        if Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2024-07-08",formatter: "yyyy-MM-dd"){
//            self.isHidden = true
//        }
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var naviVm : FoodsSearchVM = {
        let vm = FoodsSearchVM.init(frame: .zero)
        vm.backArrowButton.isHidden = true
        vm.backgroundColor = .clear
        vm.textField.isEnabled = false
        vm.searchBgView.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5)
        vm.isHidden = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vm.addGestureRecognizer(tap)
        
        return vm
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        
//        lab.text = "点击这里搜索食物\nEla数据库涵盖上万种食物，主要来源于美国农业局和香港卫生署等权威机构"
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = .white
        
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        let attr = NSMutableAttributedString(string: "点击这里搜索食物")
        let detailAttr = NSMutableAttributedString(string: "\n\nEla数据库涵盖上万种食物，主要来源于美国农业局和香港卫生署等权威机构")
        
        attr.yy_font = .systemFont(ofSize: 16, weight: .medium)
        attr.append(detailAttr)
        
        lab.attributedText = attr
        
        return lab
    }()
    lazy var borderView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_25//WHColor_ARC()
//        vi.layer.cornerRadius = kFitWidth(8)
//        vi.clipsToBounds = true
        return vi
    }()
    lazy var borderView2: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_25//WHColor_ARC()
        vi.isHidden = true
//        vi.layer.cornerRadius = kFitWidth(8)
//        vi.clipsToBounds = true
        return vi
    }()
    lazy var createFoodsButton: GJVerButton = {
        let btn = GJVerButton()
        let btnWidth = (SCREEN_WIDHT-kFitWidth(48))/3
//        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        btn.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: btnWidth, height: kFitWidth(86))
        btn.setTitle("创建食物", for: .normal)
        btn.backgroundColor = .white
        btn.setImage(UIImage(named: "foods_create_icon_normal"), for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.clipsToBounds = true
        btn.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06).cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.imagePosition(style: .top, spacing: kFitWidth(5))
        btn.isHidden = true
        
        return btn
    }()
    
    lazy var tips2Label: UILabel = {
        let lab = UILabel()
        lab.text = "如果未找到所需食物，可通过“创建食物”功能自行添加。"
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = .white
        lab.isHidden = true
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var bottomeTipsLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-WHUtils().getTabbarHeight()-kFitWidth(40), width: SCREEN_WIDHT, height: kFitWidth(20)))
        lab.text = "点击任意位置可关闭"
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5)
        lab.font = .systemFont(ofSize: 10)
        lab.textAlignment = .center
        lab.isHidden = true
    
        return lab
    }()
    lazy var gotItBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("我知道啦", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = kFitWidth(16)
        btn.clipsToBounds = true
        btn.backgroundColor = .COLOR_GRAY_BLACK_25
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        
        return btn
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

extension GuideFoodsListAlertVM{
    @objc func hiddenSelf() {
        if self.hiddenBlock != nil{
            self.hiddenBlock!()
        }
        if showNum == ""{
            UserDefaults.standard.setValue("1", forKey: guide_foods_list_search)
        }
        
        self.isHidden = true
    }
    @objc func doneClick() {
        if isShowNodata {
            return
        }
        lineLayerTrangle.removeFromSuperlayer()
        self.isHidden = true
        self.setNeedsDisplay()
        showNum = UserDefaults.standard.value(forKey: guide_foods_list_search) as? String ?? ""
        if showNum == "1"{
            isShowNodata = true
            self.isHidden = false
//            self.setNeedsDisplay()
            self.naviVm.isHidden = true
            self.tipsLabel.isHidden = true
            borderView.isHidden = true
            self.createFoodsButton.isHidden = false
            self.tips2Label.isHidden = false
//            bottomeTipsLabel.isHidden = false
            borderView2.isHidden = false
            
            gotItBtn.snp.remakeConstraints { make in
                make.centerX.lessThanOrEqualToSuperview()
//                make.top.equalTo(borderView2.snp.bottom).offset(kFitWidth(60))
                make.bottom.equalTo(-WHUtils().getTabbarHeight()-kFitWidth(20))
                make.width.equalTo(kFitWidth(88))
                make.height.equalTo(kFitWidth(32))
            }
            
            UserDefaults.standard.setValue("2", forKey: guide_foods_list_search)
//            let tap = UITapGestureRecognizer.init(target: self, action: #selector(doneClick))
//            self.addGestureRecognizer(tap)
        }else if showNum == "2" {
            self.isHidden = true
//            UserDefaults.standard.setValue("2", forKey: guide_foods_list_search)
//            if self.hiddenBlock != nil{
//                self.hiddenBlock!()
//            }
        }
    }
    @objc func tapAction() {
        if self.searchTapBlock != nil{
            self.searchTapBlock!()
        }
    }
//    func updateGuideNum() {
//        UserDefaults.standard.setValue("\(Int(showNum.doubleValue)+1)", forKey: guide_foods_list_search)
//    }
}
extension GuideFoodsListAlertVM{
    func initUI() {
        addSubview(blurEffectView)
        addSubview(naviVm)
        addSubview(borderView)
        addSubview(borderView2)
        addSubview(tipsLabel)
        addSubview(gotItBtn)
        addSubview(createFoodsButton)
        createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: WHUtils().getNavigationBarHeight() + kFitWidth(47) + kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        addSubview(tips2Label)
        addSubview(bottomeTipsLabel)
        
        setConstrait()
        borderView.addDashedBorder(borderColor: .white, dashPattern: [5,5])
        borderView2.addDashedBorder(borderColor: .white, dashPattern: [5,5])
        initLayer()
    }
    func setConstrait() {
        blurEffectView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        gotItBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(borderView.snp.bottom).offset(kFitWidth(12))
            make.width.equalTo(kFitWidth(120))
            make.height.equalTo(kFitWidth(32))
        }
        borderView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(tipsLabel)
            make.left.top.equalTo(tipsLabel).offset(kFitWidth(-8))
            make.right.bottom.equalTo(tipsLabel).offset(kFitWidth(8))
        }
        borderView2.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(tips2Label)
            make.left.top.equalTo(tips2Label).offset(kFitWidth(-8))
            make.right.bottom.equalTo(tips2Label).offset(kFitWidth(8))
        }
        
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(naviVm.snp.bottom).offset(kFitWidth(100))
            make.left.equalTo(kFitWidth(46))
            make.right.equalTo(kFitWidth(-20))
        }
        tips2Label.snp.makeConstraints { make in
            make.top.equalTo(createFoodsButton.snp.bottom).offset(kFitWidth(100))
            make.left.equalTo(kFitWidth(46))
            make.right.equalTo(kFitWidth(-20))
        }
    }
    override func draw(_ rect: CGRect) {
        lineLayerTrangle.removeFromSuperlayer()
        if showNum == "1"{
            drawArrowDashCreateFoods()
            showNum = "2"
        }else{
            drawArrowDash()
        }
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
        self.layer.addSublayer(lineLayerTrangle)
        let firstPoint = CGPoint.init(x: borderView.frame.midX - borderView.frame.width*0.25, y: borderView.frame.minY)
        let endPoint = CGPoint.init(x: naviVm.frame.midX + kFitWidth(40), y: naviVm.frame.maxY+kFitWidth(5))
        let controlPoint1 = CGPoint.init(x: firstPoint.x + (endPoint.x - firstPoint.x)*0.8,
                                         y: firstPoint.y - (firstPoint.y - endPoint.y)*0.1)
        linePath = UIBezierPath()
        linePathTrangle = UIBezierPath()
        
        linePath.move(to: firstPoint )
        linePath.addQuadCurve(to: endPoint, controlPoint: controlPoint1)
        lineLayer.path = linePath.cgPath
        
        let arcPoints = WHUtils().getArrowPoint(fPoint: CGPoint.init(x: endPoint.x-2, y: endPoint.y+15),
                                      tPoint: CGPoint.init(x: endPoint.x, y: endPoint.y+2))
        
        linePathTrangle.move(to: arcPoints.0)
        linePathTrangle.addLine(to: arcPoints.2)
        linePathTrangle.addLine(to: arcPoints.1)
        linePathTrangle.addLine(to: CGPoint.init(x: arcPoints.2.x-2, y: arcPoints.2.y))
        linePathTrangle.addLine(to: arcPoints.0)
        
        var shortenAnimation = CABasicAnimation(keyPath: "strokeEnd")
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
    
    func drawArrowDashCreateFoods() {
        let firstPoint = CGPoint.init(x: borderView2.frame.midX + borderView2.frame.width*0.25, y: borderView2.frame.minY)
        let endPoint = CGPoint.init(x: createFoodsButton.frame.midX, y: createFoodsButton.frame.maxY+kFitWidth(5))
        let controlPoint1 = CGPoint.init(x: firstPoint.x + (endPoint.x - firstPoint.x)*0.8,
                                         y: firstPoint.y - (firstPoint.y - endPoint.y)*0.1)
        linePath = UIBezierPath()
        linePathTrangle = UIBezierPath()
        
        linePath.move(to: firstPoint )
        linePath.addQuadCurve(to: endPoint, controlPoint: controlPoint1)
        lineLayer.path = linePath.cgPath
        
        let arcPoints = WHUtils().getArrowPoint(fPoint: CGPoint.init(x: endPoint.x+2, y: endPoint.y+15),
                                      tPoint: CGPoint.init(x: endPoint.x, y: endPoint.y+2))
        
        linePathTrangle.move(to: arcPoints.0)
        linePathTrangle.addLine(to: arcPoints.2)
        linePathTrangle.addLine(to: arcPoints.1)
        linePathTrangle.addLine(to: CGPoint.init(x: arcPoints.2.x, y: arcPoints.2.y+2))
        linePathTrangle.addLine(to: arcPoints.0)
        self.layer.addSublayer(lineLayerTrangle)
        self.lineLayerTrangle.path = self.linePathTrangle.cgPath
        
        let shortenAnimation = CABasicAnimation(keyPath: "strokeEnd")
        shortenAnimation.fromValue = 0.0
        shortenAnimation.toValue = 1.0
        shortenAnimation.duration = 0.7
        shortenAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // 添加动画到线段layer
        lineLayer.add(shortenAnimation, forKey: "animationKey")
    }
}

