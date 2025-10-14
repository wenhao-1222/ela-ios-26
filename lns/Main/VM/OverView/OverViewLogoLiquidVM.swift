//
//  OverViewLogoLiquidVM.swift
//  lns
//
//  Created by Elavatine on 2025/5/30.
//


class OverViewLogoLiquidVM: UIView {
    
    let selfHeight = kFitWidth(38)+statusBarHeight+kFitWidth(4)
    var number = 0
    
    var planTapBlock:(()->())?
    var editBlock:(()->())?
    
    let logoImg = UIImage(named: "main_top_logo_cj")
    let imgWidth = kFitWidth(139)
    let imgHeight = kFitWidth(25)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
//        self.backgroundColor = UIColor(white: 1, alpha: 0)
        
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // 毛玻璃（玻璃质感）背景
    private lazy var blurView: UIVisualEffectView = {
        // 使用系统材质，透明柔和，适配深浅色
        let effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.clipsToBounds = true
        view.alpha = 0//0.95
        view.backgroundColor = .clear
        return view
    }()
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.locations = [0, 1]
        return layer
    }()
//    lazy var bgView: UIView = {
//        let vi = UIView()
//        vi.backgroundColor = .COLOR_BG_WHITE
//        vi.alpha = 0
//        vi.isUserInteractionEnabled = true
//        return vi
//    }()
    lazy var logoImgView: UIImageView = {
        let img = UIImageView(frame: CGRect(x: kFitWidth(32), y: self.selfHeight-kFitWidth(25)-kFitWidth(10), width: kFitWidth(139), height: kFitWidth(25)))
        img.image = logoImg?.withRenderingMode(.alwaysTemplate)
        img.tintColor = .white
        img.contentMode = .scaleAspectFit
        return img
    }()
}

extension OverViewLogoLiquidVM{
    func updateAlpha(offsetY:CGFloat) {
        var percent = offsetY / selfHeight
        percent = min(max(percent, 0), 0.8)

        blurView.alpha = min(percent,0.65)

        let value = pow(percent, 3)
//        backgroundColor = UIColor(white: 1, alpha: value)
        gradientLayer.opacity = Float(min(value,0.2))
        let start = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        let end = WHColorWithAlpha(colorStr: "007AFF", alpha: 1)
        
        DLLog(message: "updateAlphaj:\(offsetY)")
        if offsetY >= kFitWidth(30){
            logoImgView.frame = CGRect(x: SCREEN_WIDHT*0.5-kFitWidth(139)*0.5, y: self.selfHeight-kFitWidth(25)-kFitWidth(10), width: kFitWidth(139), height: kFitWidth(25))
            logoImgView.tintColor = blendColor(from: start, to: end, progress: 1)
        }else{
            logoImgView.frame = CGRect(x: kFitWidth(32), y: self.selfHeight-kFitWidth(25)-kFitWidth(10), width: kFitWidth(139), height: kFitWidth(25))
            logoImgView.tintColor = blendColor(from: start, to: end, progress: 0)
        }
    }
}
private func blendColor(from: UIColor, to: UIColor, progress: CGFloat) -> UIColor {
    let ratio = min(max(progress, 0), 1)
    var fr: CGFloat = 0, fg: CGFloat = 0, fb: CGFloat = 0, fa: CGFloat = 0
    var tr: CGFloat = 0, tg: CGFloat = 0, tb: CGFloat = 0, ta: CGFloat = 0
    from.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
    to.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
    return UIColor(red: fr + (tr - fr) * ratio,
                   green: fg + (tg - fg) * ratio,
                   blue: fb + (tb - fb) * ratio,
                   alpha: fa + (ta - fa) * ratio)
}

extension OverViewLogoLiquidVM{
    func initUI() {
        addSubview(blurView)
        addSubview(logoImgView)
        
        blurView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        configureGradientBackground()
//        bgView.addShadow(opacity: 0.05)
    }
}
private extension OverViewLogoLiquidVM {
    func configureGradientBackground() {
        updateGradientColors()
        gradientLayer.frame = bounds
        blurView.contentView.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.opacity = 0
    }

    func updateGradientColors() {
        let lightTop = WHColorWithAlpha(colorStr: "F7F8FF", alpha: 0.8)
        let lightBottom = WHColorWithAlpha(colorStr: "D0E2FF", alpha: 0.1)
        var topColor = lightTop
        var bottomColor = lightBottom
//        if #available(iOS 13.0, *) {
//            if traitCollection.userInterfaceStyle == .dark {
//                topColor = UIColor(red: 34/255.0, green: 34/255.0, blue: 38/255.0, alpha: 0.9)
//                bottomColor = UIColor(red: 20/255.0, green: 22/255.0, blue: 30/255.0, alpha: 0.78)
//            }
//        }
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
}

extension OverViewLogoLiquidVM {
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = blurView.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            updateGradientColors()
        }
    }
}
