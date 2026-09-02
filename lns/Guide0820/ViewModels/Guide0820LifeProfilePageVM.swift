//
//  Guide0820LifeProfilePageVM.swift
//  lns
//
//  Created by Codex on 2026/8/25.
//

import UIKit
import SnapKit

/// Guide0820LifeProfilePageVM 类型，封装 Guide0820 引导流程中的相关功能。
class Guide0820LifeProfilePageVM: UIView {
    /// `validityChanged` 属性，保存该类型对外提供或内部使用的状态与配置。
    var validityChanged: ((Bool) -> Void)?
    /// `isStepValid` 属性，保存该类型对外提供或内部使用的状态与配置。
    var isStepValid: Bool { true }

    /// 初始化当前类型实例。
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 执行 `pageWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    func pageWillAppear() {}
    /// 执行 `commitCurrentValue` 操作，完成当前引导页面的状态更新或交互处理。
    func commitCurrentValue() {}

    /// 执行 `makeTitleLabel` 操作，完成当前引导页面的状态更新或交互处理。
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

/// Guide0820LifeProfileInfoCard 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileInfoCard: UIControl {
    // `titleText` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let titleText: String
    // `detailText` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let detailText: String

    /// 初始化当前类型实例。
    init(title: String, detail: String) {
        titleText = title
        detailText = detail
        super.init(frame: .zero)
        backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        layer.cornerRadius = guide0820Design(24)
        layer.cornerCurve = .continuous
        clipsToBounds = true
        initUI()
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    private func initUI() {
        let iconView = UIImageView()
        iconView.setImgLocal(imgName: "guide0820_info_icon")
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.top.equalTo(guide0820Design(50))
            make.width.height.equalTo(guide0820Design(40))
        }

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(guide0820Design(34))
            make.right.equalTo(guide0820Design(-42))
            make.top.equalTo(guide0820Design(32))
        }

        let detailLabel = UILabel()
        detailLabel.text = detailText
        detailLabel.numberOfLines = 2
        detailLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        detailLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        detailLabel.setLineHeight(textString: detailText, lineHeight: guide0820Design(36))
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(6))
        }
    }
}

/// Guide0820LifeProfileInfoOverlayVM 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileInfoOverlayVM: UIView {
    // `title` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let title: String
    // `body` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let body: String
    // `references` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let references: String?
    /// 半透明遮罩，仅点击弹窗外区域时触发关闭。
    private let dimView = UIView()
    /// 底部确认按钮。
    private let confirmButton = UIButton(type: .custom)

    /// 初始化当前类型实例。
    init(title: String, body: String, references: String? = nil) {
        self.title = title
        self.body = body
        self.references = references
        super.init(frame: .zero)
        backgroundColor = .clear
        isHidden = true
        alpha = 0
        initUI()
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 执行 `show` 操作，完成当前引导页面的状态更新或交互处理。
    func show() {
        isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }

    // 执行 `hideAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc private func hideAction() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
    }

    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    private func initUI() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideAction)))
        addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let panelView = UIView()
        panelView.backgroundColor = .COLOR_CARD_BG_WHITE
        panelView.layer.cornerRadius = guide0820Design(24)
        panelView.layer.cornerCurve = .continuous
        panelView.clipsToBounds = true
        addSubview(panelView)
        panelView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(55))
            make.centerY.equalToSuperview()
        }

        let contentView = UIView()
        panelView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(36), weight: .medium)
        titleLabel.setLineHeight(textString: title, lineHeight: guide0820Design(54))
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(40))
            make.top.equalTo(guide0820Design(40))
        }

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.numberOfLines = 0
        bodyLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        bodyLabel.font = .systemFont(ofSize: guide0820Design(28), weight: .regular)
        bodyLabel.setLineHeight(textString: body, lineHeight: guide0820Design(42))
        contentView.addSubview(bodyLabel)
        bodyLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(40))
            make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(40))
        }

        if let references {
            let referencesLabel = UILabel()
            referencesLabel.text = references
            referencesLabel.numberOfLines = 0
            referencesLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            referencesLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
            referencesLabel.setLineHeight(textString: references, lineHeight: guide0820Design(36))
            contentView.addSubview(referencesLabel)
            referencesLabel.snp.makeConstraints { make in
                make.left.right.equalTo(bodyLabel)
                make.top.equalTo(bodyLabel.snp.bottom).offset(guide0820Design(40))
                make.bottom.equalTo(guide0820Design(-40))
            }
        } else {
            bodyLabel.snp.makeConstraints { make in
                make.bottom.equalTo(guide0820Design(-40))
            }
        }

        confirmButton.setTitle("我知道了", for: .normal)
        confirmButton.setTitleColor(.THEME, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: guide0820Design(32), weight: .medium)
        confirmButton.backgroundColor = .COLOR_CARD_BG_WHITE
        confirmButton.addTarget(self, action: #selector(hideAction), for: .touchUpInside)
        panelView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(contentView.snp.bottom)
            make.height.equalTo(guide0820Design(96))
        }

        let separator = UIView()
        separator.backgroundColor = .COLOR_LINE_F0
        panelView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top)
            make.height.equalTo(guide0820Design(1))
        }
    }
}

/// Guide0820LifeProfileChoiceCard 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileChoiceCard: UIControl {
    // `iconText` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let iconText: String?
    // `iconName` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let iconName: String?
    // `titleText` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let titleText: String
    // `subtitleText` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let subtitleText: String?
    // `titleLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let titleLabel = UILabel()
    // `subtitleLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let subtitleLabel = UILabel()
    // `iconLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let iconLabel = UILabel()
    // `iconImageView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let iconImageView = UIImageView()
    // `checkImageView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let checkImageView = UIImageView()
    // `isPressedState` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var isPressedState = false
    // `hasIcon` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var hasIcon: Bool { iconText != nil || iconName != nil }

    /// `value` 属性，保存该类型对外提供或内部使用的状态与配置。
    var value = ""

    /// `isSelected` 属性，保存该类型对外提供或内部使用的状态与配置。
    override var isSelected: Bool {
        didSet { updateAppearance(animated: oldValue != isSelected) }
    }

    /// 初始化当前类型实例。
    init(iconText: String?, iconName: String? = nil, title: String, subtitle: String? = nil, value: String) {
        self.iconText = iconText
        self.iconName = iconName
        self.titleText = title
        self.subtitleText = subtitle
        self.value = value
        super.init(frame: .zero)
        backgroundColor = .COLOR_CARD_BG_WHITE
        layer.cornerRadius = guide0820Design(24)
        layer.cornerCurve = .continuous
        clipsToBounds = true
        initUI()
        updateAppearance(animated: false)
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection == nil ||
                traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        updateAppearance(animated: false)
    }

    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    private func initUI() {
        if hasIcon {
            let iconView: UIView
            if let iconName {
                iconImageView.setImgLocal(imgName: iconName)
                iconImageView.contentMode = .scaleAspectFit
                iconView = iconImageView
            } else {
                iconLabel.text = iconText
                iconLabel.textAlignment = .center
                iconLabel.textColor = .COLOR_TEXT_TITLE_0f1214
                iconLabel.font = .systemFont(ofSize: guide0820Design(22), weight: .medium)
                iconLabel.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
                iconLabel.layer.cornerRadius = guide0820Design(25)
                iconLabel.clipsToBounds = true
                iconView = iconLabel
            }
            addSubview(iconView)
            iconView.snp.makeConstraints { make in
                make.left.equalTo(guide0820Design(32))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(guide0820Design(50))
            }
        }

        titleLabel.text = titleText
        titleLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        titleLabel.font = .systemFont(ofSize: guide0820Design(32), weight: .medium)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(hasIcon ? guide0820Design(116) : guide0820Design(42))
            make.right.lessThanOrEqualTo(guide0820Design(-112))
            if subtitleText == nil {
                make.centerY.equalToSuperview()
            } else {
                make.top.equalTo(guide0820Design(44))
            }
        }

        if let subtitleText {
            subtitleLabel.text = subtitleText
            subtitleLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
            subtitleLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
            subtitleLabel.guide0820SetLineHeight(guide0820Design(36))
            addSubview(subtitleLabel)
            subtitleLabel.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(16))
                make.right.lessThanOrEqualTo(guide0820Design(-112))
            }
        }

        checkImageView.contentMode = .scaleAspectFit
        addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.right.equalTo(guide0820Design(-32))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(guide0820Design(42))
        }
    }

    // 执行 `updateAppearance` 操作，完成当前引导页面的状态更新或交互处理。
    private func updateAppearance(animated: Bool = true) {
        layer.borderWidth = isSelected ? 1.5 : 0
        layer.borderColor = isSelected
            ? UIColor.THEME.resolvedColor(with: traitCollection).cgColor
            : UIColor.clear.cgColor
        checkImageView.setCheckState(isSelected,
                                     checkedImageName: "select_icon_selected_circle_gap",
                                     uncheckedImageName: "select_icon_normal_circle_gap",
                                     animated: animated)
        transform = isPressedState ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity
        alpha = isPressedState ? 0.92 : 1
    }

    /// 执行 `touchesBegan` 操作，完成当前引导页面的状态更新或交互处理。
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressedState = true
        updateAppearance(animated: false)
        super.touchesBegan(touches, with: event)
    }

    /// 执行 `touchesEnded` 操作，完成当前引导页面的状态更新或交互处理。
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressedState = false
        updateAppearance(animated: false)
        super.touchesEnded(touches, with: event)
    }

    /// 执行 `touchesCancelled` 操作，完成当前引导页面的状态更新或交互处理。
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressedState = false
        updateAppearance(animated: false)
        super.touchesCancelled(touches, with: event)
    }
}

// Guide0820LifeProfileChoiceScrollView 类型，封装 Guide0820 引导流程中的相关功能。
private final class Guide0820LifeProfileChoiceScrollView: UIScrollView {
    // 执行 `touchesShouldCancel` 操作，完成当前引导页面的状态更新或交互处理。
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}

/// Guide0820LifeProfileChoicePageVM 类型，封装 Guide0820 引导流程中的相关功能。
class Guide0820LifeProfileChoicePageVM: Guide0820LifeProfilePageVM {
    /// Item 类型，封装 Guide0820 引导流程中的相关功能。
    struct Item {
        /// `iconText` 属性，保存该类型对外提供或内部使用的状态与配置。
        let iconText: String?
        /// `iconName` 属性，保存该类型对外提供或内部使用的状态与配置。
        let iconName: String?
        /// `title` 属性，保存该类型对外提供或内部使用的状态与配置。
        let title: String
        /// `subtitle` 属性，保存该类型对外提供或内部使用的状态与配置。
        let subtitle: String?
        /// `value` 属性，保存该类型对外提供或内部使用的状态与配置。
        let value: String

        /// 初始化当前类型实例。
        init(iconText: String?, iconName: String? = nil, title: String, subtitle: String?, value: String) {
            self.iconText = iconText
            self.iconName = iconName
            self.title = title
            self.subtitle = subtitle
            self.value = value
        }
    }

    // `titleText` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let titleText: String
    // `items` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let items: [Item]
    // `restoreValue` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let restoreValue: () -> String
    // `commitValue` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let commitValue: (String) -> Void
    // `contentBottomSpacing` 属性，保存滚动内容底部的额外留白。
    private let contentBottomSpacing: CGFloat
    // `info` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let info: (title: String, detail: String, body: String, references: String?)?
    // `scrollView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let scrollView = Guide0820LifeProfileChoiceScrollView()
    // `contentView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let contentView = UIView()
    // `topGradientView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let topGradientView = UIView()
    // `bottomGradientView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let bottomGradientView = UIView()
    // `topGradientLayer` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let topGradientLayer = CAGradientLayer()
    // `bottomGradientLayer` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let bottomGradientLayer = CAGradientLayer()
    // `cards` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var cards: [Guide0820LifeProfileChoiceCard] = []
    // `selectedValue` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var selectedValue: String? {
        didSet {
            cards.forEach { $0.isSelected = $0.value == selectedValue }
            validityChanged?(isStepValid)
        }
    }

    // `overlay` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var overlay: Guide0820LifeProfileInfoOverlayVM? = {
        guard let info else { return nil }
        return Guide0820LifeProfileInfoOverlayVM(title: info.title, body: info.body, references: info.references)
    }()

    /// `selectedAnswerValue` 属性，保存该类型对外提供或内部使用的状态与配置。
    var selectedAnswerValue: String? { selectedValue }
    /// `isStepValid` 属性，保存该类型对外提供或内部使用的状态与配置。
    override var isStepValid: Bool { selectedValue?.isEmpty == false }

    /// 初始化当前类型实例。
    init(title: String,
         items: [Item],
         info: (title: String, detail: String, body: String, references: String?)? = nil,
         contentBottomSpacing: CGFloat = 0,
         restoreValue: @escaping () -> String,
         commitValue: @escaping (String) -> Void) {
        titleText = title
        self.items = items
        self.info = info
        self.contentBottomSpacing = contentBottomSpacing
        self.restoreValue = restoreValue
        self.commitValue = commitValue
        super.init(frame: .zero)
        initUI()
        restore(selectedValue: restoreValue())
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 执行 `layoutSubviews` 操作，完成当前引导页面的状态更新或交互处理。
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topGradientView.bounds
        bottomGradientLayer.frame = bottomGradientView.bounds
        updateGradientVisibility()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection == nil ||
                traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        updateGradientColors()
    }

    /// 执行 `commitCurrentValue` 操作，完成当前引导页面的状态更新或交互处理。
    override func commitCurrentValue() {
        commitValue(selectedValue ?? "")
    }

    /// 执行 `restore` 操作，完成当前引导页面的状态更新或交互处理。
    func restore(selectedValue: String?) {
        guard let selectedValue,
              selectedValue.isEmpty == false,
              items.contains(where: { $0.value == selectedValue }) else {
            self.selectedValue = nil
            commitCurrentValue()
            return
        }
        self.selectedValue = selectedValue
        commitCurrentValue()
    }

    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    private func initUI() {
        let titleLabel = makeTitleLabel(titleText)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(guide0820Design(262))
        }

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(44))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + guide0820Design(136)))
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        let containerView = UIView()
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = guide0820Design(24)
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
        }

        items.forEach { item in
            let card = Guide0820LifeProfileChoiceCard(iconText: item.iconText,
                                                      iconName: item.iconName,
                                                      title: item.title,
                                                      subtitle: item.subtitle,
                                                      value: item.value)
            card.addTarget(self, action: #selector(cardAction(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(card)
            card.snp.makeConstraints { make in
                make.height.equalTo(guide0820Design(160))
            }
            cards.append(card)
        }

        if let info {
            let infoCard = Guide0820LifeProfileInfoCard(title: info.title, detail: info.detail)
            infoCard.addTarget(self, action: #selector(infoAction), for: .touchUpInside)
            containerView.addSubview(infoCard)
            infoCard.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(stackView.snp.bottom).offset(guide0820Design(24))
                make.height.equalTo(guide0820Design(178))
                make.bottom.equalToSuperview().offset(-contentBottomSpacing)
            }
        } else {
            stackView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
        }

        updateGradientColors()
        topGradientView.isUserInteractionEnabled = false
        bottomGradientView.isUserInteractionEnabled = false
        topGradientView.layer.addSublayer(topGradientLayer)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        addSubview(topGradientView)
        addSubview(bottomGradientView)
        topGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView)
            make.height.equalTo(guide0820Design(20))
//            make.height.equalTo(guide0820Design(72))
        }
        bottomGradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(scrollView)
            make.height.equalTo(guide0820Design(20))
        }

        if let overlay {
            addSubview(overlay)
            overlay.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    // 执行 `configureGradient` 操作，完成当前引导页面的状态更新或交互处理。
    private func configureGradient(_ layer: CAGradientLayer, from: UIColor, to: UIColor) {
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [
            from.resolvedColor(with: traitCollection).cgColor,
            to.resolvedColor(with: traitCollection).cgColor
        ]
        layer.locations = [0, 1]
    }

    private func updateGradientColors() {
        configureGradient(topGradientLayer, from: .COLOR_BG_F2, to: .COLOR_BG_F2.withAlphaComponent(0))
        configureGradient(bottomGradientLayer, from: .COLOR_BG_F2.withAlphaComponent(0), to: .COLOR_BG_F2)
    }

    // 执行 `updateGradientVisibility` 操作，完成当前引导页面的状态更新或交互处理。
    private func updateGradientVisibility() {
        let visibleHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let maxOffsetY = max(contentHeight - visibleHeight, 0)
        topGradientView.alpha = offsetY > 4 ? 1 : 0
        bottomGradientView.alpha = offsetY < maxOffsetY - 4 ? 1 : 0
    }

    // 执行 `cardAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc private func cardAction(_ sender: Guide0820LifeProfileChoiceCard) {
        selectedValue = sender.value
        commitCurrentValue()
    }

    // 执行 `infoAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc private func infoAction() {
        overlay?.show()
    }
}

/// Guide0820LifeProfileChoicePageVM 扩展，提供 Guide0820 流程相关的辅助能力。
extension Guide0820LifeProfileChoicePageVM: UIScrollViewDelegate {
    /// 执行 `scrollViewDidScroll` 操作，完成当前引导页面的状态更新或交互处理。
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateGradientVisibility()
    }
}

/// Guide0820LifeProfileTakeoutFrequencyVM 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileTakeoutFrequencyVM: Guide0820LifeProfileChoicePageVM {
    /// 初始化当前类型实例。
    init() {
        super.init(
            title: "你平均每周\n有几餐会外食或点外卖？",
            items: [
                Item(iconText: "0", iconName: "guide0820_takeout_0_icon", title: "0 餐", subtitle: nil, value: "0"),
                Item(iconText: "1", iconName: "guide0820_takeout_1_3_icon", title: "1 ~ 3 餐", subtitle: nil, value: "1-3"),
                Item(iconText: "4", iconName: "guide0820_takeout_4_7_icon", title: "4 ~ 7 餐", subtitle: nil, value: "4-7"),
                Item(iconText: "8", iconName: "guide0820_takeout_8_14_icon", title: "8 ~ 14 餐", subtitle: nil, value: "8-14"),
                Item(iconText: "15", iconName: "guide0820_takeout_15_plus_icon", title: "15 餐及以上", subtitle: nil, value: "15+")
            ],
            info: (
                title: "外食的“热量认知偏差”",
                detail: "研究发现，每周外食超过 2 餐的人，整体饮食质量通常更低，相关营养指标也更差。快餐消...",
                body: "研究发现，每周外食超过 2 餐的人，整体饮食质量通常更低，相关营养指标也更差。快餐消费者也普遍会低估所购餐食的热量，而且餐食份量越大，低估越明显。[1]\n\n外食/外卖的频率越高，潜在影响通常越大，因此更需要注意食物的选择与分量控制。[2]",
                references: "[1] Lachat et al., Obes Rev, 2012  \n[2] Block et al., BMJ, 2013"
            ),
            contentBottomSpacing: guide0820Design(30),
            restoreValue: { Guide0820Model.shared.guidanceTakeoutFrequencyType },
            commitValue: { Guide0820Model.shared.guidanceTakeoutFrequencyType = $0 }
        )
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Guide0820LifeProfileMealsPerDayVM 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileMealsPerDayVM: Guide0820LifeProfileChoicePageVM {
    /// 初始化当前类型实例。
    init() {
        super.init(
            title: "你的每天进餐频率是？",
            items: [
                Item(iconText: "1", iconName: "guide0820_meals_per_day_1_2_icon", title: "1～2 餐", subtitle: nil, value: "2"),
                Item(iconText: "3", iconName: "guide0820_meals_per_day_3_icon", title: "3 餐", subtitle: nil, value: "3"),
                Item(iconText: "4", iconName: "guide0820_meals_per_day_4_icon", title: "4 餐", subtitle: nil, value: "4"),
                Item(iconText: "5", iconName: "guide0820_meals_per_day_5_icon", title: "5 餐", subtitle: nil, value: "5"),
                Item(iconText: "6", iconName: "guide0820_meals_per_day_6_plus_icon", title: "6+ 餐", subtitle: nil, value: "6+")
            ],
            restoreValue: { Guide0820Model.shared.guidanceMealsPerDayType },
            commitValue: {
                Guide0820Model.shared.guidanceMealsPerDayType = $0
                if Guide0820Model.shared.guidanceMealsAdjustType.isEmpty {
                    Guide0820Model.shared.guidanceMealsAdjustType = $0
                }
            }
        )
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Guide0820LifeProfileCardioFrequencyVM 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileCardioFrequencyVM: Guide0820LifeProfileChoicePageVM {
    /// 初始化当前类型实例。
    init() {
        super.init(
            title: "过去 4 周，你平均每周完成几次有氧训练？",
            items: [
                Item(iconText: "C", iconName: "guide0820_cardio_never_icon", title: "几乎不做", subtitle: nil, value: "never"),
                Item(iconText: "1", iconName: "guide0820_cardio_once_icon", title: "每周 1 次", subtitle: nil, value: "commute"),
                Item(iconText: "2", iconName: "guide0820_cardio_2_3_icon", title: "每周 2～3 次", subtitle: nil, value: "2-3"),
                Item(iconText: "4", iconName: "guide0820_cardio_4_5_icon", title: "每周 4～5 次", subtitle: nil, value: "4-5"),
                Item(iconText: "6", iconName: "guide0820_cardio_6_plus_icon", title: "每周 6 次及以上", subtitle: nil, value: "6-7")
            ],
            restoreValue: { Guide0820Model.shared.guidanceCardioFrequencyType },
            commitValue: {
                Guide0820Model.shared.guidanceCardioFrequencyType = $0
                Guide0820Model.shared.events = Guide0820LifeProfileActivityEstimator.eventsValue(forCardio: $0)
            }
        )
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Guide0820LifeProfileStrengthTrainingFrequencyVM 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileStrengthTrainingFrequencyVM: Guide0820LifeProfileChoicePageVM {
    /// 初始化当前类型实例。
    init() {
        super.init(
            title: "过去 4 周 你平均每周进行几次力量训练？",
            items: [
                Item(iconText: "S", iconName: "guide0820_strength_0_2_icon", title: "每周 0～2 次", subtitle: nil, value: "0-2"),
                Item(iconText: "S", iconName: "guide0820_strength_3_4_icon", title: "每周 3～4 次", subtitle: nil, value: "3-4"),
                Item(iconText: "S", iconName: "guide0820_strength_5_6_icon", title: "每周 5～6 次", subtitle: nil, value: "5-6"),
                Item(iconText: "S", iconName: "guide0820_strength_7_plus_icon", title: "每周 7 次及以上", subtitle: nil, value: "7+")
            ],
            restoreValue: { Guide0820Model.shared.guidanceStrengthTrainingFrequencyType },
            commitValue: { Guide0820Model.shared.guidanceStrengthTrainingFrequencyType = $0 }
        )
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Guide0820LifeProfileExerciseCaloriesRecordVM 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileExerciseCaloriesRecordVM: Guide0820LifeProfileChoicePageVM {
    /// 初始化当前类型实例。
    init() {
        super.init(
            title: "你是否计划\n额外记录运动消耗？",
            items: [
                Item(iconText: "Y", iconName: "guide0820_answer_yes_icon", title: "是", subtitle: nil, value: "yes"),
                Item(iconText: "N", iconName: "guide0820_answer_no_icon", title: "否", subtitle: nil, value: "no")
            ],
            info: (
                title: "我们不建议额外记录运动消耗",
                detail: "你的每日摄入目标已经包含日常活动、训练，以及增肌或减脂所需的热量盈余或缺口。后续...",
                body: "你的每日摄入目标已经包含日常活动、训练，以及增肌或减脂所需的热量盈余或缺口。后续，我们也会根据你的体重变化持续调整目标，因此你无需再将运动消耗额外加回当天的摄入量。\n\n研究显示，不论是借助手表等设备还是手动记录，运动消耗的热量都很容易出现明显误差。部分腕戴设备研究的中位误差约为 27% 至 93%，各品牌平均绝对误差普遍超过 30%。手动记录同样不稳定，且整体更倾向于高估。现实中，几乎只有实验室间接测热能（运动）和双标水（日常）才能相对的测出热量消耗。[1] [2]\n\n因此，我们更建议大多数人优先记录饮食、体重趋势，以及力量训练频率而不是运动消耗。[3]",
                references: "[1] Germini et al. (2022), JMIR\n[2] Shcherbina et al. (2017), JPM\n[3] Dowd et al. (2018), IJBNPA"
            ),
            restoreValue: { Guide0820Model.shared.guidanceExerciseCaloriesRecordType },
            commitValue: { Guide0820Model.shared.guidanceExerciseCaloriesRecordType = $0 }
        )
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Guide0820LifeProfileCaloriesResultVM 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileCaloriesResultVM: Guide0820LifeProfilePageVM, UITextFieldDelegate {
    // `caloriesTextField` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let caloriesTextField = UITextField()
    // `maxCaloriesInputValue` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let maxCaloriesInputValue = 9999
    // `bmiOverlay` 属性，保存该类型对外提供或内部使用的状态与配置。
    private lazy var bmiOverlay = Guide0820LifeProfileInfoOverlayVM(
        title: "为什么不用BMI？",
        body: "BMI主要反映体重和身高的比例，无法区分肌肉和脂肪，因此同样BMI的两个人，代谢需求可能差很多。Katch-McArdle会参考你的瘦体重(去脂体重)，在体脂数据较准确时，通常能更贴近健身人群的代谢情况，给出更个性化的结果。"
    )

    /// 初始化当前类型实例。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 执行 `pageWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    override func pageWillAppear() {
        refreshCaloriesIfNeeded()
    }

    /// 执行 `commitCurrentValue` 操作，完成当前引导页面的状态更新或交互处理。
    override func commitCurrentValue() {
        let calories = caloriesTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        Guide0820Model.shared.caloriesNumber = calories
        Guide0820Model.shared.caloriesNumberFromServer = calories
    }

    /// 热量输入必须是至少 10 千卡的有效整数。
    var hasReasonableCaloriesInput: Bool {
        guard let calories = Int(caloriesTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") else {
            return false
        }
        return calories >= 10
    }

    /// 使用基础消耗接口返回的热量更新页面输入框及流程模型。
    func updateCaloriesFromServer(_ calories: String) {
        caloriesTextField.text = calories
        Guide0820Model.shared.caloriesNumber = calories
        Guide0820Model.shared.caloriesNumberFromServer = calories
    }

    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    private func initUI() {
        let titleLabel = makeTitleLabel("结合你的代谢和活动量\n你维持现体重所需的大致热量为：")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(guide0820Design(262))
        }

        let caloriesBgView = UIView()
        caloriesBgView.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        caloriesBgView.layer.cornerRadius = guide0820Design(24)
        caloriesBgView.layer.cornerCurve = .continuous
        caloriesBgView.clipsToBounds = true
        caloriesBgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusCaloriesInput)))
        addSubview(caloriesBgView)
        caloriesBgView.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(guide0820Design(470))
            make.height.equalTo(guide0820Design(128))
        }

        caloriesTextField.font = UIFont().DDInFontMedium(fontSize: guide0820Design(58))
        caloriesTextField.keyboardType = .numberPad
        caloriesTextField.textColor = .THEME
        caloriesTextField.text = "0"
        caloriesTextField.delegate = self
        caloriesBgView.addSubview(caloriesTextField)
        caloriesTextField.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(50))
            make.centerY.equalToSuperview()
        }

        let unitLabel = UILabel()
        unitLabel.text = "千卡"
        unitLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        unitLabel.font = .systemFont(ofSize: guide0820Design(26), weight: .regular)
        caloriesBgView.addSubview(unitLabel)
        unitLabel.snp.makeConstraints { make in
            make.left.equalTo(caloriesTextField.snp.right).offset(guide0820Design(12))
            make.top.equalTo(guide0820Design(45))
        }

        let tipsText = "这还不是你的最终摄入目标。接下来，ELA 会根据你的目标设置相应的热量缺口或盈余，并随着饮食和体重数据增加持续校准。\n\n我们根据你的体重和体脂率估算了瘦体重(去脂体重)，并使用 Katch-McArdle 公式计算基础代谢，再结合你选择的活动水平，得到维持体重所需的每日总消耗。\n\n如果你觉得该数值过高或过低，可以点击并手动调整。"
        let tipsLabel = UILabel()
        tipsLabel.numberOfLines = 0
        tipsLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        tipsLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        tipsLabel.setLineHeight(textString: tipsText, lineHeight: guide0820Design(36))
        addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(guide0820Design(638))
        }

        let infoCard = Guide0820LifeProfileInfoCard(
            title: "为什么不用BMI？",
            detail: "BMI主要反映体重和身高的比例，无法区分肌肉和脂肪，因此同样BMI的两个人，代谢需求可..."
        )
        infoCard.addTarget(self, action: #selector(showBMIInfo), for: .touchUpInside)
        addSubview(infoCard)
        infoCard.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-guide0820Design(417))
            make.height.equalTo(guide0820Design(178))
        }

        addSubview(bmiOverlay)
        bmiOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // 执行 `focusCaloriesInput` 操作，完成当前引导页面的状态更新或交互处理。
    @objc private func focusCaloriesInput() {
        caloriesTextField.becomeFirstResponder()
    }

    // 执行 `showBMIInfo` 操作，完成当前引导页面的状态更新或交互处理。
    @objc private func showBMIInfo() {
        bmiOverlay.show()
    }

    // 执行 `refreshCaloriesIfNeeded` 操作，完成当前引导页面的状态更新或交互处理。
    private func refreshCaloriesIfNeeded() {
        if let existing = Int(Guide0820Model.shared.caloriesNumber), existing > 0 {
            caloriesTextField.text = "\(existing)"
            return
        }
        let estimated = Guide0820LifeProfileActivityEstimator.estimatedMaintenanceCalories()
        caloriesTextField.text = "\(estimated)"
        commitCurrentValue()
    }

    /// 执行 `textField` 操作，完成当前引导页面的状态更新或交互处理。
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else { return false }
        if string.isEmpty { return true }
        guard string.allSatisfy({ $0.isNumber }) else { return false }
        let nextText = currentText.replacingCharacters(in: textRange, with: string)
        guard let nextValue = Int(nextText) else { return false }
        return nextValue <= maxCaloriesInputValue
    }
}

/// Guide0820LifeProfileReminderVM 类型，封装 Guide0820 引导流程中的相关功能。
final class Guide0820LifeProfileReminderVM: Guide0820LifeProfilePageVM {
    /// `enableReminderBlock` 属性，保存该类型对外提供或内部使用的状态与配置。
    var enableReminderBlock: (() -> Void)?
    /// `skipReminderBlock` 属性，保存该类型对外提供或内部使用的状态与配置。
    var skipReminderBlock: (() -> Void)?

    /// 初始化当前类型实例。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    private func initUI() {
        let titleLabel = makeTitleLabel("我们发现")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(42))
            make.top.equalTo(guide0820Design(262))
        }

        let resultLabel = UILabel()
        resultLabel.numberOfLines = 0
        let resultText = "开启个性化提醒的用户\n饮食目标达成率比未开启用户高出 46%"
        let resultAttr = NSMutableAttributedString(
            string: resultText,
            attributes: [
                .font: UIFont.systemFont(ofSize: guide0820Design(32), weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214
            ]
        )
        let highlightRange = (resultText as NSString).range(of: "46%")
        resultAttr.addAttributes([
            .font: UIFont.systemFont(ofSize: guide0820Design(32), weight: .medium),
            .foregroundColor: UIColor.THEME
        ], range: highlightRange)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = guide0820Design(38)
        paragraphStyle.maximumLineHeight = guide0820Design(38)
        resultAttr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: resultText.count))
        resultLabel.attributedText = resultAttr
        addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(24))
        }

        let noteLabel = UILabel()
        noteLabel.text = "你可以随时在设置里进行调整"
        noteLabel.textColor = .COLOR_TEXT_TITLE_0f1214_50
        noteLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        addSubview(noteLabel)
        noteLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(resultLabel.snp.bottom).offset(guide0820Design(24))
        }

        // The design uses the supplied 3D bell artwork directly. The asset is a
        // 1300px @2x canvas with transparent padding, so keeping a 650pt square
        // container preserves the artwork's intended visual scale and position.
        let reminderIconView = UIImageView()
        reminderIconView.setImgLocal(imgName: "guide_reminder_icon")
        reminderIconView.contentMode = .scaleAspectFit
        reminderIconView.isUserInteractionEnabled = false
        addSubview(reminderIconView)
        reminderIconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(guide0820Design(581))
            make.width.height.equalTo(guide0820Design(650))
        }

        let enableButton = UIButton(type: .custom)
        enableButton.setTitle("打开提醒", for: .normal)
        enableButton.setTitleColor(.COLOR_TEXT_WHITE, for: .normal)
        enableButton.titleLabel?.font = .systemFont(ofSize: guide0820Design(34), weight: .medium)
        enableButton.backgroundColor = .THEME
        enableButton.layer.cornerRadius = guide0820Design(24)
        enableButton.layer.cornerCurve = .continuous
        enableButton.clipsToBounds = true
        enableButton.enablePressEffect()
        enableButton.addTarget(self, action: #selector(enableAction), for: .touchUpInside)
        addSubview(enableButton)
        enableButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(guide0820Design(32))
            make.top.equalTo(guide0820Design(1314))
            make.height.equalTo(guide0820Design(104))
        }

        let skipButton = UIButton(type: .custom)
        skipButton.setTitle("暂时不用", for: .normal)
        skipButton.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        skipButton.addTarget(self, action: #selector(skipAction), for: .touchUpInside)
        addSubview(skipButton)
        skipButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(enableButton.snp.bottom).offset(guide0820Design(40))
            make.height.equalTo(guide0820Design(36))
        }
    }

    // 执行 `enableAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc private func enableAction() {
        enableReminderBlock?()
    }

    // 执行 `skipAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc private func skipAction() {
        skipReminderBlock?()
    }
}

/// Guide0820LifeProfileActivityEstimator 类型，封装 Guide0820 引导流程中的相关功能。
enum Guide0820LifeProfileActivityEstimator {
    /// 执行 `eventsValue` 操作，完成当前引导页面的状态更新或交互处理。
    static func eventsValue(forCardio value: String) -> String {
        switch value {
        case "never": return "1"
        case "commute": return "2"
        case "2-3": return "3"
        case "4-5": return "4"
        case "6-7": return "5"
        default: return ""
        }
    }

    /// 执行 `estimatedMaintenanceCalories` 操作，完成当前引导页面的状态更新或交互处理。
    static func estimatedMaintenanceCalories() -> Int {
        let model = Guide0820Model.shared
        let weight = Double(model.weight) ?? Guide0820ProgressStorage.bodyProfileWeight ?? 60
        let height = Double(model.height) ?? Double(Guide0820ProgressStorage.bodyProfileHeight ?? 165)
        let birthYear = Int(model.birthDay.isEmpty ? model.birthYear : model.birthDay) ?? Int(Guide0820ProgressStorage.bodyProfileBirthYear ?? "") ?? 1995
        let age = max(Calendar.current.component(.year, from: Date()) - birthYear, 18)
        let sex = model.sex.isEmpty ? (Guide0820ProgressStorage.bodyProfileSex ?? "2") : model.sex
        let bodyFat = bodyFatRatio(from: model.bodyFat.isEmpty ? (Guide0820ProgressStorage.bodyProfileBodyFat ?? "") : model.bodyFat)

        let bmr: Double
        if let bodyFat {
            bmr = 370 + 21.6 * weight * (1 - bodyFat)
        } else {
            let sexOffset = sex == "1" ? 5.0 : -161.0
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) + sexOffset
        }
        return Int((bmr * activityMultiplier()).rounded())
    }

    // 执行 `activityMultiplier` 操作，完成当前引导页面的状态更新或交互处理。
    private static func activityMultiplier() -> Double {
        let cardio = Guide0820Model.shared.guidanceCardioFrequencyType
        let strength = Guide0820Model.shared.guidanceStrengthTrainingFrequencyType
        var multiplier = 1.2
        switch cardio {
        case "commute": multiplier += 0.1
        case "2-3": multiplier += 0.18
        case "4-5": multiplier += 0.28
        case "6-7": multiplier += 0.36
        default: break
        }
        switch strength {
        case "3-4": multiplier += 0.1
        case "5-6": multiplier += 0.16
        case "7+": multiplier += 0.22
        default: multiplier += 0.04
        }
        return min(max(multiplier, 1.2), 1.85)
    }

    // 执行 `bodyFatRatio` 操作，完成当前引导页面的状态更新或交互处理。
    private static func bodyFatRatio(from value: String) -> Double? {
        let text = value.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let number = Double(text), number > 0 else { return nil }
        return number > 1 ? number / 100 : number
    }
}
