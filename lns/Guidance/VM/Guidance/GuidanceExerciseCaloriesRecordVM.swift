//
//  GuidanceExerciseCaloriesRecordVM.swift
//  lns
//
//  Created by Codex on 2026/3/17.
//

class GuidanceExerciseCaloriesRecordVM: UIView {

    struct Item {
        let title: String
        let desc: String
        let value: String
    }
    
    var showTipsBlock:(()->())?
    var selectedBlock: (() -> ())?
    private(set) var selectedIndex = -1

    private let dataArray: [Item] = [
        Item(title: "是", desc: "会用手表自动记录，或手动记录", value: "yes"),
        Item(title: "否", desc: "希望你们帮我智能估算", value: "no")
    ]

    private var itemButtons: [UIButton] = []
    private var titleLabels: [UILabel] = []
    private var descLabels: [UILabel] = []

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

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.text = "你平时是否会\n记录运动消耗热量？"
//        lab.setLineHeightMultiple(textString: lab.text, lineHeightMultiple: 1.2)
//        lab.setLineHeight(textString: "你平时是否会\n记录运动消耗热量？", lineHeight: lab.font.lineHeight * 1.1)
        return lab
    }()
    lazy var tipsButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("运动消耗的陷阱", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(showTipsAction), for: .touchUpInside)
        
        return btn
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()
}

extension GuidanceExerciseCaloriesRecordVM {
    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.guidanceExerciseCaloriesRecordType
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
            descLabels[idx].textColor = isSelected ? .COLOR_TEXT_WHITE.withAlphaComponent(0.88) : .COLOR_TEXT_TITLE_0f1214_50
        }

        if index >= 0 && index < dataArray.count {
            QuestinonaireMsgModel.shared.guidanceExerciseCaloriesRecordType = dataArray[index].value
            if notify {
                selectedBlock?()
            }
        } else {
            QuestinonaireMsgModel.shared.guidanceExerciseCaloriesRecordType = ""
        }
    }
    @objc func showTipsAction(){
        if self.showTipsBlock != nil{
            self.showTipsBlock!()
        }
    }
}

extension GuidanceExerciseCaloriesRecordVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsButton)
        addSubview(stackView)

        for (index, item) in dataArray.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
            button.layer.cornerRadius = kFitWidth(40)
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(itemTapAction(_:)), for: .touchUpInside)

            let titleLab = UILabel()
            titleLab.textAlignment = .center
            titleLab.textColor = .COLOR_TEXT_TITLE_0f1214
            titleLab.font = .systemFont(ofSize: 16, weight: .medium)
            titleLab.text = item.title

            let descLab = UILabel()
            descLab.textAlignment = .center
            descLab.textColor = .COLOR_TEXT_TITLE_0f1214_50
            descLab.font = .systemFont(ofSize: 12, weight: .regular)
            descLab.text = item.desc

            button.addSubview(titleLab)
            button.addSubview(descLab)

            titleLab.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(kFitWidth(16))
            }

            descLab.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
            }

            button.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(80))
            }

            stackView.addArrangedSubview(button)
            itemButtons.append(button)
            titleLabels.append(titleLab)
            descLabels.append(descLab)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(59))
        }
        tipsButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(21))
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(tipsButton.snp.bottom).offset(kFitWidth(142))
        }
    }
}
