//
//  AICoachPreInfoSelectPopupVM.swift
//  lns
//
//  Created by Codex on 2026/4/7.
//

import SnapKit
import UIKit

struct AICoachPreInfoSelectionOption {
    let value: Int
    let title: String
}

enum AICoachPreInfoEditableField {
    case goal
    case intensity

    var title: String {
        switch self {
        case .goal:
            return "目标"
        case .intensity:
            return "强度"
        }
    }

    var options: [AICoachPreInfoSelectionOption] {
        switch self {
        case .goal:
            return [
                .init(value: 2, title: "增肌"),
                .init(value: 1, title: "减脂")
            ]
        case .intensity:
            return [
                .init(value: 1, title: "非常放松"),
                .init(value: 2, title: "放松"),
                .init(value: 3, title: "正常"),
                .init(value: 4, title: "健身爱好者"),
                .init(value: 5, title: "职业运动员")
            ]
        }
    }

    func displayText(for value: Int) -> String {
        options.first(where: { $0.value == value })?.title ?? "--"
    }
}

final class AICoachPreInfoSelectPopupVM: AlertVMCommon {

    var confirmBlock: ((AICoachPreInfoEditableField, Int) -> Void)?

    private var currentField: AICoachPreInfoEditableField = .goal
    private var selectedValue: Int = 0
    private var optionViews: [AICoachPreInfoSelectOptionRowView] = []

    private var currentOptions: [AICoachPreInfoSelectionOption] {
        currentField.options
    }

    private var contentHeight: CGFloat {
        let rowHeight = kFitWidth(50)
        let spacing = kFitWidth(12)
        let listHeight = CGFloat(currentOptions.count) * rowHeight + CGFloat(max(currentOptions.count - 1, 0)) * spacing
        return kFitWidth(20) + kFitWidth(28) + kFitWidth(24) + listHeight + kFitWidth(24) + kFitWidth(44) + kFitWidth(5) + WHUtils().getBottomSafeAreaHeight()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        whiteViewHeight = contentHeight
        updateWhiteViewLayout()
        configureBaseStyle()
        initContentUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        button.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return button
    }()

    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = kFitWidth(12)
        return stackView
    }()
}

extension AICoachPreInfoSelectPopupVM {
    func update(field: AICoachPreInfoEditableField, selectedValue: Int) {
        currentField = field
        titleLabel.text = field.title
        self.selectedValue = field.options.contains(where: { $0.value == selectedValue }) ? selectedValue : (field.options.first?.value ?? 0)
        whiteViewHeight = contentHeight
        updateWhiteViewLayout()
        rebuildOptionViews()
    }
}

private extension AICoachPreInfoSelectPopupVM {
    func configureBaseStyle() {
        whiteView.backgroundColor = .COLOR_CARD_BG_WHITE_ALERT
        whiteBlurView.contentView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.08)
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        confirmButton.layer.cornerRadius = kFitWidth(22)
        confirmButton.removeTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    func initContentUI() {
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(optionsStackView)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(20))
            make.height.equalTo(kFitWidth(28))
        }

        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-kFitWidth(16))
            make.width.height.equalTo(kFitWidth(28))
        }

        optionsStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(16))
            make.right.equalToSuperview().offset(-kFitWidth(16))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(24))
        }

        confirmButton.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(5)))
        }

        rebuildOptionViews()
    }

    func rebuildOptionViews() {
        optionsStackView.arrangedSubviews.forEach { subview in
            optionsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        optionViews.removeAll()

        for option in currentOptions {
            let rowView = AICoachPreInfoSelectOptionRowView()
            rowView.tag = option.value
            rowView.update(title: option.title, isSelected: option.value == selectedValue)
            rowView.tapBlock = { [weak self] value in
                self?.updateSelectedValue(value)
            }
            optionsStackView.addArrangedSubview(rowView)
            rowView.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(50))
            }
            optionViews.append(rowView)
        }
    }

    func updateSelectedValue(_ value: Int) {
        selectedValue = value
        for (index, option) in currentOptions.enumerated() where index < optionViews.count {
            optionViews[index].update(title: option.title, isSelected: option.value == value)
        }
    }

    @objc func confirmAction() {
        guard currentOptions.contains(where: { $0.value == selectedValue }) else {
            hiddenSelf()
            return
        }
        confirmBlock?(currentField, selectedValue)
        hiddenSelf()
    }
}

private final class AICoachPreInfoSelectOptionRowView: UIView {

    var tapBlock: ((Int) -> Void)?

    private var optionValue: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "question_foods_normal_icon")
        
        return imageView
    }()

    private lazy var tapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        return button
    }()

    func update(title: String, isSelected: Bool) {
        optionValue = tag
        titleLabel.text = title
        
        checkmarkImageView.setCheckState(isSelected,
                              checkedImageName: "question_foods_selected_icon",
                              uncheckedImageName: "question_foods_normal_icon")
    }
}

private extension AICoachPreInfoSelectOptionRowView {
    func setupUI() {
        backgroundColor = .white.withAlphaComponent(0.72)
        layer.cornerRadius = kFitWidth(14)
        layer.cornerCurve = .continuous

        addSubview(titleLabel)
        addSubview(checkmarkImageView)
        
        addSubview(tapButton)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(16))
            make.centerY.equalToSuperview()
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(kFitWidth(-15))
            make.width.height.equalTo(kFitWidth(30))
        }

        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc func tapAction() {
        tapBlock?(optionValue)
    }
}
