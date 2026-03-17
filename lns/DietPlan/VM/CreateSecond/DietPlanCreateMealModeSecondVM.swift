//
//  DietPlanCreateMealModeSecondVM.swift
//  lns
//
//  Created by Codex on 2026/3/17.
//

class DietPlanCreateMealModeSecondVM: UIView {

    struct Item {
        let title: String
        let detail: String
        let modelValue: String
    }

    var selectedIndex = -1
    var selectedBlock: (() -> ())?

    private let fullDataArray: [Item] = [
        Item(title: "每日 3 餐", detail: "更省时间，每餐更有饱腹感，但两餐之间可能更容易饿；适合上班族和学生党", modelValue: "3"),
        Item(title: "每日 4 餐", detail: "利于血糖平稳，更容易稳住食欲；适合所有人", modelValue: "4"),
        Item(title: "每日 5 餐", detail: "方便把全天摄入分散开，减少单餐压力；适合所有人", modelValue: "5"),
        Item(title: "每日 6 餐", detail: "对小胃口和增肌期更友好，更容易吃够总量，但对时间安排要求更高；适合更追求目标达成率的人", modelValue: "6")
    ]

    private(set) var dataArray: [Item] = []
    private var cardViews: [UIView] = []
    private var titleLabels: [UILabel] = []
    private var detailLabels: [UILabel] = []

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
        lab.text = "确认进餐方式"
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

extension DietPlanCreateMealModeSecondVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        setConstraint()
        refreshOptions(caloriesText: QuestinonaireMsgModel.shared.caloriesNumber)
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

    func refreshOptions(caloriesText: String) {
        let preferredValue = selectedModelValue() ?? QuestinonaireMsgModel.shared.mealsPerDay
        dataArray = filteredItems(for: caloriesText)

        if !preferredValue.isEmpty,
           let index = dataArray.firstIndex(where: { $0.modelValue == preferredValue }) {
            selectedIndex = index
        } else {
            selectedIndex = -1
            if !preferredValue.isEmpty,
               !dataArray.contains(where: { $0.modelValue == preferredValue }) {
                QuestinonaireMsgModel.shared.mealsPerDay = ""
            }
        }

        refreshListUI()
    }

    func filteredItems(for caloriesText: String) -> [Item] {
        guard let calories = Double(caloriesText.trimmingCharacters(in: .whitespacesAndNewlines)),
              calories > 0 else {
            return fullDataArray
        }

        if calories < 1400 {
            return fullDataArray.filter { $0.modelValue == "3" || $0.modelValue == "4" }
        }
        if calories < 1700 {
            return fullDataArray.filter { $0.modelValue != "6" }
        }
        if calories > 3000 {
            return fullDataArray.filter { $0.modelValue != "3" }
        }
        return fullDataArray
    }

    func refreshListUI() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        titleLabels.removeAll()
        detailLabels.removeAll()

        for (index, item) in dataArray.enumerated() {
            let cardView = UIView()
            cardView.layer.cornerRadius = kFitWidth(47)
            cardView.clipsToBounds = true
            cardView.tag = index

            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapAction(_:)))
            cardView.addGestureRecognizer(tap)

            let titleLab = UILabel()
            titleLab.text = item.title
            titleLab.textAlignment = .center
            titleLab.textColor = .COLOR_TEXT_TITLE_0f1214
            titleLab.font = .systemFont(ofSize: 17, weight: .medium)

            let detailLab = UILabel()
            detailLab.text = item.detail
            detailLab.numberOfLines = 0
            detailLab.textAlignment = .center
            detailLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
            detailLab.font = .systemFont(ofSize: 12, weight: .regular)

            cardView.addSubview(titleLab)
            cardView.addSubview(detailLab)
            stackView.addArrangedSubview(cardView)

            cardView.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(92))
            }

            titleLab.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(20))
                make.right.equalTo(kFitWidth(-20))
                make.top.equalTo(kFitWidth(16))
            }

            detailLab.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(27))
                make.right.equalTo(kFitWidth(-27))
                make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
            }

            cardViews.append(cardView)
            titleLabels.append(titleLab)
            detailLabels.append(detailLab)
            applyCardStyle(index: index, isSelected: selectedIndex == index)
        }
    }

    func restoreSelection(modelValue: String) {
        guard let index = dataArray.firstIndex(where: { $0.modelValue == modelValue }) else {
            selectedIndex = -1
            refreshListUI()
            return
        }
        select(index: index, notify: false)
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
        QuestinonaireMsgModel.shared.mealsPerDay = dataArray[index].modelValue

        if oldIndex >= 0 {
            applyCardStyle(index: oldIndex, isSelected: false)
        }
        applyCardStyle(index: index, isSelected: true)

        if notify {
            selectedBlock?()
        }
    }

    func selectedModelValue() -> String? {
        guard selectedIndex >= 0, selectedIndex < dataArray.count else {
            return nil
        }
        return dataArray[selectedIndex].modelValue
    }

    func applyCardStyle(index: Int, isSelected: Bool) {
        guard index >= 0, index < cardViews.count else {
            return
        }
        cardViews[index].backgroundColor = isSelected ? .THEME : .COLOR_TEXT_TITLE_0f1214_05
        titleLabels[index].textColor = isSelected ? .white : .COLOR_TEXT_TITLE_0f1214
        detailLabels[index].textColor = isSelected ? UIColor.white.withAlphaComponent(0.88) : .COLOR_TEXT_TITLE_0f1214_50
    }

    @objc func cardTapAction(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view else {
            return
        }
        select(index: view.tag, notify: true)
    }
}
