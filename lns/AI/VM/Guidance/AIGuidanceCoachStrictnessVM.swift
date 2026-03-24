//
//  AIGuidanceCoachStrictnessVM.swift
//  lns
//
//  Created by Codex on 2026/3/24.
//

import UIKit
import SnapKit

class AIGuidanceCoachStrictnessVM: UIView {

    struct Item {
        let title: String
        let detail: String
        let value: String
    }

    enum GoalKind {
        case gain
        case fatLoss
    }

    var selectedBlock: (() -> ())?
    private(set) var selectedIndex = -1
    private var currentGoalKind: GoalKind = .gain
    private var dataArray: [Item] = []

    private var itemViews: [AIGuidanceCoachStrictnessItemView] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true

        initUI()
        refreshContentForCurrentGoal()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }

    var hasSelection: Bool {
        return selectedIndex >= 0
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var subtitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你可以随时调整标准"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(16)
        return st
    }()
    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()

    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()
    lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
    lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 1]
        return layer
    }()
}

extension AIGuidanceCoachStrictnessVM {
    func refreshContentForCurrentGoal() {
        currentGoalKind = goalKindFromModel()
        titleLabel.text = "你希望 AI 教练的\n执行标准有多严格？"
        dataArray = items(for: currentGoalKind)
        refreshSelectionFromModel()
        refreshListUI()
    }

    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType
        if let index = dataArray.firstIndex(where: { $0.value == selectedValue }) {
            selectedIndex = index
        } else {
            selectedIndex = -1
            QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType = ""
        }
    }

    func goalKindFromModel() -> GoalKind {
        switch QuestinonaireMsgModel.shared.goal {
        case "4", "5", "7":
            return .gain
        default:
            return .fatLoss
        }
    }

    func items(for goalKind: GoalKind) -> [Item] {
        switch goalKind {
        case .gain:
            return [
                Item(title: "非常放松",
                     detail: "更看重习惯养成，不追求效率。出现偏差时，我会按你的执行力把方案变得更易坚持，尽量把偏离缩小。",
                     value: "very_relaxed"),
                Item(title: "放松",
                     detail: "更看重习惯养成，不追求效率。出现偏差时，我会按你的执行力把方案变得更易坚持，尽量把偏离缩小。",
                     value: "relaxed"),
                Item(title: "正常",
                     detail: "增肌效率要求中等，允许少量波动。每周只给你 1 个最关键的执行重点，确保稳步进步。",
                     value: "normal"),
                Item(title: "健身爱好者",
                     detail: "增肌效率要求更严格，尽可能避免脂肪堆积。波动会被及时纠正，每周 1 个执行重点，附带少量可选优化点，尽量兼顾效率。",
                     value: "enthusiast"),
                Item(title: "职业运动员",
                     detail: "竞技级标准，在避免脂肪堆积的前提下，最大化增肌效率。我会进行大量复盘与微调，主动挖掘所有可优化点，并按优先级给出执行方案。",
                     value: "athlete")
            ]
        case .fatLoss:
            return [
                Item(title: "非常放松",
                     detail: "更看重习惯养成，不追求减脂效率。出现偏差时，我会按你的执行力把方案变得更易坚持，尽量把偏离缩小。",
                     value: "very_relaxed"),
                Item(title: "放松",
                     detail: "减脂效率要求偏低到中等。进度跑偏时会给出解决方案，也可能根据你的习惯与生活节奏适度调整目标。",
                     value: "relaxed"),
                Item(title: "正常",
                     detail: "减脂效率要求中等，允许少量波动。每周只给你 1 个最关键的执行重点，确保稳步进步。",
                     value: "normal"),
                Item(title: "健身爱好者",
                     detail: "减脂效率要求更严格，追求稳定进步。波动会被及时纠正，每周 1 个执行重点，附带少量可选优化点，尽量兼顾效率。",
                     value: "enthusiast"),
                Item(title: "职业运动员",
                     detail: "竞技级标准，最大化减脂效率和肌肉维持。我会进行大量复盘与微调，主动挖掘所有可优化点，并按优先级给出执行方案。",
                     value: "athlete")
            ]
        }
    }

    func refreshListUI() {
        if itemViews.count != dataArray.count {
            rebuildViews()
        }

        for (index, item) in dataArray.enumerated() {
            itemViews[index].update(item: item, isSelected: index == selectedIndex)
        }
    }

    func rebuildViews() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()

        for (index, item) in dataArray.enumerated() {
            let itemView = AIGuidanceCoachStrictnessItemView()
            itemView.tag = index
            itemView.update(item: item, isSelected: false)
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemTapAction(_:)))
            itemView.addGestureRecognizer(tap)

            stackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
    }

    @objc func itemTapAction(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view else {
            return
        }
        applySelection(index: view.tag, notify: true)
    }

    func applySelection(index: Int, notify: Bool) {
        guard index >= 0 && index < dataArray.count else {
            return
        }

        selectedIndex = index
        QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType = dataArray[index].value

        for idx in itemViews.indices {
            itemViews[idx].setSelectedState(idx == index)
        }

        if notify {
            selectedBlock?()
        }
    }
}

extension AIGuidanceCoachStrictnessVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(35))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(16))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(74)))
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalToSuperview().offset(kFitWidth(20))
            make.bottom.equalToSuperview().offset(-kFitWidth(20))
        }
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }

        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView)
            make.height.equalTo(kFitWidth(35))
//            make.top.equalTo(scrollView.snp.bottom).offset(kFitWidth(-56))
        }
    }
}

class AIGuidanceCoachStrictnessItemView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        return lab
    }()

    lazy var detailLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
}

extension AIGuidanceCoachStrictnessItemView {
    func update(item: AIGuidanceCoachStrictnessVM.Item, isSelected: Bool) {
        titleLabel.text = item.title
        detailLabel.attributedText = detailAttributedText(item.detail)
        setSelectedState(isSelected)
    }

    func detailAttributedText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5

        return NSAttributedString(string: text, attributes: [
            .font: detailLabel.font as Any,
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
            .paragraphStyle: paragraphStyle
        ])
    }

    func setSelectedState(_ isSelected: Bool) {
        layer.borderWidth = isSelected ? kFitWidth(1.5) : 0
        layer.borderColor = isSelected ? UIColor.THEME.cgColor : UIColor.clear.cgColor
        backgroundColor = isSelected ? UIColor.THEME.withAlphaComponent(0.06) : .COLOR_BG_BLACK_04
    }

    func initUI() {
        backgroundColor = .COLOR_BG_BLACK_04
        layer.cornerRadius = kFitWidth(16)
        clipsToBounds = true

        addSubview(titleLabel)
        addSubview(detailLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
        }

        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalToSuperview().offset(-kFitWidth(16))
        }
    }
}
