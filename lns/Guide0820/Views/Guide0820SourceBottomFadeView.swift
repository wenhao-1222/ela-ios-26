//
//  Guide0820SourceBottomFadeView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

/// 来源问卷底部渐隐遮罩。
final class Guide0820SourceBottomFadeView: UIView {
    /// 渐变图层。
    private let gradientLayer = CAGradientLayer()

    /// 创建渐隐遮罩。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 同步渐变图层尺寸。
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    /// 外观切换时刷新渐变图层中已解析的 CGColor。
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection == nil ||
                traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        updateGradientColors()
    }
}

// Guide0820SourceBottomFadeView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820SourceBottomFadeView {
    /// 初始化渐变样式。
    func initUI() {
        isUserInteractionEnabled = false
        layer.addSublayer(gradientLayer)
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        updateGradientColors()
    }

    /// 使用当前外观下的页面背景色更新底部渐隐。
    func updateGradientColors() {
        let backgroundColor = UIColor.COLOR_BG_F2.resolvedColor(with: traitCollection)
        gradientLayer.colors = [
            backgroundColor.withAlphaComponent(0).cgColor,
            backgroundColor.cgColor
        ]
    }
}
