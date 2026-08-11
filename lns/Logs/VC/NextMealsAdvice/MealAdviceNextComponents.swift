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
}

extension MealAdviceNextFoodCell {
    /// 刷新当前行内容。
    /// - Parameters:
    ///   - item: 当前行的数据。
    ///   - keepQuantityText: 是否保留输入框里正在编辑的文本。
    func sync(with item: MealAdviceNextFoodItemViewModel, keepQuantityText: Bool = false) {
        titleLabel.text = item.displayName
        caloriesLabel.text = "\(item.caloriesText)千卡"
        unitLabel.text = item.displayUnitText
        selectionButton.setImage(UIImage(named: item.selectionIconName), for: .normal)
        if keepQuantityText == false {
            quantityTextField.text = item.quantityText
        }
    }

    /// 搭建当前行的子视图和约束。
    private func buildUI() {
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 1

        caloriesLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        caloriesLabel.font = .systemFont(ofSize: 12, weight: .regular)

        quantityContainerView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        quantityContainerView.layer.cornerRadius = kFitWidth(16)
        quantityContainerView.clipsToBounds = true
        quantityContainerView.isUserInteractionEnabled = true

        quantityTextField.textColor = .THEME
        quantityTextField.font = .systemFont(ofSize: 13, weight: .medium)
        quantityTextField.textAlignment = .right
        quantityTextField.keyboardType = .decimalPad
        quantityTextField.delegate = self
        quantityTextField.textContentType = nil
        quantityTextField.backgroundColor = .clear
        quantityTextField.placeholder = "100"
        quantityTextField.setMealAdviceDoneAccessory { [weak self] in
            self?.quantityTextField.resignFirstResponder()
        }
        quantityTextField.addTarget(self, action: #selector(quantityChangedAction), for: .editingChanged)
        quantityTextField.addTarget(self, action: #selector(quantityEditingEndedAction), for: .editingDidEnd)

        unitLabel.textColor = .THEME
        unitLabel.font = .systemFont(ofSize: 13, weight: .medium)
        unitLabel.textAlignment = .left

        selectionButton.setImage(UIImage(named: "question_foods_selected_icon"), for: .normal)
        selectionButton.addTarget(self, action: #selector(selectionAction), for: .touchUpInside)

//        separatorView.backgroundColor = .COLOR_LINE_F0

        let quantityStackView = UIStackView(arrangedSubviews: [quantityTextField, unitLabel])
        quantityStackView.axis = .horizontal
        quantityStackView.alignment = .center
        quantityStackView.spacing = kFitWidth(2)

        contentView.addSubview(titleLabel)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(quantityContainerView)
        quantityContainerView.addSubview(quantityStackView)
        contentView.addSubview(selectionButton)
//        contentView.addSubview(separatorView)

        quantityContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(quantityTapAction)))

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(16))
            make.right.lessThanOrEqualTo(quantityContainerView.snp.left).offset(kFitWidth(-12))
        }
        caloriesLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(4))
            make.right.lessThanOrEqualTo(quantityContainerView.snp.left).offset(kFitWidth(-12))
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
            make.center.equalToSuperview()
        }
        quantityTextField.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(66))
        }
        unitLabel.snp.makeConstraints { make in
//            make.width.greaterThanOrEqualTo(kFitWidth(18))
            make.right.equalTo(kFitWidth(20))
            make.width.equalTo(kFitWidth(20))
        }
//        separatorView.snp.makeConstraints { make in
//            make.left.equalTo(titleLabel)
//            make.right.equalTo(selectionButton)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
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
        onQuantityChanged?(quantityTextField.text ?? "")
    }

    /// 数量编辑结束时同步回调。
    @objc private func quantityEditingEndedAction() {
        onQuantityEditingEnded?(quantityTextField.text ?? "")
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

/// 下餐规划页顶部的核心营养摘要。
final class MealAdviceNextTopMetricView: UIView {

    /// 左侧彩色圆点。
    private let dotView = UIView()
    /// 营养名称标签。
    private let titleLabel = UILabel()
    /// 大号数字标签。
    private let valueLabel = UILabel()

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
    func update(title: String, unit: String, value: Double, color: UIColor) {
        dotView.backgroundColor = color
        titleLabel.text = "\(title)(\(unit))"
        valueLabel.text = String(Int(value.rounded()))
    }

    /// 搭建顶部摘要视图。
    private func buildUI() {
        backgroundColor = .clear

        dotView.layer.cornerRadius = kFitWidth(3)
        dotView.clipsToBounds = true

        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.adjustsFontSizeToFitWidth = true

        valueLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        valueLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.8
        valueLabel.textAlignment = .center

        let titleStackView = UIStackView(arrangedSubviews: [dotView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.spacing = kFitWidth(4)

        addSubview(titleStackView)
        addSubview(valueLabel)

        dotView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(6))
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
    }
}

/// 下餐规划页底部的圆环营养展示。
final class MealAdviceNextRingMetricView: UIView {

    /// 环形容器视图。
    private let ringContainerView = UIView()
    /// 中间数字标签。
    private let valueLabel = UILabel()
    /// 底部标题标签。
    private let titleLabel = UILabel()
    /// 圆环底层。
    private let trackLayer = CAShapeLayer()
    /// 圆环进度层。
    private let progressLayer = CAShapeLayer()
    /// 当前高亮颜色。
    private var progressColor = UIColor.COLOR_CARBOHYDRATE

    /// 创建圆环视图。
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    /// 禁止从 storyboard 创建。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MealAdviceNextRingMetricView {
    /// 刷新圆环内容。
    /// - Parameters:
    ///   - title: 营养名称。
    ///   - unit: 营养单位。
    ///   - value: 当前值。
    ///   - target: 目标值。
    ///   - color: 圆环颜色。
    func update(title: String, unit: String, value: Double, target: Double, color: UIColor) {
        progressColor = color
        titleLabel.text = "\(title)(\(unit))"
        valueLabel.text = String(Int(value.rounded()))

        let progress = target > 0 ? min(max(value / target, 0), 1) : 0
        progressLayer.strokeColor = color.cgColor
        progressLayer.strokeEnd = CGFloat(progress)
        setNeedsLayout()
    }

    /// 搭建圆环视图。
    private func buildUI() {
        backgroundColor = .clear
        ringContainerView.backgroundColor = .clear

        valueLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.textAlignment = .center

        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        addSubview(ringContainerView)
        addSubview(valueLabel)
        addSubview(titleLabel)

        ringContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(66))
        }
        valueLabel.snp.makeConstraints { make in
            make.center.equalTo(ringContainerView)
            make.width.lessThanOrEqualTo(kFitWidth(52))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ringContainerView.snp.bottom).offset(kFitWidth(12))
            make.bottom.equalToSuperview()
        }

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.COLOR_TEXT_TITLE_0f1214_10.cgColor
        trackLayer.lineWidth = kFitWidth(5)
        trackLayer.lineCap = .round

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = kFitWidth(5)
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        ringContainerView.layer.addSublayer(trackLayer)
        ringContainerView.layer.addSublayer(progressLayer)
    }

    /// 更新圆环路径。
    override func layoutSubviews() {
        super.layoutSubviews()

        let bounds = ringContainerView.bounds
        trackLayer.frame = bounds
        progressLayer.frame = bounds

        let inset = progressLayer.lineWidth / 2 + kFitWidth(1)
        let ringRect = bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(ovalIn: ringRect)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = progressColor.cgColor
    }
}
