//
//  Guide0820ProfessionalBasisView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820 专业依据页。
final class Guide0820ProfessionalBasisView: UIView {
    /// 专业依据页视图模型。
    private let vm: Guide0820ProfessionalBasisVM
    /// 下一步回调。
    private let onNext: () -> Void
    /// 专业依据内容视图。
    private lazy var contentView = Guide0820ProfessionalBasisUIKitVM(frame: .zero)
    /// 主按钮。
    private lazy var primaryButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: onNext)

    /// 创建专业依据页。
    /// - Parameters:
    ///   - vm: 专业依据页视图模型。
    ///   - onNext: 下一步回调。
    init(vm: Guide0820ProfessionalBasisVM,
         onNext: @escaping () -> Void) {
        self.vm = vm
        self.onNext = onNext
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 停止内容滚动。
    deinit {
        contentView.stopScrollers()
    }

    /// 设置页面是否处于展示态。
    /// - Parameter isActive: 是否正在展示。
    func setActive(_ isActive: Bool) {
        if isActive {
            contentView.startScrollersIfNeeded()
        } else {
            contentView.stopScrollers()
        }
    }
}

// Guide0820ProfessionalBasisView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820ProfessionalBasisView {
    /// 初始化页面布局。
    func initUI() {
        backgroundColor = .COLOR_BG_WHITE

        addSubview(contentView)
        addSubview(primaryButton)

        updateBarrierContent()
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        primaryButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(32))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview().offset(-max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(26)))
        }
    }

    /// 更新复用内容文案。
    func updateBarrierContent() {
        contentView.titleLabel.text = "建立在专业依据之上"
        contentView.zhunayeLabel.text = "与传奇运动员和营养师合作\n将专业经验融入 ELA"
        contentView.zhunayeLabel.font = .systemFont(ofSize: 11, weight: .regular)
        contentView.zhunayeLabel.guide0820SetLineHeight(kFitWidth(18))
        contentView.jijianLabel.text = "结合美国农业部 USDA 等权威\n数据库 让记录与分析更有依据"
        contentView.jijianLabel.font = .systemFont(ofSize: 11, weight: .regular)
        contentView.jijianLabel.guide0820SetLineHeight(kFitWidth(18))
    }
}
