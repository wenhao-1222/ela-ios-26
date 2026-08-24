//
//  Guide0820BottomSheetView.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// Guide0820 通用底部弹层容器。
final class Guide0820BottomSheetView: UIView {
    /// 背景遮罩视图。
    private let dimView = UIView()
    /// 白色圆角内容容器。
    private let sheetView = UIView()
    /// 外部内容挂载容器。
    let contentContainerView = UIView()
    /// 内容高度约束。
    private var heightConstraint: Constraint?
    /// 底部偏移约束。
    private var bottomConstraint: Constraint?
    /// 是否跟随键盘上移。
    private var keyboardAvoidanceEnabled = false

    /// 创建底部弹层容器。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// 不支持 storyboard 初始化。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 移除键盘通知监听。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 展示指定内容。
    /// - Parameters:
    ///   - contentView: 需要展示的内容视图。
    ///   - contentHeight: 内容高度。
    ///   - keyboardAvoidanceEnabled: 是否跟随键盘上移。
    func present(contentView: UIView, contentHeight: CGFloat, keyboardAvoidanceEnabled: Bool) {
        self.keyboardAvoidanceEnabled = keyboardAvoidanceEnabled
        setContentView(contentView)
        heightConstraint?.update(offset: contentHeight)
        bottomConstraint?.update(offset: contentHeight)
        layoutIfNeeded()

        isHidden = false
        dimView.alpha = 0
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1
            self.bottomConstraint?.update(offset: 0)
            self.layoutIfNeeded()
        }
    }

    /// 隐藏弹层。
    /// - Parameter completion: 隐藏完成回调。
    func dismiss(completion: (() -> Void)? = nil) {
        endEditing(true)
        let height = sheetView.bounds.height
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            self.dimView.alpha = 0
            self.bottomConstraint?.update(offset: max(height, kFitWidth(320)))
            self.layoutIfNeeded()
        } completion: { _ in
            self.isHidden = true
            self.contentContainerView.subviews.forEach { $0.removeFromSuperview() }
            completion?()
        }
    }

    /// 更新键盘避让能力。
    /// - Parameter enabled: 是否启用键盘避让。
    func setKeyboardAvoidanceEnabled(_ enabled: Bool) {
        keyboardAvoidanceEnabled = enabled
    }
}

private extension Guide0820BottomSheetView {
    /// 初始化容器结构。
    func initUI() {
        isHidden = true
        backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.24)
        dimView.alpha = 0
        sheetView.backgroundColor = .COLOR_BG_WHITE
        sheetView.layer.cornerRadius = kFitWidth(13)
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true

        addSubview(dimView)
        addSubview(sheetView)
        sheetView.addSubview(contentContainerView)

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sheetView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            bottomConstraint = make.bottom.equalToSuperview().offset(kFitWidth(360)).constraint
            heightConstraint = make.height.equalTo(kFitWidth(320)).constraint
        }

        contentContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dimTapAction))
        dimView.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    /// 挂载弹层内容。
    /// - Parameter contentView: 需要展示的内容视图。
    func setContentView(_ contentView: UIView) {
        contentContainerView.subviews.forEach { $0.removeFromSuperview() }
        contentContainerView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 点击遮罩关闭弹层。
    @objc func dimTapAction() {
        dismiss()
    }

    /// 键盘高度变化时更新弹层位置。
    /// - Parameter notification: 键盘通知。
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard keyboardAvoidanceEnabled,
              isHidden == false,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let convertedFrame = convert(keyboardFrame, from: nil)
        let overlap = max(0, bounds.maxY - convertedFrame.minY)
        animateWithKeyboard(notification) {
            self.bottomConstraint?.update(offset: -overlap)
            self.layoutIfNeeded()
        }
    }

    /// 键盘隐藏时让弹层回到底部。
    /// - Parameter notification: 键盘通知。
    @objc func keyboardWillHide(_ notification: Notification) {
        guard keyboardAvoidanceEnabled, isHidden == false else { return }
        animateWithKeyboard(notification) {
            self.bottomConstraint?.update(offset: 0)
            self.layoutIfNeeded()
        }
    }

    /// 按键盘动画参数执行布局动画。
    /// - Parameters:
    ///   - notification: 键盘通知。
    ///   - changes: 需要执行的布局变化。
    func animateWithKeyboard(_ notification: Notification, changes: @escaping () -> Void) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curveValue << 16),
                       animations: changes)
    }
}
