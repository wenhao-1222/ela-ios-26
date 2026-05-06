//
//  DietPlanCondimentAlertVM.swift
//  lns
//
//  Created by Codex on 2026/5/6.
//

import UIKit

final class DietPlanCondimentAlertVM: AlertVMCommon {

    override init(frame: CGRect) {
        super.init(frame: frame)
        whiteViewHeight = kFitWidth(385) + WHUtils().getBottomSafeAreaHeight()
        updateWhiteViewLayout()
        configureBaseStyle()
        initContentUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "dietplan_condiment_recommend_alert_img")
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "我们已为你挑选好合适的酱料"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "根据你的口味偏好，我们已筛选出合适搭配正餐的酱料，并标注每餐建议用量。在控制热量的同时，让饮食执行更轻松。"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
}

private extension DietPlanCondimentAlertVM {
    func configureBaseStyle() {
        whiteView.backgroundColor = .COLOR_CARD_BG_WHITE_ALERT
        whiteBlurView.contentView.backgroundColor = UIColor.COLOR_CARD_BG_WHITE_ALERT.withAlphaComponent(0.08)

        confirmButton.setTitle("查看推荐酱料", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        confirmButton.layer.cornerRadius = kFitWidth(22)
    }

    func initContentUI() {
        whiteView.addSubview(iconImageView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(messageLabel)

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(38))
            make.width.equalTo(kFitWidth(250))
            make.height.equalTo(kFitWidth(130))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(30))
            make.right.equalToSuperview().offset(-kFitWidth(30))
            make.top.equalTo(iconImageView.snp.bottom).offset(kFitWidth(22))
        }

        messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(37))
            make.right.equalToSuperview().offset(-kFitWidth(37))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }

        confirmButton.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(20))
            make.right.equalToSuperview().offset(-kFitWidth(20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalToSuperview().offset(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(5)))
        }

        messageLabel.setLineHeightMultiple(textString: messageLabel.text, lineHeightMultiple: 1.32)
    }
}
