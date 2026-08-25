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

    /// 底部分割线。
    private let separator = UIView()

    /// 弹窗高度约束，展示前按内容重新计算。
    private var cardHeightConstraint: Constraint?

    /// 弹窗可用最大高度。
    private var availableCardHeight: CGFloat {
        let topInset = WHUtils().getNavigationBarHeight() + guide0820Design(24)
        let bottomInset = max(WHUtils().getBottomSafeAreaHeight(), guide0820Design(24))
        return SCREEN_HEIGHT - topInset - bottomInset
    }

    /// 标题、按钮和边距占用的固定高度。
    private var fixedLayoutHeight: CGFloat {
        guide0820Design(177)
    }

    /// 正文内容测量宽度。
    private var bodyContentWidth: CGFloat {
        SCREEN_WIDHT - guide0820Design(110) - guide0820Design(80)
    }

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
        updateCardLayout()
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
            make.centerY.equalToSuperview().priority(750)
            make.top.greaterThanOrEqualToSuperview().offset(WHUtils().getNavigationBarHeight() + guide0820Design(24))
            make.bottom.lessThanOrEqualToSuperview().offset(-max(WHUtils().getBottomSafeAreaHeight(), guide0820Design(24)))
            cardHeightConstraint = make.height.equalTo(availableCardHeight).constraint
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

        separator.backgroundColor = .COLOR_LINE_F0
        cardView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top)
            make.height.equalTo(guide0820Design(1))
        }

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.contentInsetAdjustmentBehavior = .never
        cardView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(guide0820Design(40))
            make.bottom.equalTo(separator.snp.top).offset(guide0820Design(-40))
        }

        contentStack.axis = .vertical
        contentStack.spacing = guide0820Design(40)
        scrollView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(UIEdgeInsets(top: 0,
                                                                                 left: guide0820Design(40),
                                                                                 bottom: 0,
                                                                                 right: guide0820Design(40)))
            make.width.equalTo(scrollView.frameLayoutGuide).offset(guide0820Design(-80))
        }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(36), weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = bodyContentWidth
        contentStack.addArrangedSubview(titleLabel)

        bodyItems.forEach { item in
            if let heading = item.0 {
                let headingLabel = UILabel()
                headingLabel.text = heading
                headingLabel.textColor = .COLOR_TEXT_TITLE_0f1214
                headingLabel.font = .systemFont(ofSize: guide0820Design(28), weight: .medium)
                headingLabel.numberOfLines = 0
                headingLabel.preferredMaxLayoutWidth = bodyContentWidth
                headingLabel.setLineHeight(textString: heading, lineHeight: guide0820Design(40))
                contentStack.addArrangedSubview(headingLabel)
            }

            let bodyLabel = UILabel()
            bodyLabel.text = item.1
            bodyLabel.textColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.5)
            bodyLabel.font = .systemFont(ofSize: guide0820Design(28), weight: .regular)
            bodyLabel.numberOfLines = 0
            bodyLabel.preferredMaxLayoutWidth = bodyContentWidth
            bodyLabel.setLineHeight(textString: item.1, lineHeight: guide0820Design(42))
            contentStack.addArrangedSubview(bodyLabel)
        }

        if let references {
            let referencesLabel = UILabel()
            referencesLabel.text = references
            referencesLabel.textColor = .COLOR_TEXT_TITLE_0f1214.withAlphaComponent(0.5)
            referencesLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
            referencesLabel.numberOfLines = 0
            referencesLabel.preferredMaxLayoutWidth = bodyContentWidth
            referencesLabel.setLineHeight(textString: references, lineHeight: guide0820Design(36))
            contentStack.addArrangedSubview(referencesLabel)
        }

        updateCardLayout()
    }

    /// 按内容高度更新弹窗高度，短文案自适应，长文案限制高度后滚动。
    private func updateCardLayout() {
        let contentHeight = measuredContentHeight()
        let maxScrollHeight = max(0, availableCardHeight - fixedLayoutHeight)
        let contentFits = contentHeight <= maxScrollHeight
        let targetHeight = min(availableCardHeight, fixedLayoutHeight + contentHeight)

        scrollView.isScrollEnabled = !contentFits
        scrollView.bounces = !contentFits
        scrollView.alwaysBounceVertical = !contentFits
        cardHeightConstraint?.update(offset: targetHeight)
        layoutIfNeeded()
    }

    /// 使用 Auto Layout 测量正文栈高度。
    private func measuredContentHeight() -> CGFloat {
        let targetSize = CGSize(width: bodyContentWidth, height: UIView.layoutFittingCompressedSize.height)
        let measuredSize = contentStack.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return ceil(measuredSize.height)
    }

    /// 处理确认按钮点击并关闭弹窗。
    @objc private func confirmButtonAction() {
        dismiss()
    }
}
