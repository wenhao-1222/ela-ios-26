//
//  GuidanceNutritionGoalVM.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit
import SnapKit

class GuidanceNutritionGoalVM: UIView {

    var saveBlock: (() -> ())?
    private var titleTopConstraint: Constraint?
    private var cardViewTopConstraint: Constraint?
    private let titleDefaultTopOffset = WHUtils().getNavigationBarHeight() + kFitWidth(88)
    private let titleMinimumTopOffset = WHUtils().getNavigationBarHeight() + kFitWidth(12)
    private let cardViewDefaultTopOffset = kFitWidth(56)
    private let cardViewKeyboardSpacing = kFitWidth(16)

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        initUI()
        registerKeyboardNotifications()
        refreshContentFromModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "输入你的每日营养目标"
//        lab.text = "你的卡路里和营养素目标"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .semibold)
        return lab
    }()

    lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 28, weight: .regular)
        lab.text = "-"
        return lab
    }()

    lazy var caloriesTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "卡路里 (千卡)"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    lazy var goalIconView: UIImageView = {
        let img = UIImageView()
//        if #available(iOS 13.0, *) {
//            img.image = UIImage(systemName: "target")
//        }
        img.image = UIImage(named: "question_goal_selected")
//        img.tintColor = .THEME
//        img.contentMode = .scaleAspectFit
        return img
    }()

    lazy var carbRow = GuidanceNutritionGoalRowView(title: "碳水化合物")
    lazy var proteinRow = GuidanceNutritionGoalRowView(title: "蛋白质")
    lazy var fatRow = GuidanceNutritionGoalRowView(title: "脂肪")

    lazy var saveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveTapAction), for: .touchUpInside)
        return btn
    }()
}

extension GuidanceNutritionGoalVM {
    @objc func saveTapAction() {
        saveBlock?()
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardFrameInView = convert(keyboardFrame, from: nil)
        let keyboardMinY = keyboardFrameInView.minY
        layoutIfNeeded()
        guard let anchorView = currentKeyboardAnchorView() else {
            updateLayoutOffsets(headerShift: 0, cardOffset: cardViewDefaultTopOffset, notification: notification)
            return
        }
        let anchorFrame = convert(anchorView.bounds, from: anchorView)
        let targetBottom = keyboardMinY - cardViewKeyboardSpacing
        let overlap = max(0, anchorFrame.maxY - targetBottom)
        let maxHeaderShift = max(0, titleLabel.frame.minY - titleMinimumTopOffset)
        let headerShift = min(overlap, maxHeaderShift)
        updateLayoutOffsets(headerShift: headerShift,
                            cardOffset: cardViewDefaultTopOffset - overlap + headerShift,
                            notification: notification)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        updateLayoutOffsets(headerShift: 0, cardOffset: cardViewDefaultTopOffset, notification: notification)
    }

    func updateLayoutOffsets(headerShift: CGFloat, cardOffset: CGFloat, notification: Notification?) {
        titleTopConstraint?.update(offset: titleDefaultTopOffset - headerShift)
        cardViewTopConstraint?.update(offset: cardOffset)

        let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let curveRaw = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) {
            self.layoutIfNeeded()
        }
    }

    func currentKeyboardAnchorView() -> UIView? {
        cardView.findFirstResponderView()
    }

    func refreshContentFromModel() {
        caloriesLabel.text = QuestinonaireMsgModel.shared.caloriesNumber.isEmpty ? "0" : QuestinonaireMsgModel.shared.caloriesNumber
        carbRow.updateValue(QuestinonaireMsgModel.shared.carbohydratesNumber)
        proteinRow.updateValue(QuestinonaireMsgModel.shared.proteinNumber)
        fatRow.updateValue(QuestinonaireMsgModel.shared.fatsNumber)
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(cardView)

        cardView.addSubview(caloriesLabel)
        cardView.addSubview(caloriesTitleLabel)
        cardView.addSubview(goalIconView)
        cardView.addSubview(carbRow)
        cardView.addSubview(proteinRow)
        cardView.addSubview(fatRow)
        cardView.addSubview(saveButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            titleTopConstraint = make.top.equalTo(titleDefaultTopOffset).constraint
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            cardViewTopConstraint = make.top.equalTo(titleLabel.snp.bottom).offset(cardViewDefaultTopOffset).constraint
        }

        caloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(kFitWidth(26))
        }

        caloriesTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesLabel)
            make.top.equalTo(caloriesLabel.snp.bottom).offset(kFitWidth(6))
        }

        goalIconView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-26))
            make.centerY.equalTo(caloriesLabel.snp.centerY).offset(kFitWidth(14))
            make.width.height.equalTo(kFitWidth(44))
        }

        carbRow.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-14))
            make.top.equalTo(caloriesTitleLabel.snp.bottom).offset(kFitWidth(42))
            make.height.equalTo(kFitWidth(72))
        }

        proteinRow.snp.makeConstraints { make in
            make.left.right.height.equalTo(carbRow)
            make.top.equalTo(carbRow.snp.bottom)
        }

        fatRow.snp.makeConstraints { make in
            make.left.right.height.equalTo(carbRow)
            make.top.equalTo(proteinRow.snp.bottom)
        }

        saveButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(fatRow.snp.bottom).offset(kFitWidth(40))
            make.bottom.equalTo(kFitWidth(-24))
        }
    }
}

private extension UIView {
    func findFirstResponderView() -> UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let responder = subview.findFirstResponderView() {
                return responder
            }
        }
        return nil
    }
}

class GuidanceNutritionGoalRowView: UIView {

    init(title: String) {
        self.titleText = title
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleText: String

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = titleText
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 15, weight: .medium)
        return lab
    }()

    lazy var valueLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 15, weight: .regular)
        lab.textAlignment = .right
        return lab
    }()

    lazy var separatorLine: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_10
        return vi
    }()
}

extension GuidanceNutritionGoalRowView {
    func updateValue(_ value: String) {
        let display = value.isEmpty ? "输入数值" : value
        valueLabel.text = "\(display) g"
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(separatorLine)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.centerY.equalToSuperview()
        }

        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.right.equalTo(kFitWidth(-8))
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
