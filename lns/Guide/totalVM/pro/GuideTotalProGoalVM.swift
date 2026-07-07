//
//  GuideTotalProGoalVM.swift
//  lns
//
//  Created by Codex on 2026/7/7.
//

import UIKit
import SnapKit

class GuideTotalProGoalVM: UIView {

    struct Item {
        let title: String
        let value: String
    }

    var selectedBlock: (() -> Void)?
    var nextBlock: (() -> Void)?
    private(set) var selectedIndex = -1

    private let dataArray: [Item] = [
        Item(title: "增肌", value: "5"),
        Item(title: "减脂", value: "3")
    ]

    private var itemButtons: [FeedBackButton] = []
    private var titleLabels: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F5
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
        refreshSelectionFromModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var hasSelection: Bool {
        selectedIndex >= 0
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "再次确认你的目标"
//        lab.text = "你的目标是？"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var stackView: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = kFitWidth(12)
        return st
    }()

    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("下一步", for: .normal)
        btn.setTitle("下一步", for: .disabled)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return btn
    }()
}

extension GuideTotalProGoalVM {
    func refreshSelectionFromModel() {
        let goalValue = QuestinonaireMsgModel.shared.goal
        switch goalValue {
        case "4", "5", "7":
            applySelection(index: 0, notify: false)
        case "1", "2", "3":
            applySelection(index: 1, notify: false)
        default:
            applySelection(index: -1, notify: false)
        }
    }

    @objc func itemTapAction(_ sender: UIButton) {
        applySelection(index: sender.tag, notify: true)
    }

    @objc private func nextButtonAction() {
        guard hasSelection else { return }
        nextBlock?()
    }

    private func applySelection(index: Int, notify: Bool) {
        selectedIndex = index

        for (idx, button) in itemButtons.enumerated() {
            let isSelected = idx == index
            button.backgroundColor = isSelected ? .THEME : .COLOR_BG_BLACK_04
            titleLabels[idx].textColor = isSelected ? .COLOR_TEXT_WHITE : .COLOR_TEXT_TITLE_0f1214
        }

        if index >= 0 && index < dataArray.count {
            QuestinonaireMsgModel.shared.goal = dataArray[index].value
            if notify {
                selectedBlock?()
            }
        } else {
            QuestinonaireMsgModel.shared.goal = ""
        }

        nextButton.isEnabled = hasSelection
    }
}

extension GuideTotalProGoalVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(stackView)
        addSubview(nextButton)

        for (index, item) in dataArray.enumerated() {
            let button = FeedBackButton()
            button.tag = index
            button.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
            button.layer.cornerRadius = kFitWidth(30)
            button.clipsToBounds = true
            button.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
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
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(175))
        }

        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }
    }
}

extension GuideTotalProGoalVM {
    func prepareEntranceAnimation() {
        titleLabel.alpha = 0
        stackView.alpha = 0
        nextButton.alpha = 0
    }

    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.55, delay: 0, options: .curveLinear) {
            self.titleLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.55, delay: 0.1, options: .curveLinear) {
                self.stackView.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
}
