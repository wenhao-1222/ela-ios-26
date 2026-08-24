//
//  Guide0820SourceRow.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 来源问卷选项行。
final class Guide0820SourceRow: UIControl {
    /// 当前来源选项。
    let item: Guide0820SourceVM.SourceItem
    /// 点击来源选项回调。
    private let action: (Guide0820SourceVM.SourceItem) -> Void
    /// 选中状态图标。
    private let checkImageView = UIImageView()

    /// 创建来源选项行。
    /// - Parameters:
    ///   - item: 来源选项。
    ///   - isSelected: 是否选中。
    ///   - action: 点击来源选项回调。
    init(item: Guide0820SourceVM.SourceItem,
         isSelected: Bool,
         action: @escaping (Guide0820SourceVM.SourceItem) -> Void) {
        self.item = item
        self.action = action
        super.init(frame: .zero)
        initUI(isSelected: isSelected)
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 更新选中状态。
    /// - Parameters:
    ///   - isSelected: 是否选中。
    ///   - animated: 是否执行动画。
    func setSelected(_ isSelected: Bool, animated: Bool) {
        checkImageView.setCheckState(isSelected,
                                     checkedImageName: "select_icon_selected_circle",
                                     uncheckedImageName: "select_icon_normal_circle",
                                     animated: animated)
    }
}

private extension Guide0820SourceRow {
    /// 初始化来源行布局。
    /// - Parameter isSelected: 是否选中。
    func initUI(isSelected: Bool) {
        backgroundColor = .COLOR_BG_WHITE
        layer.cornerRadius = kFitWidth(12)
        clipsToBounds = true
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)

        let iconView = UIImageView()
        iconView.setImgLocal(imgName: item.iconName)
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(16), weight: .medium)

        checkImageView.contentMode = .scaleAspectFit
        setSelected(isSelected, animated: false)

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(checkImageView)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(25))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(17))
            make.centerY.equalToSuperview()
        }

        checkImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
    }

    /// 处理来源行点击。
    @objc func tapAction() {
        action(item)
    }
}
