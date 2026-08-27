//
//  Guide0820SheetHeaderView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820 底部弹层通用标题栏。
final class Guide0820SheetHeaderView: UIView {
    /// 标题文本。
    private let title: String
    /// 关闭按钮回调。
    private let onClose: () -> Void

    /// 创建弹层标题栏。
    /// - Parameters:
    ///   - title: 标题文本。
    ///   - onClose: 关闭按钮回调。
    init(title: String, onClose: @escaping () -> Void) {
        self.title = title
        self.onClose = onClose
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Guide0820SheetHeaderView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820SheetHeaderView {
    /// 初始化标题栏布局。
    func initUI() {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(17), weight: .semibold)

        let closeButton = UIButton(type: .custom)
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        let closeImageView = UIImageView(image: UIImage(named: "guide0820_close_icon"))
        closeImageView.contentMode = .scaleAspectFit
        closeImageView.isUserInteractionEnabled = false
        closeButton.addSubview(closeImageView)

        addSubview(titleLabel)
        addSubview(closeButton)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(closeButton.snp.left).offset(kFitWidth(-16))
        }

        closeButton.snp.makeConstraints { make in
//            make.right.equalTo(kFitWidth(-16))
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(52))
        }

        closeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }

    /// 处理关闭按钮点击。
    @objc func closeButtonAction() {
        onClose()
    }
}
