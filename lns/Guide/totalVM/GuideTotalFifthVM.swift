//
//  GuideTotalFifthVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/10.
//


class GuideTotalFifthVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(()->())?
    private let dashLineLayer = CAShapeLayer()
    private let dashSquareLayer = CAShapeLayer()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*4, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
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
        lab.text = "恭喜！ \n你完成了一餐记录的80%"
        lab.numberOfLines = 2
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        //        lab.backgroundColor = WHColor_ARC()
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
        img.setImgLocal(imgName: "guide_img_step_5")
        img.isUserInteractionEnabled = true
        img.layer.cornerRadius = kFitWidth(18)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        
        return img
    }()
    
    lazy var chatBoxImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "guide_chat_box")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        return img
    }()
    lazy var chatLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.text = "选择完食物和份量后，"
        
        return lab
    }()
    lazy var chatLabel2: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        lab.text = "添加"
        
        return lab
    }()
    lazy var chatLabel3: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.text = "即可"
        
        return lab
    }()
    
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("添加", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.backgroundColor = .THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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

extension GuideTotalFifthVM{
    @objc func addTapAction() {
        self.nextBlock?()
    }
}
extension GuideTotalFifthVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.frame = CGRect.init(x: 0, y: statusBarHeight+kFitWidth(30), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-statusBarHeight-kFitWidth(30))
        scrollView.addSubview(titleLab)
        scrollView.addSubview(imgBottomView)
        imgBottomView.addSubview(imgView)
        
        imgView.addSubview(chatBoxImgView)
        chatBoxImgView.addSubview(chatLabel)
        chatBoxImgView.addSubview(chatLabel2)
        chatBoxImgView.addSubview(chatLabel3)
        
        imgView.addSubview(searchButton)
        // flip chat box vertically
        chatBoxImgView.transform = CGAffineTransform(scaleX: 1, y: -1)
        chatLabel.transform = CGAffineTransform(scaleX: 1, y: -1)
        chatLabel2.transform = CGAffineTransform(scaleX: 1, y: -1)
        chatLabel3.transform = CGAffineTransform(scaleX: 1, y: -1)

//        // setup dash line layers
//        dashLineLayer.strokeColor = UIColor.white.cgColor
//        dashLineLayer.fillColor = nil
//        dashLineLayer.lineWidth = kFitWidth(1)
//        dashLineLayer.lineDashPattern = [5,3]
//        imgView.layer.addSublayer(dashLineLayer)
//
//        dashSquareLayer.fillColor = UIColor.white.cgColor
//        imgView.layer.addSublayer(dashSquareLayer)
        // Capture taps outside the searchButton to show shake animation
        addGestureRecognizer(backgroundTap)
        setConstrait()
    }
    func setConstrait() {
        titleLab.snp.makeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(47))
            make.top.equalTo(kFitWidth(42))
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
        chatBoxImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(361))
            make.width.equalTo(kFitWidth(217))
            make.height.equalTo(kFitWidth(40))
        }
        chatLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(10))
        }
        chatLabel2.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(chatLabel.snp.right).offset(kFitWidth(1))
        }
        chatLabel3.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(chatLabel2.snp.right).offset(kFitWidth(1))
        }
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(492))
            make.width.equalTo(kFitWidth(301))
            make.height.equalTo(kFitWidth(48))
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
}
extension GuideTotalFifthVM {
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
    }
}

extension GuideTotalFifthVM {
    func drawDashLine(animate: Bool) {
        let start = CGPoint(x: chatBoxImgView.frame.midX,
                            y: chatBoxImgView.frame.maxY+kFitWidth(2))
        let end = CGPoint(x: searchButton.frame.midX ,
                          y: searchButton.frame.minY - kFitWidth(10))
        
        let path = UIBezierPath()
        path.move(to: start)

        path.addLine(to: end)

        dashLineLayer.path = path.cgPath

        let squareRect = CGRect(x: end.x - kFitWidth(2),
                                y: end.y + kFitWidth(2),
                                width: kFitWidth(4),
                                height: kFitWidth(4))
        
        dashSquareLayer.frame = squareRect
        let squarePath = UIBezierPath(rect: dashSquareLayer.bounds)
//        dashSquareLayer.path = squarePath.cgPath
//        dashSquareLayer.setAffineTransform(CGAffineTransform(rotationAngle: .pi * 0.5))
        dashSquareLayer.path = squarePath.cgPath
        dashSquareLayer.transform = CATransform3DMakeRotation(-.pi / 4, 0, 0, 1)

        if animate {
            dashLineLayer.removeAllAnimations()
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 0.3
            dashLineLayer.strokeEnd = 1
            dashLineLayer.add(animation, forKey: "dash")
        }
    }
    /// Handles taps outside the searchButton
    @objc private func backgroundTapAction(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: searchButton)
        if !searchButton.bounds.contains(point) {
            shakeSearchButton()
            if  WHUtils().getBottomSafeAreaHeight() == 0 {
                let extra = kFitWidth(-20) //+ WHUtils().getBottomSafeAreaHeight()
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
extension GuideTotalFifthVM {
    /// Prepare subviews before entrance animation
    func prepareEntranceAnimation() {
        titleLab.alpha = 0
        imgBottomView.alpha = 0
        self.scrollView.setContentOffset(.zero, animated: false)
    }

    /// Fades in title then image container
    func startEntranceAnimation() {
//        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.titleLab.alpha = 1
//            self.tipsLabel.alpha = 1
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
