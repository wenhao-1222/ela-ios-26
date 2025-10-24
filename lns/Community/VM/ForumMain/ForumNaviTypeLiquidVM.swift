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
    private let selfHeight = WHUtils().getNavigationBarHeight()+kFitWidth(20)
    private let btnWidth = kFitWidth(60)
    let glass = GradientGlassView()
    private var segmentDecorator: SegmentedLiquidDecorator?
    // 毛玻璃层（背景层，放在最底）
    private lazy var blurView: UIVisualEffectView = {
        let effect: UIBlurEffect
        effect = UIBlurEffect(style: .systemThinMaterialDark)
        let v = UIVisualEffectView(effect: effect)
//        v.clipsToBounds = true
        v.alpha = 0.15          // 模糊层总体不透明度 7%
        v.backgroundColor = .clear
        return v
    }()
    private let bottomFeatherMask = CAGradientLayer()
    
    // 分段选择器：课程 / 发现 / 商品
    private lazy var segment: UISegmentedControl = {
        let items = ["课程", "发现"]
//        let items = ["课程", "发现", "商品"]
        let seg = UISegmentedControl(items: items)
        // 初始选中「发现」
        seg.selectedSegmentIndex = 1
        seg.backgroundColor = UIColor.clear
        seg.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_03.cgColor
        seg.layer.borderWidth = kFitWidth(2)
        if #available(iOS 13.0, *) {
            seg.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.6) // 让选中更贴近玻璃感（可按需改）
            // 普通/选中态颜色
            seg.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_30
            ], for: .normal)
            seg.setTitleTextAttributes([
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214
            ], for: .selected)
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
    }
    
    // MARK: UI
    private func initUI() {
//        addSubview(blurView)
//        blurView.translatesAutoresizingMaskIntoConstraints = false
        glass.translatesAutoresizingMaskIntoConstraints = false
        glass.topOpacity = 1.0
        glass.bottomOpacity = 0.0
        addSubview(glass)

        addSubview(segment)
        addSubview(publishButton)
        setConstraints()
        updateButtonStatus() // 同步初始选中态
        // 让分段控件更“立体”
        segment.layer.cornerRadius = kFitWidth(20)
        if #available(iOS 13.0, *) { segment.layer.cornerCurve = .continuous }
        segment.layer.masksToBounds = false
        segment.layer.shadowOpacity = 0    // 关键：关闭外部阴影
        segment.layer.shadowPath = nil

        self.segmentDecorator = SegmentedLiquidDecorator(target: segment)
//        self.segmentDecorator.back
        // 配置底部羽化遮罩
//        configureBottomFeatherMask()
    }
    
    private func configureBottomFeatherMask() {
        bottomFeatherMask.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomFeatherMask.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
//        applySoftMask(to: bottomFeatherMask, topHold: 0.15, steps: 18, strength: 1)
        // 想更轻一点（整体弱化）：strength 设小些，比如 0.75
        // 想过渡更丝滑：steps 设 8 或 10（注意性能影响非常小）

//        blurView.layer.mask = bottomFeatherMask
    }
    /// 生成一组柔和的梯度遮罩（上强下弱）
    /// - Parameters:
    ///   - topHold: 顶部保持强模糊的占比 [0,1]
    ///   - steps: 过渡分段数（越大越平滑，建议 4~8）
    ///   - strength: 整体“雾量”，1.0=原强度，0.6=更轻
    func applySoftMask(to layer: CAGradientLayer,
                       topHold: CGFloat = 0.25,
                       steps: Int = 6,
                       strength: CGFloat = 1.0)
    {
        func easeInOut(_ t: CGFloat) -> CGFloat {
            // 经典 cubic ease-in-out
            return t < 0.5 ? 4*t*t*t : 1 - pow(-2*t + 2, 3)/2
        }

        // 组装 locations：前面 0 和 topHold 做 plateau，其后做等距细分
        var locs: [CGFloat] = [0.0, max(0.0, min(1.0, topHold))]
        for i in 1...steps {
            let p = CGFloat(i) / CGFloat(steps)           // 0→1
            let y = topHold + (1 - topHold) * p           // topHold→1
            locs.append(y)
        }

        // 组装 colors：alpha 从 1.0（顶部）按 S 曲线缓慢降到 0
        var cols: [CGColor] = []
        for (idx, l) in locs.enumerated() {
            let t: CGFloat
            if l <= topHold {
                t = 0                                     // plateau 区全强
            } else {
                let local = (l - topHold) / (1 - topHold) // 归一化到 0~1
                t = easeInOut(local)
            }
            let a = max(0, min(1, (1 - t) * strength))    // 由强(1)到弱(0)
            cols.append(UIColor.black.withAlphaComponent(a).cgColor)
            
            // 小技巧：在 topHold 位置再插一个相同 alpha，做更稳的台阶
            if idx == 1 {
                cols.append(UIColor.black.withAlphaComponent(a).cgColor)
            }
        }

        // locations 也要对应重复一个（与上面对齐）
        locs.insert(locs[1], at: 2)

        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        layer.locations  = locs.map { NSNumber(value: Double($0)) }
        layer.colors     = cols
    }

    private func setConstraints() {
//        blurView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        blurView.snp.makeConstraints { make in
//            make.left.top.right.equalToSuperview()
//            make.bottom.equalTo(kFitWidth(54))
//        }
        glass.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(kFitWidth(94))
        }
        // segment 居中，靠近底部（与原先按钮位置一致）
        segment.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.left.equalTo(kFitWidth(16))
            make.left.equalTo(kFitWidth(18))
            make.bottom.equalToSuperview().offset(-kFitWidth(8))
            make.width.greaterThanOrEqualTo(btnWidth * 3 + kFitWidth(32)) // 3段 + 内间距
            make.height.equalTo(kFitWidth(40))
        }
        publishButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kFitWidth(16))
            make.centerY.equalTo(segment.snp.centerY)
            make.width.height.equalTo(kFitWidth(24))
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
        
        if offsetY > kFitWidth(44){
            if segment.backgroundColor == UIColor.COLOR_TEXT_TITLE_0f1214_06{
                UIView.animate(withDuration: 0.15, animations: {
                    self.segment.backgroundColor = UIColor.white.withAlphaComponent(0.8)//UIColor.COLOR_TEXT_TITLE_0f1214_30
                })
            }
        }else{
            if segment.backgroundColor == UIColor.COLOR_TEXT_TITLE_0f1214_30{
                UIView.animate(withDuration: 0.15, animations: {
                    self.segment.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_06
                })
            }
        }
    }
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
//        // 根据当前高度计算羽化分界位置
        bottomFeatherMask.frame = blurView.bounds
        segmentDecorator?.relayout() // 跟随尺寸变化刷新遮罩/高光位置
    }
}

