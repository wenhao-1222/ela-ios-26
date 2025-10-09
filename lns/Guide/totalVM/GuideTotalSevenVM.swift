//
//  GuideTotalSevenVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/10.
//


class GuideTotalSevenVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(()->())?
    private let dashLineLayer = CAShapeLayer()
    private let dashSquareLayer = CAShapeLayer()
    
    private let currentDashLineLayer = CAShapeLayer()//今日已摄入
    private let goalDashLineLayer = CAShapeLayer()//目标
    private let currentArrowLayer = CAShapeLayer()//今日已摄入箭头
    private let goalArrowLayer = CAShapeLayer()//目标箭头
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*6, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_F5
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.bounces = false
        scro.alwaysBounceVertical = true
        scro.showsVerticalScrollIndicator = false
        return scro
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.text = "目标 vs 摄入"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)

        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.text = "摄入越接近目标 进步越快！"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    lazy var imgBottomView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        return vi
    }()
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_img_step_7")
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(18)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    lazy var circleImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_img_step_7_circle")
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = kFitWidth(12)
        img.clipsToBounds = true
        
        return img
    }()
    lazy var caloriesCircleVm: GuideSevenCircleVM = {
        let vm = GuideSevenCircleVM.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(55), width: kFitWidth(76), height: kFitWidth(76)))
        return vm
    }()
    lazy var todayEatLabel : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .THEME
        lab.layer.cornerRadius = kFitWidth(6)
        lab.clipsToBounds = true
        lab.text = "今日已摄入"
        lab.textColor = .white
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var goalLabel : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .COLOR_GRAY_E8
        lab.layer.cornerRadius = kFitWidth(6)
        lab.clipsToBounds = true
        lab.text = "你刚刚设置的目标"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var chatBoxImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_chat_box_2")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        return img
    }()
    lazy var chatLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.text = "点击 "
        return lab
    }()
    lazy var chatLabel2: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        lab.text = "营养目标卡片"
        
        return lab
    }()
    lazy var chatLabel3: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.text = ",可对目标进行编辑"
        
        return lab
    }()
    
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("去记录", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.backgroundColor = .THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(addTapAction), for: .touchUpInside)
        
        return btn
    }()
    /// Tap gesture used to trigger shake animation when tapping outside the button
    private lazy var backgroundTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapAction(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }()
}

extension GuideTotalSevenVM{
    @objc func addTapAction() {
        self.nextBlock?()
    }
}
extension GuideTotalSevenVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.frame = CGRect.init(x: 0, y: statusBarHeight+kFitWidth(30), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-statusBarHeight-kFitWidth(30))
        scrollView.addSubview(titleLab)
        scrollView.addSubview(tipsLabel)
        scrollView.addSubview(imgBottomView)
        imgBottomView.addSubview(imgView)
        imgView.addSubview(circleImgView)
        circleImgView.addSubview(caloriesCircleVm)
        circleImgView.addSubview(todayEatLabel)
        circleImgView.addSubview(goalLabel)
        
        imgView.addSubview(chatBoxImgView)
        chatBoxImgView.addSubview(chatLabel)
        chatBoxImgView.addSubview(chatLabel2)
        chatBoxImgView.addSubview(chatLabel3)
        
        imgView.addSubview(searchButton)
        
//        // setup dash line layers
//        dashLineLayer.strokeColor = UIColor.white.cgColor
//        dashLineLayer.fillColor = nil
//        dashLineLayer.lineWidth = kFitWidth(1)
//        dashLineLayer.lineDashPattern = [5,3]
//        imgView.layer.addSublayer(dashLineLayer)
        
        currentDashLineLayer.strokeColor = UIColor.THEME.cgColor
        currentDashLineLayer.fillColor = nil
        currentDashLineLayer.lineWidth = kFitWidth(1)
        currentDashLineLayer.lineDashPattern = [5,3]
        circleImgView.layer.addSublayer(currentDashLineLayer)
        currentArrowLayer.fillColor = UIColor.THEME.cgColor
        circleImgView.layer.addSublayer(currentArrowLayer)
        
        goalDashLineLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor
        goalDashLineLayer.fillColor = nil
        goalDashLineLayer.lineWidth = kFitWidth(1)
        goalDashLineLayer.lineDashPattern = [5,3]
        circleImgView.layer.addSublayer(goalDashLineLayer)
        goalArrowLayer.fillColor = UIColor.COLOR_TEXT_TITLE_0f1214.cgColor
        circleImgView.layer.addSublayer(goalArrowLayer)
//
//        dashSquareLayer.fillColor = UIColor.white.cgColor
//        imgView.layer.addSublayer(dashSquareLayer)
        // Capture taps outside the searchButton to show shake animation
        addGestureRecognizer(backgroundTap)
        setConstrait()
        
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(42))
//            make.top.equalTo(statusBarHeight+kFitWidth(72))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(92))
//            make.top.equalTo(statusBarHeight+kFitWidth(122))
        }
        imgBottomView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(335))
            make.top.equalTo(kFitWidth(167))
        }
        imgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(5))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(325))
            make.height.equalTo(kFitWidth(576.5))
            make.bottom.equalToSuperview().offset(kFitWidth(-5))
        }
        circleImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(308))
            make.height.equalTo(kFitWidth(143))
            make.top.equalTo(kFitWidth(87))
        }
        todayEatLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(123))
            make.top.equalTo(kFitWidth(53))
            make.width.equalTo(kFitWidth(78))
            make.height.equalTo(kFitWidth(25))
        }
        goalLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(123))
            make.top.equalTo(kFitWidth(99))
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(25))
        }
        chatBoxImgView.snp.makeConstraints { make in
            make.top.equalTo(circleImgView.snp.bottom).offset(kFitWidth(68))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(280))
            make.height.equalTo(kFitWidth(40))
        }
        chatLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview().offset(kFitWidth(3))
            make.left.equalTo(kFitWidth(16))
        }
        chatLabel2.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(chatLabel)
            make.left.equalTo(chatLabel.snp.right).offset(kFitWidth(1))
        }
        chatLabel3.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(chatLabel)
            make.left.equalTo(chatLabel2.snp.right).offset(kFitWidth(1))
        }
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(488))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }
    }
}
extension GuideTotalSevenVM {
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0,
                                   y: statusBarHeight + kFitWidth(30),
                                   width: bounds.width,
                                   height: bounds.height - statusBarHeight - kFitWidth(30))
        layoutIfNeeded()
        if WHUtils().getBottomSafeAreaHeight() == 0 {
            let extra = kFitWidth(-20) + WHUtils().getBottomSafeAreaHeight()
            scrollView.contentSize = CGSize(width: 0, height: imgBottomView.frame.maxY + extra)
        }
        
        drawDashLine(animate: true)
    }
}

extension GuideTotalSevenVM {
    func drawDashLine(animate: Bool) {
        let start = CGPoint(x: chatBoxImgView.frame.midX,
                            y: chatBoxImgView.frame.minY-kFitWidth(2))
        let end = CGPoint(x: circleImgView.frame.midX ,
                          y: circleImgView.frame.maxY + kFitWidth(16))
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)

        dashLineLayer.path = path.cgPath
        
        let currentStart = CGPoint(x: todayEatLabel.frame.minX-kFitWidth(3),
                            y: todayEatLabel.frame.minY+kFitWidth(10))
        let currentEnd = CGPoint(x: caloriesCircleVm.frame.maxX-kFitWidth(12) ,
                          y: todayEatLabel.frame.maxY + kFitWidth(4))
        
        let controlPoint1 = CGPoint.init(x: currentEnd.x + (currentStart.x - currentEnd.x)*0.6,
                                         y: currentEnd.y + kFitWidth(3))
        
        let currentPath = UIBezierPath()
        currentPath.move(to: currentStart)
        currentPath.addQuadCurve(to: currentEnd, controlPoint: controlPoint1)
        currentDashLineLayer.path = currentPath.cgPath
        
        let arrowSize = kFitWidth(6)
        let currentArrowPath = UIBezierPath()
        currentArrowPath.move(to: currentEnd)
        currentArrowPath.addLine(to: CGPoint(x: currentEnd.x + arrowSize, y: currentEnd.y - arrowSize/2))
        currentArrowPath.addLine(to: CGPoint(x: currentEnd.x + arrowSize, y: currentEnd.y + arrowSize/2))
        currentArrowPath.close()
        currentArrowLayer.path = currentArrowPath.cgPath
        
        let goalStart = CGPoint(x: goalLabel.frame.minX-kFitWidth(3),
                                y: goalLabel.frame.midY)
        let goalEnd = CGPoint(x: caloriesCircleVm.frame.maxX-kFitWidth(12) ,
                              y: goalLabel.frame.minY + kFitWidth(5))
        
        let goalPath = UIBezierPath()
        goalPath.move(to: goalStart)
        goalPath.addLine(to: goalEnd)
        goalDashLineLayer.path = goalPath.cgPath
        
        let goalArrowPath = UIBezierPath()
        goalArrowPath.move(to: goalEnd)
        goalArrowPath.addLine(to: CGPoint(x: goalEnd.x + arrowSize - kFitWidth(1), y: goalEnd.y - arrowSize/2 + kFitWidth(1)))
        goalArrowPath.addLine(to: CGPoint(x: goalEnd.x + arrowSize - kFitWidth(2), y: goalEnd.y + arrowSize/2 + kFitWidth(1)))
        goalArrowPath.close()
        goalArrowLayer.path = goalArrowPath.cgPath
        
    }
    /// Handles taps outside the searchButton
    @objc private func backgroundTapAction(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: searchButton)
        if !searchButton.bounds.contains(point){
            shakeSearchButton()
            
            if  WHUtils().getBottomSafeAreaHeight() == 0 {
                let extra = kFitWidth(-20)// + WHUtils().getBottomSafeAreaHeight()
                scrollView.setContentOffset(CGPoint.init(x: 0, y: imgBottomView.frame.maxY + extra - scrollView.frame.height), animated: true)
            }
        }
    }

    /// Performs a subtle left-right shake on the search button
    private func shakeSearchButton() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.3
        animation.values = [-5, 5, -5, 5, 0]
        searchButton.layer.add(animation, forKey: "shake")
    }
}

extension GuideTotalSevenVM {
    /// Resets alpha for entrance animation
    func prepareEntranceAnimation() {
        titleLab.alpha = 0
        tipsLabel.alpha = 0
        imgBottomView.alpha = 0
        self.scrollView.setContentOffset(.zero, animated: false)
    }

    /// Fades in text labels then the bottom image view
    func startEntranceAnimation() {
        self.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.titleLab.alpha = 1
            self.tipsLabel.alpha = 1
//            self.nextButton.alpha = 1
        }completion: { _ in
            UIView.animate(withDuration: 0.8, delay: 0.5,options: .curveLinear) {
                self.imgBottomView.alpha = 1
            }completion: { _ in
                self.isUserInteractionEnabled = true
            }
        }
    }
}
