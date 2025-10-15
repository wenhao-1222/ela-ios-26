//
//  ForumNaviTypeLiquidVM.swift
//  lns
//
//  Created by LNS2 on 2025/10/13.
//


// MARK: - 导航视图：使用 UISegmentedControl + 毛玻璃背景
class ForumNaviTypeLiquidVM: UIView {
    
    // MARK: Public
    var selectType: FORUM_TYPE_ENUM = .forum
    var statTypeBlock: ((FORUM_TYPE_ENUM) -> ())?
    
    // MARK: Private UI
    private let selfHeight = WHUtils().getNavigationBarHeight()
    private let btnWidth = kFitWidth(60)
    
    // ------- 可按需调整的外观参数 -------
    private let tintLightHex = "FFFFFF"     // 浅色模式主色（品牌蓝）
    private let tintDarkHex  = "1E5EFF"     // 深色模式主色（略调暗）
    private let topAlpha: CGFloat    = 0.5 // 顶部透明度
    private let bottomAlpha: CGFloat = 0 // 底部透明度
    private let featherHeight: CGFloat = 0//WHUtils().getNavigationBarHeight()// 底部羽化高度（px），越大越柔

    // 毛玻璃层：常显
    private lazy var blurView: UIVisualEffectView = {
        let effect: UIBlurEffect
//        if #available(iOS 13.0, *) {
//            effect = traitCollection.userInterfaceStyle == .dark
//            ? UIBlurEffect(style: .systemChromeMaterialDark)
//            : UIBlurEffect(style: .systemChromeMaterial)
//        } else {
            effect = UIBlurEffect(style: .systemChromeMaterial)
//        }
        let v = UIVisualEffectView(effect: effect)
        v.clipsToBounds = true
        v.alpha = 1
        v.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return v
    }()

    // 渐变着色层（在毛玻璃上叠一层颜色从上到下逐渐变淡）
    private let gradientLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.startPoint = CGPoint(x: 0.5, y: 0.0)
        g.endPoint   = CGPoint(x: 0.5, y: 1.0)
        // 三段更自然：顶 -> 过渡 -> 底
        g.locations  = [0.0, 0.42, 1.0]
        g.opacity    = 0.66
        return g
    }()

    // 顶部轻微高光（提升玻璃质感，可按需调低/去掉）
    private let shineLayer: CAGradientLayer = {
        let s = CAGradientLayer()
        s.startPoint = CGPoint(x: 0.5, y: 0.0)
        s.endPoint   = CGPoint(x: 0.5, y: 1.0)
        s.locations  = [0, 0.15]
        s.opacity    = 0.22
        s.colors = [
            UIColor.white.withAlphaComponent(0.22).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        return s
    }()

    // 底部羽化遮罩：让底缘在最后 featherHeight 内渐隐为 0，衔接更柔
    private let bottomFeatherMask = CAGradientLayer()
    
    // 分段选择器：课程 / 发现 / 商品
    private lazy var segment: UISegmentedControl = {
        let items = ["课程", "发现", "商品"]
        let seg = UISegmentedControl(items: items)
        // 初始选中「发现」
        seg.selectedSegmentIndex = 1
        if #available(iOS 13.0, *) {
            seg.selectedSegmentTintColor = UIColor.COLOR_TEXT_TITLE_0f1214_20 // 让选中更贴近玻璃感（可按需改）
            // 普通/选中态颜色
            seg.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50
            ], for: .normal)
            seg.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214
            ], for: .selected)
            // 背景透明，融入毛玻璃
            seg.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_06
        }
        seg.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return seg
    }()
    
    // 保留原有发布按钮逻辑
    lazy var publishButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "forum_publish_icon"), for: .normal)
        btn.isHidden = !UserInfoModel.shared.isAllowedPosterForum
        return btn
    }()
    
    // MARK: Init
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        // 背景透明以凸显毛玻璃
        backgroundColor = .clear
        initUI()
        configureGlassAppearanceIfNeeded()
    }
    
    // MARK: UI
    private func initUI() {
        addSubview(blurView)
//        blurView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(segment)
        addSubview(publishButton)
        setConstraints()
        updateButtonStatus() // 同步初始选中态
        // 渐变与高光叠到毛玻璃之上
        blurView.contentView.layer.addSublayer(gradientLayer)
        blurView.contentView.layer.addSublayer(shineLayer)

        // 设置固定外观
        applyFixedTint()

        // 配置底部羽化遮罩
        configureBottomFeatherMask()
    }
    /// 根据深/浅色模式套用主色，并设置自上而下 0.8→0.02 的透明度
    private func applyFixedTint() {
        let baseTint: UIColor
        if #available(iOS 13.0, *), traitCollection.userInterfaceStyle == .dark {
            baseTint = WHColor_16(colorStr: tintDarkHex)
        } else {
            baseTint = WHColor_16(colorStr: tintLightHex)
        }
        let aTop = max(0, min(1, topAlpha))
        let aBot = max(0, min(1, bottomAlpha))
        let aMid = (aTop + aBot) * 0.5

        gradientLayer.colors = [
            baseTint.withAlphaComponent(aTop).cgColor,
//            baseTint.withAlphaComponent(aMid).cgColor,
            baseTint.withAlphaComponent(aBot).cgColor
        ]
    }

    /// 底部竖向羽化遮罩：中上部完全可见，最后 featherHeight 区间渐隐为 0
    private func configureBottomFeatherMask() {
        bottomFeatherMask.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomFeatherMask.endPoint   = CGPoint(x: 0.5, y: 1.0)
        // mask 使用 alpha：白(1)=可见，黑(0)=不可见
        bottomFeatherMask.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,                       // 全可见
            UIColor.white.withAlphaComponent(0).cgColor,                       // 全可见
//            UIColor.black.withAlphaComponent(0).cgColor  // 渐隐到 0
        ]
        blurView.layer.mask = bottomFeatherMask
    }
    private func setConstraints() {
//        blurView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        blurView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(26))
        }
        // segment 居中，靠近底部（与原先按钮位置一致）
        segment.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kFitWidth(8))
            make.width.greaterThanOrEqualTo(btnWidth * 3 + kFitWidth(32)) // 3段 + 内间距
            make.height.equalTo(kFitWidth(32))
        }
        publishButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kFitWidth(16))
            make.centerY.equalTo(segment.snp.centerY)
            make.width.height.equalTo(kFitWidth(24))
        }
    }
    
    // MARK: 玻璃质感：在自定义导航容器上模拟系统导航栏的毛玻璃效果
    private func configureGlassAppearanceIfNeeded() {
        // 已在 blurView 中使用系统材质；如需更强调度，可叠加轻微半透色
        if #available(iOS 13.0, *) {
            // 在毛玻璃上叠一层极浅的背景色，效果更接近导航栏
            let overlay = UIView()
            overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0)
            overlay.isUserInteractionEnabled = false
            blurView.contentView.addSubview(overlay)
            overlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
}

// MARK: - 事件与状态同步
extension ForumNaviTypeLiquidVM {
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: selectType = .course
        case 1: selectType = .forum
        case 2: selectType = .market
        default: selectType = .forum
        }
        // 同步按钮状态（虽然现在使用 segment，但沿用原方法名，保证 ForumVC 兼容）
        updateButtonStatus()
        statTypeBlock?(selectType)
        // 轻微触感反馈（可选）
        let gen = UISelectionFeedbackGenerator()
        gen.prepare()
        gen.selectionChanged()
    }
    
    /// 兼容原有代码：更新选中态（现仅同步 segment 选中项）
    func updateButtonStatus() {
        switch selectType {
        case .course: segment.selectedSegmentIndex = 0
        case .forum:  segment.selectedSegmentIndex = 1
        case .market: segment.selectedSegmentIndex = 2
        }
    }
}

extension ForumNaviTypeLiquidVM{
    func updateAlpha(offsetY:CGFloat) {
        var percent = (offsetY * 3) / selfHeight
        percent = min(max(percent, 0), 0.9)
        blurView.alpha = percent
    }
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = blurView.bounds
        shineLayer.frame    = blurView.bounds

        // 根据当前高度计算羽化分界位置
        bottomFeatherMask.frame = blurView.bounds
        let h = bounds.height
        let fadeStart = max(0, min(1, (h - featherHeight) / max(h, 1))) // 渐隐起点的比例
        bottomFeatherMask.locations = [0.0, NSNumber(value: Double(fadeStart)), 1.0]
    }
}

