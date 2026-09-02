//
//  GuidanceGoalPlanChoicePageVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit
import SnapKit

/// GuidanceGoalPlanPageVM 类型，封装 Guide0820 引导流程中的相关功能。
protocol GuidanceGoalPlanPageVM where Self: UIView {
    /// `selectionChanged` 属性，保存该类型对外提供或内部使用的状态与配置。
    var selectionChanged: (() -> Void)? { get set }
    /// `hasSelection` 属性，保存该类型对外提供或内部使用的状态与配置。
    var hasSelection: Bool { get }
    /// 执行 `pageWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    func pageWillAppear()
}

/// GuidanceGoalPlanChoicePageVM 类型，封装 Guide0820 引导流程中的相关功能。
class GuidanceGoalPlanChoicePageVM: UIView, GuidanceGoalPlanPageVM {
    /// Layout 类型，封装 Guide0820 引导流程中的相关功能。
    struct Layout {
        /// `titleTopOffset` 属性，保存该类型对外提供或内部使用的状态与配置。
        let titleTopOffset: CGFloat
        /// `titleHorizontalInset` 属性，保存该类型对外提供或内部使用的状态与配置。
        let titleHorizontalInset: CGFloat
        /// `titleFontSize` 属性，保存该类型对外提供或内部使用的状态与配置。
        let titleFontSize: CGFloat
        /// `subtitleTopOffset` 属性，保存该类型对外提供或内部使用的状态与配置。
        let subtitleTopOffset: CGFloat
        /// `stackTopOffset` 属性，保存该类型对外提供或内部使用的状态与配置。
        let stackTopOffset: CGFloat
        /// `stackHorizontalInset` 属性，保存该类型对外提供或内部使用的状态与配置。
        let stackHorizontalInset: CGFloat
        /// `stackBottomInset` 属性，保存该类型对外提供或内部使用的状态与配置。
        let stackBottomInset: CGFloat
        /// `cardSpacing` 属性，保存该类型对外提供或内部使用的状态与配置。
        let cardSpacing: CGFloat
        /// `cardMinimumHeight` 属性，保存该类型对外提供或内部使用的状态与配置。
        let cardMinimumHeight: CGFloat

        /// `default` 布局，提供通用选择页的默认尺寸与间距配置。
        static let `default` = Layout(
            titleTopOffset: guide0820Design(262),
            titleHorizontalInset: guide0820Design(42),
            titleFontSize: guide0820Design(48),
            subtitleTopOffset: guide0820Design(12),
            stackTopOffset: guide0820Design(44),
            stackHorizontalInset: guide0820Design(42),
            stackBottomInset: guide0820Design(24),
            cardSpacing: guide0820Design(24),
            cardMinimumHeight: 0
        )

        /// `goal` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let goal = Layout(
            titleTopOffset: guide0820Design(262),
            titleHorizontalInset: guide0820Design(42),
            titleFontSize: guide0820Design(48),
            subtitleTopOffset: guide0820Design(12),
            stackTopOffset: guide0820Design(44),
            stackHorizontalInset: guide0820Design(42),
            stackBottomInset: guide0820Design(24),
            cardSpacing: guide0820Design(24),
            cardMinimumHeight: guide0820Design(160)
        )

        /// `profile` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let profile = Layout(
            titleTopOffset: guide0820Design(262),
            titleHorizontalInset: guide0820Design(42),
            titleFontSize: guide0820Design(48),
            subtitleTopOffset: guide0820Design(12),
            stackTopOffset: guide0820Design(44),
            stackHorizontalInset: guide0820Design(42),
            stackBottomInset: guide0820Design(24),
            cardSpacing: guide0820Design(24),
            cardMinimumHeight: guide0820Design(196)
        )

        // The protein-habit screen uses the 160pt cards shown in the MasterGo
        // design, rather than the compact default choice cards.
        /// `proteinHabit` 属性，保存该类型对外提供或内部使用的状态与配置。
        static let proteinHabit = Layout(
            titleTopOffset: guide0820Design(262),
            titleHorizontalInset: guide0820Design(42),
            titleFontSize: guide0820Design(48),
            subtitleTopOffset: guide0820Design(12),
            stackTopOffset: guide0820Design(44),
            stackHorizontalInset: guide0820Design(42),
            stackBottomInset: guide0820Design(24),
            cardSpacing: guide0820Design(24),
            cardMinimumHeight: guide0820Design(160)
        )
    }

    /// `selectionChanged` 属性，保存该类型对外提供或内部使用的状态与配置。
    var selectionChanged: (() -> Void)?
    /// `valueChanged` 属性，保存该类型对外提供或内部使用的状态与配置。
    var valueChanged: ((String) -> Void)?
    /// `selectedValue` 属性，保存该类型对外提供或内部使用的状态与配置。
    var selectedValue = "" {
        didSet {
            refreshSelection(animated: true)
            valueChanged?(selectedValue)
            selectionChanged?()
        }
    }

    // `title` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let title: String
    // `subtitle` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let subtitle: String?
    // `options` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let options: [GuidanceGoalPlanOption]
    // `accentColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let accentColor: UIColor
    // `layout` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let layout: Layout
    // `detailOnlyWhenSelected` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let detailOnlyWhenSelected: Bool
    // `infoNoticeText` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let infoNoticeText: String?
    /// Enables checkbox-style multi-selection for pages such as food adjustment.
    private let allowsMultipleSelection: Bool
    /// Value that cannot be selected together with any other value.
    private let mutuallyExclusiveValue: String?
    // `cards` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var cards: [GuidanceGoalPlanOptionCardView] = []
    // Card width is deterministic because the stack uses fixed page insets.
    private var cardWidth: CGFloat {
        SCREEN_WIDHT - layout.stackHorizontalInset * 2
    }

    /// `hasSelection` 属性，保存该类型对外提供或内部使用的状态与配置。
    var hasSelection: Bool {
        !selectedValue.isEmpty
    }

    /// When enabled, cards collapse to the compact design state and reveal
    /// their detail copy only for the currently selected option.
    init(title: String,
         subtitle: String? = nil,
         options: [GuidanceGoalPlanOption],
         accentColor: UIColor,
         layout: Layout = .default,
         detailOnlyWhenSelected: Bool = false,
         infoNoticeText: String? = nil,
         allowsMultipleSelection: Bool = false,
         mutuallyExclusiveValue: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.options = options
        self.accentColor = accentColor
        self.layout = layout
        self.detailOnlyWhenSelected = detailOnlyWhenSelected
        self.infoNoticeText = infoNoticeText
        self.allowsMultipleSelection = allowsMultipleSelection
        self.mutuallyExclusiveValue = mutuallyExclusiveValue
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        initUI()
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 执行 `pageWillAppear` 操作，完成当前引导页面的状态更新或交互处理。
    func pageWillAppear() {
        refreshSelection(animated: false)
    }
}

// GuidanceGoalPlanChoicePageVM 扩展，提供 Guide0820 流程相关的辅助能力。
private extension GuidanceGoalPlanChoicePageVM {
    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    func initUI() {
        backgroundColor = GuidanceGoalPlanStyle.pageBackgroundColor

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
        titleLabel.font = .systemFont(ofSize: layout.titleFontSize, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.guide0820SetLineHeight(guide0820Design(72))

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = GuidanceGoalPlanStyle.detailColor
        subtitleLabel.font = .systemFont(ofSize: guide0820Design(28), weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.isHidden = subtitle?.isEmpty ?? true
        subtitleLabel.guide0820SetLineHeight(guide0820Design(42))

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = layout.cardSpacing

        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        let infoNoticeView: GuidanceGoalPlanInfoNoticeView?
        if let infoNoticeText, !infoNoticeText.isEmpty {
            let notice = GuidanceGoalPlanInfoNoticeView(text: infoNoticeText)
            infoNoticeView = notice
            scrollView.addSubview(notice)
        } else {
            infoNoticeView = nil
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(layout.titleHorizontalInset)
            make.right.equalTo(-layout.titleHorizontalInset)
            make.top.equalTo(layout.titleTopOffset)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.subtitleTopOffset)
        }

        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(subtitleLabel.isHidden ? titleLabel.snp.bottom : subtitleLabel.snp.bottom).offset(layout.stackTopOffset)
        }

        stackView.snp.makeConstraints { make in
            make.left.equalTo(layout.stackHorizontalInset)
            make.right.equalTo(-layout.stackHorizontalInset)
            make.top.equalToSuperview()
            make.width.equalTo(SCREEN_WIDHT - layout.stackHorizontalInset * 2)
            if let infoNoticeView {
                make.bottom.equalTo(infoNoticeView.snp.top).offset(-layout.cardSpacing)
            } else {
                make.bottom.equalToSuperview().offset(layout.stackBottomInset * -1)
            }
        }

        infoNoticeView?.snp.makeConstraints { make in
            make.left.right.equalTo(stackView)
            make.height.equalTo(guide0820Design(136))
            make.bottom.equalToSuperview().offset(layout.stackBottomInset * -1)
        }

        for (index, option) in options.enumerated() {
            let card = GuidanceGoalPlanOptionCardView()
            card.tag = index
            card.configure(option: option,
                           accentColor: accentColor,
                           detailOnlyWhenSelected: detailOnlyWhenSelected,
                           checkedImageName: allowsMultipleSelection ? "guide0820_checkbox_selected_icon" : "select_icon_selected_circle_gap",
                           uncheckedImageName: allowsMultipleSelection ? "guide0820_checkbox_normal_icon" : "select_icon_normal_circle_gap")
            card.addTarget(self, action: #selector(cardTapAction(_:)), for: .touchUpInside)
            card.snp.makeConstraints { make in
                let defaultHeight = kFitWidth(option.detail == nil ? 64 : 92)
                if detailOnlyWhenSelected {
                    make.height.equalTo(card.preferredHeight(expanded: false, constrainedTo: cardWidth))
                } else if layout.cardMinimumHeight > 0 {
                    make.height.equalTo(layout.cardMinimumHeight)
                } else {
                    make.height.equalTo(defaultHeight)
                }
            }
            stackView.addArrangedSubview(card)
            cards.append(card)
        }

        refreshSelection(animated: false)
    }

    // 执行 `cardTapAction` 操作，完成当前引导页面的状态更新或交互处理。
    @objc func cardTapAction(_ sender: GuidanceGoalPlanOptionCardView) {
        guard options.indices.contains(sender.tag) else { return }
        let value = options[sender.tag].value
        guard allowsMultipleSelection else {
            selectedValue = value
            return
        }

        var values = selectedValue
            .split(separator: ",")
            .map(String.init)
        if let existingIndex = values.firstIndex(of: value) {
            values.remove(at: existingIndex)
        } else {
            if let mutuallyExclusiveValue, value == mutuallyExclusiveValue {
                values = [value]
            } else {
                if let mutuallyExclusiveValue {
                    values.removeAll { $0 == mutuallyExclusiveValue }
                }
                values.append(value)
            }
        }
        // Keep persisted values deterministic in the visual option order.
        let orderedValues = options.map(\.value).filter { values.contains($0) }
        selectedValue = orderedValues.joined(separator: ",")
    }

    // 执行 `refreshSelection` 操作，完成当前引导页面的状态更新或交互处理。
    func refreshSelection(animated: Bool) {
        for (index, card) in cards.enumerated() {
            let selected: Bool
            if allowsMultipleSelection {
                selected = selectedValue.split(separator: ",").contains { String($0) == options[index].value }
            } else {
                selected = options[index].value == selectedValue
            }
            card.setSelected(selected, animated: animated)
            if detailOnlyWhenSelected {
                card.snp.updateConstraints { make in
                    make.height.equalTo(card.preferredHeight(expanded: selected, constrainedTo: cardWidth))
                }
            }
        }
        if detailOnlyWhenSelected, animated {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
}

/// Compact explanatory notice shown below a choice list when a page needs
/// additional context without competing with the page title.
final class GuidanceGoalPlanInfoNoticeView: UIView {
    // `iconImageView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let iconImageView = UIImageView()
    // `textLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let textLabel = UILabel()

    /// 初始化当前类型实例。
    init(text: String) {
        super.init(frame: .zero)
        backgroundColor = GuidanceGoalPlanStyle.infoNoticeBackgroundColor
        layer.cornerRadius = guide0820Design(24)
        layer.cornerCurve = .continuous
        clipsToBounds = true

        iconImageView.image = UIImage(named: "guide0820_info_icon")
        iconImageView.contentMode = .scaleAspectFit

        textLabel.text = text
        textLabel.textColor = GuidanceGoalPlanStyle.detailColor
        textLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        textLabel.numberOfLines = 0

        addSubview(iconImageView)
        addSubview(textLabel)

        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(guide0820Design(42))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(guide0820Design(40))
        }

        textLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(guide0820Design(34))
            make.right.equalTo(guide0820Design(-42))
            make.centerY.equalToSuperview()
        }
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
