//
//  DietPlanCreateSpecialAdjustmentVM.swift
//  lns
//
//  Created by Codex on 2026/3/16.
//

class DietPlanCreateSpecialAdjustmentVM: UIView {

    struct Item {
        let title: String
        let modelValue: String
    }

    var selectedIndexes = Set<Int>()
    var selectedIndex: Int {
        return selectedIndexes.sorted().first ?? -1
    }
    var hasSelection: Bool {
        return !selectedIndexes.isEmpty
    }
    var selectedBlock: (() -> ())?

    private var cardViews: [UIView] = []
    private var titleLabels: [UILabel] = []
//    private var iconViews: [UIView] = []
    private var checkImageViews: [UIImageView] = []

    lazy var dataArray: [Item] = {
        return [
            Item(title: "高尿酸", modelValue: "1"),
            Item(title: "高血脂", modelValue: "2"),
            Item(title: "无", modelValue: "3")
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
        lab.text = "针对性饮食调整"
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

    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "选择以上选项可能会修改你的现有摄入目标"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .medium)
        return lab
    }()
}

extension DietPlanCreateSpecialAdjustmentVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(stackView)
        addSubview(tipsLabel)

        setConstraint()
        refreshListUI()
    }

    func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(72))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-45))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(80))
        }

        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(88)))
        }
    }

    func refreshListUI() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        titleLabels.removeAll()
//        iconViews.removeAll()
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

//            let iconWrapView = UIView()
//            iconWrapView.layer.cornerRadius = kFitWidth(15)
//            iconWrapView.layer.borderWidth = kFitWidth(1.5)
//            iconWrapView.clipsToBounds = true

            let checkImageView = UIImageView()
            checkImageView.image = UIImage(named: "question_foods_normal_icon")
            
//            checkImageView.setCheckState(isSelected,
//                                  checkedImageName: "circle_today_select_icon",
//                                  uncheckedImageName: "question_foods_normal_icon")

            cardView.addSubview(titleLab)
//            cardView.addSubview(iconWrapView)
            cardView.addSubview(checkImageView)
            stackView.addArrangedSubview(cardView)

            cardView.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(60))
            }

            titleLab.snp.makeConstraints { make in
                make.left.equalTo(kFitWidth(20))
                make.centerY.equalToSuperview()
            }

//            iconWrapView.snp.makeConstraints { make in
//                make.right.equalTo(kFitWidth(-20))
//                make.centerY.equalToSuperview()
//                make.width.height.equalTo(kFitWidth(30))
//            }

            checkImageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(kFitWidth(-16))
                make.width.height.equalTo(kFitWidth(30))
            }

            cardViews.append(cardView)
            titleLabels.append(titleLab)
//            iconViews.append(iconWrapView)
            checkImageViews.append(checkImageView)
            applyCardStyle(index: index, isSelected: selectedIndexes.contains(index))
        }
    }

    func restoreSelection(modelValue: String) {
        let values = splitModelValues(modelValue)
        if values.isEmpty {
            return
        }
        if values.contains("3"), let noneIndex = dataArray.firstIndex(where: { $0.modelValue == "3" }) {
            applySelection(Set([noneIndex]), notify: false)
            return
        }
        let restoredIndexes = Set(dataArray.enumerated().compactMap { index, item in
            values.contains(item.modelValue) ? index : nil
        })
        guard !restoredIndexes.isEmpty else {
            return
        }
        applySelection(restoredIndexes, notify: false)
    }

    func toggleSelection(index: Int, notify: Bool) {
        guard index >= 0 && index < dataArray.count else {
            return
        }

        var newSelection = selectedIndexes
        let tappedItem = dataArray[index]
        let noneIndex = dataArray.firstIndex(where: { $0.modelValue == "3" })

        if tappedItem.modelValue == "3" {
            if newSelection == Set([index]) && notify {
                return
            }
            newSelection = Set([index])
        } else {
            if newSelection.contains(index) {
                if newSelection.count == 1 && notify {
                    return
                }
                newSelection.remove(index)
            } else {
                if let noneIndex {
                    newSelection.remove(noneIndex)
                }
                newSelection.insert(index)
            }
        }
        applySelection(newSelection, notify: notify)
    }

    func applySelection(_ newSelection: Set<Int>, notify: Bool) {
        if newSelection == selectedIndexes {
            return
        }
        selectedIndexes = newSelection
        QuestinonaireMsgModel.shared.specialAdjustmentType = selectedModelValue()

        for index in dataArray.indices {
            applyCardStyle(index: index, isSelected: selectedIndexes.contains(index))
        }

        if notify {
            selectedBlock?()
        }
    }

    func selectedModelValue() -> String {
        return dataArray.enumerated()
            .filter { selectedIndexes.contains($0.offset) }
            .map { $0.element.modelValue }
            .joined(separator: ",")
    }

    func splitModelValues(_ text: String) -> [String] {
        return text
            .split(whereSeparator: { ",，".contains($0) })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func applyCardStyle(index: Int, isSelected: Bool) {
        guard index >= 0, index < cardViews.count else {
            return
        }
        cardViews[index].layer.borderWidth = isSelected ? kFitWidth(1.5) : 0
        cardViews[index].layer.borderColor = isSelected ? UIColor.THEME.cgColor : UIColor.clear.cgColor
        titleLabels[index].textColor = .COLOR_TEXT_TITLE_0f1214
//        iconViews[index].backgroundColor = isSelected ? .THEME : .white
//        iconViews[index].layer.borderColor = isSelected ? UIColor.THEME.cgColor : UIColor.COLOR_TEXT_TITLE_0f1214_20.cgColor
//        checkImageViews[index].isHidden = !isSelected
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
