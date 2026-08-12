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
    case tone

    var title: String {
        switch self {
        case .goal:
            return "目标"
        case .intensity:
            return "强度"
        case .tone:
            return "风格"
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
                .init(value: 1, title: "非常轻松"),
                .init(value: 2, title: "轻松"),
                .init(value: 3, title: "正常"),
                .init(value: 4, title: "健身爱好者"),
                .init(value: 5, title: "职业运动员")
            ]
        case .tone:
            return [
                .init(value: 1, title: "专业"),
                .init(value: 2, title: "温柔"),
                .init(value: 3, title: "毒舌"),
                .init(value: 4, title: "诛心")
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
        backgroundColor = .COLOR_CARD_BG_WHITE
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

final class AICoachPreToneStylePopupVM: AlertVMCommon, UIGestureRecognizerDelegate {

    var confirmBlock: ((Int) -> Void)?

    private var selectedValue: Int = 1
    private weak var whiteViewPanGestureRecognizer: UIPanGestureRecognizer?
    private let labelHorizontalInset: CGFloat = kFitWidth(11)
    private let labelWidth: CGFloat = kFitWidth(56)

    private let options: [AICoachPreInfoSelectionOption] = [
        .init(value: 2, title: "温柔"),
        .init(value: 1, title: "专业"),
        .init(value: 3, title: "毒舌"),
        .init(value: 4, title: "诛心")
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        whiteViewHeight = kFitWidth(223) + WHUtils().getBottomSafeAreaHeight()
        updateWhiteViewLayout()
        configureBaseStyle()
        initContentUI()
        configureWhiteViewPanGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutToneOptionLabels()
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "教练风格"
        label.textAlignment = .center
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()

    private lazy var closeButton: ElaExpandedTapButton = {
        let button = ElaExpandedTapButton(type: .custom)
        button.hitTestEdgeInsets = .init(top: -12, left: -12, bottom: -12, right: -12)
//        button.backgroundColor = UIColor.white.withAlphaComponent(0.76)
        button.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
//        button.layer.cornerRadius = kFitWidth(20)
//        button.clipsToBounds = true
        button.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return button
    }()

    private lazy var labelsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var optionLabels: [UILabel] = {
        options.map { option in
            let label = UILabel()
            label.text = option.title
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.75
            label.isUserInteractionEnabled = true
            label.tag = option.value
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(optionLabelTapAction(_:))))
            return label
        }
    }()

    private lazy var toneSliderView: AICoachPreToneStyleSliderView = {
        let view = AICoachPreToneStyleSliderView(values: options.map { $0.value })
        view.valuePreviewBlock = { [weak self] value in
            self?.updateSelectedValue(value, animated: true, notifiesChange: false)
        }
        view.valueCommitBlock = { [weak self] value in
            self?.commitSelectedValue(value, animated: true)
        }
        return view
    }()
}

extension AICoachPreToneStylePopupVM {
    func update(selectedValue: Int) {
        let normalizedValue = options.contains(where: { $0.value == selectedValue })
            ? selectedValue
            : (options.first?.value ?? 1)
        updateSelectedValue(normalizedValue, animated: false, notifiesChange: false)
    }
}

private extension AICoachPreToneStylePopupVM {
    func configureBaseStyle() {
        whiteView.backgroundColor = .COLOR_CARD_BG_WHITE_ALERT
        whiteBlurView.contentView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.08)
        confirmButton.isHidden = true
    }

    func initContentUI() {
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(labelsContainerView)
        whiteView.addSubview(toneSliderView)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(25))
            make.height.equalTo(kFitWidth(25))
        }

        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-kFitWidth(25))
            make.width.height.equalTo(kFitWidth(25))
        }

        labelsContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(21))
            make.right.equalToSuperview().offset(-kFitWidth(21))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(50))
            make.height.equalTo(kFitWidth(22))
        }

        for label in optionLabels {
            labelsContainerView.addSubview(label)
        }

        toneSliderView.snp.makeConstraints { make in
            make.left.right.equalTo(labelsContainerView)
            make.top.equalTo(labelsContainerView.snp.bottom).offset(kFitWidth(14))
            make.height.equalTo(kFitWidth(30))
        }

        updateSelectedValue(selectedValue, animated: false, notifiesChange: false)
    }

    func layoutToneOptionLabels() {
        let labelHeight = labelsContainerView.bounds.height
        guard labelHeight > 0 else { return }

        let maxIndex = max(optionLabels.count - 1, 1)
        let availableWidth = max(1, labelsContainerView.bounds.width - labelHorizontalInset * 2)
        for (index, label) in optionLabels.enumerated() {
            let progress = CGFloat(index) / CGFloat(maxIndex)
            let centerX = labelHorizontalInset + progress * availableWidth
            label.frame = CGRect(x: centerX - labelWidth * 0.5,
                                 y: 0,
                                 width: labelWidth,
                                 height: labelHeight)
        }
    }

    func configureWhiteViewPanGesture() {
        let panGesture = whiteView.gestureRecognizers?.compactMap { $0 as? UIPanGestureRecognizer }.first
        panGesture?.delegate = self
        whiteViewPanGestureRecognizer = panGesture
    }

    func updateSelectedValue(_ value: Int, animated: Bool, notifiesChange: Bool) {
        let shouldNotifyChange = notifiesChange && selectedValue != value
        guard selectedValue != value || toneSliderView.selectedValue != value else {
            toneSliderView.setSelectedValue(value, animated: animated)
            updateLabelStates()
            return
        }

        selectedValue = value
        toneSliderView.setSelectedValue(value, animated: animated)
        updateLabelStates()
        if shouldNotifyChange {
            confirmBlock?(value)
        }
    }

    func commitSelectedValue(_ value: Int, animated: Bool) {
        updateSelectedValue(value, animated: animated, notifiesChange: true)
    }

    func updateLabelStates() {
        for label in optionLabels {
            let isSelected = label.tag == selectedValue
            label.textColor = isSelected ? .COLOR_TEXT_TITLE_0f1214 : .COLOR_TEXT_TITLE_0f1214_50
            label.font = .systemFont(ofSize: 14,
                                     weight: isSelected ? .medium : .regular)
        }
    }

    @objc func optionLabelTapAction(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        toneSliderView.commitSelectedValue(label.tag, animated: true)
    }

}

extension AICoachPreToneStylePopupVM {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === whiteViewPanGestureRecognizer else { return true }
        let touchedView = touch.view
        if touchedView?.isDescendant(of: toneSliderView) == true
            || touchedView?.isDescendant(of: labelsContainerView) == true {
            return false
        }
        return true
    }
}

private final class AICoachPreToneStyleSliderView: UIControl {

    /// 拖拽过程中选中值变化时触发，只用于预览 UI，不负责最终提交。
    var valuePreviewBlock: ((Int) -> Void)?
    /// 用户结束拖拽后触发，用于把最终选中的风格值提交给外层。
    var valueCommitBlock: ((Int) -> Void)?
    /// 当前选中的风格值，外部只读，避免绕过布局刷新直接修改。
    private(set) var selectedValue: Int = 1

    /// 滑杆支持的风格值数组，数组顺序决定从左到右的档位顺序。
    private let values: [Int]
    /// 轨道视觉高度。
    private let trackHeight: CGFloat = kFitWidth(30)
    /// 白色滑块直径。
    private let thumbDiameter: CGFloat = kFitWidth(26)
    /// 灰色圆点中心到轨道左右边缘的距离。
    private let dotHorizontalInset: CGFloat = kFitWidth(11)
    /// 滑块在最左/最右时，滑块边缘到轨道左右边缘的距离。
    private let thumbHorizontalInset: CGFloat = kFitWidth(2)

    /// 灰色底部轨道。
    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = trackHeight * 0.5
        view.layer.cornerCurve = .continuous
        return view
    }()

    /// 蓝色已选进度轨道。
    private lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .THEME
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = trackHeight * 0.5
        view.layer.cornerCurve = .continuous
        return view
    }()

    /// 白色圆形滑块。
    private lazy var thumbView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_BG_WHITE
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = thumbDiameter * 0.5
        view.layer.cornerCurve = .continuous
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = kFitWidth(9)
        view.layer.shadowOffset = CGSize(width: 0, height: kFitWidth(4))
        return view
    }()

    /// 未选中档位的灰色圆点集合。
    private var dotViews: [UIView] = []
    /// 标记当前是否正在手指拖拽，避免外部刷新动画和拖拽手感冲突。
    private var isTrackingTouch = false
    /// 拖拽过程中的滑块中心点 x 坐标，用于让滑块跟随手指连续移动。
    private var trackingThumbCenterX: CGFloat?

    /// 使用指定档位值初始化滑杆，空数组时回退为 1...4。
    init(values: [Int]) {
        self.values = values.isEmpty ? [1, 2, 3, 4] : values
        super.init(frame: .zero)
        selectedValue = self.values.first ?? 1
        setupUI()
    }

    /// 不支持从 xib/storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 子视图尺寸变化时同步刷新轨道、圆点和滑块位置。
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout(animated: false)
    }

    /// 扩大滑杆触摸热区，让可拖拽范围比视觉控件更大。
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -kFitWidth(18), dy: -kFitWidth(18)).contains(point)
    }

    /// 手指开始触摸时进入拖拽状态，并立即根据触点更新预览值。
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isTrackingTouch = true
        updateTrackingPosition(for: touch)
        updateValue(for: touch, animated: false, shouldNotifyPreview: true)
        return true
    }

    /// 手指移动时持续更新预览值。
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateTrackingPosition(for: touch)
        updateValue(for: touch, animated: false, shouldNotifyPreview: true)
        return true
    }

    /// 手指抬起时结束拖拽，并提交最终选中的值。
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch = touch {
            updateTrackingPosition(for: touch)
            updateValue(for: touch, animated: true, shouldNotifyPreview: true)
        } else {
            updateLayout(animated: true)
        }
        isTrackingTouch = false
        trackingThumbCenterX = nil
        updateLayout(animated: true)
        valueCommitBlock?(selectedValue)
    }

    /// 系统取消触摸时结束拖拽，并把滑块回弹到当前选中档位。
    override func cancelTracking(with event: UIEvent?) {
        isTrackingTouch = false
        trackingThumbCenterX = nil
        updateLayout(animated: true)
    }

    /// 外部设置选中值，并按需刷新滑块动画。
    func setSelectedValue(_ value: Int, animated: Bool) {
        selectedValue = values.contains(value) ? value : (values.first ?? 1)
        if !isTrackingTouch {
            trackingThumbCenterX = nil
        }
        updateLayout(animated: animated && !isTrackingTouch)
    }

    /// 外部触发最终选中值提交，供点击文案等非拖拽入口复用。
    func commitSelectedValue(_ value: Int, animated: Bool) {
        setSelectedValue(value, animated: animated)
        valueCommitBlock?(selectedValue)
    }
}

private extension AICoachPreToneStyleSliderView {
    /// 创建轨道、进度、圆点和滑块视图。
    func setupUI() {
        backgroundColor = .clear
        isMultipleTouchEnabled = false

        addSubview(trackView)

        for _ in 0..<max(values.count - 1, 0) {
            let dotView = UIView()
            dotView.backgroundColor = UIColor(hex: "D3D3D3")
            dotView.isUserInteractionEnabled = false
            dotView.layer.cornerRadius = kFitWidth(5)
            trackView.addSubview(dotView)
            dotViews.append(dotView)
        }

        trackView.addSubview(progressView)
        addSubview(thumbView)
    }

    /// 根据触摸位置换算最近档位，并按需通知外层刷新预览。
    func updateValue(for touch: UITouch, animated: Bool, shouldNotifyPreview: Bool) {
        let location = touch.location(in: self)
        let value = nearestValue(for: location.x)
        guard value != selectedValue else {
            updateLayout(animated: animated)
            return
        }

        selectedValue = value
        updateLayout(animated: animated)
        if shouldNotifyPreview {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            valuePreviewBlock?(value)
            sendActions(for: .valueChanged)
        }
    }

    /// 根据触摸位置更新拖拽中的滑块连续坐标。
    func updateTrackingPosition(for touch: UITouch) {
        let location = touch.location(in: self)
        trackingThumbCenterX = clampedThumbCenterX(for: location.x)
        updateLayout(animated: false)
    }

    /// 根据横向坐标计算最近的档位值。
    func nearestValue(for x: CGFloat) -> Int {
        let minCenterX = thumbHorizontalInset + thumbDiameter * 0.5
        let maxCenterX = bounds.width - thumbHorizontalInset - thumbDiameter * 0.5
        let usableWidth = max(1, maxCenterX - minCenterX)
        let progress = min(1, max(0, (clampedThumbCenterX(for: x) - minCenterX) / usableWidth))
        let maxIndex = max(values.count - 1, 0)
        let index = min(maxIndex, max(0, Int((progress * CGFloat(maxIndex)).rounded())))
        return values[index]
    }

    /// 根据档位值计算滑块中心点 x 坐标。
    func thumbCenterX(for value: Int) -> CGFloat {
        let maxIndex = max(values.count - 1, 1)
        let index = values.firstIndex(of: value) ?? 0
        let progress = CGFloat(index) / CGFloat(maxIndex)
        return thumbHorizontalInset + thumbDiameter * 0.5 + progress * max(1, bounds.width - thumbDiameter - thumbHorizontalInset * 2)
    }

    /// 将手指横向坐标限制在滑块可移动范围内。
    func clampedThumbCenterX(for x: CGFloat) -> CGFloat {
        let minCenterX = thumbHorizontalInset + thumbDiameter * 0.5
        let maxCenterX = bounds.width - thumbHorizontalInset - thumbDiameter * 0.5
        return min(maxCenterX, max(minCenterX, x))
    }

    /// 根据档位值计算灰色圆点中心点 x 坐标。
    func dotCenterX(for value: Int) -> CGFloat {
        let maxIndex = max(values.count - 1, 1)
        let index = values.firstIndex(of: value) ?? 0
        let progress = CGFloat(index) / CGFloat(maxIndex)
        return dotHorizontalInset + progress * max(1, bounds.width - dotHorizontalInset * 2)
    }

    /// 刷新轨道、进度条、圆点和滑块的 frame。
    func updateLayout(animated: Bool) {
        let trackFrame = CGRect(x: 0,
                                y: (bounds.height - trackHeight) * 0.5,
                                width: bounds.width,
                                height: trackHeight)
        let thumbCenterX = trackingThumbCenterX ?? thumbCenterX(for: selectedValue)
        let progressGap = kFitWidth(3)
        let thumbFrame = CGRect(x: thumbCenterX - self.thumbDiameter * 0.5,
                                y: (bounds.height - self.thumbDiameter) * 0.5,
                                width: self.thumbDiameter,
                                height: self.thumbDiameter)
        let progressMaxX = thumbFrame.maxX
        let progressWidth = max(0, progressMaxX - progressGap)
        let changes = {
            self.trackView.frame = trackFrame
            self.trackView.layer.cornerRadius = self.trackHeight * 0.5
            self.progressView.isHidden = false
            self.progressView.frame = CGRect(x: progressGap,
                                             y: progressGap,
                                             width: progressWidth,
                                             height: self.trackHeight - progressGap * 2)
            self.progressView.layer.cornerRadius = (self.trackHeight - progressGap * 2) * 0.5

            let dotDiameter = kFitWidth(8)
            let dotValues = Array(self.values.dropFirst())
            for (index, value) in dotValues.enumerated() where index < self.dotViews.count {
                let dotX = self.dotCenterX(for: value) - dotDiameter * 0.5
                self.dotViews[index].frame = CGRect(x: dotX,
                                                    y: (self.trackHeight - dotDiameter) * 0.5,
                                                    width: dotDiameter,
                                                    height: dotDiameter)
                self.dotViews[index].layer.cornerRadius = dotDiameter * 0.5
                self.dotViews[index].alpha = 1
            }

            self.thumbView.frame = thumbFrame
            self.thumbView.layer.cornerRadius = self.thumbDiameter * 0.5
        }

        if animated {
            UIView.animate(withDuration: 0.22,
                           delay: 0,
                           usingSpringWithDamping: 0.86,
                           initialSpringVelocity: 0.15,
                           options: [.curveEaseOut, .allowUserInteraction],
                           animations: changes)
        } else {
            changes()
        }
    }
}
