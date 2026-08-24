//
//  Guide0820PrimaryButton.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

/// Guide0820 模块通用主按钮。
final class Guide0820PrimaryButton: UIButton {
    /// 点击按钮回调。
    private let tapActionBlock: () -> Void

    /// 创建主按钮。
    /// - Parameters:
    ///   - title: 按钮标题。
    ///   - action: 点击按钮回调。
    init(title: String, action: @escaping () -> Void) {
        self.tapActionBlock = action
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        initUI()
        enablePressEffect()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820PrimaryButton {
    /// 初始化按钮样式。
    func initUI() {
        backgroundColor = .THEME
        setTitleColor(.white, for: .normal)
        tintColor = .white
        imageView?.contentMode = .scaleAspectFit
        titleLabel?.font = .systemFont(ofSize: kFitWidth(17), weight: .medium)
        layer.cornerRadius = kFitWidth(12)
        clipsToBounds = true
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }

    /// 处理点击事件。
    @objc func tapAction() {
        tapActionBlock()
    }
}
