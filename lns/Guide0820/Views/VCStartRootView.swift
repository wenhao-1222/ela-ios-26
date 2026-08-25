//
//  VCStartRootView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// “让我们开始吧”页面根视图。
final class VCStartRootView: UIView {
    /// 页面视图模型。
    private let vm: VCStartVM
    /// 点击开始按钮回调。
    private let onStart: () -> Void
    /// 标题标签。
    private let titleLabel = UILabel()
    /// 副标题标签。
    private let subtitleLabel = UILabel()
    /// 步骤列表容器。
    private let stepsContainerView = UIView()
    /// 底部开始按钮。
    private lazy var startButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: onStart)

    /// 创建开始页根视图。
    /// - Parameters:
    ///   - vm: 页面视图模型。
    ///   - onStart: 点击开始按钮回调。
    init(vm: VCStartVM, onStart: @escaping () -> Void) {
        self.vm = vm
        self.onStart = onStart
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 刷新步骤状态。
    func reloadSteps() {
        stepsContainerView.subviews.forEach { $0.removeFromSuperview() }
        stepsContainerView.snp.updateConstraints { make in
            make.height.equalTo(stepsContainerHeight())
        }
        buildStepRows()
    }
}

private extension VCStartRootView {
    /// 初始化页面布局。
    func initUI() {
        backgroundColor = .COLOR_BG_F2

        titleLabel.text = vm.title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(24), weight: .medium)
        titleLabel.guide0820SetLineHeight(kFitWidth(36))

        subtitleLabel.text = vm.subtitle
        subtitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        subtitleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.guide0820SetLineHeight(kFitWidth(21))

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(stepsContainerView)
        addSubview(startButton)

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalToSuperview().offset(kFitWidth(165.5))
            make.height.equalTo(kFitWidth(36))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.right.equalTo(kFitWidth(-32))
            make.height.equalTo(kFitWidth(21))
        }

        stepsContainerView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(40))
            make.top.equalToSuperview().offset(kFitWidth(273.5))
            make.width.equalTo(kFitWidth(295))
            make.height.equalTo(stepsContainerHeight())
        }

        startButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview().offset(-max(WHUtils().getBottomSafeAreaHeight(), kFitWidth(26)))
        }

        buildStepRows()
    }

    /// 创建步骤行。
    func buildStepRows() {
        var previousRow: VCStartStepRow?
        let steps = vm.steps
        let activeIndex = steps.firstIndex { $0.isActive } ?? 0
        steps.enumerated().forEach { index, step in
            let row = VCStartStepRow(vm: step, showsBottomLine: index < steps.count - 1)
            stepsContainerView.addSubview(row)
            row.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                if let previousRow = previousRow {
                    make.top.equalTo(previousRow.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                make.height.equalTo(rowHeight(index: index, activeIndex: activeIndex, totalCount: steps.count))
                if index == steps.count - 1 {
                    make.bottom.lessThanOrEqualToSuperview()
                }
            }
            previousRow = row
        }
    }

    /// 当前步骤列表总高度。
    func stepsContainerHeight() -> CGFloat {
        let steps = vm.steps
        let activeIndex = steps.firstIndex { $0.isActive } ?? 0
        return steps.indices.reduce(0) { $0 + rowHeight(index: $1, activeIndex: activeIndex, totalCount: steps.count) }
    }

    /// 单行步骤高度。
    func rowHeight(index: Int, activeIndex: Int, totalCount: Int) -> CGFloat {
        if index == activeIndex {
            return kFitWidth(105.5)
        } else if index < totalCount - 1 {
            return kFitWidth(64)
        } else {
            return kFitWidth(34)
        }
    }
}
