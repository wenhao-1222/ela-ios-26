//
//  Guide0820AgreementRow.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 隐私页协议列表行。
final class Guide0820AgreementRow: UIControl {
    /// 点击协议行回调。
    private let action: () -> Void

    /// 创建协议行。
    /// - Parameters:
    ///   - item: 协议配置。
    ///   - action: 点击协议行回调。
    init(item: Guide0820PrivacyVM.AgreementItem, action: @escaping () -> Void) {
        self.action = action
        super.init(frame: .zero)
        initUI(item: item)
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820AgreementRow {
    /// 初始化协议行样式。
    /// - Parameter item: 协议配置。
    func initUI(item: Guide0820PrivacyVM.AgreementItem) {
        backgroundColor = .clear
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)

        let iconView = UIImageView()
        iconView.setImgLocal(imgName: item.iconName)
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: .regular)

        let arrowView = UIImageView()
        arrowView.setImgLocal(imgName: "plan_arrow_gray")
        arrowView.contentMode = .scaleAspectFit

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(arrowView)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12.5))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(16))
            make.centerY.equalToSuperview()
        }

        arrowView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }

    /// 处理点击事件。
    @objc func tapAction() {
        action()
    }
}
