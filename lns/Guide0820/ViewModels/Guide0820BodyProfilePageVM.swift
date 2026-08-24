//
//  Guide0820BodyProfilePageVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

/// 身体资料引导页的 VM 基类，提供统一尺寸、校验回调和标题样式。
class Guide0820BodyProfilePageVM: UIView {
    /// 页面有效性变化回调，用于通知外层 VC 刷新下一步按钮状态。
    var validityChanged: ((Bool) -> Void)?

    /// 当前页面是否已满足进入下一步的条件。
    var isStepValid: Bool { true }

    /// 初始化页面基础 frame 和交互状态。
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
    }

    /// Storyboard 初始化入口，本页面不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 页面即将显示时的生命周期钩子，子类按需覆盖。
    func pageWillAppear() {}

    /// 将当前页面值写入问卷模型，子类按需覆盖。
    func commitCurrentValue() {}

    /// 创建符合 MasterGo 身体资料页样式的标题 Label。
    func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: guide0820Design(48), weight: .medium)
        label.setLineHeight(textString: text, lineHeight: guide0820Design(72))
        return label
    }
}
