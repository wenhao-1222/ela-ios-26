//
//  GradientGlassView.swift
//  lns
//
//  Created by LNS2 on 2025/10/23.
//

import UIKit

final class GradientGlassView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let gradientMask = CAGradientLayer()

    /// 1.0 = 顶部完全显示毛玻璃；0.0 = 完全透明
    var topOpacity: CGFloat = 1.0 {
        didSet { updateMaskColors() }
    }
    var bottomOpacity: CGFloat = 0.0 {
        didSet { updateMaskColors() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // 毛玻璃层
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }        // 圆角 & 玻璃描边（可选）
//        layer.cornerRadius = 16
        layer.masksToBounds = true
//        layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
//        layer.borderWidth = 1

        // 渐变蒙版（纵向）
        gradientMask.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientMask.endPoint   = CGPoint(x: 0.5, y: 1.0)
        updateMaskColors()
        blurView.layer.mask = gradientMask
    }

    private func updateMaskColors() {
        gradientMask.colors = [
            UIColor.white.withAlphaComponent(topOpacity).cgColor,
            UIColor.white.withAlphaComponent(bottomOpacity).cgColor
        ]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
        gradientMask.frame = blurView.bounds
    }
}
