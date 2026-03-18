//
//  GuidanceReminderPromptVM.swift
//  lns
//
//  Created by Codex on 2026/3/18.
//

import UIKit

class GuidanceReminderPromptVM: UIView {

    var enableReminderBlock: (() -> ())?
    var skipBlock: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_WHITE
        isUserInteractionEnabled = true
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "我们发现"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .semibold)
        return lab
    }()

    lazy var subtitleLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()

    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你可以随时在设置里进行调整"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()

    lazy var placeholderImageView: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()

    lazy var placeholderLabel: UILabel = {
        let lab = UILabel()
        lab.text = "缺图后补"
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        return lab
    }()

    lazy var enableButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("打开提醒", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(enableTapAction), for: .touchUpInside)
        return btn
    }()

    lazy var skipButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("暂时不用", for: .normal)
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        btn.addTarget(self, action: #selector(skipTapAction), for: .touchUpInside)
        return btn
    }()
}

extension GuidanceReminderPromptVM {
    @objc func enableTapAction() {
        enableReminderBlock?()
    }

    @objc func skipTapAction() {
        skipBlock?()
    }

    func initUI() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = kFitWidth(8)
        let subtitleText = NSMutableAttributedString(
            string: "开启个性化提醒的用户\n达成饮食计划目标的概率高出 46%",
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
        let highlightRange = (subtitleText.string as NSString).range(of: "46%")
        subtitleText.addAttributes([
            .foregroundColor: UIColor.THEME,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ], range: highlightRange)
        subtitleLabel.attributedText = subtitleText

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(tipsLabel)
        addSubview(placeholderImageView)
        placeholderImageView.addSubview(placeholderLabel)
        addSubview(enableButton)
        addSubview(skipButton)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(56))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(28))
        }

        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(28))
        }

        placeholderImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(38))
            make.height.equalTo(kFitWidth(310))
        }

        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        enableButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(placeholderImageView.snp.bottom).offset(kFitWidth(34))
        }

        skipButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(enableButton.snp.bottom).offset(kFitWidth(22))
        }
    }
}
