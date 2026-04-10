//
//  GuidanceCardioFrequencyVM.swift
//  lns
//
//  Created by Codex on 2026/3/17.
//

class GuidanceCardioFrequencyVM: UIView {

    struct Item {
        let title: String
        let value: String
    }

    var selectedBlock: (() -> ())?
    private(set) var selectedIndex = -1

    private let dataArray: [Item] = [
        Item(title: "几乎不会", value: "never"),
        Item(title: "每周 1 次", value: "commute"),
        Item(title: "每周 2-3 次", value: "2-3"),
        Item(title: "每周 4-5 次", value: "4-5"),
        Item(title: "每周 6+ 次", value: "6-7")
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
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 22, weight: .medium)
        lab.setLineHeight(textString: "你日常会做有氧吗？", lineHeight: lab.font.lineHeight * 1.2)
        return lab
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()
}

extension GuidanceCardioFrequencyVM {
    func selectNeverAsDefault() {
        applySelection(index: 0, notify: false)
    }

    func clearSelection() {
        applySelection(index: -1, notify: false)
    }

    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.guidanceCardioFrequencyType
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
            titleLabels[idx].textColor = isSelected ? .COLOR_TEXT_WHITE : .COLOR_TEXT_TITLE_0f1214
        }

        if index >= 0 && index < dataArray.count {
            QuestinonaireMsgModel.shared.guidanceCardioFrequencyType = dataArray[index].value
            QuestinonaireMsgModel.shared.events = "\(index + 1)"
            if notify {
                selectedBlock?()
            }
        } else {
            QuestinonaireMsgModel.shared.guidanceCardioFrequencyType = ""
            QuestinonaireMsgModel.shared.events = ""
        }
    }
}

extension GuidanceCardioFrequencyVM {
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
            lab.textColor = .COLOR_TEXT_TITLE_0f1214
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
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(59))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(106))
        }
    }
}
