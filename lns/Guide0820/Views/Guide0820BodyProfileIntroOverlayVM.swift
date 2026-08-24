//
//  Guide0820BodyProfileIntroOverlayVM.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit
import SnapKit

/// 身体资料页说明弹窗，负责展示背景遮罩、文本内容和确认按钮。
final class Guide0820BodyProfileIntroOverlayVM: UIView {
    /// 弹窗标题。
    private let title: String

    /// 弹窗正文条目，元组第一项为可选小标题，第二项为正文。
    private let bodyItems: [(String?, String)]

    /// 弹窗底部参考资料文案。
    private let references: String?

    /// 弹窗关闭后的回调。
    private let dismissAction: () -> Void

    /// 半透明遮罩视图。
    private let dimView = UIView()

    /// 白色弹窗容器。
    private let cardView = UIView()

    /// 弹窗正文滚动容器。
    private let scrollView = UIScrollView()

    /// 正文内容纵向栈。
    private let contentStack = UIStackView()

    /// 底部确认按钮。
    private let confirmButton = UIButton(type: .custom)

    /// 使用标题、正文、参考资料和关闭回调初始化弹窗。
    init(title: String,
         bodyItems: [(String?, String)],
         references: String? = nil,
         dismissAction: @escaping () -> Void) {
        self.title = title
        self.bodyItems = bodyItems
        self.references = references
        self.dismissAction = dismissAction
        super.init(frame: .zero)
        initUI()
        isHidden = true
    }

    /// Storyboard 初始化入口，本弹窗不支持。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 淡入展示弹窗。
    func show() {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }

    /// 淡出隐藏弹窗，并在动画结束后回调外层。
    func dismiss() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
            self.dismissAction()
        }
    }

    /// 按 MasterGo 弹窗设计稿创建遮罩、卡片、正文和按钮。
    private func initUI() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = guide0820Design(24)
        cardView.layer.cornerCurve = .continuous
        cardView.clipsToBounds = true
        addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(55))
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualTo(guide0820Design(1348))
        }

        scrollView.showsVerticalScrollIndicator = false
        cardView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(guide0820Design(-96))
        }

        contentStack.axis = .vertical
        contentStack.spacing = guide0820Design(40)
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(guide0820Design(40))
            make.width.equalToSuperview().offset(guide0820Design(-80))
        }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(36), weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        contentStack.addArrangedSubview(titleLabel)

        bodyItems.forEach { item in
            if let heading = item.0 {
                let headingLabel = UILabel()
                headingLabel.text = heading
                headingLabel.textColor = .COLOR_TEXT_TITLE_0f1214
                headingLabel.font = .systemFont(ofSize: guide0820Design(28), weight: .medium)
                headingLabel.numberOfLines = 0
                headingLabel.setLineHeight(textString: heading, lineHeight: guide0820Design(40))
                contentStack.addArrangedSubview(headingLabel)
            }

            let bodyLabel = UILabel()
            bodyLabel.text = item.1
            bodyLabel.textColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.5)
            bodyLabel.font = .systemFont(ofSize: guide0820Design(28), weight: .regular)
            bodyLabel.numberOfLines = 0
            bodyLabel.setLineHeight(textString: item.1, lineHeight: guide0820Design(42))
            contentStack.addArrangedSubview(bodyLabel)
        }

        if let references {
            let referencesLabel = UILabel()
            referencesLabel.text = references
            referencesLabel.textColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.5)
            referencesLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
            referencesLabel.numberOfLines = 0
            referencesLabel.setLineHeight(textString: references, lineHeight: guide0820Design(36))
            contentStack.addArrangedSubview(referencesLabel)
        }

        confirmButton.setTitle("我知道了", for: .normal)
        confirmButton.setTitleColor(.THEME, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: guide0820Design(32), weight: .medium)
        confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        cardView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(guide0820Design(96))
        }

        let separator = UIView()
        separator.backgroundColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.1)
        cardView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top)
            make.height.equalTo(0.5)
        }
    }

    /// 处理确认按钮点击并关闭弹窗。
    @objc private func confirmButtonAction() {
        dismiss()
    }
}
