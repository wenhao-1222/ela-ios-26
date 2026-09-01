//
//  GuidanceGoalPlanOptionCardView.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit
import SnapKit

/// GuidanceGoalPlanOptionCardView 类型，封装 Guide0820 引导流程中的相关功能。
final class GuidanceGoalPlanOptionCardView: UIControl {
    // PresentationStyle 类型，封装 Guide0820 引导流程中的相关功能。
    private enum PresentationStyle {
        case standard
        case goal
        case profile
        case expandable
    }

    // `titleLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let titleLabel = UILabel()
    // `detailLabel` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let detailLabel = UILabel()
    // `iconImageView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let iconImageView = UIImageView()
    // `checkImageView` 属性，保存该类型对外提供或内部使用的状态与配置。
    private let checkImageView = UIImageView()
    // `accentColor` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var accentColor: UIColor = .THEME
    // `presentationStyle` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var presentationStyle: PresentationStyle = .standard
    // `detailExpanded` 属性，保存该类型对外提供或内部使用的状态与配置。
    private var detailExpanded = false
    // Selection indicator assets; multi-select pages override these with checkbox icons.
    private var checkedImageName = "select_icon_selected_circle"
    private var uncheckedImageName = "select_icon_normal_circle"
    private var selectionState: Bool?

    /// 初始化当前类型实例。
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    /// 初始化当前类型实例。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// `isHighlighted` 属性，保存该类型对外提供或内部使用的状态与配置。
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.72 : 1
        }
    }

    /// 执行 `configure` 操作，完成当前引导页面的状态更新或交互处理。
    func configure(option: GuidanceGoalPlanOption,
                   accentColor: UIColor,
                   detailOnlyWhenSelected: Bool = false,
                   checkedImageName: String = "select_icon_selected_circle",
                   uncheckedImageName: String = "select_icon_normal_circle") {
        self.accentColor = accentColor
        self.checkedImageName = checkedImageName
        self.uncheckedImageName = uncheckedImageName
        self.selectionState = nil
        if detailOnlyWhenSelected && option.detail?.isEmpty == false {
            presentationStyle = .expandable
        } else if option.iconName != nil && (option.detail?.isEmpty == true || option.detail == nil) {
            presentationStyle = .goal
        } else if option.iconName != nil {
            presentationStyle = .profile
        } else {
            presentationStyle = .standard
        }

        layer.cornerRadius = (presentationStyle == .standard) ? kFitWidth(12) : guide0820Design(24)
        layer.borderWidth = presentationStyle == .standard ? 1 : 0
        backgroundColor = GuidanceGoalPlanStyle.cardBackgroundColor
        titleLabel.text = option.title
        detailLabel.text = option.detail
        detailExpanded = presentationStyle != .expandable
        detailLabel.isHidden = option.detail?.isEmpty ?? true || presentationStyle == .goal || (presentationStyle == .expandable && !detailExpanded)

        if let iconName = option.iconName {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.tintColor = GuidanceGoalPlanStyle.titleColor
        } else {
            iconImageView.isHidden = true
            iconImageView.image = nil
        }

        if presentationStyle == .goal || presentationStyle == .profile || presentationStyle == .expandable {
            titleLabel.font = .systemFont(ofSize: guide0820Design(32), weight: .medium)
            titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
            detailLabel.textColor = GuidanceGoalPlanStyle.detailColor
        } else {
            titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
            titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
            detailLabel.textColor = GuidanceGoalPlanStyle.detailColor
        }

        detailLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        detailLabel.guide0820SetLineHeight(guide0820Design(36))

        remakeLayout()
        updateBorderAppearance()
    }

    /// 执行 `setSelected` 操作，完成当前引导页面的状态更新或交互处理。
    func setSelected(_ selected: Bool, animated: Bool = false) {
        if let selectionState, selectionState == selected { return }
        selectionState = selected
        updateBorderAppearance()
        checkImageView.setCheckState(selected,
                                     checkedImageName: checkedImageName,
                                     uncheckedImageName: uncheckedImageName,
                                     animated: animated)
        if presentationStyle == .expandable {
            setDetailExpanded(selected, animated: animated)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection == nil ||
                traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        updateBorderAppearance()
    }

    // 执行 `setDetailExpanded` 操作，完成当前引导页面的状态更新或交互处理。
    private func setDetailExpanded(_ expanded: Bool, animated: Bool) {
        guard detailExpanded != expanded else { return }
        detailExpanded = expanded
        detailLabel.isHidden = !expanded
        remakeLayout()
        guard animated else { return }
        UIView.animate(withDuration: 0.25) {
            self.superview?.layoutIfNeeded()
        }
    }
}

// GuidanceGoalPlanOptionCardView 扩展，提供 Guide0820 流程相关的辅助能力。
private extension GuidanceGoalPlanOptionCardView {
    // 执行 `initUI` 操作，完成当前引导页面的状态更新或交互处理。
    func initUI() {
        backgroundColor = GuidanceGoalPlanStyle.cardBackgroundColor
        layer.cornerRadius = kFitWidth(12)
        layer.borderWidth = 1
        layer.borderColor = GuidanceGoalPlanStyle.unselectedBorderColor
            .resolvedColor(with: traitCollection).cgColor

        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
        titleLabel.numberOfLines = 0

        detailLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
        detailLabel.textColor = GuidanceGoalPlanStyle.detailColor
        detailLabel.numberOfLines = 0

        iconImageView.isUserInteractionEnabled = false
        iconImageView.isHidden = true

        checkImageView.isUserInteractionEnabled = false
        checkImageView.contentMode = .scaleAspectFit

        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(checkImageView)

        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(0)
        }

        checkImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-18))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.right.equalTo(checkImageView.snp.left).offset(kFitWidth(-14))
            make.top.equalTo(kFitWidth(16))
        }

        detailLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            make.bottom.lessThanOrEqualTo(kFitWidth(-16))
        }
    }

    // 执行 `remakeLayout` 操作，完成当前引导页面的状态更新或交互处理。
    func remakeLayout() {
        switch presentationStyle {
        case .goal:
            iconImageView.snp.remakeConstraints { make in
                make.left.equalTo(guide0820Design(32))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(guide0820Design(50))
            }

            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(guide0820Design(116))
                make.right.equalTo(checkImageView.snp.left).offset(guide0820Design(-36))
                make.centerY.equalToSuperview()
            }

            checkImageView.snp.remakeConstraints { make in
                make.right.equalTo(guide0820Design(-32))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(guide0820Design(42))
            }

            detailLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
                make.bottom.lessThanOrEqualTo(kFitWidth(-16))
            }
        case .profile:
            iconImageView.snp.remakeConstraints { make in
                make.left.equalTo(guide0820Design(32))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(guide0820Design(50))
            }

            checkImageView.snp.remakeConstraints { make in
                make.right.equalTo(guide0820Design(-32))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(guide0820Design(42))
            }

            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(guide0820Design(116))
                make.right.equalTo(checkImageView.snp.left).offset(guide0820Design(-36))
                make.top.equalTo(guide0820Design(40))
            }

            detailLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(guide0820Design(12))
                make.bottom.lessThanOrEqualTo(guide0820Design(-40))
            }
        case .expandable:
            iconImageView.snp.remakeConstraints { make in
                make.left.equalTo(guide0820Design(32))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(guide0820Design(50))
            }

            checkImageView.snp.remakeConstraints { make in
                make.right.equalTo(guide0820Design(-32))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(guide0820Design(42))
            }

            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(guide0820Design(116))
                // The mode cards reserve the same 58pt gap between copy and
                // the trailing 42pt selection control as the MasterGo layer.
                make.right.equalTo(checkImageView.snp.left).offset(guide0820Design(-58))
                if detailExpanded {
                    make.top.equalTo(kFitWidth(20))
                } else {
                    make.centerY.equalToSuperview()
                }
            }

            detailLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
                if detailExpanded {
                    make.bottom.equalToSuperview().offset(kFitWidth(-20))
                } else {
                    make.height.equalTo(0)
                }
            }
        case .standard:
            iconImageView.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(18))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(0)
            }

            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(18))
                make.right.equalTo(checkImageView.snp.left).offset(kFitWidth(-14))
                make.top.equalTo(kFitWidth(16))
            }

            checkImageView.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-18))
                make.centerY.equalToSuperview()
                make.width.height.equalTo(kFitWidth(20))
            }

            detailLabel.snp.remakeConstraints { make in
                make.left.right.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
                make.bottom.lessThanOrEqualTo(kFitWidth(-16))
            }
        }
    }

    func updateBorderAppearance() {
        let selected = selectionState ?? false
        let color: UIColor
        switch presentationStyle {
        case .goal, .profile:
            layer.borderWidth = selected ? 1 : 0
            color = selected ? accentColor : .clear
        case .expandable:
            layer.borderWidth = selected ? guide0820Design(4) : 0
            color = selected ? accentColor : .clear
        case .standard:
            layer.borderWidth = 1
            color = selected ? accentColor : GuidanceGoalPlanStyle.unselectedBorderColor
        }
        layer.borderColor = color.resolvedColor(with: traitCollection).cgColor
    }
}
