//
//  GuidanceMealsPerDayVM.swift
//  lns
//
//  Created by Codex on 2026/3/17.
//

class GuidanceMealsPerDayVM: UIView {

    struct Item {
        let title: String
        let value: String
    }

    var selectedBlock: (() -> ())?
    private(set) var selectedIndex = -1

    private let dataArray: [Item] = [
        Item(title: "1-2 餐", value: "2"),
        Item(title: "3 餐", value: "3"),
        Item(title: "4 餐", value: "4"),
        Item(title: "5 餐", value: "5"),
        Item(title: "6+ 餐", value: "6+")
    ]

    private var itemButtons: [UIButton] = []
    private var titleLabels: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true

        initUI()
        refreshSelectionFromModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        lab.setLineHeight(textString: "你习惯每天吃几餐？", lineHeight: lab.font.lineHeight * 1.2)
        return lab
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()
}

extension GuidanceMealsPerDayVM {
    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.guidanceMealsPerDayType
        if let index = dataArray.firstIndex(where: { $0.value == selectedValue }) {
            applySelection(index: index, notify: false)
        } else {
            applySelection(index: -1, notify: false)
        }
    }

    @objc func itemTapAction(_ sender: UIButton) {
        applySelection(index: sender.tag, notify: true)
    }

    private func applySelection(index: Int, notify: Bool) {
        selectedIndex = index

        for (idx, button) in itemButtons.enumerated() {
            let isSelected = idx == index
            button.backgroundColor = isSelected ? .THEME : .COLOR_TEXT_TITLE_0f1214_05
            titleLabels[idx].textColor = isSelected ? .COLOR_TEXT_WHITE : .COLOR_TEXT_TITLE_0f1214_50
        }

        if index >= 0 && index < dataArray.count {
            QuestinonaireMsgModel.shared.guidanceMealsPerDayType = dataArray[index].value
            if notify {
                selectedBlock?()
            }
        } else {
            QuestinonaireMsgModel.shared.guidanceMealsPerDayType = ""
        }
    }
}

extension GuidanceMealsPerDayVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(stackView)

        for (index, item) in dataArray.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
            button.layer.cornerRadius = kFitWidth(30)
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(itemTapAction(_:)), for: .touchUpInside)

            let lab = UILabel()
            lab.text = item.title
            lab.textAlignment = .center
            lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
            lab.font = .systemFont(ofSize: 20, weight: .medium)

            button.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            button.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(60))
            }

            stackView.addArrangedSubview(button)
            itemButtons.append(button)
            titleLabels.append(lab)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(35))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(64))
        }
    }
}
