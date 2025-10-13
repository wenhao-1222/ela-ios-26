//
//  ForumNaviTypeLiquidVM.swift
//  lns
//
//  Created by LNS2 on 2025/10/13.
//


//import UIKit
//import SnapKit
//import MCToast
//import Photos
//import MobileCoreServices

// MARK: - 导航视图：使用 UISegmentedControl + 毛玻璃背景
class ForumNaviTypeLiquidVM: UIView {
    
    // MARK: Public
    var selectType: FORUM_TYPE_ENUM = .forum
    var statTypeBlock: ((FORUM_TYPE_ENUM) -> ())?
    
    // MARK: Private UI
    private let selfHeight = WHUtils().getNavigationBarHeight()
    private let btnWidth = kFitWidth(60)
    
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
    
    // 顶部发丝分割线（更贴近系统导航栏质感）
    private lazy var topSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.separator.withAlphaComponent(0.4)
        return v
    }()
    
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
        addSubview(topSeparator)
        addSubview(segment)
        addSubview(publishButton)
        setConstraints()
        updateButtonStatus() // 同步初始选中态
    }
    
    private func setConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        topSeparator.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
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
}
