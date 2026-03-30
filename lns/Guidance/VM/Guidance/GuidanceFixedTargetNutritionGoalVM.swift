//
//  GuidanceFixedTargetNutritionGoalVM.swift
//  lns
//
//  Created by Codex on 2026/3/19.
//

import UIKit
import SnapKit
import MCToast

class GuidanceFixedTargetNutritionGoalVM: UIView {

    var saveBlock: (() -> ())?

    private let maxCaloriesInputValue = 9999
    private let maxMacroInputValue = 4999
    private var isUpdatingCaloriesProgrammatically = false
    private var shouldAutoFocusCarbInput = false
    private var autoFocusRetryCount = 0
    private var titleTopConstraint: Constraint?
    private var tipsTopConstraint: Constraint?
    private var cardViewTopConstraint: Constraint?
    private let titleDefaultTopOffset = WHUtils().getNavigationBarHeight() + kFitWidth(60)
    private let tipsDefaultTopOffset = WHUtils().getNavigationBarHeight() + kFitWidth(108)
    private let titleMinimumTopOffset = WHUtils().getNavigationBarHeight() + kFitWidth(12)
    private let cardViewDefaultTopOffset = kFitWidth(20)
    private let cardViewKeyboardSpacing = kFitWidth(16)
    private var isMacroEditingEnabled = false
    private var hasUserEditedMacros = false

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
//        lab.text = "卡路里和营养素目标"
//        lab.text = "每日营养目标"
        lab.text = "输入你的每日营养目标"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    private lazy var tipsButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("摄入太高/太低？", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        return btn
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
        tf.placeholder = "-"
        tf.isUserInteractionEnabled = false
        tf.tintColor = .clear
//        tf.keyboardType = .numberPad
//        tf.delegate = self
//        tf.addTarget(self, action: #selector(caloriesDidChange(_:)), for: .editingChanged)
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

//    private lazy var caloriesTapAreaButton: UIButton = {
//        let btn = UIButton(type: .custom)
//        btn.backgroundColor = .clear
//        btn.addTarget(self, action: #selector(caloriesTapAreaAction), for: .touchUpInside)
//        return btn
//    }()

    private lazy var caloriesTapAreaButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        btn.isUserInteractionEnabled = false
        return btn
    }()

    private lazy var carbInputRow: GuidanceFixedTargetNutritionInputRowView = {
        let row = GuidanceFixedTargetNutritionInputRowView(title: "碳水化合物", unit: "g", maxValue: maxMacroInputValue)
        row.valueChangedBlock = { [weak self] _ in
            self?.handleMacroInputChanged()
        }
        return row
    }()

    private lazy var proteinInputRow: GuidanceFixedTargetNutritionInputRowView = {
        let row = GuidanceFixedTargetNutritionInputRowView(title: "蛋白质", unit: "g", maxValue: maxMacroInputValue)
        row.valueChangedBlock = { [weak self] _ in
            self?.handleMacroInputChanged()
        }
        return row
    }()

    private lazy var fatInputRow: GuidanceFixedTargetNutritionInputRowView = {
        let row = GuidanceFixedTargetNutritionInputRowView(title: "脂肪", unit: "g", maxValue: maxMacroInputValue)
        row.valueChangedBlock = { [weak self] _ in
            self?.handleMacroInputChanged()
        }
        return row
    }()

    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
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

    private lazy var alertVm: QuestionCustomTipsAlertVM = {
        let vm = QuestionCustomTipsAlertVM(frame: .zero)
        vm.isHidden = true
        vm.titleLabel.text = "摄入太高/太低？"
        vm.contentLabelOne.text = "Elavatine的计划的重心更偏向于最快达到健身目标，比起日常生活更接近专业运动员的需求，如果你觉得某营养素数值过高或者过低，你可以点击该值并进行手动修改。"
        return vm
    }()
}

extension GuidanceFixedTargetNutritionGoalVM: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return isValidNumericInput(currentText: textField.text ?? "",
                                   range: range,
                                   replacementString: string,
                                   maxValue: maxCaloriesInputValue)
    }
}

extension GuidanceFixedTargetNutritionGoalVM {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func refreshContentFromModel() {
        let carbText = preferredModelText(
            primary: QuestinonaireMsgModel.shared.carbohydratesNumber,
            fallback: QuestinonaireMsgModel.shared.carbohydratesNumberFromServer,
            maxValue: maxMacroInputValue
        )
        let proteinText = preferredModelText(
            primary: QuestinonaireMsgModel.shared.proteinNumber,
            fallback: QuestinonaireMsgModel.shared.proteinNumberFromServer,
            maxValue: maxMacroInputValue
        )
        let fatText = preferredModelText(
            primary: QuestinonaireMsgModel.shared.fatsNumber,
            fallback: QuestinonaireMsgModel.shared.fatsNumberFromServer,
            maxValue: maxMacroInputValue
        )

        if !carbInputRow.textField.isFirstResponder {
            carbInputRow.updateValue(carbText)
        }
        if !proteinInputRow.textField.isFirstResponder {
            proteinInputRow.updateValue(proteinText)
        }
        if !fatInputRow.textField.isFirstResponder {
            fatInputRow.updateValue(fatText)
        }
        hasUserEditedMacros = false
        let caloriesText = preferredModelText(
            primary: QuestinonaireMsgModel.shared.caloriesNumber,
            fallback: QuestinonaireMsgModel.shared.caloriesNumberFromServer,
            maxValue: maxCaloriesInputValue
        )
        let calculatedCalories = calculateCalories(
            carb: Int(carbText) ?? 0,
            protein: Int(proteinText) ?? 0,
            fat: Int(fatText) ?? 0
        )
//        updateCaloriesText(calculatedCalories > 0 ? "\(calculatedCalories)" : "")
        if !caloriesText.isEmpty {
            updateCaloriesText(caloriesText)
        } else {
            updateCaloriesText(calculatedCalories > 0 ? "\(calculatedCalories)" : "")
        }
        updateSaveButtonState()
    }

    func applyEditingMode(isEditable: Bool) {
        isMacroEditingEnabled = isEditable
        if !isEditable {
            endEditing(true)
        }
        carbInputRow.updateEditable(isEditable)
        proteinInputRow.updateEditable(isEditable)
        fatInputRow.updateEditable(isEditable)
        saveButton.setTitle(isEditable ? "保存目标" : "下一步", for: .normal)
        updateSaveButtonState()
    }

    func focusCarbInput() {
        guard isMacroEditingEnabled else { return }
        shouldAutoFocusCarbInput = true
        autoFocusRetryCount = 0
        attemptFocusCarbInputIfNeeded()
    }

    @objc func saveTapAction() {
        guard validateInputs(showToast: true) else { return }
        guard syncModelFromInputs() else { return }
        endEditing(true)
        saveBlock?()
    }

//    @objc func caloriesDidChange(_ sender: UITextField) {
//        if !isUpdatingCaloriesProgrammatically {
//            hasManualCaloriesOverride = true
//        }
//        updateSaveButtonState()
//    }

//    @objc func caloriesTapAreaAction() {
//        _ = caloriesTextField.becomeFirstResponder()
//    }

    @objc func tipsTapAction() {
        endEditing(true)
        alertVm.showView()
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardFrameInView = convert(keyboardFrame, from: nil)
        let keyboardMinY = keyboardFrameInView.minY
        layoutIfNeeded()
        let targetBottom = keyboardMinY - cardViewKeyboardSpacing
        let anchorView = currentKeyboardAnchorView() ?? cardView
        let anchorFrame = convert(anchorView.bounds, from: anchorView)
        let overlap = max(0, anchorFrame.maxY - targetBottom)
        let maxHeaderShift = max(0, titleLabel.frame.minY - titleMinimumTopOffset)
        let headerShift = min(overlap, maxHeaderShift)
        updateLayoutOffsets(headerShift: headerShift,
                            cardOffset: cardViewDefaultTopOffset - overlap + headerShift,
                            notification: notification)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        updateLayoutOffsets(headerShift: 0,
                            cardOffset: cardViewDefaultTopOffset,
                            notification: notification)
    }

    func updateLayoutOffsets(headerShift: CGFloat, cardOffset: CGFloat, notification: Notification?) {
        titleTopConstraint?.update(offset: titleDefaultTopOffset - headerShift)
        tipsTopConstraint?.update(offset: tipsDefaultTopOffset - headerShift)
        cardViewTopConstraint?.update(offset: cardOffset)

        let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let curveRaw = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: [options, .beginFromCurrentState]) {
            self.layoutIfNeeded()
        }
    }

    func handleMacroInputChanged() {
        hasUserEditedMacros = true
        recalculateCaloriesFromMacros()
        updateSaveButtonState()
    }

    func recalculateCaloriesFromMacros() {
        guard hasUserEditedMacros else { return }
        let calories = calculateCalories(
            carb: inputValue(for: carbInputRow),
            protein: inputValue(for: proteinInputRow),
            fat: inputValue(for: fatInputRow)
        )
        let limitedCalories = min(calories, maxCaloriesInputValue)
        updateCaloriesText(limitedCalories > 0 ? "\(limitedCalories)" : "")
    }

    func updateCaloriesText(_ value: String) {
        isUpdatingCaloriesProgrammatically = true
        caloriesTextField.text = normalizedModelText(value, maxValue: maxCaloriesInputValue)
        isUpdatingCaloriesProgrammatically = false
    }

    func updateSaveButtonState() {
        saveButton.isEnabled = validateInputs(showToast: false)
    }

    func validateInputs(showToast: Bool) -> Bool {
        let carb = inputValue(for: carbInputRow)
        let protein = inputValue(for: proteinInputRow)
        let fat = inputValue(for: fatInputRow)

        let carbText = carbInputRow.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if carbText.isEmpty {
            if showToast {
                MCToast.mc_text("请输入碳水化合物数值", respond: .allow)
            }
            return false
        }
        if carb < 0 || carb > maxMacroInputValue {
            if showToast {
                MCToast.mc_text("碳水化合物目标数值范围 0 ~ \(maxMacroInputValue) g", respond: .allow)
            }
            return false
        }
        if protein < 1 || protein > maxMacroInputValue {
            if showToast {
                MCToast.mc_text("蛋白质目标数值范围 1 ~ \(maxMacroInputValue) g", respond: .allow)
            }
            return false
        }
        if fat < 1 || fat > maxMacroInputValue {
            if showToast {
                MCToast.mc_text("脂肪目标数值范围 1 ~ \(maxMacroInputValue) g", respond: .allow)
            }
            return false
        }
        return true
    }

    @discardableResult
    func syncModelFromInputs() -> Bool {
        let calories = caloriesValue()
        let carb = inputValue(for: carbInputRow)
        let protein = inputValue(for: proteinInputRow)
        let fat = inputValue(for: fatInputRow)
        guard validateInputs(showToast: false), calories > 0 else {
            updateSaveButtonState()
            return false
        }

        syncNutritionValuesToModel(carb: carb, protein: protein, fat: fat, calories: calories)
        return true
    }

    func syncNutritionValuesToModel(carb: Int, protein: Int, fat: Int, calories: Int) {
        QuestinonaireMsgModel.shared.carbohydratesNumber = "\(carb)"
        QuestinonaireMsgModel.shared.fatsNumber = "\(fat)"
        QuestinonaireMsgModel.shared.proteinNumber = "\(protein)"
        QuestinonaireMsgModel.shared.caloriesNumber = "\(calories)"

//        QuestinonaireMsgModel.shared.caloriesNumberFromServer = "\(calories)"
        QuestinonaireMsgModel.shared.protein = "\(protein)"
        QuestinonaireMsgModel.shared.carbohydrates = "\(carb)"
        QuestinonaireMsgModel.shared.fats = "\(fat)"
    }

    func caloriesValue() -> Int {
        min(Int(caloriesTextField.text ?? "") ?? 0, maxCaloriesInputValue)
    }

    func inputValue(for row: GuidanceFixedTargetNutritionInputRowView) -> Int {
        min(Int(row.textField.text ?? "") ?? 0, maxMacroInputValue)
    }

    func calculateCalories(carb: Int, protein: Int, fat: Int) -> Int {
        carb * 4 + protein * 4 + fat * 9
    }

    func normalizedModelText(_ value: String, maxValue: Int) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "0" else { return "" }
        let numericValue = min(Int(trimmed) ?? 0, maxValue)
        guard numericValue > 0 else { return "" }
        return "\(numericValue)"
    }

    func preferredModelText(primary: String, fallback: String, maxValue: Int) -> String {
        let primaryText = normalizedModelText(primary, maxValue: maxValue)
        if !primaryText.isEmpty {
            return primaryText
        }
        return normalizedModelText(fallback, maxValue: maxValue)
    }

    func isValidNumericInput(currentText: String,
                             range: NSRange,
                             replacementString string: String,
                             maxValue: Int) -> Bool {
        if string.isEmpty { return true }
        let allowed = CharacterSet.decimalDigits
        guard string.rangeOfCharacter(from: allowed.inverted) == nil else { return false }
        let updated = (currentText as NSString).replacingCharacters(in: range, with: string)
        guard !updated.hasPrefix("0") else { return false }
        guard let updatedValue = Int(updated) else { return false }
        return updatedValue <= maxValue
    }

    func attemptFocusCarbInputIfNeeded() {
        guard shouldAutoFocusCarbInput else { return }
        guard isMacroEditingEnabled else {
            shouldAutoFocusCarbInput = false
            return
        }
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
    
    func currentKeyboardAnchorView() -> UIView? {
        if let responder = cardView.findFirstResponderView() {
            return responder
        }
        return nil
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsButton)
        addSubview(cardView)
        addSubview(alertVm)

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
            titleTopConstraint = make.top.equalTo(titleDefaultTopOffset).constraint
        }

        tipsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            tipsTopConstraint = make.top.equalTo(tipsDefaultTopOffset).constraint
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            cardViewTopConstraint = make.top.equalTo(tipsButton.snp.bottom).offset(cardViewDefaultTopOffset).constraint
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

        applyEditingMode(isEditable: false)
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

class GuidanceFixedTargetNutritionInputRowView: UIView, UITextFieldDelegate {

    var valueChangedBlock: ((String) -> ())?

    init(title: String, unit: String, maxValue: Int) {
        self.titleText = title
        self.unitText = unit
        self.maxValue = maxValue
        super.init(frame: .zero)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleText: String
    private let unitText: String
    private let maxValue: Int

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
        tf.placeholder = "输入数值"
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
        textField.text = normalizedInputText(value)
    }

    func updateEditable(_ isEditable: Bool) {
        if !isEditable {
            textField.resignFirstResponder()
        }
        textField.isEnabled = isEditable
        textField.textColor = .COLOR_TEXT_TITLE_0f1214
        unitLabel.textColor = isEditable ? .COLOR_TEXT_TITLE_0f1214_50 : .COLOR_TEXT_TITLE_0f1214
    }

    @objc func textDidChange(_ sender: UITextField) {
        let normalizedText = normalizedInputText(sender.text ?? "")
        if normalizedText != sender.text {
            sender.text = normalizedText
        }
        valueChangedBlock?(sender.text ?? "")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        let allowed = CharacterSet.decimalDigits
        guard string.rangeOfCharacter(from: allowed.inverted) == nil else { return false }
        let current = textField.text ?? ""
        let updated = (current as NSString).replacingCharacters(in: range, with: string)
        guard !updated.hasPrefix("0") else { return false }
        guard let updatedValue = Int(updated) else { return false }
        return updatedValue <= maxValue
    }

    func normalizedInputText(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        let numericValue = min(Int(trimmed) ?? 0, maxValue)
        guard numericValue > 0 else { return "" }
        return "\(numericValue)"
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
