//
//  Guide0820InviteSourceSheetView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// “你怎么知道我们的？”邀请码输入弹层视图。
final class Guide0820InviteSourceSheetView: UIView {
    /// 输入弹层状态。
    private let vm: Guide0820InviteSourceInputVM
    /// 关闭弹层回调。
    private let onClose: () -> Void
    /// 文本输入框。
    private let textField = UITextField()
    /// 错误提示容器。
    private let errorView = UIView()
    /// 确认按钮。
    private lazy var confirmButton = Guide0820PrimaryButton(title: vm.buttonTitle, action: confirmAction)

    /// 创建邀请码输入弹层。
    /// - Parameters:
    ///   - vm: 输入弹层状态。
    ///   - onClose: 关闭弹层回调。
    init(vm: Guide0820InviteSourceInputVM,
         onClose: @escaping () -> Void) {
        self.vm = vm
        self.onClose = onClose
        super.init(frame: .zero)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 激活输入框并拉起键盘。
    func focusInput() {
        textField.becomeFirstResponder()
    }
}

private extension Guide0820InviteSourceSheetView {
    /// 初始化面板结构。
    func initUI() {
        backgroundColor = .COLOR_BG_WHITE

        let headerView = Guide0820SheetHeaderView(title: vm.title, onClose: onClose)
        let separator = UIView()
        separator.backgroundColor = UIColor.COLOR_BG_F2
        let fieldTitleLabel = UILabel()
        fieldTitleLabel.text = vm.fieldTitle
        fieldTitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        fieldTitleLabel.font = .systemFont(ofSize: kFitWidth(14), weight: .medium)

        textField.backgroundColor = UIColor.COLOR_BG_F2
        textField.layer.cornerRadius = kFitWidth(12)
        textField.clipsToBounds = true
        textField.textColor = .COLOR_TEXT_TITLE_0f1214
        textField.font = .systemFont(ofSize: kFitWidth(14), weight: .regular)
        textField.placeholder = vm.placeholder
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: kFitWidth(16), height: 1))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)

        makeErrorView()
        errorView.isHidden = true
        updateConfirmButton()

        addSubview(headerView)
        addSubview(separator)
        addSubview(fieldTitleLabel)
        addSubview(textField)
        addSubview(errorView)
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

        fieldTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(separator.snp.bottom).offset(kFitWidth(20))
        }

        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.top.equalTo(fieldTitleLabel.snp.bottom).offset(kFitWidth(20))
            make.height.equalTo(kFitWidth(44))
        }

        errorView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(textField.snp.bottom).offset(kFitWidth(10))
            make.height.equalTo(kFitWidth(14))
        }

        confirmButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(kFitWidth(16))
            make.height.equalTo(kFitWidth(52))
            make.bottom.equalToSuperview().offset(kFitWidth(-34))
        }
    }

    /// 创建错误提示行。
    func makeErrorView() {
        let iconView = UIImageView()
        iconView.image = UIImage(named: "guide0820_error_icon")

        let label = UILabel()
        label.text = vm.errorText
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: kFitWidth(11), weight: .regular)

        errorView.addSubview(iconView)
        errorView.addSubview(label)
        iconView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(14))
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(kFitWidth(4.5))
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    /// 同步确认按钮可用状态。
    func updateConfirmButton() {
        let hasInput = vm.invitationCode.isEmpty == false
        confirmButton.backgroundColor = hasInput ? .THEME : UIColor(hex: "#C4C4C4")
    }

    /// 展示错误状态。
    func showErrorState() {
        errorView.isHidden = false
        textField.layer.borderWidth = kFitWidth(1)
        textField.layer.borderColor = UIColor.systemRed.cgColor
        textField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.06)
    }

    /// 展示提交成功状态。
    func showSuccessState() {
        errorView.isHidden = true
        textField.layer.borderWidth = 0
        textField.backgroundColor = UIColor.COLOR_BG_F2
        confirmButton.setTitle(nil, for: .normal)
        confirmButton.setImage(UIImage(named: "guide0820_button_check_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        confirmButton.tintColor = .white
    }

    /// 输入内容变化时更新 VM。
    @objc func textFieldEditingChanged() {
        vm.updateInvitationCode(textField.text)
        updateConfirmButton()
    }

    /// 当前版本不接入业务逻辑，仅在本地切换成功/错误页面状态。
    func confirmAction() {
        vm.updateInvitationCode(textField.text)
        if vm.invitationCode.isEmpty {
            showErrorState()
        } else {
            showSuccessState()
        }
    }
}
