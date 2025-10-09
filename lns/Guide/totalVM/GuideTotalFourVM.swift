//
//  GuideTotalFourVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/9.
//


class GuideTotalFourVM: UIView {
    
    var selfHeight = SCREEN_HEIGHT
    var nextBlock:(()->())?
    private let dashLineLayer = CAShapeLayer()
    private let dashSquareLayer = CAShapeLayer()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT*3, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
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
        lab.text = "你吃的，这里都有"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 25, weight: .semibold)
        //        lab.backgroundColor = WHColor_ARC()
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.text = "万种食物，来自USDA等权威数据库"
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
        img.setImgLocal(imgName: "guide_img_step_4")
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
        lab.text = "输入你吃的食物后，点击"
//        var attr = NSMutableAttributedString(string: "输入你吃的食物后，点击")
//        var attr1 = NSMutableAttributedString(string: "搜索")
//        
//        attr.yy_font = .systemFont(ofSize: 13, weight: .regular)
//        attr1.yy_font = .systemFont(ofSize: 18, weight: .semibold)
//        attr.append(attr1)
//        
//        lab.attributedText = attr
//        
        return lab
    }()
    lazy var chatLabel2: UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        lab.text = "搜索"
        
        return lab
    }()
    
    lazy var searchButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("搜索", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        
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

extension GuideTotalFourVM{
    @objc func addTapAction() {
        self.nextBlock?()
    }
}
extension GuideTotalFourVM{
    func initUI() {
        addSubview(scrollView)
        scrollView.frame = CGRect.init(x: 0, y: statusBarHeight+kFitWidth(30), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-statusBarHeight-kFitWidth(30))
        scrollView.addSubview(titleLab)
        scrollView.addSubview(tipsLabel)
        scrollView.addSubview(imgBottomView)
        imgBottomView.addSubview(imgView)
        
        imgView.addSubview(chatBoxImgView)
        chatBoxImgView.addSubview(chatLabel)
        chatBoxImgView.addSubview(chatLabel2)
        
        imgView.addSubview(searchButton)
        // flip chat box vertically
        chatBoxImgView.transform = CGAffineTransform(scaleX: 1, y: -1)
        chatLabel.transform = CGAffineTransform(scaleX: 1, y: -1)
        chatLabel2.transform = CGAffineTransform(scaleX: 1, y: -1)

        // setup dash line layers
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
        startSearchButtonColorAnimation()
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
        chatBoxImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(265))
            make.width.equalTo(kFitWidth(217))
            make.height.equalTo(kFitWidth(40))
        }
        chatLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.centerX.lessThanOrEqualToSuperview().offset(kFitWidth(-14))
        }
        chatLabel2.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(chatLabel.snp.right).offset(kFitWidth(1))
        }
        searchButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-2.5))
            make.top.equalTo(kFitWidth(426.5))
            make.width.equalTo(kFitWidth(60))
            make.height.equalTo(kFitWidth(85))
        }
    }
}
extension GuideTotalFourVM {
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0,
                                   y: statusBarHeight + kFitWidth(30),
                                   width: bounds.width,
                                   height: bounds.height - statusBarHeight - kFitWidth(30))
        layoutIfNeeded()
        if WHUtils().getBottomSafeAreaHeight() == 0 {
            let extra = kFitWidth(-20)// + WHUtils().getBottomSafeAreaHeight()
            scrollView.contentSize = CGSize(width: 0, height: imgBottomView.frame.maxY + extra)
        }
    }
}

extension GuideTotalFourVM {
    func drawDashLine(animate: Bool) {
        let start = CGPoint(x: chatBoxImgView.frame.midX,
                            y: chatBoxImgView.frame.maxY+kFitWidth(2))
        let end = CGPoint(x: searchButton.frame.minX - kFitWidth(17),
                          y: searchButton.frame.minY + kFitWidth(24))
        
        let controlPoint1 = CGPoint.init(x: start.x + (end.x - start.x)*0.2,
                                         y: end.y - (end.y - start.y)*0.1)
        let path = UIBezierPath()
        path.move(to: start)
        path.addQuadCurve(to: end, controlPoint: controlPoint1)

        dashLineLayer.path = path.cgPath
        let squareSize = kFitWidth(4)
        dashSquareLayer.bounds = CGRect(x: 0, y: 0, width: squareSize, height: squareSize)
        dashSquareLayer.position = CGPoint(x: end.x, y: end.y)

        let squarePath = UIBezierPath(rect: dashSquareLayer.bounds)
        dashSquareLayer.path = squarePath.cgPath

        // 使用 CATransform3D 进行真正的顺时针旋转
        dashSquareLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)

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
                let extra = kFitWidth(-20) + WHUtils().getBottomSafeAreaHeight()
    //            scrollView.contentSize = CGSize(width: 0, height: imgBottomView.frame.maxY + extra)
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

extension GuideTotalFourVM {
    /// Animates the search button's background color between theme and 0x00E5FF.
    private func startSearchButtonColorAnimation() {
        let anim = CABasicAnimation(keyPath: "backgroundColor")
        anim.fromValue = UIColor.THEME.cgColor
        anim.toValue = UIColor(hex: "00E5FF").cgColor
        anim.duration = 1.0
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false
        searchButton.layer.add(anim, forKey: "colorChange")
    }
}
extension GuideTotalFourVM {
    /// Resets alpha values for entrance animation
    func prepareEntranceAnimation() {
        titleLab.alpha = 0
        tipsLabel.alpha = 0
        imgBottomView.alpha = 0
        self.scrollView.setContentOffset(.zero, animated: false)
    }

    /// Sequentially fades in texts then image view
    func startEntranceAnimation() {
//        self.isUserInteractionEnabled = false
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
