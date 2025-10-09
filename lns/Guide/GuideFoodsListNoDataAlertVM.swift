//
//  GuideFoodsListNoDataAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/12.
//


import Foundation

class GuideFoodsListNoDataAlertVM: UIView {
    
    let originY = kFitWidth(152) + statusBarHeight + 44
    
    var searchTapBlock:(()->())?
    var hiddenBlock:(()->())?
    var isShowNodata = false
    
    private let lineLayer = CAShapeLayer()
    private var linePath = UIBezierPath()
    private let lineLayerTrangle = CAShapeLayer()
    private var linePathTrangle = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        let showNum = UserDefaults.standard.value(forKey: guide_foods_list_search) as? String ?? ""
        
        if showNum.count > 0{
            self.isHidden = true
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
        self.addGestureRecognizer(tap)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
        
        return btn
    }()
    
    lazy var tips2Label: UILabel = {
        let lab = UILabel()
        lab.text = "如果未找到所需食物，可通过“创建食物”功能自行添加。"
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = .white
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
    /// 展示视图并带有淡入动画
    /// - Parameters:
    ///   - view: 父视图
    ///   - subview: 需要在其之上的视图，可为nil
    func show(in view: UIView, above subview: UIView? = nil) {
        let showNum = UserDefaults.standard.value(forKey: guide_foods_list_search) as? String ?? ""
        if showNum.count > 0 {
            return
        }
        self.alpha = 0
        self.isHidden = false
        if let sub = subview {
            view.insertSubview(self, aboveSubview: sub)
        } else {
            view.addSubview(self)
        }
        UIView.animate(withDuration: 0.45) {
            self.alpha = 1
        }
    }
}

extension GuideFoodsListNoDataAlertVM{
    @objc func hiddenSelf() {
        if self.hiddenBlock != nil{
            self.hiddenBlock!()
        }
//        if showNum == ""{
            UserDefaults.standard.setValue("1", forKey: guide_foods_list_search)
//        }
        UIView.animate(withDuration: 0.45) {
            self.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
//        self.isHidden = true
    }
    @objc func tapAction() {
        if self.searchTapBlock != nil{
            self.searchTapBlock!()
        }
    }
}
extension GuideFoodsListNoDataAlertVM{
    func initUI() {
        addSubview(blurEffectView)
        addSubview(borderView2)
        addSubview(createFoodsButton)
        createFoodsButton.frame = CGRect.init(x: kFitWidth(16), y: WHUtils().getNavigationBarHeight() + kFitWidth(47) + kFitWidth(17), width: kFitWidth(168), height: kFitWidth(86))
        addSubview(tips2Label)
        addSubview(bottomeTipsLabel)
        
        setConstrait()
        borderView2.addDashedBorder(borderColor: .white, dashPattern: [5,5])
        initLayer()
    }
    func setConstrait() {
        blurEffectView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        borderView2.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(tips2Label)
            make.left.top.equalTo(tips2Label).offset(kFitWidth(-8))
            make.right.bottom.equalTo(tips2Label).offset(kFitWidth(8))
        }
        tips2Label.snp.makeConstraints { make in
            make.top.equalTo(createFoodsButton.snp.bottom).offset(kFitWidth(100))
            make.left.equalTo(kFitWidth(46))
            make.right.equalTo(kFitWidth(-20))
        }
    }
    override func draw(_ rect: CGRect) {
        lineLayerTrangle.removeFromSuperlayer()
        drawArrowDashCreateFoods()
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

