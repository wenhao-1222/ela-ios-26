//
//  Guide0820DeleteConfirmationSheetView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 清空数据确认弹层视图。
final class Guide0820DeleteConfirmationSheetView: UIView {
    /// 删除确认状态。
    private let vm: Guide0820DeleteConfirmationVM
    /// 关闭弹层回调。
    private let onClose: () -> Void
    /// 确认删除回调。
    private let onConfirm: () -> Void
    /// 确认勾选框。
    private let checkBoxView = Guide0820CheckBoxView()
    /// 确认按钮。
    private lazy var confirmButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: confirmAction)

    /// 创建清空数据确认弹层。
    /// - Parameters:
    ///   - vm: 删除确认状态。
    ///   - onClose: 关闭弹层回调。
    ///   - onConfirm: 确认删除回调。
    init(vm: Guide0820DeleteConfirmationVM,
         onClose: @escaping () -> Void,
         onConfirm: @escaping () -> Void) {
        self.vm = vm
        self.onClose = onClose
        self.onConfirm = onConfirm
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Guide0820DeleteConfirmationSheetView {
    /// 初始化面板结构。
    func initUI() {
        backgroundColor = .COLOR_BG_WHITE

        let headerView = Guide0820SheetHeaderView(title: vm.title, onClose: onClose)
        let separator = UIView()
        separator.backgroundColor = UIColor.COLOR_BG_F2
        let titleLabel = UILabel()
        titleLabel.text = vm.messageTitle
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.guide0820SetLineHeight(kFitWidth(21))

        let bodyLabel = UILabel()
        bodyLabel.text = vm.messageBody
        bodyLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        bodyLabel.font = .systemFont(ofSize: kFitWidth(12), weight: .regular)
        bodyLabel.numberOfLines = 0
        bodyLabel.guide0820SetLineHeight(kFitWidth(18))

        checkBoxView.addTarget(self, action: #selector(checkBoxTapAction), for: .touchUpInside)
        updateConfirmButton()

        addSubview(headerView)
        addSubview(separator)
        addSubview(titleLabel)
        addSubview(bodyLabel)
        addSubview(checkBoxView)
        addSubview(confirmButton)

        headerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54.5))
        }

        separator.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(kFitWidth(4))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(checkBoxView.snp.left).offset(kFitWidth(-18))
            make.top.equalTo(separator.snp.bottom).offset(kFitWidth(20))
        }

        bodyLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(7))
        }

        checkBoxView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(separator.snp.bottom).offset(kFitWidth(37))
            make.width.height.equalTo(kFitWidth(24))
        }

        confirmButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview().offset(kFitWidth(-34))
        }
    }

    /// 同步确认按钮状态。
    func updateConfirmButton() {
        confirmButton.isEnabled = vm.isAcknowledged
        confirmButton.backgroundColor = vm.isAcknowledged ? .THEME : UIColor(hex: "#C4C4C4")
    }

    /// 切换勾选框。
    @objc func checkBoxTapAction() {
        let checked = vm.toggleAcknowledgement()
        checkBoxView.setChecked(checked, animated: true)
        updateConfirmButton()
    }

    /// 确认删除并切换为完成态。
    func confirmAction() {
        guard vm.isAcknowledged else { return }
        confirmButton.setTitle(nil, for: .normal)
        confirmButton.setImage(UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        confirmButton.tintColor = .white
        onConfirm()
    }
}
