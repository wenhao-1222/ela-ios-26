//
//  DefaultNutritionMineralsTargetVC.swift
//  lns
//
//  Created by Codex on 2026/7/21.
//

import Foundation
import IQKeyboardManagerSwift
import MCToast

private final class DefaultNutritionMineralsScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UITextField {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}

private final class DefaultNutritionMineralsRowView: UIView {
    let item: FoodsNutritionCatalog.Item
    var numberChangeBlock: ((String) -> Void)?
    var beginEditingBlock: (() -> Void)?

    private let rowHeight = kFitWidth(47)
    private let maxIntegerLength = 6
    private let maxFractionLength = 4

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    lazy var textField: NumericTextField = {
        let text = NumericTextField()
        text.keyboardType = .decimalPad
        text.textColor = .THEME
        text.tintColor = .COLOR_TEXT_TITLE_0f1214
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.textAlignment = .right
        text.delegate = self
        text.textContentType = nil
        text.autocorrectionType = .no
        text.spellCheckingType = .no
        return text
    }()

    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .right
        lab.adjustsFontSizeToFitWidth = true
        return lab
    }()

    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()

    init(item: FoodsNutritionCatalog.Item, y: CGFloat) {
        self.item = item
        super.init(frame: CGRect(x: 0, y: y, width: SCREEN_WIDHT, height: rowHeight))
        backgroundColor = .COLOR_CARD_BG_WHITE
        isUserInteractionEnabled = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateValue(_ value: String) {
        textField.text = value
    }

    ///将光标移动到输入框结尾位置
    func beginEditing() {
//        let shouldMoveCursorToEnd = textField.isFirstResponder == false
        textField.becomeFirstResponder()
//        if shouldMoveCursorToEnd {
//            textField.moveCursorToEnd()
//        }
    }

    func configureAccessory(onCancel: (() -> Void)?, onConfirm: (() -> Void)?) {
        textField.setNutritionInputAccessory(title: item.title, onCancel: onCancel, onConfirm: onConfirm)
    }

    private func initUI() {
        titleLabel.text = item.title
        unitLabel.text = item.unit

        addSubview(titleLabel)
        addSubview(textField)
        addSubview(unitLabel)
        addSubview(lineView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(rowTapAction))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.lessThanOrEqualTo(kFitWidth(120))
        }
        unitLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(26))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(130))
            make.right.equalTo(unitLabel.snp.left)//.offset(kFitWidth(-4))
            make.top.bottom.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }

    @objc private func rowTapAction() {
//        let shouldMoveCursorToEnd = textField.isFirstResponder == false
        textField.becomeFirstResponder()
//        if shouldMoveCursorToEnd {
//            textField.moveCursorToEnd()
//        }
    }
}

extension DefaultNutritionMineralsRowView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        DispatchQueue.main.async { [weak textField] in
//            textField?.moveCursorToEnd()
//        }
        beginEditingBlock?()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        if string.isEmpty {
            let updatedText = currentText.replacingCharacters(in: textRange, with: "")
            numberChangeBlock?(updatedText.replacingOccurrences(of: ",", with: "."))
            return true
        }

        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return false
        }

        var prospectiveText = currentText.replacingCharacters(in: textRange, with: string)
        let shouldApplyTextManually = currentText == "0"
            && range.location == 1
            && range.length == 0
            && string.count == 1
            && string != "."
            && string != ","
        if shouldApplyTextManually {
            prospectiveText = string
        }

        if prospectiveText.first == "." || prospectiveText.first == "," {
            return false
        }
        let separatorCount = prospectiveText.filter { $0 == "." || $0 == "," }.count
        if separatorCount > 1 {
            return false
        }
        let parts = prospectiveText.split(omittingEmptySubsequences: false, whereSeparator: { $0 == "." || $0 == "," })
        let integerPart = parts.first.map(String.init) ?? ""
        if integerPart.count > maxIntegerLength {
            return false
        }
        if parts.count > 1, parts[1].count > maxFractionLength {
            return false
        }

        let normalizedText = prospectiveText.replacingOccurrences(of: ",", with: ".")
        if let value = Double(normalizedText), value > 999_999.9999 {
            return false
        }
        if shouldApplyTextManually {
            textField.text = prospectiveText
        }
        numberChangeBlock?(normalizedText)
        return shouldApplyTextManually == false
    }
}

//private extension UITextField {
//    func moveCursorToEnd() {
//        let endPosition = endOfDocument
//        selectedTextRange = textRange(from: endPosition, to: endPosition)
//    }
//}

class DefaultNutritionMineralsTargetVC: WHBaseViewVC {
    private let sectionTitleHeight = kFitWidth(77)
    private let rowHeight = kFitWidth(47)
    private let bottomActionHeight = kFitWidth(134)

    private var rowViews: [String: DefaultNutritionMineralsRowView] = [:]
    private var targetValues: [String: String] = [:]
    private var editingOriginalValues: [String: String] = [:]
    private var contentBottomY: CGFloat = 0
    var selectedItemKey: String?
    private var didFocusSelectedItem = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        loadTargetsFromCache()
        sendDefaultMineralsRequestIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        focusSelectedItemIfNeeded(animated: false)
    }

    private lazy var contentScrollView: UIScrollView = {
        let scroll = DefaultNutritionMineralsScrollView(frame: CGRect(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT - getNavigationBarHeight()))
        scroll.backgroundColor = .COLOR_CARD_BG_WHITE
        scroll.alwaysBounceVertical = true
        scroll.canCancelContentTouches = true
        scroll.delaysContentTouches = false
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .interactive
        scroll.contentInsetAdjustmentBehavior = .never
        return scroll
    }()

    private lazy var contentView: UIView = {
        let vi = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        return vi
    }()

    private lazy var restoreButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("恢复默认", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.addTarget(self, action: #selector(restoreDefaultAction), for: .touchUpInside)
        return btn
    }()

    private lazy var hintIconLabel: UILabel = {
        let lab = UILabel()
        lab.text = "?"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: 11, weight: .regular)
        lab.textAlignment = .center
        lab.layer.cornerRadius = kFitWidth(7)
        lab.layer.borderWidth = kFitWidth(1)
        lab.layer.borderColor = UIColor.COLOR_TEXT_TITLE_0f1214_35.cgColor
        lab.clipsToBounds = true
        return lab
    }()

    private lazy var hintLabel: UILabel = {
        let lab = UILabel()
        lab.text = "Elavatine是如何计算推荐摄入量的?"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_35
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.8
        return lab
    }()

    private lazy var hintTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hintTapAction)))
        return vi
    }()

    private lazy var nutritionRecommendAlertVm: JournalReportNutritionRecommendAlertVM = {
        let vm = JournalReportNutritionRecommendAlertVM(frame: .zero)
        return vm
    }()
}

private extension DefaultNutritionMineralsTargetVC {
    func initUI() {
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        initNavi(titleStr: "目标")
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)

        var currentY: CGFloat = 0
        for section in FoodsNutritionCatalog.shared.sectionItems {
            let sectionLabel = makeSectionLabel(section.section.title)
            contentView.addSubview(sectionLabel)
            sectionLabel.frame = CGRect(x: kFitWidth(16), y: currentY, width: SCREEN_WIDHT - kFitWidth(32), height: sectionTitleHeight)
            currentY += sectionTitleHeight

            for item in section.items {
                let row = DefaultNutritionMineralsRowView(item: item, y: currentY)
                row.numberChangeBlock = { [weak self] number in
                    self?.targetValues[item.key] = number
                }
                row.beginEditingBlock = { [weak self, weak row] in
                    guard let self = self, let row = row else { return }
                    self.editingOriginalValues[item.key] = self.targetValues[item.key] ?? row.textField.text ?? ""
                    if self.contentScrollView.contentInset.bottom > 0 {
                        let keyboardObscuredHeight = max(self.contentScrollView.contentInset.bottom - kFitWidth(16), 0)
                        self.scrollRowToVisible(row, keyboardObscuredHeight: keyboardObscuredHeight, animated: true)
                    }
                }
//                row.configureAccessory(onCancel: { [weak self, weak row] in
//                    guard let self = self, let row = row else { return }
//                    let originalValue = self.editingOriginalValues[item.key] ?? self.targetValues[item.key] ?? ""
//                    row.updateValue(originalValue)
//                    self.targetValues[item.key] = originalValue
//                },
                row.configureAccessory(onCancel: { [weak row] in
                    guard let row = row else { return }
                    row.textField.resignFirstResponder()
                }, onConfirm: { [weak self, weak row] in
                    guard let self = self, let row = row else { return }
                    self.confirmTarget(row)
                })
                contentView.addSubview(row)
                rowViews[item.key] = row
                currentY += rowHeight
            }
        }

        contentView.addSubview(restoreButton)
        contentView.addSubview(hintIconLabel)
        contentView.addSubview(hintLabel)
        contentView.addSubview(hintTapView)
        restoreButton.frame = CGRect(x: 0, y: currentY + kFitWidth(10), width: SCREEN_WIDHT, height: kFitWidth(35))
        hintIconLabel.frame = CGRect(x: kFitWidth(111), y: restoreButton.frame.maxY + kFitWidth(15), width: kFitWidth(14), height: kFitWidth(14))
        hintLabel.frame = CGRect(x: hintIconLabel.frame.maxX + kFitWidth(6), y: restoreButton.frame.maxY + kFitWidth(12), width: SCREEN_WIDHT - hintIconLabel.frame.maxX - kFitWidth(26), height: kFitWidth(20))
        hintTapView.frame = CGRect(x: kFitWidth(72), y: restoreButton.frame.maxY, width: SCREEN_WIDHT - kFitWidth(144), height: kFitWidth(45))

        contentBottomY = currentY + bottomActionHeight
        contentView.frame.size.height = contentBottomY
        updateContentSize()
    }

    func makeSectionLabel(_ title: String) -> UILabel {
        let lab = UILabel()
        lab.text = title
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 15, weight: .semibold)
        return lab
    }

    func loadTargetsFromCache() {
        let cache = UserDefaults.getDictionary(forKey: .nutritionDefaultMineral) as NSDictionary? ?? [:]
        refreshTargets(from: cache)
    }

    func refreshTargets(from dict: NSDictionary) {
        for section in FoodsNutritionCatalog.shared.sectionItems {
            for item in section.items {
                let value = targetValue(in: dict, for: item) ?? 0
                let text = displayText(from: value)
                targetValues[item.key] = text
                rowViews[item.key]?.updateValue(text)
            }
        }
    }

    func sendDefaultMineralsRequestIfNeeded(force: Bool = false) {
        if force == false, UserDefaults.hasNutritionDefaultMineralCache() {
            return
        }
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition_minerals_get, parameters: nil) { [weak self] responseObject in
            guard let self = self else { return }
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            UserDefaults.setNutritionDefaultMineral(dataDict)
            self.refreshTargets(from: dataDict)
            self.focusSelectedItemIfNeeded(animated: true)
        }
    }

    func confirmTarget(_ row: DefaultNutritionMineralsRowView) {
        let item = row.item
        let value = (row.textField.text ?? "").replacingOccurrences(of: ",", with: ".")
        let doubleValue: Double
        if value.isEmpty {
            doubleValue = 0
        } else if let inputValue = Double(value), inputValue >= item.minimumInputValue {
            doubleValue = inputValue
        } else {
            MCToast.mc_text("请输入\(item.title)数值", offset: kFitWidth(100) + SCREEN_HEIGHT * 0.5, respond: .allow)
            return
        }

        row.textField.resignFirstResponder()
        MCToast.mc_loading()
        let targetText = displayText(from: doubleValue)
        let param = [item.key: targetText]
        WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition_minerals_set,
                                          parameters: param as [String: AnyObject],
                                          isNeedToast: true,
                                          vc: self) { [weak self] _ in
            guard let self = self else { return }
            row.updateValue(targetText)
            self.targetValues[item.key] = targetText
            self.updateCache(key: item.key, value: doubleValue)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
        }
    }

    @objc func restoreDefaultAction() {
        view.endEditing(true)
        presentAlertVc(confirmBtn: "恢复默认",
                       message: "将覆盖已修改的目标值",
                       title: "恢复默认值？",
                       cancelBtn: "取消",
                       confirmTextColor: .THEME,
                       cancelTextColor: .COLOR_TEXT_TITLE_0f1214,
                       handler: { action in
            MCToast.mc_loading()
            WHNetworkUtil.shareManager().POST(urlString: URL_get_default_nutrition_minerals_delete,
                                              parameters: nil,
                                              isNeedToast: true,
                                              vc: self) { [weak self] _ in
                guard let self = self else { return }
                UserDefaults.clearNutritionDefaultMineralCache()
                self.sendDefaultMineralsRequestIfNeeded(force: true)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLogsMsg"), object: nil)
            }
        }, viewController: self)
    }

    @objc func hintTapAction() {
        view.endEditing(true)
        nutritionRecommendAlertVm.showSelf(in: view)
    }

    func updateCache(key: String, value: Double) {
        let cache = NSMutableDictionary(dictionary: UserDefaults.getDictionary(forKey: .nutritionDefaultMineral) ?? [:])
        cache.setValue(displayText(from: value), forKey: key)
        UserDefaults.setNutritionDefaultMineral(cache)
    }

    func updateContentSize() {
        let minHeight = SCREEN_HEIGHT - getNavigationBarHeight()
        contentView.frame.size.height = max(contentBottomY, minHeight + kFitWidth(1))
        contentScrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: contentView.frame.height)
    }

    func scrollRowToVisible(_ row: DefaultNutritionMineralsRowView, keyboardObscuredHeight: CGFloat, animated: Bool) {
        let activeFrame = row.convert(row.bounds, to: contentScrollView)
        let visibleHeight = SCREEN_HEIGHT - getNavigationBarHeight() - keyboardObscuredHeight
        let targetBottom = activeFrame.maxY + kFitWidth(16)
        guard targetBottom > contentScrollView.contentOffset.y + visibleHeight else { return }

        let maxOffsetY = max(contentBottomY - visibleHeight, 0)
        let offsetY = min(targetBottom - visibleHeight, maxOffsetY)
        contentScrollView.setContentOffset(CGPoint(x: 0, y: max(offsetY, 0)), animated: animated)
    }

    func focusSelectedItemIfNeeded(animated: Bool) {
        guard didFocusSelectedItem == false,
              let selectedItemKey = selectedItemKey,
              let row = rowViews[selectedItemKey] else { return }

        didFocusSelectedItem = true
        let visibleHeight = SCREEN_HEIGHT - getNavigationBarHeight()
        let rowMidY = row.frame.midY
        let maxOffsetY = max(contentView.frame.height - visibleHeight, 0)
        let offsetY = min(max(rowMidY - visibleHeight/2, 0), maxOffsetY)
        contentScrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)
        DispatchQueue.main.async { [weak row] in
            row?.beginEditing()
        }
    }

    func targetValue(in dict: NSDictionary, for item: FoodsNutritionCatalog.Item) -> Double? {
        if let value = numberValue(from: dict[item.key]) {
            return value
        }
        if let nestedDict = dict[item.key] as? NSDictionary,
           let value = targetValue(inTargetDict: nestedDict) {
            return value
        }
        for listKey in ["list", "items", "data", "minerals"] {
            guard let array = dict[listKey] as? NSArray,
                  let value = targetValue(in: array, for: item) else { continue }
            return value
        }
        return nil
    }

    func targetValue(in array: NSArray, for item: FoodsNutritionCatalog.Item) -> Double? {
        for element in array {
            guard let dict = element as? NSDictionary else { continue }
            let keys = ["key", "code", "name", "field", "nutritionKey"]
            let isMatched = keys.contains { dict.rawStringValueForKey(key: $0) == item.key }
            guard isMatched else { continue }
            if let value = targetValue(inTargetDict: dict) {
                return value
            }
        }
        return nil
    }

    func targetValue(inTargetDict dict: NSDictionary) -> Double? {
        for key in ["target", "targetValue", "value", "default", "amount", "num"] {
            if let value = numberValue(from: dict[key]) {
                return value
            }
        }
        return nil
    }

    func numberValue(from value: Any?) -> Double? {
        guard let value = value, !(value is NSNull) else { return nil }
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        if let string = value as? String {
            let normalized = string.replacingOccurrences(of: ",", with: ".")
            guard normalized.count > 0 else { return nil }
            return Double(normalized)
        }
        return Double("\(value)".replacingOccurrences(of: ",", with: "."))
    }

    func displayText(from value: Double) -> String {
        if value.rounded() == value {
            return "\(Int(value))"
        }
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

extension DefaultNutritionMineralsTargetVC {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardObscuredHeight = keyboardSize.cgRectValue.height + NutritionInputAccessoryView.preferredHeight
        contentScrollView.contentInset.bottom = keyboardObscuredHeight + kFitWidth(16)
        contentScrollView.scrollIndicatorInsets = contentScrollView.contentInset
        updateContentSize()

        guard let activeRow = rowViews.values.first(where: { $0.textField.isEditing }) else { return }
        editingOriginalValues[activeRow.item.key] = targetValues[activeRow.item.key] ?? activeRow.textField.text ?? ""
        scrollRowToVisible(activeRow, keyboardObscuredHeight: keyboardObscuredHeight, animated: true)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        contentScrollView.contentInset.bottom = 0
        contentScrollView.scrollIndicatorInsets = .zero
        updateContentSize()
    }
}
