//
//  AIGuidanceIntroVM.swift
//  lns
//
//  Created by Codex on 2026/4/15.
//

import UIKit
import SnapKit

class AIGuidanceIntroVM: UIView {

    var startBlock: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .white
        isUserInteractionEnabled = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ai_guidance_intro_bg"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 50, weight: .semibold)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 22, weight: .medium)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = kFitWidth(4)

        label.attributedText = NSAttributedString(
            string: "在开始之前，AI教练需要和你\n确认一些信息",
            attributes: [
                .font: label.font as Any,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
        return label
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_expired_alert_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("开始", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        button.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .highlighted)
        button.layer.cornerRadius = kFitWidth(25)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(startButtonTapAction), for: .touchUpInside)
        return button
    }()
}

private extension AIGuidanceIntroVM {
    @objc func startButtonTapAction() {
        startBlock?()
    }

    func initUI() {
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(logoImageView)
        addSubview(startButton)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(200))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(14))
        }

        startButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.height.equalTo(kFitWidth(50))
            make.bottom.equalTo(-(WHUtils().getBottomSafeAreaHeight() + kFitWidth(65)))
        }

        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(130))
            make.height.equalTo(kFitWidth(23))
            make.bottom.equalTo(startButton.snp.top).offset(-kFitWidth(55))
        }
    }
}
