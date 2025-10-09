//
//  AddFoodsAlertVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/20.
//


class AddFoodsAlertVM: UIView {
    
    var addBtnOriginY = statusBarHeight + 44 + LogsNaturalGoalVM().selfHeight + kFitWidth(12)
    
    var addBlock:(()->())?
    
    private let lineLayer = CAShapeLayer()
    private var linePath = UIBezierPath()
    private let lineLayerTrangle = CAShapeLayer()
    private var linePathTrangle = UIBezierPath()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        self.alpha = 0
        if UserInfoModel.shared.hidden_survery_button_status{
            addBtnOriginY = statusBarHeight + 44 + kFitWidth(180) + kFitWidth(12)
        }
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14)
        lab.textColor = .white
        lab.text = "点击“+”，记录吃进去的食物"
        
        return lab
    }()
    lazy var addBottomView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "logs_add_icon_theme"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var borderView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_BLACK_25
        return vi
    }()
    lazy var blurEffect: UIBlurEffect = {
        let vi = UIBlurEffect(style:.extraLight)
        return vi
    }()
    lazy var blurEffectView: UIVisualEffectView = {
        let vi = UIVisualEffectView(effect: blurEffect)
        vi.alpha = 0.6

        return vi
    }()
}

extension AddFoodsAlertVM{
    @objc func addAction() {
        if self.addBlock != nil{
            self.addBlock!()
        }
        self.isHidden = true
    }
    @objc func showView() {
        self.isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0,options: .curveLinear) {
            self.alpha = 1
        }
    }
    @objc func hiddenView() {
        UIView.animate(withDuration: 0.15, delay: 0) {
            self.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
}
extension AddFoodsAlertVM{
    override func draw(_ rect: CGRect) {
        borderView.setNeedsLayout()
        borderView.layoutIfNeeded()
        addBottomView.setNeedsLayout()
        addBottomView.layoutIfNeeded()
        drawArrowDash()
    }
    func asImage() -> UIImage {
            let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
            return renderer.image { (rendererContext) in
                layer.render(in: rendererContext.cgContext)
            }
        }
    func initUI() {
        addSubview(blurEffectView)
        addSubview(borderView)
        addSubview(tipsLabel)
        
        addSubview(addBottomView)
        addSubview(addButton)
        
        setConstrait()
        
        borderView.addDashedBorder(borderColor: .white, dashPattern: [5,5])
        
        initLayer()
    }
    func setConstrait(){
        blurEffectView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        borderView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(tipsLabel)
            make.left.top.equalTo(tipsLabel).offset(kFitWidth(-8))
            make.right.bottom.equalTo(tipsLabel).offset(kFitWidth(8))
        }
        tipsLabel.snp.remakeConstraints { make in
            make.right.equalTo(addBottomView.snp.left).offset(kFitWidth(-20))
            make.centerY.lessThanOrEqualTo(addBottomView).offset(kFitWidth(90))
        }
        addButton.snp.makeConstraints { make in
            make.top.equalTo(addBtnOriginY)
            make.right.equalTo(kFitWidth(-8))
            make.width.equalTo(kFitWidth(52))
            make.height.equalTo(kFitWidth(50))
        }
        addBottomView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(addButton)
            make.width.height.equalTo(kFitWidth(36))
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
        let firstPoint = CGPoint.init(x: borderView.frame.midX - borderView.frame.width*0.25, y: borderView.frame.minY)
        let endPoint = CGPoint.init(x: addBottomView.frame.minX-5, y: addBottomView.frame.midY)
        let controlPoint1 = CGPoint.init(x: firstPoint.x + (endPoint.x - firstPoint.x)*0.3,
                                         y: endPoint.y - (firstPoint.y - endPoint.y)*0.1)
        linePath = UIBezierPath()
        linePathTrangle = UIBezierPath()
        
        linePath.move(to: firstPoint )
        linePath.addQuadCurve(to: endPoint, controlPoint: controlPoint1)
        lineLayer.path = linePath.cgPath
        
        let arcPoints = WHUtils().getArrowPoint(fPoint: CGPoint.init(x: endPoint.x-15, y: endPoint.y),
                                      tPoint: CGPoint.init(x: endPoint.x-5, y: endPoint.y))
        
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
}
