//
//  NutritionInputAccessoryView.swift
//  lns
//
//  Created by Codex on 2026/7/16.
//

import UIKit

final class NutritionInputAccessoryView: UIView {

    static var preferredHeight: CGFloat {
        return kFitWidth(50)
    }

    var cancelHandler: (() -> Void)?
    var confirmHandler: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .medium)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.75
        return lab
    }()

    private lazy var cancelButton: ElaExpandedTapButton = {
        let btn = ElaExpandedTapButton(type: .custom)
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.accessibilityLabel = "取消"
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()

    private lazy var confirmButton: ElaExpandedTapButton = {
        let btn = ElaExpandedTapButton(type: .custom)
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.accessibilityLabel = "完成"
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        return btn
    }()

    init(title: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: Self.preferredHeight))
        backgroundColor = .COLOR_BG_F2
        clipsToBounds = true
        layer.cornerRadius = kFitWidth(10)
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        titleLabel.text = title
        addSubview(titleLabel)
        addSubview(cancelButton)
        addSubview(confirmButton)
        
        titleLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        confirmButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Self.preferredHeight)
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        let buttonWidth = kFitWidth(56)
//        let buttonHeight = bounds.height
//        cancelButton.frame = CGRect(x: kFitWidth(19), y: 0, width: buttonWidth, height: buttonHeight)
//        confirmButton.frame = CGRect(x: bounds.width - kFitWidth(19) - buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)
//        titleLabel.frame = CGRect(x: kFitWidth(92), y: 0, width: bounds.width - kFitWidth(184), height: buttonHeight)
//    }

    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
}

private extension NutritionInputAccessoryView {
    @objc func cancelAction() {
        cancelHandler?()
    }

    @objc func confirmAction() {
        confirmHandler?()
    }
}

extension UITextField {
    @discardableResult
    func setNutritionInputAccessory(title: String,
                                    onCancel: (() -> Void)? = nil,
                                    onConfirm: (() -> Void)? = nil) -> NutritionInputAccessoryView {
        let accessoryView = NutritionInputAccessoryView(title: title)
        accessoryView.cancelHandler = onCancel ?? { [weak self] in
            self?.resignFirstResponder()
        }
        accessoryView.confirmHandler = onConfirm ?? { [weak self] in
            self?.resignFirstResponder()
        }
        inputAccessoryView = accessoryView
        reloadInputViews()
        return accessoryView
    }
}
