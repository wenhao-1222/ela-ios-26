//
//  DietPlanManualTargetLimitAlertVM.swift
//  lns
//
//  Created by LNS2 on 2026/4/14.
//

enum ManualTargetLimitAlertType {
    case tooLow(gender: DietTargetGender, minimumCalories: Int)
    case tooHigh
}

enum DietTargetGender {
    case male
    case female
    case unknown

    var minimumCalories: Int {
        switch self {
        case .male:
            return 1500
        case .female, .unknown:
            return 1200
        }
    }
}

class DietPlanManualTargetLimitAlertVM: AlertVMCommon {

    override init(frame: CGRect) {
        super.init(frame: frame)
        whiteViewHeight = kFitWidth(278) + WHUtils().getBottomSafeAreaHeight()
        updateWhiteViewLayout()
        configureBaseStyle()
        initContentUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    private lazy var iconView: UIImageView = {
//        let view = UIImageView()
//        view.contentMode = .scaleAspectFit
//        view.image = UIImage(systemName: "exclamationmark.circle.fill")
//        view.tintColor = UIColor.THEME.withAlphaComponent(0.08)
//        return view
//    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .COLOR_TEXT_TITLE_0f1214_20
        button.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .THEME
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
}

private extension DietPlanManualTargetLimitAlertVM {
    func configureBaseStyle() {
        whiteView.backgroundColor = .COLOR_CARD_BG_WHITE_ALERT
        whiteBlurView.contentView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.08)
        confirmButton.setTitle("知道了", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
    }

    func initContentUI() {
//        whiteView.addSubview(iconView)
        whiteView.addSubview(closeButton)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(messageLabel)

//        iconView.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(kFitWidth(18))
//            make.top.equalToSuperview().offset(kFitWidth(20))
//            make.width.height.equalTo(kFitWidth(56))
//        }

        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-kFitWidth(16))
            make.top.equalToSuperview().offset(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(28))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(44))
            make.right.equalToSuperview().offset(-kFitWidth(44))
            make.top.equalToSuperview().offset(kFitWidth(50))
        }

        messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(34))
            make.right.equalToSuperview().offset(-kFitWidth(34))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(22))
        }
    }

}

extension DietPlanManualTargetLimitAlertVM {
    func update(type: ManualTargetLimitAlertType) {
        switch type {
        case let .tooLow(gender, minimumCalories):
            titleLabel.text = "热量目标过低"
            messageLabel.text = buildLowMessage(gender: gender, minimumCalories: minimumCalories)
        case .tooHigh:
            titleLabel.text = "热量目标过高"
            messageLabel.text = "每日摄入超过 5000 大卡可能会给身体带来额外负担。建议您适度下调热量目标，循序渐进。"
        }

        messageLabel.setLineHeightMultiple(textString: messageLabel.text, lineHeightMultiple: 1.35)
    }

    func buildLowMessage(gender: DietTargetGender, minimumCalories: Int) -> String {
        switch gender {
        case .male:
            return "为了保证基础代谢和身体健康，男性的每日建议摄入量不应低于 \(minimumCalories) 大卡。请适当上调您的目标。"
        case .female:
            return "为了保证基础代谢和身体健康，女性的每日建议摄入量不应低于 \(minimumCalories) 大卡。请适当上调您的目标。"
        case .unknown:
            return "为了保证基础代谢和身体健康，每日建议摄入量不应低于 \(minimumCalories) 大卡。请适当上调您的目标。"
        }
    }
}
