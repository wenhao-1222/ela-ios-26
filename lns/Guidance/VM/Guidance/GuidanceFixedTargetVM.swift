//
//  GuidanceFixedTargetVM.swift
//  lns
//
//  Created by Codex on 2026/3/17.
//

import UIKit
import SnapKit

class GuidanceFixedTargetVM: UIView {

    struct Item {
        let title: String
        let value: String
    }

    var selectedBlock: (() -> ())?
    private(set) var selectedIndex = -1

    private let dataArray: [Item] = [
        Item(title: "还没有，需要建议", value: "uncertain"),
        Item(title: "已有明确目标", value: "fixed")
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

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 22, weight: .medium)
        lab.text = "你已经有\n明确的营养目标了吗？"
//        lab.setLineHeightMultiple(textString: lab.text, lineHeightMultiple: 1.18)
//        lab.setLineHeight(textString: "你已经有\n明确的营养目标了吗？", lineHeight: lab.font.lineHeight * 1.2)
//        lab.setLineHeight(textString: "你已经有固定的\n饮食目标吗？", lineHeight: lab.font.lineHeight * 1.2)
        return lab
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()

    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.text = "我们会根据你的实际情况\n为你定制更高效的使用方式"
        lab.font = .systemFont(ofSize: 14, weight: .regular)
//        lab.setLineHeight(textString: "我们会根据你的实际情况\n为你定制更高效的使用方式", lineHeight: lab.font.lineHeight * 1.35)
        lab.setLineHeightMultiple(textString: lab.text, lineHeightMultiple: 1.2)
        return lab
    }()
}

extension GuidanceFixedTargetVM {
    func refreshSelectionFromModel() {
        let selectedValue = QuestinonaireMsgModel.shared.guidanceFixedTargetType
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
            button.backgroundColor = isSelected ? .THEME : .COLOR_BG_BLACK_04
            titleLabels[idx].textColor = isSelected ? .COLOR_TEXT_WHITE : .COLOR_TEXT_TITLE_0f1214_50
        }

        if index >= 0 && index < dataArray.count {
            QuestinonaireMsgModel.shared.guidanceFixedTargetType = dataArray[index].value
            if notify {
                selectedBlock?()
            }
        } else {
            QuestinonaireMsgModel.shared.guidanceFixedTargetType = ""
        }
    }
}

extension GuidanceFixedTargetVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(stackView)
        addSubview(tipsLabel)
        
        for (index, item) in dataArray.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
            button.layer.cornerRadius = kFitWidth(40)
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
                make.height.equalTo(kFitWidth(80))
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
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(150))
        }

        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.top.equalTo(stackView.snp.bottom).offset(kFitWidth(140))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(136))
        }
    }
}
