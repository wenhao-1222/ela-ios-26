//
//  Guide0820BodyProfileInfoCard.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 身体资料页通用说明卡，包含信息图标、标题和简短说明。
final class Guide0820BodyProfileInfoCard: UIControl {
    /// 左侧信息图标。
    private let iconView = UIImageView()

    /// 说明卡标题。
    private let titleLabel = UILabel()

    /// 说明卡摘要文案。
    private let detailLabel = UILabel()

    /// 使用标题和摘要初始化说明卡。
    init(title: String, detail: String) {
        super.init(frame: .zero)
        initUI(title: title, detail: detail)
    }

    /// Storyboard 初始化入口，本控件不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 按 MasterGo 设计稿创建说明卡内部视图和约束。
    private func initUI(title: String, detail: String) {
        backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.05)
        layer.cornerRadius = guide0820Design(24)
        layer.cornerCurve = .continuous
        clipsToBounds = true

        iconView.setImgLocal(imgName: "guide0820_info_icon")
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)

        detailLabel.text = detail
        detailLabel.textColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.5)
        detailLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        detailLabel.numberOfLines = 2
        detailLabel.guide0820SetLineHeight(guide0820Design(36))

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(detailLabel)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(guide0820Design(40))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(guide0820Design(34))
            make.top.equalTo(guide0820Design(32))
            make.right.equalTo(guide0820Design(-42))
        }

        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(6))
        }
    }
}
