//
//  GuidanceFixedTargetNutritionGoalVM.swift
//  lns
//
//  Created by Codex on 2026/3/19.
//

import UIKit
import SnapKit

class GuidanceFixedTargetNutritionGoalVM: UIView {

    var saveBlock: (() -> ())?

    private var isUpdatingCaloriesProgrammatically = false
    private var hasManualCaloriesOverride = false
    private var shouldAutoFocusCarbInput = false
    private var autoFocusRetryCount = 0
    private var cardViewTopConstraint: Constraint?
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

    override func didMoveToWindow() {
        super.didMoveToWindow()
        attemptFocusCarbInputIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        attemptFocusCarbInputIfNeeded()
    }

    private lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "卡路里和营养素目标"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .semibold)
        return lab
    }()

    private lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        return vi
    }()

    private lazy var caloriesTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = .COLOR_TEXT_TITLE_0f1214
        tf.font = UIFont().DDInFontMedium(fontSize: 28)//.systemFont(ofSize: 28, weight: .regular)
        tf.keyboardType = .numberPad
        tf.placeholder = "0"
        tf.delegate = self
        tf.addTarget(self, action: #selector(caloriesDidChange(_:)), for: .editingChanged)
        return tf
    }()

    private lazy var caloriesTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "卡路里 (千卡)"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    private lazy var goalIconView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "question_goal_selected")
        img.contentMode = .scaleAspectFit
        return img
    }()

    private lazy var caloriesTapAreaButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(caloriesTapAreaAction), for: .touchUpInside)
        return btn
    }()

    private lazy var carbInputRow: GuidanceFixedTargetNutritionInputRowView = {
        let row = GuidanceFixedTargetNutritionInputRowView(title: "碳水化合物", unit: "g")
        row.valueChangedBlock = { [weak self] _ in
            self?.handleMacroInputChanged()
        }
        return row
    }()

    private lazy var proteinInputRow: GuidanceFixedTargetNutritionInputRowView = {
        let row = GuidanceFixedTargetNutritionInputRowView(title: "蛋白质", unit: "g")
        row.valueChangedBlock = { [weak self] _ in
            self?.handleMacroInputChanged()
        }
        return row
    }()

    private lazy var fatInputRow: GuidanceFixedTargetNutritionInputRowView = {
        let row = GuidanceFixedTargetNutritionInputRowView(title: "脂肪", unit: "g")
        row.valueChangedBlock = { [weak self] _ in
            self?.handleMacroInputChanged()
        }
        return row
    }()

    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("保存目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveTapAction), for: .touchUpInside)
        return btn
    }()
}

extension GuidanceFixedTargetNutritionGoalVM: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        let allowed = CharacterSet.decimalDigits
        guard string.rangeOfCharacter(from: allowed.inverted) == nil else { return false }
        let current = textField.text ?? ""
        let updated = (current as NSString).replacingCharacters(in: range, with: string)
        return updated.count <= 4
    }
}

extension GuidanceFixedTargetNutritionGoalVM {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func refreshContentFromModel() {
        let carbText = normalizedModelText(QuestinonaireMsgModel.shared.carbohydratesNumber)
        let proteinText = normalizedModelText(QuestinonaireMsgModel.shared.proteinNumber)
        let fatText = normalizedModelText(QuestinonaireMsgModel.shared.fatsNumber)
        let caloriesText = normalizedModelText(QuestinonaireMsgModel.shared.caloriesNumber)

        if !carbInputRow.textField.isFirstResponder {
            carbInputRow.updateValue(carbText)
        }
        if !proteinInputRow.textField.isFirstResponder {
            proteinInputRow.updateValue(proteinText)
        }
        if !fatInputRow.textField.isFirstResponder {
            fatInputRow.updateValue(fatText)
        }
        if !caloriesTextField.isFirstResponder {
            caloriesTextField.text = caloriesText
        }

        let storedCalories = Int(caloriesText) ?? 0
        let calculatedCalories = calculateCalories(
            carb: Int(carbText) ?? 0,
            protein: Int(proteinText) ?? 0,
            fat: Int(fatText) ?? 0
        )
        hasManualCaloriesOverride = storedCalories > 0 && storedCalories != calculatedCalories
        if !hasManualCaloriesOverride && !caloriesTextField.isFirstResponder {
            updateCaloriesText(calculatedCalories > 0 ? "\(calculatedCalories)" : "")
        }
        updateSaveButtonState()
    }

    func focusCarbInput() {
        shouldAutoFocusCarbInput = true
        autoFocusRetryCount = 0
        attemptFocusCarbInputIfNeeded()
    }

    @objc func saveTapAction() {
        guard syncModelFromInputs() else { return }
        endEditing(true)
        saveBlock?()
    }

    @objc func caloriesDidChange(_ sender: UITextField) {
        if !isUpdatingCaloriesProgrammatically {
            hasManualCaloriesOverride = true
        }
        updateSaveButtonState()
    }

    @objc func caloriesTapAreaAction() {
        _ = caloriesTextField.becomeFirstResponder()
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardFrameInView = convert(keyboardFrame, from: nil)
        let keyboardMinY = keyboardFrameInView.minY
        layoutIfNeeded()
        let defaultCardTop = titleLabel.frame.maxY + cardViewDefaultTopOffset
        let defaultCardBottom = defaultCardTop + cardView.bounds.height
        let targetBottom = keyboardMinY - cardViewKeyboardSpacing
        let overlap = max(0, defaultCardBottom - targetBottom)
        updateCardViewTopOffset(cardViewDefaultTopOffset - overlap, notification: notification)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        updateCardViewTopOffset(cardViewDefaultTopOffset, notification: notification)
    }

    func updateCardViewTopOffset(_ offset: CGFloat, notification: Notification?) {
        cardViewTopConstraint?.update(offset: offset)

        let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let curveRaw = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) {
            self.layoutIfNeeded()
        }
    }

    func handleMacroInputChanged() {
        hasManualCaloriesOverride = false
        recalculateCaloriesFromMacros()
        updateSaveButtonState()
    }

    func recalculateCaloriesFromMacros() {
        guard !hasManualCaloriesOverride else { return }
        let calories = calculateCalories(
            carb: inputValue(for: carbInputRow),
            protein: inputValue(for: proteinInputRow),
            fat: inputValue(for: fatInputRow)
        )
        updateCaloriesText(calories > 0 ? "\(calories)" : "")
    }

    func updateCaloriesText(_ value: String) {
        isUpdatingCaloriesProgrammatically = true
        caloriesTextField.text = value
        isUpdatingCaloriesProgrammatically = false
    }

    func updateSaveButtonState() {
        let isEnabled = caloriesValue() > 100 &&
            inputValue(for: carbInputRow) > 10 &&
            inputValue(for: proteinInputRow) > 10 &&
            inputValue(for: fatInputRow) > 10
        saveButton.isEnabled = isEnabled
    }

    @discardableResult
    func syncModelFromInputs() -> Bool {
        let calories = caloriesValue()
        let carb = inputValue(for: carbInputRow)
        let protein = inputValue(for: proteinInputRow)
        let fat = inputValue(for: fatInputRow)
        guard calories > 10, carb > 10, protein > 10, fat > 10 else {
            updateSaveButtonState()
            return false
        }

        QuestinonaireMsgModel.shared.caloriesNumber = "\(calories)"
        QuestinonaireMsgModel.shared.caloriesNumberFromServer = "\(calories)"
        QuestinonaireMsgModel.shared.carbohydratesNumber = "\(carb)"
        QuestinonaireMsgModel.shared.proteinNumber = "\(protein)"
        QuestinonaireMsgModel.shared.fatsNumber = "\(fat)"
        return true
    }

    func caloriesValue() -> Int {
        Int(caloriesTextField.text ?? "") ?? 0
    }

    func inputValue(for row: GuidanceFixedTargetNutritionInputRowView) -> Int {
        Int(row.textField.text ?? "") ?? 0
    }

    func calculateCalories(carb: Int, protein: Int, fat: Int) -> Int {
        carb * 4 + protein * 4 + fat * 9
    }

    func normalizedModelText(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "0" else { return "" }
        return trimmed
    }

    func attemptFocusCarbInputIfNeeded() {
        guard shouldAutoFocusCarbInput else { return }
        guard window != nil else { return }
        if carbInputRow.textField.isFirstResponder {
            shouldAutoFocusCarbInput = false
            return
        }
        let focused = carbInputRow.textField.becomeFirstResponder()
        if focused {
            shouldAutoFocusCarbInput = false
        } else {
            scheduleCarbInputFocusRetry()
        }
    }

    func scheduleCarbInputFocusRetry() {
        guard shouldAutoFocusCarbInput, autoFocusRetryCount < 8 else { return }
        autoFocusRetryCount += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.attemptFocusCarbInputIfNeeded()
        }
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(cardView)

        cardView.addSubview(caloriesTapAreaButton)
        cardView.addSubview(caloriesTextField)
        cardView.addSubview(caloriesTitleLabel)
        cardView.addSubview(goalIconView)
        cardView.addSubview(carbInputRow)
        cardView.addSubview(proteinInputRow)
        cardView.addSubview(fatInputRow)
        cardView.addSubview(saveButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(88))
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            cardViewTopConstraint = make.top.equalTo(titleLabel.snp.bottom).offset(cardViewDefaultTopOffset).constraint
        }

        caloriesTapAreaButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.right.equalTo(caloriesTitleLabel.snp.right)
            make.bottom.equalTo(caloriesTitleLabel.snp.bottom)
        }

        caloriesTextField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(kFitWidth(26))
            make.right.lessThanOrEqualTo(goalIconView.snp.left).offset(kFitWidth(-16))
        }

        caloriesTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesTextField)
            make.top.equalTo(caloriesTextField.snp.bottom).offset(kFitWidth(6))
        }

        goalIconView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-26))
            make.centerY.equalTo(caloriesTextField.snp.centerY).offset(kFitWidth(14))
            make.width.height.equalTo(kFitWidth(44))
        }

        carbInputRow.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(14))
            make.right.equalTo(kFitWidth(-14))
            make.top.equalTo(caloriesTitleLabel.snp.bottom).offset(kFitWidth(42))
            make.height.equalTo(kFitWidth(72))
        }

        proteinInputRow.snp.makeConstraints { make in
            make.left.right.height.equalTo(carbInputRow)
            make.top.equalTo(carbInputRow.snp.bottom)
        }

        fatInputRow.snp.makeConstraints { make in
            make.left.right.height.equalTo(carbInputRow)
            make.top.equalTo(proteinInputRow.snp.bottom)
        }

        saveButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(fatInputRow.snp.bottom).offset(kFitWidth(40))
            make.bottom.equalTo(kFitWidth(-24))
        }
    }
}

class GuidanceFixedTargetNutritionInputRowView: UIView, UITextFieldDelegate {

    var valueChangedBlock: ((String) -> ())?

    init(title: String, unit: String) {
        self.titleText = title
        self.unitText = unit
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleText: String
    private let unitText: String

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = titleText
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()

    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.text = unitText
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        return lab
    }()

    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.textAlignment = .right
        tf.textColor = .COLOR_TEXT_TITLE_0f1214
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.keyboardType = .numberPad
        tf.placeholder = "0"
        tf.delegate = self
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return tf
    }()

    lazy var separatorLine: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()
}

extension GuidanceFixedTargetNutritionInputRowView {
    func updateValue(_ value: String) {
        textField.text = value
    }

    @objc func textDidChange(_ sender: UITextField) {
        valueChangedBlock?(sender.text ?? "")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        let allowed = CharacterSet.decimalDigits
        guard string.rangeOfCharacter(from: allowed.inverted) == nil else { return false }
        let current = textField.text ?? ""
        let updated = (current as NSString).replacingCharacters(in: range, with: string)
        return updated.count <= 4
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(unitLabel)
        addSubview(textField)
        addSubview(separatorLine)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.centerY.equalToSuperview()
        }

        unitLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-12))
            make.centerY.equalToSuperview()
        }

        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(unitLabel.snp.left).offset(kFitWidth(-10))
            make.width.equalTo(kFitWidth(110))
        }

        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.right.equalTo(kFitWidth(-8))
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
