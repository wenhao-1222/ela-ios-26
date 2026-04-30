//
//  DietPlanCreateBarrierVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

class DietPlanCreateBarrierVM: UIView {

    var selectedIndex = -1
    var selectedIndexes: Set<Int> = []
    var selectedBlock: (() -> ())?

    lazy var dataArray: [String] = {
        return [
            "容易嘴馋",
            "做饭太麻烦",
            "健身餐不好吃",
            "无法平衡家庭餐和健身餐",
            "不知道吃什么",
            "不确定"
        ]
    }()

    private var itemViews: [DietPlanCreateItemVM] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        topGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        bottomGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(1).cgColor
        ]
    }
    
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.text = "你在以往控制饮食时\n最大的阻碍是？"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.showsVerticalScrollIndicator = false
        return scro
    }()

    lazy var contentView: UIView = {
        let vi = UIView()
        return vi
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()

    lazy var topGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
    }()

    lazy var bottomGradientView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = false
        return vi
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
}

extension DietPlanCreateBarrierVM {
    private var uncertainIndex: Int? {
        dataArray.firstIndex(of: "不确定")
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)

        setConstraint()
        refreshListUI()

//        updateTitleLabel()
//        titleLabel.setLineHeight(
//            textString: "你在以往控制饮食时\n最大的阻碍是？",
//            lineHeight: titleLabel.font.lineHeight * 0.8
//        )
    }
    private func updateTitleLabel() {
        let text = "你在以往控制饮食时\n最大的阻碍是？"
        let targetLineHeight = titleLabel.font.lineHeight// * 1.2
        let baselineOffset = (targetLineHeight - titleLabel.font.lineHeight) / 2

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = titleLabel.textAlignment
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.minimumLineHeight = targetLineHeight
        paragraphStyle.maximumLineHeight = targetLineHeight

        titleLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: titleLabel.font as Any,
                .foregroundColor: titleLabel.textColor as Any,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: baselineOffset
            ]
        )
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(41))
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(35))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(8)))
        }

        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView.snp.top)
            make.height.equalTo(kFitWidth(35))
        }

        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom)
            make.height.equalTo(kFitWidth(35))
        }

        contentView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.top.equalTo(kFitWidth(28))
            make.bottom.equalTo(kFitWidth(-28))
            make.width.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(2))
            make.bottom.equalToSuperview().offset(kFitWidth(-2))
        }
    }

    func refreshListUI() {
        normalizeSelectionState()

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()

        for (index, title) in dataArray.enumerated() {
            let itemVm = DietPlanCreateItemVM(frame: .zero)
            itemVm.updateUI(title: title, isSelected: selectedIndexes.contains(index))
            itemVm.tapBlock = { [weak self] in
                self?.selectItem(index: index)
            }
            stackView.addArrangedSubview(itemVm)
            itemVm.snp.makeConstraints { make in
                make.height.equalTo(itemVm.selfHeight)
            }
            itemViews.append(itemVm)
        }
    }

    func selectItem(index: Int) {
        guard index >= 0 && index < dataArray.count else {
            return
        }

        let wasSelected = selectedIndexes.contains(index)
        if let uncertainIndex, index == uncertainIndex {
            selectedIndexes = wasSelected ? [] : [uncertainIndex]
        } else {
            selectedIndexes.remove(uncertainIndex ?? -1)
            if wasSelected {
                selectedIndexes.remove(index)
            } else {
                selectedIndexes.insert(index)
            }
        }

        normalizeSelectionState()
        refreshSelectionUI()
        selectedBlock?()
    }

    private func normalizeSelectionState() {
        guard let uncertainIndex else {
            selectedIndex = selectedIndexes.sorted().first ?? -1
            syncSelectedBarrierText()
            return
        }

        if selectedIndexes.contains(uncertainIndex) && selectedIndexes.count > 1 {
            selectedIndexes = [uncertainIndex]
        }

        selectedIndex = selectedIndexes.sorted().first ?? -1
        syncSelectedBarrierText()
    }

    private func refreshSelectionUI() {
        for (index, itemView) in itemViews.enumerated() {
            itemView.updateUI(title: dataArray[index], isSelected: selectedIndexes.contains(index))
        }
    }

    private func syncSelectedBarrierText() {
        let titles = selectedIndexes.sorted().map { dataArray[$0] }
        QuestinonaireMsgModel.shared.foodBarrier = titles.joined(separator: ",")
    }

    // 后台 dietBarriers 枚举映射：
    // 1不确定 2容易嘴馋 3做饭太麻烦 4健身餐不好吃 5无法平衡家庭餐和健身餐 6不知道吃什么
    func buildDietBarriers() -> [Int] {
        let selectedTitles = QuestinonaireMsgModel.shared.foodBarrier
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let mapping: [String: Int] = [
            "不确定": 1,
            "容易嘴馋": 2,
            "做饭太麻烦": 3,
            "健身餐不好吃": 4,
            "无法平衡家庭餐和健身餐": 5,
            "不知道吃什么": 6
        ]
        return Array(Set(selectedTitles.compactMap { mapping[$0] })).sorted()
    }
}
