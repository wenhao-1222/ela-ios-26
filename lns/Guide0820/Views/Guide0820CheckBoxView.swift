//
//  Guide0820CheckBoxView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

/// 删除确认面板使用的勾选框。
final class Guide0820CheckBoxView: UIControl {
    /// 当前是否已选中。
    private(set) var isChecked = false
    /// 勾选图标视图。
    private let checkImageView = UIImageView()

    /// 创建勾选框。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 更新勾选状态。
    /// - Parameters:
    ///   - checked: 是否选中。
    ///   - animated: 是否执行动画。
    func setChecked(_ checked: Bool, animated: Bool) {
        isChecked = checked
        checkImageView.setImgLocal(imgName: checked ? "guide0820_checkbox_selected_icon" : "guide0820_checkbox_normal_icon")
        guard animated else { return }
        transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        UIView.animate(withDuration: 0.18) {
            self.transform = .identity
        }
    }
}

// Guide0820CheckBoxView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820CheckBoxView {
    /// 初始化勾选框样式。
    func initUI() {
        clipsToBounds = true

        checkImageView.contentMode = .scaleAspectFit
        addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setChecked(false, animated: false)
    }
}
