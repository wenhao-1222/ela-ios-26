//
//  DietPlanCreateEatStyleSecondVM.swift
//  lns
//
//  Created by Codex on 2026/3/16.
//

class DietPlanCreateEatStyleSecondVM: UIView {

    struct Item {
        let title: String
        let subTitle: String
        let detail: String
    }

    var selectedIndex = -1
    var selectedBlock: (() -> ())?

    private var cardViews: [UIView] = []
    private var titleLabels: [UILabel] = []
    private var subTitleLabels: [UILabel] = []
    private var detailLabels: [UILabel] = []

    lazy var dataArray: [Item] = {
        return [
            Item(title: "均衡", subTitle: "碳蛋脂平衡", detail: "更贴近大多数人的日常饮食"),
            Item(title: "高蛋白", subTitle: "中碳水，高蛋白质，低脂肪", detail: "饱腹感更强，更利于肌肉生长"),
            Item(title: "生酮", subTitle: "几乎无碳水，中蛋白质，高脂肪", detail: "更适合在医生指导下使用，健康人群一般不建议"),
            Item(title: "低碳", subTitle: "低碳水，高蛋白质，中脂肪", detail: "血糖波动更小，适合喜欢少主食的人")
        ]
    }()

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

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "选择你的饮食风格"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var scrollView: UIScrollView = {
        let vi = UIScrollView()
        vi.showsVerticalScrollIndicator = false
        return vi
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
}

extension DietPlanCreateEatStyleSecondVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        setConstraint()
        refreshListUI()
    }

    func setConstraint() {
        let bottomSafe = WHUtils().getBottomSafeAreaHeight()
        let nextButtonTopOffset = bottomSafe + kFitWidth(58)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(72))
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(48))
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(nextButtonTopOffset + kFitWidth(12)))
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.bottom.equalToSuperview()
        }
    }

    func refreshListUI() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        titleLabels.removeAll()
        subTitleLabels.removeAll()
        detailLabels.removeAll()

        for (index, item) in dataArray.enumerated() {
            let cardView = UIView()
            cardView.layer.cornerRadius = kFitWidth(47)
            cardView.clipsToBounds = true
            cardView.tag = index

            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapAction(_:)))
            cardView.addGestureRecognizer(tap)

            let titleLab = UILabel()
            titleLab.textAlignment = .center
            titleLab.font = .systemFont(ofSize: 17, weight: .medium)
            titleLab.text = item.title

            let subTitleLab = UILabel()
            subTitleLab.textAlignment = .center
            subTitleLab.font = .systemFont(ofSize: 13, weight: .regular)
            subTitleLab.numberOfLines = 0
            subTitleLab.text = item.subTitle

            let detailLab = UILabel()
            detailLab.textAlignment = .center
            detailLab.font = .systemFont(ofSize: 12, weight: .regular)
            detailLab.numberOfLines = 0
            detailLab.text = item.detail

            cardView.addSubview(titleLab)
            cardView.addSubview(subTitleLab)
            cardView.addSubview(detailLab)
            stackView.addArrangedSubview(cardView)

            cardView.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(94))
            }

            titleLab.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(kFitWidth(16))
            }

            subTitleLab.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(20))
                make.right.equalTo(kFitWidth(-20))
                make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(7))
            }

            detailLab.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(20))
                make.right.equalTo(kFitWidth(-20))
                make.height.equalTo(kFitWidth(16))
                make.top.equalTo(subTitleLab.snp.bottom).offset(kFitWidth(6))
            }

            cardViews.append(cardView)
            titleLabels.append(titleLab)
            subTitleLabels.append(subTitleLab)
            detailLabels.append(detailLab)
            applyCardStyle(index: index, isSelected: selectedIndex == index)
        }
    }

    func restoreSelection(modelValue: String) {
        guard let value = Int(modelValue), value > 0, value <= dataArray.count else {
            return
        }
        select(index: value - 1, notify: false)
    }

    func select(index: Int, notify: Bool) {
        guard index >= 0 && index < dataArray.count else {
            return
        }
        if selectedIndex == index && notify {
            return
        }

        let oldIndex = selectedIndex
        selectedIndex = index
        QuestinonaireMsgModel.shared.dietType = "\(index + 1)"

        if oldIndex >= 0 {
            applyCardStyle(index: oldIndex, isSelected: false)
        }
        applyCardStyle(index: index, isSelected: true)

        if notify {
            selectedBlock?()
        }
    }

    func applyCardStyle(index: Int, isSelected: Bool) {
        guard index >= 0, index < cardViews.count else {
            return
        }
        cardViews[index].backgroundColor = isSelected ? .THEME : .COLOR_TEXT_TITLE_0f1214_05
        titleLabels[index].textColor = isSelected ? .white : .COLOR_TEXT_TITLE_0f1214
        subTitleLabels[index].textColor = isSelected ? .white : .COLOR_TEXT_TITLE_0f1214
        detailLabels[index].textColor = isSelected ? UIColor.white.withAlphaComponent(0.88) : .COLOR_TEXT_TITLE_0f1214_50
    }

    @objc func cardTapAction(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view else {
            return
        }
        select(index: view.tag, notify: true)
    }
}
