//
//  ElaProReadyVM.swift
//  lns
//
//  Created by Codex on 2026/3/4.
//

import UIKit
import SnapKit

class ElaProReadyVM: UIView {
    enum DietStrategy {
        case balanced
        case highProtein
        case keto
        case lowCarb
    }
    
    enum SpecialAdjustment {
        case lowerUricAcid
        case lowerBloodLipids
    }
    
    private struct ReadyItem {
        let title: String
        let desc: String
        let highlights: [String]
    }
    
    private var selectedStrategy: DietStrategy = .balanced
    private var selectedSpecialAdjustment: SpecialAdjustment?
    private var items: [ReadyItem] = []
    private var titleTopConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        
        applySelectionsFromQuestionnaire()
        initUI()
        rebuildCards()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        titleTopConstraint?.update(offset: resolvedStatusBarHeight() + kFitWidth(52))
    }
    
    private func resolvedStatusBarHeight() -> CGFloat {
        if let scene = window?.windowScene {
            return scene.statusBarManager?.statusBarFrame.height ?? statusBarHeight
        }
        return statusBarHeight
    }
    
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_progress_bg")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView()
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        return vi
    }()
    
    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "一切都替你准备好了"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var stackView: UIStackView = {
        let vi = UIStackView()
        vi.axis = .vertical
        vi.spacing = kFitWidth(12)
        vi.alignment = .fill
        vi.distribution = .fill
        return vi
    }()
}

extension ElaProReadyVM {
    func configure(strategy: DietStrategy, specialAdjustment: SpecialAdjustment?) {
        selectedStrategy = strategy
        selectedSpecialAdjustment = specialAdjustment
        rebuildCards()
    }
    
    private func applySelectionsFromQuestionnaire() {
        selectedStrategy = resolveStrategyFromQuestionnaire()
        selectedSpecialAdjustment = resolveSpecialAdjustmentFromQuestionnaire()
    }
    
    private func resolveStrategyFromQuestionnaire() -> DietStrategy {
        // 新问卷里饮食风格会写到 events（1~4），优先按索引解析。
        let styleRaw = QuestinonaireMsgModel.shared.events.trimmingCharacters(in: .whitespacesAndNewlines)
        if let styleIndex = Int(styleRaw) {
            switch styleIndex {
            case 1: return .balanced
            case 2: return .highProtein
            case 3: return .keto
            case 4: return .lowCarb
            default: break
            }
        }
        
        // 兼容直接存中文/英文关键字的情况。
        let combined = (QuestinonaireMsgModel.shared.events + "|" + QuestinonaireMsgModel.shared.dietHistoryType).lowercased()
        if combined.contains("高蛋白") || combined.contains("protein") {
            return .highProtein
        }
        if combined.contains("生酮") || combined.contains("keto") {
            return .keto
        }
        if combined.contains("低碳") || combined.contains("low") || combined.contains("carb") {
            return .lowCarb
        }
        return .balanced
    }
    
    private func resolveSpecialAdjustmentFromQuestionnaire() -> SpecialAdjustment? {
        // 优先级：降尿酸 > 降血脂
        let goalRaw = QuestinonaireMsgModel.shared.goal
        let combined = (goalRaw + "|" + QuestinonaireMsgModel.shared.foodBarrier).lowercased()
        if combined.contains("尿酸") {
            return .lowerUricAcid
        }
        if combined.contains("血脂") {
            return .lowerBloodLipids
        }
        
        // 兼容旧问卷 goal 为枚举值：7=改善血脂，8=降低尿酸
        let tokens = goalRaw
            .split(whereSeparator: { ",|， ".contains($0) })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        if tokens.contains("8") {
            return .lowerUricAcid
        }
        if tokens.contains("7") {
            return .lowerBloodLipids
        }
        return nil
    }
    
    private func buildItems() -> [ReadyItem] {
        var result: [ReadyItem] = []
        result.append(ReadyItem(
            title: "精准无猜测",
            desc: "我们将菜谱内每个食材精细到“克”级别，而不仅仅是提供一道菜名，始终将效果和达成目标放在第一位。",
            highlights: ["精细到“克”级别","效果和达成目标"]
        ))
        
        result.append(ReadyItem(
            title: "定制化饮食策略",
            desc: strategyText(),
            highlights: strategyHighlights()
        ))
        
        result.append(ReadyItem(
            title: "节省外食成本",
            desc: "我们为你定制的食谱能帮你以外食 20% 左右的价格达到营养目标，一年下来可节省超过 40,000 元。（按包含 40g 蛋白质的轻食外卖均价 30 到 40 元，一天 3 到 5 餐取中间值估算）",
            highlights: ["外食 20% 左右的价格","节省超过 40,000 元。"]
        ))
        
        result.append(ReadyItem(
            title: "食材生熟重对照",
            desc: "和家人吃饭用熟重分餐，自己单独备餐按生重准备，适配各种用餐场景。",
            highlights: ["熟重分餐","生重准备"]
        ))
        
        result.append(ReadyItem(
            title: "灵活贴近日常",
            desc: "每一餐都为你准备了多种备选，可自由替换。\n突然加班、聚餐，或临时不想做饭？你也可以跳过该餐，按我们给你的当天营养目标继续保持进度。",
            highlights: ["自由替换","跳过该餐","继续保持进度"]
        ))
        
        if selectedSpecialAdjustment != nil {
        let special = SpecialAdjustment.lowerUricAcid
            result.append(ReadyItem(
                title: "为你做出特殊调整",
                desc: specialText(special),
                highlights: specialHighlights(special)
            ))
        }
        
        return result
    }
    
    private func strategyText() -> String {
        switch selectedStrategy {
        case .balanced:
            return "我们为你搭配的餐食计划将更接近你的日常饮食习惯，为你节省每一餐的决策成本，并提供专业支持。"
        case .highProtein:
            return "我们为你搭配的餐食计划包含约 40% 的蛋白质，无需担心吃不到目标。"
        case .keto:
            return "我们为你搭配的餐食计划包含约 65% 的优质脂肪，帮助你更快进入生酮状态。"
        case .lowCarb:
            return "我们为你安排了丰富的高营养密度食物，帮助你在低碳的情况下依然保证饱腹感。"
        }
    }
    
    private func strategyHighlights() -> [String] {
        switch selectedStrategy {
        case .balanced:
            return ["更接近你的日常饮食习惯", "节省每一餐的决策成本"]
        case .highProtein:
            return ["约 40% 的蛋白质"]
        case .keto:
            return ["约 65% 优质脂肪", "更快进入生酮状态"]
        case .lowCarb:
            return ["保证饱腹感"]
        }
    }
    
    private func specialText(_ special: SpecialAdjustment) -> String {
        switch special {
        case .lowerUricAcid:
            return "我们会优先选择中低嘌呤食材，让你在对齐健身目标的同时，辅助降低尿酸。"
        case .lowerBloodLipids:
            return "我们会为你定制更利于血脂管理的搭配，帮助你更平稳地维持在理想状态。"
        }
    }
    
    private func specialHighlights(_ special: SpecialAdjustment) -> [String] {
        switch special {
        case .lowerUricAcid:
            return ["中低嘌呤食材"]
        case .lowerBloodLipids:
            return ["更平稳的维持"]
        }
    }
    
    private func rebuildCards() {
        items = buildItems()
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for item in items {
            let card = ElaProReadyItemCardView()
            card.configure(title: item.title, desc: item.desc, highlights: item.highlights)
            stackView.addArrangedSubview(card)
        }
    }
}

extension ElaProReadyVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        
        setConstrait()
//        scrollView.contentSize
        //-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(86))
    }
    
    func setConstrait() {
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(86)))
        }
        
        contentView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(86)))
        }
        
        titleLabel.snp.makeConstraints { make in
            titleTopConstraint = make.top.equalTo(statusBarHeight + kFitWidth(52)).constraint
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(45))
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.bottom.equalToSuperview().offset(kFitWidth(-20))
        }
    }
}

private final class ElaProReadyItemCardView: UIView {
    private let titleColor = UIColor.COLOR_TEXT_TITLE_0f1214
    private let descColor = UIColor.COLOR_TEXT_TITLE_0f1214_60
    
    private lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = WHColor_16(colorStr: "CFCFD2")
        img.layer.cornerRadius = kFitWidth(10)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 1
        return lab
    }()
    
    private lazy var descLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 0
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .COLOR_CARD_BG_WHITE//UIColor.white.withAlphaComponent(0.72)
        layer.cornerRadius = kFitWidth(12)
        clipsToBounds = true
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descLabel)
        
        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(20))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(7))
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalTo(iconView)
        }
        
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView)
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(iconView.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalTo(kFitWidth(-16))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, desc: String, highlights: [String]) {
        titleLabel.text = title
        let attr = NSMutableAttributedString(string: desc)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        attr.addAttributes([
            .foregroundColor: descColor,
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: desc.count))
        
        for keyword in highlights where !keyword.isEmpty {
            var searchRange = desc.startIndex..<desc.endIndex
            while let range = desc.range(of: keyword, options: [], range: searchRange) {
                let nsRange = NSRange(range, in: desc)
                attr.addAttributes([
                    .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium)
                ], range: nsRange)
                searchRange = range.upperBound..<desc.endIndex
            }
        }
        
        descLabel.attributedText = attr
    }
}
