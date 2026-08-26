//
//  GuidanceGoalPlanOptionCardView.swift
//  lns
//
//  Created by Codex on 2026/8/26.
//

import UIKit
import SnapKit

final class GuidanceGoalPlanOptionCardView: UIControl {
    private enum PresentationStyle {
        case standard
        case goal
        case profile
    }

    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let iconImageView = UIImageView()
    private let checkImageView = UIImageView()
    private var accentColor: UIColor = .THEME
    private var presentationStyle: PresentationStyle = .standard

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.72 : 1
        }
    }

    func configure(option: GuidanceGoalPlanOption, accentColor: UIColor) {
        self.accentColor = accentColor
        if option.iconName != nil && (option.detail?.isEmpty == true || option.detail == nil) {
            presentationStyle = .goal
        } else if option.iconName != nil {
            presentationStyle = .profile
        } else {
            presentationStyle = .standard
        }

        layer.cornerRadius = (presentationStyle == .standard) ? kFitWidth(12) : guide0820Design(24)
        layer.borderWidth = presentationStyle == .standard ? 1 : 0
        layer.borderColor = presentationStyle == .standard ? GuidanceGoalPlanStyle.unselectedBorderColor : UIColor.clear.cgColor
        backgroundColor = presentationStyle == .standard ? GuidanceGoalPlanStyle.cardBackgroundColor : .white
        titleLabel.text = option.title
        detailLabel.text = option.detail
        detailLabel.isHidden = option.detail?.isEmpty ?? true || presentationStyle == .goal

        if let iconName = option.iconName {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.tintColor = GuidanceGoalPlanStyle.titleColor
        } else {
            iconImageView.isHidden = true
            iconImageView.image = nil
        }

        if presentationStyle == .goal || presentationStyle == .profile {
            titleLabel.font = .systemFont(ofSize: guide0820Design(32), weight: .medium)
            titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
            detailLabel.font = .systemFont(ofSize: guide0820Design(24), weight: .regular)
            detailLabel.textColor = GuidanceGoalPlanStyle.detailColor
        } else {
            titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
            titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
            detailLabel.font = .systemFont(ofSize: 13, weight: .regular)
            detailLabel.textColor = GuidanceGoalPlanStyle.detailColor
        }

        remakeLayout()
    }

    func setSelected(_ selected: Bool, animated: Bool = false) {
        if presentationStyle == .goal || presentationStyle == .profile {
            backgroundColor = selected ? accentColor.withAlphaComponent(0.10) : .white
            layer.borderColor = selected ? accentColor.cgColor : UIColor.clear.cgColor
            layer.borderWidth = selected ? 1 : 0
            titleLabel.textColor = selected ? accentColor : GuidanceGoalPlanStyle.titleColor
        } else {
            backgroundColor = selected ? accentColor.withAlphaComponent(0.10) : GuidanceGoalPlanStyle.cardBackgroundColor
            layer.borderColor = selected ? accentColor.cgColor : GuidanceGoalPlanStyle.unselectedBorderColor
            layer.borderWidth = 1
            titleLabel.textColor = selected ? accentColor : GuidanceGoalPlanStyle.titleColor
        }
        checkImageView.setCheckState(selected,
                                     checkedImageName: "select_icon_selected_circle",
                                     uncheckedImageName: "select_icon_normal_circle",
                                     animated: animated)
    }
}

private extension GuidanceGoalPlanOptionCardView {
    func initUI() {
        backgroundColor = GuidanceGoalPlanStyle.cardBackgroundColor
        layer.cornerRadius = kFitWidth(12)
        layer.borderWidth = 1
        layer.borderColor = GuidanceGoalPlanStyle.unselectedBorderColor

        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = GuidanceGoalPlanStyle.titleColor
        titleLabel.numberOfLines = 0

        detailLabel.font = .systemFont(ofSize: 13, weight: .regular)
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
}
