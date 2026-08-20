//
//  MealAdviceNextComponents.swift
//  lns
//
//  Created by Codex on 2026/8/10.
//

import UIKit
import SnapKit

/// iOS26 原生液态玻璃是否可用。
private enum MealAdviceNextLiquidGlassRuntime {

    /// 判断当前系统是否支持原生 liquid glass。
    static var isNativeAvailable: Bool {
        if #available(iOS 26.0, *) {
            return true
        } else {
            return false
        }
    }
}

/// 下餐规划页的数量输入条。
final class MealAdviceNextFoodCell: FeedBackTableViewCell {

    /// 当前行的名称标签。
    private let titleLabel = UILabel()
    /// 当前行的热量标签。
    private let caloriesLabel = UILabel()
    /// 当前行的数量输入容器。
    private let quantityContainerView = UIView()
    /// 当前行的数量输入框。
    private let quantityTextField = NumericTextField()
    /// 当前行的单位标签。
    private let unitLabel = UILabel()
    /// 真实内容容器。
    private let contentContainerView = UIView()
    /// 当前行名称骨架。
    private let titleSkeletonView = UIView()
    /// 当前行热量骨架。
    private let caloriesSkeletonView = UIView()
    /// 当前行数量骨架。
    private let quantitySkeletonView = UIView()
    /// 数量输入框宽度约束。
    private var quantityTextFieldWidthConstraint: Constraint?
    /// 当前行的勾选按钮。
    private let selectionButton = UIButton(type: .custom)
    /// 当前行底部的分割线。
//    private let separatorView = UIView()

    /// 点击勾选按钮后的回调。
    var onSelectionTap: (() -> Void)?
    /// 数量变化时的回调。
    var onQuantityChanged: ((String) -> Void)?
    /// 数量编辑结束时的回调。
    var onQuantityEditingEnded: ((String) -> Void)?

    /// 创建列表行。
    /// - Parameter reuseIdentifier: 复用标识。
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        buildUI()
    }

    /// 禁止从 storyboard 创建。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 设置高亮时的背景表现。
    /// - Parameters:
    ///   - highlighted: 是否高亮。
    ///   - animated: 是否动画。
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = highlighted ? .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT : .clear
    }

    /// 复用前清理动画和残留骨架，避免旧内容参与下一次淡入。
    override func prepareForReuse() {
        super.prepareForReuse()
        contentContainerView.layer.removeAllAnimations()
        selectionButton.layer.removeAllAnimations()
        [titleSkeletonView, caloriesSkeletonView, quantitySkeletonView].forEach {
            $0.removeSkeletonImmediately()
        }
        onSelectionTap = nil
        onQuantityChanged = nil
        onQuantityEditingEnded = nil
    }
}

extension MealAdviceNextFoodCell {
    /// 刷新当前行内容。
    /// - Parameters:
    ///   - item: 当前行的数据。
    ///   - keepQuantityText: 是否保留输入框里正在编辑的文本。
    func sync(with item: MealAdviceNextFoodItemViewModel,
              keepQuantityText: Bool = false,
              animateContent: Bool = false) {
        UIView.performWithoutAnimation {
            contentContainerView.layer.removeAllAnimations()
            selectionButton.layer.removeAllAnimations()
            titleLabel.text = item.displayName
            caloriesLabel.text = "\(item.caloriesText)千卡"
            unitLabel.text = item.displayUnitText
            selectionButton.setImage(UIImage(named: item.selectionIconName), for: .normal)
            if keepQuantityText == false {
                quantityTextField.text = item.quantityText
            }
            updateQuantityTextFieldWidth()
            setLoading(false, animateContent: false)
            contentContainerView.alpha = animateContent ? 0 : 1
            selectionButton.alpha = 1
            contentView.layoutIfNeeded()
            layoutIfNeeded()
        }
        guard animateContent else { return }
        UIView.animate(withDuration: 0.22,
                       delay: 0,
                       options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction]) {
            self.contentContainerView.alpha = 1
        }
    }

    /// 显示骨架态。
    func setLoading() {
        contentContainerView.layer.removeAllAnimations()
        selectionButton.layer.removeAllAnimations()
        titleLabel.isHidden = true
        caloriesLabel.isHidden = true
        contentContainerView.alpha = 1
        titleSkeletonView.isHidden = false
        caloriesSkeletonView.isHidden = false
        quantitySkeletonView.isHidden = false
        quantityTextField.isHidden = true
        unitLabel.isHidden = true
        quantityTextField.alpha = 0
        unitLabel.alpha = 0
        selectionButton.isHidden = true
        selectionButton.alpha = 0
        selectionButton.isEnabled = false
        quantityContainerView.isUserInteractionEnabled = false
        quantityTextField.isUserInteractionEnabled = false
        quantitySkeletonView.setMealAdviceSkeletonAnimating(true)
        titleSkeletonView.setMealAdviceSkeletonAnimating(true)
        caloriesSkeletonView.setMealAdviceSkeletonAnimating(true)
    }

    /// 退出骨架态。
    func setLoading(_ loading: Bool,
                    animateContent: Bool = false) {
        guard loading == false else { return }
        contentContainerView.layer.removeAllAnimations()
        selectionButton.layer.removeAllAnimations()
        titleLabel.isHidden = false
        caloriesLabel.isHidden = false
        quantitySkeletonView.setMealAdviceSkeletonAnimating(false)
        titleSkeletonView.setMealAdviceSkeletonAnimating(false)
        caloriesSkeletonView.setMealAdviceSkeletonAnimating(false)
        titleSkeletonView.isHidden = true
        caloriesSkeletonView.isHidden = true
        quantitySkeletonView.isHidden = true
        quantityTextField.isHidden = false
        unitLabel.isHidden = false
        quantityTextField.alpha = 1
        unitLabel.alpha = 1
        selectionButton.isHidden = false
        selectionButton.isEnabled = true
        quantityContainerView.isUserInteractionEnabled = true
        quantityTextField.isUserInteractionEnabled = true
        quantityTextField.textColor = .THEME
        if animateContent {
            contentContainerView.alpha = 0
            selectionButton.alpha = 1
            layoutIfNeeded()
            UIView.animate(withDuration: 0.22,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction]) {
                self.contentContainerView.alpha = 1
            }
        } else {
            contentContainerView.alpha = 1
            selectionButton.alpha = 1
        }
    }

    /// 搭建当前行的子视图和约束。
    private func buildUI() {
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.numberOfLines = 1

        titleSkeletonView.backgroundColor = .COLOR_BG_BLACK_06
        titleSkeletonView.layer.cornerRadius = kFitWidth(5)
        titleSkeletonView.clipsToBounds = true
        titleSkeletonView.isHidden = true

        caloriesLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        caloriesLabel.font = .systemFont(ofSize: 13, weight: .regular)

        caloriesSkeletonView.backgroundColor = .COLOR_BG_BLACK_06
        caloriesSkeletonView.layer.cornerRadius = kFitWidth(5)
        caloriesSkeletonView.clipsToBounds = true
        caloriesSkeletonView.isHidden = true

        quantitySkeletonView.backgroundColor = .COLOR_BG_BLACK_06
        quantitySkeletonView.layer.cornerRadius = kFitWidth(5)
        quantitySkeletonView.clipsToBounds = true
        quantitySkeletonView.isHidden = true

        quantityContainerView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        quantityContainerView.layer.cornerRadius = kFitWidth(16)
        quantityContainerView.clipsToBounds = true
        quantityContainerView.isUserInteractionEnabled = true

        quantityTextField.textColor = .THEME
        quantityTextField.font = .systemFont(ofSize: 13, weight: .medium)
        quantityTextField.textAlignment = .right
        quantityTextField.keyboardType = .decimalPad
        quantityTextField.shouldLimitFoodQuantityInput = true
        quantityTextField.delegate = self
        quantityTextField.textContentType = nil
        quantityTextField.backgroundColor = .clear
        quantityTextField.placeholder = "100"
        quantityTextField.maximumFoodQuantityValue = 9999.99
        quantityTextField.maximumFoodQuantityFractionDigits = 2
        quantityTextField.setContentHuggingPriority(.required, for: .horizontal)
        quantityTextField.setContentCompressionResistancePriority(.required, for: .horizontal)
        quantityTextField.setMealAdviceDoneAccessory { [weak self] in
            self?.quantityTextField.resignFirstResponder()
        }
        quantityTextField.addTarget(self, action: #selector(quantityChangedAction), for: .editingChanged)
        quantityTextField.addTarget(self, action: #selector(quantityEditingEndedAction), for: .editingDidEnd)

        unitLabel.textColor = .THEME
        unitLabel.font = .systemFont(ofSize: 13, weight: .medium)
        unitLabel.textAlignment = .left
        unitLabel.setContentHuggingPriority(.required, for: .horizontal)
        unitLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        selectionButton.setImage(UIImage(named: "question_foods_selected_icon"), for: .normal)
        selectionButton.addTarget(self, action: #selector(selectionAction), for: .touchUpInside)

//        separatorView.backgroundColor = .COLOR_LINE_F0

        let quantityStackView = UIStackView(arrangedSubviews: [quantityTextField, unitLabel])
        quantityStackView.axis = .horizontal
        quantityStackView.alignment = .center
        quantityStackView.spacing = kFitWidth(2)
        quantityStackView.distribution = .fill

        contentView.addSubview(contentContainerView)
        contentView.addSubview(titleSkeletonView)
        contentView.addSubview(caloriesSkeletonView)
        contentContainerView.addSubview(titleLabel)
        contentContainerView.addSubview(caloriesLabel)
        contentContainerView.addSubview(quantityContainerView)
        quantityContainerView.addSubview(quantityStackView)
        quantityContainerView.addSubview(quantitySkeletonView)
        contentContainerView.addSubview(selectionButton)
//        contentView.addSubview(separatorView)

        quantityContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(quantityTapAction)))

        contentContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(16))
            make.right.lessThanOrEqualTo(quantityContainerView.snp.left).offset(kFitWidth(-12))
            make.height.equalTo(titleLabel.font.lineHeight)
        }
        caloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(4))
            make.right.lessThanOrEqualTo(quantityContainerView.snp.left).offset(kFitWidth(-12))
            make.height.equalTo(caloriesLabel.font.lineHeight)
        }
        titleSkeletonView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.top)
            make.width.equalTo(kFitWidth(84))
            make.height.equalTo(titleLabel.font.lineHeight)
        }
        caloriesSkeletonView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(caloriesLabel.snp.top)
            make.width.equalTo(kFitWidth(58))
            make.height.equalTo(caloriesLabel.font.lineHeight)
        }
        quantitySkeletonView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectionButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(21))
        }
        quantityContainerView.snp.makeConstraints { make in
            make.right.equalTo(selectionButton.snp.left).offset(kFitWidth(-17))
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(85))
            make.height.equalTo(kFitWidth(32))
        }
        quantityStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        quantityTextField.snp.makeConstraints { make in
            quantityTextFieldWidthConstraint = make.width.equalTo(kFitWidth(24)).constraint
        }
//        separatorView.snp.makeConstraints { make in
//            make.left.equalTo(titleLabel)
//            make.right.equalTo(selectionButton)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
        updateQuantityTextFieldWidth()
    }

    /// 点击勾选按钮。
    @objc private func selectionAction() {
        onSelectionTap?()
    }

    /// 点击数量容器时让输入框进入编辑。
    @objc private func quantityTapAction() {
        quantityTextField.becomeFirstResponder()
    }

    /// 数量变化时同步回调。
    @objc private func quantityChangedAction() {
        updateQuantityTextFieldWidth()
        onQuantityChanged?(quantityTextField.text ?? "")
    }

    /// 数量编辑结束时同步回调。
    @objc private func quantityEditingEndedAction() {
        updateQuantityTextFieldWidth()
        onQuantityEditingEnded?(quantityTextField.text ?? "")
    }

    /// 根据当前文本调整数量输入框宽度，让单位始终贴着数字居中显示。
    private func updateQuantityTextFieldWidth() {
        let currentText = quantityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let textForMeasure = currentText.isEmpty ? (quantityTextField.placeholder ?? "") : currentText
        let font = quantityTextField.font ?? .systemFont(ofSize: 13, weight: .medium)
        let measuredWidth = ceil((textForMeasure as NSString).size(withAttributes: [.font: font]).width)
        let maximumTextWidth = ceil(("9999.99" as NSString).size(withAttributes: [.font: font]).width) + kFitWidth(8)
        let targetWidth = min(max(measuredWidth + kFitWidth(8), kFitWidth(24)), maximumTextWidth)
        quantityTextFieldWidthConstraint?.update(offset: targetWidth)
        layoutIfNeeded()
    }
}

extension MealAdviceNextFoodCell: UITextFieldDelegate {
    /// 限制输入内容，避免首位空格等非法字符。
    /// - Parameters:
    ///   - textField: 当前输入框。
    ///   - range: 替换范围。
    ///   - string: 输入内容。
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === quantityTextField else { return true }

        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        guard NumericTextField.shouldAllowFoodQuantityChange(currentText: currentText,
                                                             range: range,
                                                             replacementString: string,
                                                             maximumValue: quantityTextField.maximumFoodQuantityValue,
                                                             maximumFractionDigits: quantityTextField.maximumFoodQuantityFractionDigits) else {
            return false
        }
        return !(updatedText.first?.isWhitespace ?? false)
    }
}

/// 下餐规划页数量键盘上的“完成”辅助按钮。
final class MealAdviceNextDoneAccessoryView: UIView {

    /// 辅助栏固定高度。
    static let preferredHeight: CGFloat = kFitWidth(56)
    /// 右侧完成按钮。
    private let confirmButton = UIButton(type: .custom)
    /// 原生玻璃按钮背景。
    private let glassBackgroundView = UIVisualEffectView(effect: nil)

    /// 点击“完成”后的回调。
    var confirmHandler: (() -> Void)?

    /// 创建辅助按钮视图。
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: Self.preferredHeight))
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = false

        buildUI()
        updateAppearance()
    }

    /// 禁止从 storyboard 创建。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 让输入辅助视图保持固定高度。
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Self.preferredHeight)
    }

    /// 让圆角跟随实际尺寸刷新。
    override func layoutSubviews() {
        super.layoutSubviews()
        glassBackgroundView.layer.cornerRadius = glassBackgroundView.bounds.height * 0.5
    }

    /// 监听外观变化并刷新玻璃效果。
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
            return
        }

        updateAppearance()
    }

    /// 根据当前系统刷新玻璃效果。
    func updateAppearance() {
        glassBackgroundView.effect = makeGlassEffect()
    }

    /// 构造辅助按钮的界面。
    private func buildUI() {
        addSubview(glassBackgroundView)
        glassBackgroundView.contentView.addSubview(confirmButton)

        glassBackgroundView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-6))
            make.width.equalTo(kFitWidth(78))
            make.height.equalTo(kFitWidth(44))
        }

        confirmButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        glassBackgroundView.layer.cornerRadius = kFitWidth(22)
        glassBackgroundView.layer.cornerCurve = .continuous
        glassBackgroundView.clipsToBounds = true

        confirmButton.setTitle("完成", for: .normal)
        confirmButton.setTitleColor(.COLOR_TEXT_TITLE_0f1214, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        confirmButton.backgroundColor = .clear
        confirmButton.accessibilityLabel = "完成"
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    /// 生成当前系统对应的按钮背景效果。
    private func makeGlassEffect() -> UIVisualEffect? {
        let isDark = traitCollection.userInterfaceStyle == .dark

        if MealAdviceNextLiquidGlassRuntime.isNativeAvailable {
            if #available(iOS 26.0, *) {
                let effect = UIGlassEffect(style: .regular)
                effect.tintColor = isDark
                    ? UIColor.white.withAlphaComponent(0.12)
                    : UIColor.white.withAlphaComponent(0.32)
                effect.isInteractive = true
                return effect
            }
        }

        return UIBlurEffect(style: isDark ? .systemThinMaterialDark : .systemThinMaterialLight)
    }

    /// 点击完成按钮。
    @objc private func confirmAction() {
        confirmHandler?()
    }
}

/// 下餐规划页数量输入框的辅助按钮扩展。
extension UITextField {

    /// 为数量输入框安装“完成”按钮。
    /// - Parameter onConfirm: 点击完成后的回调。
    @discardableResult
    func setMealAdviceDoneAccessory(onConfirm: (() -> Void)? = nil) -> MealAdviceNextDoneAccessoryView {
        let accessoryView = MealAdviceNextDoneAccessoryView()
        accessoryView.confirmHandler = onConfirm ?? { [weak self] in
            self?.resignFirstResponder()
        }
        inputAccessoryView = accessoryView
        reloadInputViews()
        return accessoryView
    }
}

/// 下餐规划页的整数数值过渡动画。
private final class MealAdviceNextNumberAnimator: NSObject {

    /// 需要刷新文本的标签。
    private weak var label: UILabel?
    /// 驱动数字变化的 display link。
    private var displayLink: CADisplayLink?
    /// 起始值。
    private var startValue = 0
    /// 目标值。
    private var targetValue = 0
    /// 动画起始时间。
    private var startTime: CFTimeInterval = 0
    /// 动画时长。
    private var duration: CFTimeInterval = 0.35

    /// 创建数值动画器。
    /// - Parameter label: 需要显示数字的标签。
    init(label: UILabel) {
        self.label = label
        super.init()
    }

    deinit {
        stop()
    }

    /// 直接设置最终值。
    /// - Parameter value: 最终值。
    func setValue(_ value: Int) {
        stop()
        label?.text = "\(value)"
    }

    /// 从旧值滚动到新值。
    /// - Parameters:
    ///   - fromValue: 起始值。
    ///   - toValue: 目标值。
    ///   - duration: 动画时长。
    func animate(from fromValue: Int, to toValue: Int, duration: CFTimeInterval = 0.35) {
        guard fromValue != toValue else {
            setValue(toValue)
            return
        }

        stop()
        startValue = fromValue
        targetValue = toValue
        self.duration = duration
        startTime = CACurrentMediaTime()
        label?.text = "\(fromValue)"

        let link = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// 停止当前动画。
    private func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    /// 逐帧刷新数字。
    /// - Parameter link: 当前 display link。
    @objc private func handleDisplayLink(_ link: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        let progress = min(max(elapsed / duration, 0), 1)
        let easedProgress = 1 - pow(1 - progress, 3)
        let delta = Double(targetValue - startValue) * easedProgress
        let currentValue = Int((Double(startValue) + delta).rounded())
        label?.text = "\(currentValue)"

        if progress >= 1 {
            label?.text = "\(targetValue)"
            stop()
        }
    }
}

/// 下餐规划页顶部的核心营养摘要。
final class MealAdviceNextTopMetricView: UIView {

    /// 左侧彩色圆点。
    private let dotView = UIView()
    /// 营养名称标签。
    private let titleLabel = UILabel()
    /// 大号数字标签。
    private let valueLabel = UILabel()
    /// 名称骨架。
    private let titleSkeletonView = UIView()
    /// 数值骨架。
    private let valueSkeletonView = UIView()
    /// 数字过渡动画器。
    private lazy var numberAnimator = MealAdviceNextNumberAnimator(label: valueLabel)
    /// 当前已展示的整数值。
    private var displayedValue: Int?

    /// 创建顶部摘要视图。
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    /// 禁止从 storyboard 创建。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MealAdviceNextTopMetricView {
    /// 刷新顶部摘要内容。
    /// - Parameters:
    ///   - title: 营养名称。
    ///   - unit: 营养单位。
    ///   - value: 当前摄入值。
    ///   - color: 标识颜色。
    func update(title: String, unit: String, value: Double, color: UIColor, animated: Bool = false) {
        setLoading(false)
        dotView.backgroundColor = color
        titleLabel.text = "\(title)(\(unit))"
        updateValue(Int(value.rounded()), animated: animated)
    }

    /// 切换骨架态。
    func setLoading(_ loading: Bool) {
        dotView.isHidden = false
        titleLabel.isHidden = false
        valueLabel.isHidden = loading
        titleSkeletonView.isHidden = true
        valueSkeletonView.isHidden = !loading
        valueSkeletonView.setMealAdviceSkeletonAnimating(loading)
        if loading {
            numberAnimator.setValue(0)
            displayedValue = nil
        }
    }

    /// 骨架态下直接展示营养名称和圆点，只对数值保留骨架。
    func setLoading(title: String, unit: String, color: UIColor) {
        dotView.backgroundColor = color
        titleLabel.text = "\(title)(\(unit))"
        setLoading(true)
    }

    /// 刷新数字文本。
    /// - Parameters:
    ///   - value: 新值。
    ///   - animated: 是否展示数字滚动动画。
    private func updateValue(_ value: Int, animated: Bool) {
        guard let oldValue = displayedValue else {
            displayedValue = value
            numberAnimator.setValue(value)
            return
        }

        displayedValue = value
        if animated {
            numberAnimator.animate(from: oldValue, to: value)
        } else {
            numberAnimator.setValue(value)
        }
    }

    /// 搭建顶部摘要视图。
    private func buildUI() {
        backgroundColor = .clear

        dotView.layer.cornerRadius = kFitWidth(2)
        dotView.clipsToBounds = true

        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        titleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        titleLabel.adjustsFontSizeToFitWidth = true

        titleSkeletonView.backgroundColor = .COLOR_BG_BLACK_06
        titleSkeletonView.layer.cornerRadius = kFitWidth(4)
        titleSkeletonView.clipsToBounds = true
        titleSkeletonView.isHidden = true

        valueLabel.textColor = .COLOR_TEXT_TITLE_0f1214
//        valueLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        valueLabel.font = UIFont().DDInFontSemiBold(fontSize: 20)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.8
        valueLabel.textAlignment = .center

        valueSkeletonView.backgroundColor = .COLOR_BG_BLACK_06
        valueSkeletonView.layer.cornerRadius = kFitWidth(8)
        valueSkeletonView.clipsToBounds = true
        valueSkeletonView.isHidden = true

        let titleStackView = UIStackView(arrangedSubviews: [dotView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.spacing = kFitWidth(3)

        addSubview(titleStackView)
        addSubview(valueLabel)
        addSubview(titleSkeletonView)
        addSubview(valueSkeletonView)

        dotView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(4))
        }
        titleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleStackView.snp.bottom).offset(kFitWidth(10))
            make.bottom.equalToSuperview()
        }
        titleSkeletonView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(1))
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(9))
        }
        valueSkeletonView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleSkeletonView.snp.bottom).offset(kFitWidth(12))
            make.width.equalTo(kFitWidth(38))
            make.height.equalTo(kFitWidth(19))
        }
    }
}

/// 下餐规划页底部的圆环营养展示。
final class MealAdviceNextRingMetricView: UIView {

    /// 日志页同款圆圈组件。
    private let circleView = LogsNaturalGoalCircleVM(frame: .zero)
    /// 圆环骨架容器。
    private let skeletonContainerView = UIView()
    /// 圆形骨架。
    private let skeletonCircleView = UIView()
    /// 圆心数值骨架。
    private let skeletonValueView = UIView()
    /// 加载态直接显示的营养标题。
    private let loadingTitleLabel = UILabel()
    /// 数字过渡动画器。
    private lazy var numberAnimator = MealAdviceNextNumberAnimator(label: circleView.currentNumberLabel)
    /// 圆环过渡动画器。
    private var circleDisplayLink: CADisplayLink?
    /// 圆环动画起始时间。
    private var circleAnimationStartTime: CFTimeInterval = 0
    /// 圆环动画时长。
    private var circleAnimationDuration: CFTimeInterval = 0.35
    /// 上一次展示的剩余数值。
    private var displayedRemainingValue: Int?
    /// 上一次展示的已摄入数值，用于驱动圆环过渡。
    private var displayedConsumedValue: Int?
    /// 当前目标数值。
    private var displayedTargetValue = 1
    /// 圆环动画起始已摄入数值。
    private var circleStartConsumedValue = 0
    /// 圆环动画目标已摄入数值。
    private var circleTargetConsumedValue = 0

    /// 创建圆环视图。
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    /// 禁止从 storyboard 创建。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopCircleAnimation()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: kFitWidth(53), height: kFitWidth(76))
    }
}

extension MealAdviceNextRingMetricView {
    /// 刷新圆环内容。
    /// - Parameters:
    ///   - title: 营养名称。
    ///   - unit: 营养单位。
    ///   - displayValue: 圆环中间展示值。
    ///   - shouldHighlightNegativeValue: 负数是否高亮。
    ///   - consumedValue: 当前已摄入值。
    ///   - target: 目标值。
    ///   - color: 圆环颜色。
    func update(title: String,
                unit: String,
                displayValue: Double,
                shouldHighlightNegativeValue: Bool,
                consumedValue: Double,
                target: Double,
                color: UIColor,
                overflowColor: UIColor,
                animated: Bool = false) {
        setLoading(false)
        circleView.circleColor = color
        circleView.circleFillColor = overflowColor
        circleView.titleLab.text = "\(title)(\(unit))"
        let targetInt = max(Int(target.rounded()), 0)
        let consumedInt = max(Int(consumedValue.rounded()), 0)
        let displayInt = Int(displayValue.rounded())

        circleView.currentNumberLabel.textColor = shouldHighlightNegativeValue && displayValue < 0 ? WHColor_16(colorStr: "D54941") : .COLOR_TEXT_TITLE_0f1214

        circleView.updateTotalNumber(text: "/\(targetInt)\(MealAdviceNextRingMetricView.totalSuffix(for: unit))")
        updateRemainingValue(displayInt, animated: animated)
        updateCircleProgress(consumedValue: consumedInt, targetValue: max(targetInt, 1), animated: animated)
    }

    /// 切换骨架态。
    func setLoading(_ loading: Bool) {
        circleView.isHidden = loading
        skeletonContainerView.isHidden = !loading
        [skeletonCircleView, skeletonValueView].forEach {
            $0.setMealAdviceSkeletonAnimating(loading)
        }
        loadingTitleLabel.isHidden = !loading
        if loading {
            stopCircleAnimation()
            displayedRemainingValue = nil
            displayedConsumedValue = nil
        }
    }

    /// 设置加载态标题，标题本身不显示骨架。
    func setLoading(title: String, unit: String) {
        loadingTitleLabel.text = "\(title)(\(unit))"
        setLoading(true)
    }

    /// 搭建圆环视图。
    private func buildUI() {
        backgroundColor = .clear
        addSubview(circleView)
        addSubview(skeletonContainerView)
        skeletonContainerView.addSubview(skeletonCircleView)
        skeletonCircleView.addSubview(skeletonValueView)
        skeletonContainerView.addSubview(loadingTitleLabel)

        skeletonContainerView.isHidden = true
        loadingTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        loadingTitleLabel.font = .systemFont(ofSize: 10, weight: .regular)
        loadingTitleLabel.textAlignment = .center
        loadingTitleLabel.numberOfLines = 1
        loadingTitleLabel.isHidden = true
        skeletonCircleView.backgroundColor = .COLOR_BG_BLACK_06
        skeletonCircleView.layer.cornerRadius = kFitWidth(26.5)
        skeletonCircleView.clipsToBounds = true
        skeletonValueView.backgroundColor = .COLOR_CARD_BG_WHITE
        skeletonValueView.layer.cornerRadius = kFitWidth(5)
        skeletonValueView.clipsToBounds = true

        circleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(kFitWidth(53))
            make.height.equalTo(kFitWidth(76))
        }
        skeletonContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(kFitWidth(53))
            make.height.equalTo(kFitWidth(76))
        }
        skeletonCircleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(53))
        }
        skeletonValueView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(kFitWidth(26))
            make.height.equalTo(kFitWidth(10))
        }
        loadingTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(skeletonCircleView.snp.bottom).offset(kFitWidth(5))
            make.left.right.equalToSuperview()
            make.height.equalTo(kFitWidth(12))
        }
    }

    /// 刷新中间剩余数字。
    /// - Parameters:
    ///   - value: 新剩余值。
    ///   - animated: 是否展示数字跳动动画。
    private func updateRemainingValue(_ value: Int, animated: Bool) {
        guard let oldValue = displayedRemainingValue else {
            displayedRemainingValue = value
            numberAnimator.setValue(value)
            return
        }

        displayedRemainingValue = value
        if animated {
            numberAnimator.animate(from: oldValue, to: value)
        } else {
            numberAnimator.setValue(value)
        }
    }

    /// 刷新圆环进度。
    /// - Parameters:
    ///   - consumedValue: 新已摄入值。
    ///   - targetValue: 新目标值。
    ///   - animated: 是否展示进度动画。
    private func updateCircleProgress(consumedValue: Int, targetValue: Int, animated: Bool) {
        let normalizedTarget = max(targetValue, 1)
        guard let oldConsumedValue = displayedConsumedValue else {
            displayedConsumedValue = consumedValue
            displayedTargetValue = normalizedTarget
            circleView.setData(currentNumber: consumedValue, totalNumber: normalizedTarget)
            return
        }

        displayedConsumedValue = consumedValue
        displayedTargetValue = normalizedTarget

        guard animated, oldConsumedValue != consumedValue else {
            stopCircleAnimation()
            circleView.setData(currentNumber: consumedValue, totalNumber: normalizedTarget)
            return
        }

        animateCircleProgress(from: oldConsumedValue, to: consumedValue, targetValue: normalizedTarget)
    }

    /// 从旧进度平滑过渡到新进度。
    /// - Parameters:
    ///   - fromValue: 起始已摄入值。
    ///   - toValue: 目标已摄入值。
    ///   - targetValue: 目标总值。
    private func animateCircleProgress(from fromValue: Int, to toValue: Int, targetValue: Int) {
        stopCircleAnimation()
        circleStartConsumedValue = fromValue
        circleTargetConsumedValue = toValue
        displayedTargetValue = max(targetValue, 1)
        circleAnimationStartTime = CACurrentMediaTime()
        circleView.setData(currentNumber: fromValue, totalNumber: displayedTargetValue)

        let link = CADisplayLink(target: self, selector: #selector(handleCircleDisplayLink(_:)))
        link.add(to: .main, forMode: .common)
        circleDisplayLink = link
    }

    /// 停止圆环过渡动画。
    private func stopCircleAnimation() {
        circleDisplayLink?.invalidate()
        circleDisplayLink = nil
    }

    /// 逐帧刷新圆环进度。
    /// - Parameter link: 当前 display link。
    @objc private func handleCircleDisplayLink(_ link: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - circleAnimationStartTime
        let progress = min(max(elapsed / circleAnimationDuration, 0), 1)
        let easedProgress = 1 - pow(1 - progress, 3)
        let delta = Double(circleTargetConsumedValue - circleStartConsumedValue) * easedProgress
        let currentValue = Int((Double(circleStartConsumedValue) + delta).rounded())
        circleView.setData(currentNumber: currentValue, totalNumber: displayedTargetValue)

        if progress >= 1 {
            circleView.setData(currentNumber: circleTargetConsumedValue, totalNumber: displayedTargetValue)
            stopCircleAnimation()
        }
    }

    /// 日志页同款圆圈的总数后缀。
    private static func totalSuffix(for unit: String) -> String {
        if unit.contains("千卡") || unit.lowercased().contains("kcal") {
            return ""
        }
        if unit.contains("g") || unit.contains("克") || unit.contains("ml") || unit.contains("毫升") {
            return "g"
        }
        return unit
    }
}

private extension UIView {
    /// 开关下餐规划骨架占位动画。
    func setMealAdviceSkeletonAnimating(_ animating: Bool) {
        if animating {
            layoutIfNeeded()
            showSkeleton(
                SkeletonConfig(baseColorLight: .COLOR_GRAY_E8,
                               highlightColorLight: .COLOR_GRAY_D6D6D6,
//                               baseColorDark: .COLOR_GRAY_E8,
//                               highlightColorDark: .COLOR_GRAY_D6D6D6,
                               baseColorDark: UIColor(white: 0.5, alpha: 0.5),
                               highlightColorDark: UIColor(white: 0.08, alpha: 0.55),
                               cornerRadius: layer.cornerRadius,
                               shimmerWidth: 0.22,
                               shimmerDuration: 1.0,
                               skeletonFadeInDuration: 0.0,
                               contentFadeInDuration: 0.18)
            )
        } else {
            removeSkeletonImmediately()
        }
    }
}
