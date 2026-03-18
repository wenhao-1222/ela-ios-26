//
//  GuidanceGoalBarrierVM.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

class GuidanceGoalBarrierVM: UIView {

    struct Item {
        let title: String
        let value: String
    }

    var selectedBlock: (() -> ())?
    private(set) var selectedValues = Set<String>()

    private var dataArray: [Item] = []

    private var cardViews: [UIView] = []
    private var titleLabels: [UILabel] = []
    private var checkImageViews: [UIImageView] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        clipsToBounds = true
        initUI()
        refreshSelectionFromModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var hasSelection: Bool {
        return !selectedValues.isEmpty
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "是什么在阻碍你达成目标？"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
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
}

extension GuidanceGoalBarrierVM {
    func itemsForCurrentGoal(modelValue: String) -> [Item] {
        switch modelValue {
        case "4", "5", "7":
            return [
                Item(title: "休息日容易摆烂", value: "rest_day"),
                Item(title: "训练后没胃口", value: "post_workout_appetite"),
                Item(title: "一吃多就消化不好", value: "digestion"),
                Item(title: "太忙没时间加餐", value: "busy"),
                Item(title: "吃不够蛋白质", value: "protein"),
                Item(title: "备餐太麻烦", value: "meal_prep"),
                Item(title: "不知道吃什么", value: "unknown_food"),
                Item(title: "家庭因素干扰", value: "family")
            ]
        default:
            return [
                Item(title: "休息日容易摆烂", value: "rest_day"),
                Item(title: "练完肚子更饿了", value: "more_hungry"),
                Item(title: "不吃点东西睡不着", value: "cant_sleep"),
                Item(title: "压力一大就想暴饮暴食", value: "binge_eating"),
                Item(title: "方法太极端，总是反弹", value: "rebound"),
                Item(title: "备餐太麻烦", value: "meal_prep"),
                Item(title: "不知道吃什么", value: "unknown_food"),
                Item(title: "家庭因素干扰", value: "family")
            ]
        }
    }

    func updateContentForGoal(modelValue: String) {
        let oldSelectedValues = selectedValues
        dataArray = itemsForCurrentGoal(modelValue: modelValue)
        let validValues = Set(dataArray.map { $0.value })
        selectedValues = oldSelectedValues.intersection(validValues)
        syncModelValue()
        refreshListUI()
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(35))
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(40))
            make.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-45))
            make.top.equalToSuperview().offset(kFitWidth(40))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(88)))
        }

        dataArray = itemsForCurrentGoal(modelValue: QuestinonaireMsgModel.shared.goal)
        refreshListUI()
        refreshSelectionFromModel()
    }

    func refreshSelectionFromModel() {
        let selectedValues = Set(QuestinonaireMsgModel.shared.guidanceGoalBarrierType
            .split(separator: ",")
            .map { String($0) })
        let validValues = Set(dataArray.map { $0.value })
        self.selectedValues = selectedValues.intersection(validValues)
        syncModelValue()
        for idx in cardViews.indices {
            applyCardStyle(index: idx, isSelected: self.selectedValues.contains(dataArray[idx].value))
        }
    }

    func refreshListUI() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        titleLabels.removeAll()
        checkImageViews.removeAll()

        for (index, item) in dataArray.enumerated() {
            let cardView = UIView()
            cardView.backgroundColor = .COLOR_CARD_BG_WHITE
            cardView.layer.cornerRadius = kFitWidth(12)
            cardView.clipsToBounds = true
            cardView.tag = index

            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapAction(_:)))
            cardView.addGestureRecognizer(tap)

            let titleLab = UILabel()
            titleLab.text = item.title
            titleLab.textColor = .COLOR_TEXT_TITLE_0f1214
            titleLab.font = .systemFont(ofSize: 16, weight: .medium)

            let checkImageView = UIImageView()
            checkImageView.image = UIImage(named: "question_foods_normal_icon")

            cardView.addSubview(titleLab)
            cardView.addSubview(checkImageView)
            stackView.addArrangedSubview(cardView)

            cardView.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(60))
            }

            titleLab.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(20))
                make.centerY.equalToSuperview()
            }

            checkImageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(kFitWidth(-16))
                make.width.height.equalTo(kFitWidth(30))
            }

            cardViews.append(cardView)
            titleLabels.append(titleLab)
            checkImageViews.append(checkImageView)
            applyCardStyle(index: index, isSelected: selectedValues.contains(item.value))
        }
    }

    func toggleSelection(index: Int, notify: Bool) {
        guard index >= 0 && index < dataArray.count else {
            return
        }
        let itemValue = dataArray[index].value
        let isSelected = selectedValues.contains(itemValue)
        if isSelected {
            selectedValues.remove(itemValue)
        } else {
            selectedValues.insert(itemValue)
        }
        applyCardStyle(index: index, isSelected: !isSelected)
        syncModelValue()

        if notify {
            selectedBlock?()
        }
    }

    func syncModelValue() {
        let orderedValues = dataArray
            .map { $0.value }
            .filter { selectedValues.contains($0) }
        QuestinonaireMsgModel.shared.guidanceGoalBarrierType = orderedValues.joined(separator: ",")
    }

    func applyCardStyle(index: Int, isSelected: Bool) {
        guard index >= 0, index < cardViews.count else {
            return
        }
        cardViews[index].layer.borderWidth = isSelected ? kFitWidth(1.5) : 0
        cardViews[index].layer.borderColor = isSelected ? UIColor.THEME.cgColor : UIColor.clear.cgColor
        titleLabels[index].textColor = .COLOR_TEXT_TITLE_0f1214
        checkImageViews[index].setCheckState(isSelected,
                                             checkedImageName: "circle_today_select_icon",
                                             uncheckedImageName: "question_foods_normal_icon")
    }

    @objc func cardTapAction(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view else {
            return
        }
        toggleSelection(index: view.tag, notify: true)
    }
}
