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
    private(set) var selectedIndex = -1

    private let dataArray: [Item] = [
        Item(title: "休息日容易摆烂", value: "rest_day"),
        Item(title: "训练后没胃口", value: "post_workout_appetite"),
        Item(title: "一吃多就消化不好", value: "digestion"),
        Item(title: "太忙没时间加餐", value: "busy"),
        Item(title: "吃不够蛋白质", value: "protein"),
        Item(title: "家庭因素干扰", value: "family")
    ]

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
        return selectedIndex >= 0
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "是什么在阻碍你达成目标？"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(16)
        return st
    }()
}

extension GuidanceGoalBarrierVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(stackView)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(35))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-45))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(80))
        }

        refreshListUI()
    }

    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.guidanceGoalBarrierType
        if let index = dataArray.firstIndex(where: { $0.value == selectedValue }) {
            select(index: index, notify: false)
        } else {
            selectedIndex = -1
            for idx in cardViews.indices {
                applyCardStyle(index: idx, isSelected: false)
            }
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
            applyCardStyle(index: index, isSelected: selectedIndex == index)
        }
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
        QuestinonaireMsgModel.shared.guidanceGoalBarrierType = dataArray[index].value

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
        select(index: view.tag, notify: true)
    }
}
