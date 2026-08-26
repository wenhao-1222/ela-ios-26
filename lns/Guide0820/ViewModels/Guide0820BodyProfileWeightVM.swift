//
//  Guide0820BodyProfileWeightVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 当前体重页 VM，负责横向体重刻度尺、体重展示和说明卡。
final class Guide0820BodyProfileWeightVM: Guide0820BodyProfilePageVM {
    /// 点击说明卡时通知外层 VC 展示弹窗。
    var showTipsBlock: (() -> Void)?

    /// 体重变化回调，用于后续页面同步当前体重。
    var weightChangedBlock: ((Double) -> Void)?

    /// 当前体重值，单位为公斤。
    private var currentWeight = 60.0

    /// 当前体重值，单位为公斤。
    var currentWeightValue: Double { currentWeight }

    /// 应用性别页提供的默认体重。
    func applyDefaultWeight(integer: Int, decimal: Int = 0) {
        let value = Double(integer) + Double(decimal) / 10.0
        updateWeight(min(max(value, 30), 300))
        rulerView.setValue(currentWeight, animated: false, notifies: false)
    }

    /// 体重页使用默认体重值初始化，进入页面后即可继续下一步。
    override var isStepValid: Bool { true }

    /// 顶部显示当前体重的富文本 Label。
    private let valueLabel = UILabel()

    /// 按当前 MasterGo 图层重绘的横向体重刻度尺。
    private let rulerView = Guide0820WeightRulerView()

    /// 初始化并搭建页面 UI。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 将当前体重写入问卷模型。
    override func commitCurrentValue() {
        Guide0820Model.shared.weight = String(format: "%.1f", currentWeight)
    }

    /// 恢复本地保存的体重。
    func restore(weight: Double?) {
        guard let weight else { return }
        let safeWeight = min(max(weight, 30), 300)
        updateWeight(safeWeight)
        DispatchQueue.main.async { [weak self] in
            self?.rulerView.setValue(safeWeight, animated: false, notifies: false)
        }
    }

    /// 按 MasterGo 设计稿创建标题、体重值、刻度尺和说明卡。
    private func initUI() {
        let titleLabel = makeTitleLabel("你现在的体重是？")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        valueLabel.textAlignment = .center
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(guide0820Design(612))
        }

        rulerView.minValue = 30
        rulerView.maxValue = 300
        rulerView.stepValue = 0.1
        rulerView.onValueChanged = { [weak self] value in
            self?.updateWeight(value)
        }
        addSubview(rulerView)
        rulerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(47))
            make.top.equalTo(guide0820Design(782))
            make.height.equalTo(guide0820Design(170))
        }

        let infoCard = Guide0820BodyProfileInfoCard(
            title: "什么时候称更准？",
            detail: "建议固定在早上起床排空后、进食饮水前称重。食物、水分和排便情况都会让体重短期波动..."
        )
        infoCard.addTarget(self, action: #selector(infoCardAction), for: .touchUpInside)
        addSubview(infoCard)
        infoCard.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(guide0820Design(976))
            make.height.equalTo(guide0820Design(178))
        }

        updateWeight(currentWeight)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.rulerView.setValue(self.currentWeight, animated: false, notifies: false)
        }
    }

    /// 更新体重富文本、提交模型并通知外部当前体重变化。
    private func updateWeight(_ value: Double) {
        currentWeight = value
        let text = NSMutableAttributedString(string: String(format: "%.1f", value))
        text.addAttributes([
            .foregroundColor: UIColor.THEME,
            .font: UIFont().DDInFontMedium(fontSize: guide0820Design(80))
        ], range: NSRange(location: 0, length: text.length))
        let unit = NSAttributedString(
            string: " 公斤",
            attributes: [
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .font: UIFont.systemFont(ofSize: guide0820Design(24), weight: .regular)
            ]
        )
        text.append(unit)
        valueLabel.attributedText = text
        commitCurrentValue()
        weightChangedBlock?(value)
    }

    /// 处理说明卡点击。
    @objc private func infoCardAction() {
        showTipsBlock?()
    }
}

/// Guide0820 当前体重页专用横向刻度尺，尺寸按 MasterGo 选中图层换算。
private final class Guide0820WeightRulerView: UIView, UIScrollViewDelegate {
    var minValue: Double = 30 {
        didSet { rebuildRuler() }
    }

    var maxValue: Double = 300 {
        didSet { rebuildRuler() }
    }

    var stepValue: Double = 0.1 {
        didSet { rebuildRuler() }
    }

    var onValueChanged: ((Double) -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let centerLine = UIView()
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let spacing = guide0820Design(16.4)
    private var centerInset: CGFloat = 0
    private var lastSize: CGSize = .zero
    private var currentIndex = 0
    private var shouldNotifyValueChange = true

    private lazy var leftGradientView = makeGradientContainer()
    private lazy var rightGradientView = makeGradientContainer()

    private lazy var leftGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = [
            UIColor.COLOR_BG_F2.cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        return layer
    }()

    private lazy var rightGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        leftGradientLayer.colors = [
            UIColor.COLOR_BG_F2.cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        rightGradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        leftGradientLayer.frame = leftGradientView.bounds
        rightGradientLayer.frame = rightGradientView.bounds
        centerLine.frame = CGRect(x: (bounds.width - guide0820Design(8)) * 0.5,
                                  y: 0,
                                  width: guide0820Design(8),
                                  height: guide0820Design(112))
        guard bounds.size != lastSize else { return }
        lastSize = bounds.size
        rebuildRuler()
        updateOffset(index: currentIndex, animated: false)
    }

    func setValue(_ value: Double, animated: Bool, notifies: Bool = true) {
        guard valueCount > 0 else { return }
        let clamped = min(max(value, minValue), maxValue)
        let index = Int(round((clamped - minValue) / stepValue))
        currentIndex = min(max(index, 0), valueCount - 1)
        shouldNotifyValueChange = notifies
        updateOffset(index: currentIndex, animated: animated)
        emitValueIfNeeded()
        shouldNotifyValueChange = true
    }
}

private extension Guide0820WeightRulerView {
    var valueCount: Int {
        guard stepValue > 0, maxValue >= minValue else { return 0 }
        return Int(round((maxValue - minValue) / stepValue)) + 1
    }

    var majorInterval: Int {
        guard stepValue > 0 else { return 1 }
        return max(1, Int(round(1.0 / stepValue)))
    }

    func initUI() {
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        centerLine.backgroundColor = .THEME
        centerLine.layer.cornerRadius = guide0820Design(4)
        centerLine.clipsToBounds = true
        addSubview(centerLine)

        addSubview(leftGradientView)
        addSubview(rightGradientView)
        leftGradientView.layer.addSublayer(leftGradientLayer)
        rightGradientView.layer.addSublayer(rightGradientLayer)

        leftGradientView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(guide0820Design(128))
            make.height.equalTo(guide0820Design(112))
        }

        rightGradientView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(guide0820Design(128))
            make.height.equalTo(guide0820Design(112))
        }

        feedbackGenerator.prepare()
    }

    func makeGradientContainer() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }

    func rebuildRuler() {
        guard bounds.width > 0, valueCount > 0 else { return }
        contentView.subviews.forEach { $0.removeFromSuperview() }
        centerInset = bounds.width * 0.5

        let totalWidth = centerInset * 2 + CGFloat(max(valueCount - 1, 0)) * spacing
        contentView.frame = CGRect(x: 0, y: 0, width: totalWidth, height: bounds.height)
        scrollView.contentSize = contentView.bounds.size

        for index in 0..<valueCount {
            addTick(at: index)
        }
    }

    func addTick(at index: Int) {
        let x = centerInset + CGFloat(index) * spacing
        let isMajor = index % majorInterval == 0
        let tickView = UIView()
        tickView.backgroundColor = WHColor_16(colorStr: "D8D8D8")
        let tickWidth = isMajor ? guide0820Design(4) : guide0820Design(2)
        tickView.frame = CGRect(x: x - tickWidth * 0.5,
                                y: isMajor ? guide0820Design(44) : guide0820Design(68),
                                width: tickWidth,
                                height: isMajor ? guide0820Design(68) : guide0820Design(44))
        contentView.addSubview(tickView)

        guard isMajor else { return }
        let label = UILabel(frame: CGRect(x: x - guide0820Design(36),
                                          y: guide0820Design(128),
                                          width: guide0820Design(72),
                                          height: guide0820Design(42)))
        label.textAlignment = .center
        label.font = UIFont().DDInFontMedium(fontSize: guide0820Design(28))
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        let value = minValue + Double(index) * stepValue
        label.text = "\(Int(round(value)))"
        contentView.addSubview(label)
    }

    func updateOffset(index: Int, animated: Bool) {
        let targetCenterX = centerInset + CGFloat(index) * spacing
        let targetOffsetX = targetCenterX - scrollView.bounds.width * 0.5
        let maxOffsetX = max(scrollView.contentSize.width - scrollView.bounds.width, 0)
        let finalOffsetX = min(max(targetOffsetX, 0), maxOffsetX)
        scrollView.setContentOffset(CGPoint(x: finalOffsetX, y: 0), animated: animated)
        if !animated {
            updateIndexByContentOffset()
        }
    }

    func updateIndexByContentOffset() {
        guard valueCount > 0 else { return }
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width * 0.5
        let rawIndex = (centerX - centerInset) / spacing
        let index = min(max(Int(round(rawIndex)), 0), valueCount - 1)
        guard index != currentIndex else { return }
        currentIndex = index
        feedbackGenerator.selectionChanged()
        feedbackGenerator.prepare()
        emitValueIfNeeded()
    }

    func emitValueIfNeeded() {
        guard shouldNotifyValueChange else { return }
        let value = minValue + Double(currentIndex) * stepValue
        onValueChanged?(value)
    }

    func snapToCurrentIndex() {
        updateOffset(index: currentIndex, animated: true)
    }
}

private extension Guide0820WeightRulerView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateIndexByContentOffset()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToCurrentIndex()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToCurrentIndex()
    }
}
