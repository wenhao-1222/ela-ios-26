//
//  Guide0820OperationRow.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 操作面板的一行操作视图。
final class Guide0820OperationRow: UIControl {
    /// 当前操作项配置。
    private let item: Guide0820OperationItem
    /// 点击操作项回调。
    private let action: (Guide0820OperationItem) -> Void

    /// 创建操作行。
    /// - Parameters:
    ///   - item: 操作项配置。
    ///   - action: 点击操作项回调。
    init(item: Guide0820OperationItem,
         action: @escaping (Guide0820OperationItem) -> Void) {
        self.item = item
        self.action = action
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820OperationRow {
    /// 初始化操作行样式。
    func initUI() {
        addTarget(self, action: #selector(tapAction), for: .touchUpInside)

        let iconView = UIImageView()
        iconView.setImgLocal(imgName: item.iconName)
        iconView.contentMode = .scaleAspectFit
        iconView.alpha = item.isEnabled ? 1 : 0.35

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.textColor = item.titleColor
        titleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: .medium)

        let arrowView = UIImageView()
        arrowView.image = UIImage(named: "guide0820_operation_arrow_icon")
        arrowView.contentMode = .scaleAspectFit
        arrowView.isHidden = item.showsDisclosure == false

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(arrowView)

        iconView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(17.5))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(15))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(65))
            make.centerY.equalToSuperview()
        }

        arrowView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-27.5))
            make.centerY.equalToSuperview()
            make.width.equalTo(kFitWidth(8))
            make.height.equalTo(kFitWidth(14))
        }
    }

    /// 处理点击事件。
    @objc func tapAction() {
        guard item.isEnabled else { return }
        action(item)
    }
}
