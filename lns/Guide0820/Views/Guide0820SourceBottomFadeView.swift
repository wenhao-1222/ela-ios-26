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
}

// Guide0820SourceBottomFadeView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820SourceBottomFadeView {
    /// 初始化渐变样式。
    func initUI() {
        isUserInteractionEnabled = false
        layer.addSublayer(gradientLayer)
        gradientLayer.colors = [
            UIColor.COLOR_BG_F2.withAlphaComponent(0).cgColor,
            UIColor.COLOR_BG_F2.cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }
}
