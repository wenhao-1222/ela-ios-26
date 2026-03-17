//
//  GuidanceMealsAdjustVM.swift
//  lns
//
//  Created by Codex on 2026/3/17.
//

class GuidanceMealsAdjustVM: UIView {

    struct Item {
        let title: String
        let value: String
        let bulking: String
        let cutting: String
        let advantages: [String]
        let disadvantages: [String]
        let targetGroup: String
    }

    var selectedBlock: (() -> ())?
    private(set) var selectedIndex = -1
    private var itemViews: [GuidanceMealsAdjustItemView] = []

    private let dataArray: [Item] = [
        Item(
            title: "A. 每日 1-2 餐",
            value: "1-2",
            bulking: "不适合",
            cutting: "一般",
            advantages: ["更省时间", "每餐饱腹感更强"],
            disadvantages: ["血糖波动较大", "两餐之间更容易饿，可能诱发暴食", "可能影响训练质量", "难以摄入充足营养"],
            targetGroup: "时间紧张、胃功能正常的上班族和学生党"
        ),
        Item(
            title: "B. 每日 3 餐",
            value: "3",
            bulking: "一般",
            cutting: "适合",
            advantages: ["相对省时间", "能满足大部分人的健身需求"],
            disadvantages: ["两餐之间可能更容易饿", "增肌效果上限相对有限"],
            targetGroup: "除对训练结果有较高要求以外的大多数人"
        ),
        Item(
            title: "C. 每日 4 餐",
            value: "4",
            bulking: "适合",
            cutting: "适合",
            advantages: ["能较好平衡生活与训练效果", "增肌期更有利于摄入足够营养", "减脂期更容易维持肌肉量"],
            disadvantages: ["相对更耗时间"],
            targetGroup: "对训练结果有较高要求的人"
        ),
        Item(
            title: "D. 每日 5 餐",
            value: "5",
            bulking: "非常适合",
            cutting: "非常适合",
            advantages: ["增肌期更容易吃够总量与营养", "减脂期更有利于维持肌肉量", "不容易暴饮暴食", "对肠胃更友好"],
            disadvantages: ["更耗时间", "没有备餐时更难执行", "需要一定自律能力"],
            targetGroup: "对训练结果有较高要求的人；有胃炎、功能性消化不良史的人"
        ),
        Item(
            title: "E. 每日 6 餐",
            value: "6+",
            bulking: "最适合",
            cutting: "最适合",
            advantages: ["更容易获得最佳增肌效果", "能最大化减脂期的肌肉保留", "不容易暴饮暴食", "对肠胃更友好"],
            disadvantages: ["非常耗时间", "没有备餐时几乎无法执行", "需要极强的自律能力", "对大部分人来说很难长期坚持"],
            targetGroup: "对训练结果有极高要求的人；运动员、有胃炎、功能性消化不良史的人"
        )
    ]

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true

        initUI()
        refreshSelectionFromModel()
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

    lazy var titleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.setLineHeight(textString: "不过如果你想做出调整", lineHeight: lab.font.lineHeight * 1.2)
        return lab
    }()

    lazy var subTitleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.setLineHeight(textString: "我们也会根据你的习惯，适配你的使用体验", lineHeight: lab.font.lineHeight * 1.35)
        return lab
    }()

    lazy var tipLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "你可以随时在设置里更改"
        return lab
    }()

    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView()
        vi.showsVerticalScrollIndicator = false
        vi.contentInsetAdjustmentBehavior = .never
        vi.delegate = self
        return vi
    }()

    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()

    lazy var stackView: UIStackView = {
        let vi = UIStackView()
        vi.axis = .vertical
        vi.spacing = kFitWidth(12)
        vi.alignment = .fill
        vi.distribution = .fill
        return vi
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

extension GuidanceMealsAdjustVM {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateGradientVisibility()
    }

    private func updateGradientVisibility() {
        let visibleHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let maxOffsetY = max(contentHeight - visibleHeight, 0)

        topGradientView.alpha = offsetY > 4 ? 1 : 0
        bottomGradientView.alpha = offsetY < maxOffsetY - 4 ? 1 : 0
    }

    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.guidanceMealsAdjustType
        if let index = dataArray.firstIndex(where: { $0.value == selectedValue }) {
            applySelection(index: index, notify: false)
        } else {
            applySelection(index: -1, notify: false)
        }
    }

    private func applySelection(index: Int, notify: Bool) {
        selectedIndex = index

        for (idx, itemView) in itemViews.enumerated() {
            itemView.updateSelection(isSelected: idx == index)
        }

        if index >= 0 && index < dataArray.count {
            QuestinonaireMsgModel.shared.guidanceMealsAdjustType = dataArray[index].value
            if notify {
                selectedBlock?()
            }
        } else {
            QuestinonaireMsgModel.shared.guidanceMealsAdjustType = ""
        }
    }

    @objc func itemTapAction(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        applySelection(index: view.tag, notify: true)
    }
}

extension GuidanceMealsAdjustVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(tipLabel)
        addSubview(scrollView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        for (index, item) in dataArray.enumerated() {
            let itemView = GuidanceMealsAdjustItemView()
            itemView.tag = index
            itemView.update(item: item)
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemTapAction(_:)))
            itemView.addGestureRecognizer(tap)
            stackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(35))
        }

        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(22))
        }

        tipLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subTitleLabel.snp.bottom).offset(kFitWidth(16))
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tipLabel.snp.bottom).offset(kFitWidth(26))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(68)))
        }

        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView.snp.top)
            make.height.equalTo(kFitWidth(36))
        }

        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom)
            make.height.equalTo(kFitWidth(72))
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.bottom.equalToSuperview()
        }

        updateGradientVisibility()
    }
}

extension GuidanceMealsAdjustVM: UIScrollViewDelegate {}

private final class GuidanceMealsAdjustItemView: UIView {
    private var normalBorderColor = UIColor.clear.cgColor
    private var selectedBorderColor = UIColor.THEME.cgColor

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        layer.cornerRadius = kFitWidth(18)
        layer.borderWidth = 1.5
        layer.borderColor = normalBorderColor
        clipsToBounds = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 20, weight: .semibold)
        return lab
    }()

    private lazy var fitLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .right
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()

    private lazy var advantageLabel: LineHeightLabel = makeBodyLabel()
    private lazy var disadvantageLabel: LineHeightLabel = makeBodyLabel()
    private lazy var groupLabel: LineHeightLabel = makeBodyLabel()

    private func makeBodyLabel() -> LineHeightLabel {
        let lab = LineHeightLabel()
        lab.numberOfLines = 0
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }

    private func initUI() {
        addSubview(titleLabel)
        addSubview(fitLabel)
        addSubview(advantageLabel)
        addSubview(disadvantageLabel)
        addSubview(groupLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(18))
        }

        fitLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalTo(titleLabel)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(kFitWidth(8))
        }

        advantageLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }

        disadvantageLabel.snp.makeConstraints { make in
            make.left.right.equalTo(advantageLabel)
            make.top.equalTo(advantageLabel.snp.bottom).offset(kFitWidth(18))
        }

        groupLabel.snp.makeConstraints { make in
            make.left.right.equalTo(advantageLabel)
            make.top.equalTo(disadvantageLabel.snp.bottom).offset(kFitWidth(18))
            make.bottom.equalTo(kFitWidth(-18))
        }
    }

    func update(item: GuidanceMealsAdjustVM.Item) {
        titleLabel.text = item.title
        fitLabel.text = "增肌：\(item.bulking) | 减脂：\(item.cutting)"
        advantageLabel.setLineHeight(
            textString: formattedSection(title: "优点：", items: item.advantages),
            lineHeight: advantageLabel.font.lineHeight * 1.5
        )
        disadvantageLabel.setLineHeight(
            textString: formattedSection(title: "缺点：", items: item.disadvantages),
            lineHeight: disadvantageLabel.font.lineHeight * 1.5
        )
        groupLabel.setLineHeight(
            textString: "群体：\(item.targetGroup)",
            lineHeight: groupLabel.font.lineHeight * 1.5
        )
    }

    func updateSelection(isSelected: Bool) {
        backgroundColor = isSelected ? .white : .COLOR_TEXT_TITLE_0f1214_05
        layer.borderColor = isSelected ? selectedBorderColor : normalBorderColor
        titleLabel.textColor = isSelected ? .THEME : .COLOR_TEXT_TITLE_0f1214
    }

    private func formattedSection(title: String, items: [String]) -> String {
        let lines = items.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
        return "\(title) \(lines)"
    }
}
