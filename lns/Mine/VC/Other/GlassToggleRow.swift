//
//  GlassToggleRow.swift
//  lns
//
//  Created by Elavatine on 2025/9/5.
//

import UIKit

final class GlassToggleRow: UIView {
    let label = UILabel()
    let toggle = UISwitch()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 毛玻璃背景
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // 圆角 + 轻描边，营造“玻璃边缘”
        layer.cornerRadius = 14
        layer.masksToBounds = true
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        // 左侧说明文案
        label.text = "轻按可调整变焦、曝光等"
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false

        // 右侧系统开关
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = UIColor.systemGreen // ON 轨道色
        // 如需改变 OFF 态轮廓，可视需要设置：toggle.tintColor = .tertiaryLabel
        // 如需改变拇指色：toggle.thumbTintColor = .white

        addSubview(label)
        addSubview(toggle)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            toggle.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 12),
            toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            toggle.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
