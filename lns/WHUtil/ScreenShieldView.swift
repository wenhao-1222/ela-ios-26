//
//  ScreenShieldView.swift
//  lns
//
//  Created by Elavatine on 2025/8/1.
//

import UIKit

/// 一个可重用的安全容器，内部利用 UITextField 的 secureTextEntry 特性
final class ScreenShieldView: UIView {

    private let shieldCanvas: UIView

    /// 把待保护的 `content` 放进来
    init(content: UIView) {
        // 1. 造一个看不见的 UITextField
        let textField = UITextField()
        textField.isSecureTextEntry = true      // 关键：开启密码模式
//        textField.isHidden = true               // 不需要真正显示
        textField.translatesAutoresizingMaskIntoConstraints = false

        // 2. 系统在它下面自动生成 `_UITextFieldCanvasView`
        guard let canvas = textField.subviews.first else {
            fatalError("未找到 _UITextFieldCanvasView，可能是系统实现变更")
        }
        canvas.isUserInteractionEnabled = true  // 把事件继续向下传

        self.shieldCanvas = canvas
        super.init(frame: .zero)

        // 3. 把 textField 加到层级里（否则 canvas 会被回收）
        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 4. 把真正想显示的内容加到 canvas
        canvas.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: canvas.topAnchor),
            content.leadingAnchor.constraint(equalTo: canvas.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: canvas.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: canvas.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
