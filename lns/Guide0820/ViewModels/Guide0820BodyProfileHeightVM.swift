//
//  Guide0820BodyProfileHeightVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 身高页 VM，负责垂直刻度尺、身高数值展示和身高字段提交。
final class Guide0820BodyProfileHeightVM: Guide0820BodyProfilePageVM, rulerDelegate {
    /// 身高变化回调，用于外层实时保存当前选择。
    var heightChangedBlock: ((Int) -> Void)?

    /// 当前身高值，单位为厘米。
    var currentValue = 170

    /// 应用性别页提供的默认身高。
    func applyDefaultHeight(_ value: Int) {
        currentValue = min(max(value, 110), 240)
        updateHeightText(value: currentValue)
        commitCurrentValue()
        if hasAppliedInitialValue {
            rulerView.scroll(toValue: currentValue, animation: false)
        }
    }

    /// 标记初始身高是否已同步到刻度尺，避免约束未完成时滚动失效。
    private var hasAppliedInitialValue = false

    /// 左侧显示当前身高的富文本 Label。
    private let numberLabel = UILabel()

    /// 项目内已有的垂直刻度尺控件。
    private lazy var rulerView: TTScrollRulerView = {
        let view = TTScrollRulerView(frame: CGRect(x: kFitWidth(183), y: 0, width: kFitWidth(200), height: kFitWidth(420)))
        view.backgroundColor = .clear
        view.rulerBackgroundColor = .clear
        return view
    }()

    /// 刻度变化时的轻触反馈。
    private let feedbackGenerator = UISelectionFeedbackGenerator()

    /// DietPlan 身高尺每一刻度对应的滚动距离。
    private let rulerStepHeight = kFitWidth(7)

    /// 缓存刻度尺内部的 ScrollView，用于代理拖拽。
    private var linkedRulerScrollView: UIScrollView?

    /// 覆盖数值左侧区域的透明拖拽层，让用户在数值区域也能滑动刻度尺。
    private lazy var rulerPanProxyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleProxyPan(_:)))
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        return view
    }()

    /// 刻度尺顶部渐隐遮罩。
    private lazy var topMaskView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    /// 刻度尺顶部渐隐 Layer。
    private lazy var topMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        return layer
    }()

    /// 刻度尺底部渐隐遮罩。
    private lazy var bottomMaskView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

    /// 刻度尺底部渐隐 Layer。
    private lazy var bottomMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        return layer
    }()

    /// 初始化并搭建页面 UI。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateHeightText(value: currentValue)
        topMaskLayer.colors = [
            UIColor.COLOR_BG_F2.cgColor,
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor
        ]
        bottomMaskLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
    }

    /// 将当前身高写入问卷模型。
    override func commitCurrentValue() {
        Guide0820Model.shared.height = "\(currentValue)"
    }

    /// 恢复本地保存的身高。
    func restore(height: Int?) {
        guard let height else { return }
        currentValue = min(max(height, 110), 240)
        updateHeightText(value: currentValue)
        Guide0820Model.shared.height = "\(currentValue)"
        if hasAppliedInitialValue {
            rulerView.scroll(toValue: currentValue, animation: false)
        }
    }

    /// 按 MasterGo 设计稿创建标题、数值和刻度尺。
    private func initUI() {
        let titleLabel = makeTitleLabel("你的身高是？")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(262))
        }

        addSubview(rulerPanProxyView)
        addSubview(rulerView)
        addSubview(topMaskView)
        addSubview(bottomMaskView)
        topMaskView.layer.addSublayer(topMaskLayer)
        bottomMaskView.layer.addSublayer(bottomMaskLayer)

        numberLabel.textAlignment = .right
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.right.lessThanOrEqualTo(rulerView.snp.left).offset(kFitWidth(-30))
            make.centerY.equalTo(rulerView)
        }

        rulerView.rulerDelegate = self
        rulerView.rulerDirection = .vertical
        rulerView.rulerFace = .down_right
        rulerView.lockMax = 240
        rulerView.lockMin = 110
        rulerView.lockDefault = rulerView.lockMax + rulerView.lockMin - currentValue
        rulerView.pointerBackgroundColor = .THEME
        rulerView.h_height = Float(kFitWidth(36))
        rulerView.m_height = Float(kFitWidth(24))
        rulerView.customRuler(with: customColorMake(217.0 / 255.0, 217.0 / 255.0, 217.0 / 255.0),
                              numColor: .COLOR_TEXT_TITLE_0f1214_20,
                              scrollEnable: true)
        rulerView.unitValue = 1
        rulerView.classicRuler()
        rulerView.scroll(toValue: currentValue, animation: false)

        rulerPanProxyView.snp.makeConstraints { make in
            make.top.bottom.equalTo(rulerView)
            make.left.equalToSuperview()
            make.right.equalTo(rulerView.snp.left)
        }

        rulerView.snp.makeConstraints { make in
            make.left.equalTo(SCREEN_WIDHT * 0.5)
            make.top.equalTo(guide0820Design(440))
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(420))
        }

        topMaskView.snp.makeConstraints { make in
            make.top.equalTo(rulerView.snp.top)
            make.left.equalTo(rulerView.snp.left)
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(128))
        }

        bottomMaskView.snp.makeConstraints { make in
            make.bottom.equalTo(rulerView.snp.bottom)
            make.left.equalTo(rulerView.snp.left)
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(128))
        }

        updateHeightText(value: currentValue)
        commitCurrentValue()
        feedbackGenerator.prepare()
    }

    /// 更新身高富文本，包含蓝色数字和黑色单位。
    private func updateHeightText(value: Int) {
        let text = NSMutableAttributedString(string: "\(value)")
        text.addAttributes([
            .foregroundColor: UIColor.THEME,
            .font: UIFont().DDInFontMedium(fontSize: guide0820Design(80))
        ], range: NSRange(location: 0, length: text.length))
        let unit = NSAttributedString(
            string: " 厘米",
            attributes: [
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .font: UIFont.systemFont(ofSize: guide0820Design(24), weight: .regular)
            ]
        )
        text.append(unit)
        numberLabel.attributedText = text
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topMaskLayer.frame = topMaskView.bounds
        bottomMaskLayer.frame = bottomMaskView.bounds
        linkedRulerScrollView = resolveRulerScrollView()
        if !hasAppliedInitialValue {
            hasAppliedInitialValue = true
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.rulerView.scroll(toValue: self.currentValue, animation: false)
                self.commitCurrentValue()
                self.updateHeightText(value: self.currentValue)
            }
        }
    }

    private func resolveRulerScrollView() -> UIScrollView? {
        if let linkedRulerScrollView {
            return linkedRulerScrollView
        }
        return rulerView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }

    private func clampRulerOffset(_ offsetY: CGFloat, scrollView: UIScrollView) -> CGFloat {
        let minOffset = CGFloat(rulerView.lockMin / max(rulerView.unitValue, 1)) * rulerStepHeight
        let maxOffset = CGFloat(rulerView.lockMax / max(rulerView.unitValue, 1)) * rulerStepHeight
        return min(max(offsetY, minOffset), maxOffset)
    }

    @objc
    private func handleProxyPan(_ gesture: UIPanGestureRecognizer) {
        guard let scrollView = resolveRulerScrollView() else { return }

        switch gesture.state {
        case .began, .changed:
            let translation = gesture.translation(in: rulerPanProxyView)
            let targetOffsetY = clampRulerOffset(scrollView.contentOffset.y - translation.y, scrollView: scrollView)
            scrollView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: false)
            gesture.setTranslation(.zero, in: rulerPanProxyView)
        case .ended, .cancelled, .failed:
            let snappedIndex = round(scrollView.contentOffset.y / rulerStepHeight)
            let snappedOffsetY = clampRulerOffset(snappedIndex * rulerStepHeight, scrollView: scrollView)
            scrollView.setContentOffset(CGPoint(x: 0, y: snappedOffsetY), animated: true)
        default:
            break
        }
    }

    /// 接收刻度尺滚动回调，更新数值、触感和问卷模型。
    func ruler(with value: Int) {
        if currentValue != value {
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
        }
        currentValue = value
        updateHeightText(value: value)
        commitCurrentValue()
        heightChangedBlock?(value)
    }
}
