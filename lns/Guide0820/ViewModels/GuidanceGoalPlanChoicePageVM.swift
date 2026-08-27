//
//  GuidanceGoalPlanChoicePageVM.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit
import SnapKit

protocol GuidanceGoalPlanPageVM where Self: UIView {
    var selectionChanged: (() -> Void)? { get set }
    var hasSelection: Bool { get }
    func pageWillAppear()
}

class GuidanceGoalPlanChoicePageVM: UIView, GuidanceGoalPlanPageVM {
    struct Layout {
        let titleTopOffset: CGFloat
        let titleHorizontalInset: CGFloat
        let titleFontSize: CGFloat
        let subtitleTopOffset: CGFloat
        let subtitleFontSize: CGFloat
        let stackTopOffset: CGFloat
        let stackHorizontalInset: CGFloat
        let stackBottomInset: CGFloat
        let cardSpacing: CGFloat
        let cardMinimumHeight: CGFloat

        static let `default` = Layout(
            titleTopOffset: guide0820Design(262),
            titleHorizontalInset: guide0820Design(42),
            titleFontSize: guide0820Design(48),
            subtitleTopOffset: guide0820Design(12),
            subtitleFontSize: guide0820Design(28),
            stackTopOffset: guide0820Design(44),
            stackHorizontalInset: guide0820Design(42),
            stackBottomInset: guide0820Design(24),
            cardSpacing: guide0820Design(24),
            cardMinimumHeight: 0
        )

        static let goal = Layout(
            titleTopOffset: guide0820Design(262),
            titleHorizontalInset: guide0820Design(42),
            titleFontSize: guide0820Design(48),
            subtitleTopOffset: guide0820Design(12),
            subtitleFontSize: guide0820Design(28),
            stackTopOffset: guide0820Design(44),
            stackHorizontalInset: guide0820Design(42),
            stackBottomInset: guide0820Design(24),
            cardSpacing: guide0820Design(24),
            cardMinimumHeight: guide0820Design(160)
        )

        static let profile = Layout(
            titleTopOffset: guide0820Design(262),
            titleHorizontalInset: guide0820Design(42),
            titleFontSize: guide0820Design(48),
            subtitleTopOffset: guide0820Design(12),
            subtitleFontSize: guide0820Design(28),
            stackTopOffset: guide0820Design(44),
            stackHorizontalInset: guide0820Design(42),
            stackBottomInset: guide0820Design(24),
            cardSpacing: guide0820Design(24),
            cardMinimumHeight: guide0820Design(196)
        )

        // The protein-habit screen uses the 160pt cards shown in the MasterGo
        // design, rather than the compact default choice cards.
        static let proteinHabit = Layout(
            titleTopOffset: guide0820Design(262),
            titleHorizontalInset: guide0820Design(42),
            titleFontSize: guide0820Design(48),
            subtitleTopOffset: guide0820Design(12),
            subtitleFontSize: guide0820Design(28),
            stackTopOffset: guide0820Design(44),
            stackHorizontalInset: guide0820Design(42),
            stackBottomInset: guide0820Design(24),
            cardSpacing: guide0820Design(24),
            cardMinimumHeight: guide0820Design(160)
        )
    }

    var selectionChanged: (() -> Void)?
    var valueChanged: ((String) -> Void)?
    var selectedValue = "" {
        didSet {
            refreshSelection(animated: true)
            valueChanged?(selectedValue)
            selectionChanged?()
        }
    }

    private let title: String
    private let subtitle: String?
    private let options: [GuidanceGoalPlanOption]
    private let accentColor: UIColor
    private let layout: Layout
    private let detailOnlyWhenSelected: Bool
    private var cards: [GuidanceGoalPlanOptionCardView] = []

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
         detailOnlyWhenSelected: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.options = options
        self.accentColor = accentColor
        self.layout = layout
        self.detailOnlyWhenSelected = detailOnlyWhenSelected
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pageWillAppear() {
        refreshSelection(animated: false)
    }
}

private extension GuidanceGoalPlanChoicePageVM {
    func initUI() {
        backgroundColor = GuidanceGoalPlanStyle.pageBackgroundColor

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
        titleLabel.font = .systemFont(ofSize: layout.titleFontSize, weight: .medium)
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = GuidanceGoalPlanStyle.detailColor
        subtitleLabel.font = .systemFont(ofSize: layout.subtitleFontSize, weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.isHidden = subtitle?.isEmpty ?? true

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
            make.bottom.equalToSuperview().offset(layout.stackBottomInset * -1)
            make.width.equalTo(SCREEN_WIDHT - layout.stackHorizontalInset * 2)
        }

        for (index, option) in options.enumerated() {
            let card = GuidanceGoalPlanOptionCardView()
            card.tag = index
            card.configure(option: option,
                           accentColor: accentColor,
                           detailOnlyWhenSelected: detailOnlyWhenSelected)
            card.addTarget(self, action: #selector(cardTapAction(_:)), for: .touchUpInside)
            card.snp.makeConstraints { make in
                let defaultHeight = kFitWidth(option.detail == nil ? 64 : 92)
                if detailOnlyWhenSelected {
                    make.height.equalTo(guide0820Design(160))
                } else {
                    make.height.greaterThanOrEqualTo(max(layout.cardMinimumHeight, defaultHeight))
                }
            }
            stackView.addArrangedSubview(card)
            cards.append(card)
        }

        refreshSelection(animated: false)
    }

    @objc func cardTapAction(_ sender: GuidanceGoalPlanOptionCardView) {
        guard options.indices.contains(sender.tag) else { return }
        selectedValue = options[sender.tag].value
    }

    func refreshSelection(animated: Bool) {
        for (index, card) in cards.enumerated() {
            let selected = options[index].value == selectedValue
            card.setSelected(selected, animated: animated)
            if detailOnlyWhenSelected {
                card.snp.updateConstraints { make in
                    make.height.equalTo(guide0820Design(selected ? 232 : 160))
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
