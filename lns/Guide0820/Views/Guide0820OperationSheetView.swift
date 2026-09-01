//
//  Guide0820OperationSheetView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 右上角“操作”底部面板。
final class Guide0820OperationSheetView: UIView {
    /// 操作面板状态。
    private let vm: Guide0820OperationSheetVM
    /// 关闭弹层回调。
    private let onClose: () -> Void
    /// 点击操作项回调。
    private let onSelectItem: (Guide0820OperationItem) -> Void

    /// 创建操作面板。
    /// - Parameters:
    ///   - vm: 操作面板状态。
    ///   - onClose: 关闭弹层回调。
    ///   - onSelectItem: 点击操作项回调。
    init(vm: Guide0820OperationSheetVM,
         onClose: @escaping () -> Void,
         onSelectItem: @escaping (Guide0820OperationItem) -> Void) {
        self.vm = vm
        self.onClose = onClose
        self.onSelectItem = onSelectItem
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Guide0820OperationSheetView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension Guide0820OperationSheetView {
    /// 初始化操作面板布局。
    func initUI() {
        backgroundColor = .clear

        let headerView = Guide0820SheetHeaderView(title: vm.title, onClose: onClose)
        let separator = UIView()
        separator.backgroundColor = UIColor.COLOR_BG_F2
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0

        addSubview(headerView)
        addSubview(separator)
        addSubview(stackView)

        vm.items.enumerated().forEach { index, item in
            let row = Guide0820OperationRow(item: item) { [weak self] selectedItem in
                self?.onSelectItem(selectedItem)
            }
            stackView.addArrangedSubview(row)
            row.snp.makeConstraints { make in
                make.height.equalTo(kFitWidth(65))
            }

            if index < vm.items.count - 1 {
                let separatorContainer = UIView()
                let line = UIView()
                line.backgroundColor = UIColor.COLOR_TEXT_TITLE_0f1214_05
                separatorContainer.addSubview(line)
                stackView.addArrangedSubview(separatorContainer)
                separatorContainer.snp.makeConstraints { make in
                    make.height.equalTo(0.5)
                }
                line.snp.makeConstraints { make in
                    make.left.equalTo(kFitWidth(65))
                    make.right.top.bottom.equalToSuperview()
                }
            }
        }

        headerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54.5))
        }

        separator.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(kFitWidth(4))
        }

        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(separator.snp.bottom)
        }
    }
}
