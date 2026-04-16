//
//  AIGuidanceElaProIntroVM.swift
//  lns
//
//  Created by Codex on 2026/3/24.
//

import UIKit
import SnapKit

class AIGuidanceElaProIntroVM: UIView {

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ai_ela_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeTitleText("基于你的饮食训练与身体变化\n系统化复盘进度")
        return label
    }()

    private lazy var featureStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            FeatureItemView(
                iconImageName: "ai_guidance_intro_target_icon",
                title: "精准突破瓶颈",
                detail: "从多维数据里提前发现卡点，在瓶颈期出现前就先介入，并给出可执行的动作。"
            ),
            FeatureItemView(
                iconImageName: "ai_guidance_intro_meditation_icon",
                title: "告别结果焦虑",
                detail: "帮你区分哪些体重波动是真正的进度阻碍，哪些只是短期噪音，拒绝盲目内耗。"
            ),
            FeatureItemView(
                iconImageName: "ai_guidance_intro_chart_icon",
                title: "持续动态优化",
                detail: "随着使用更加了解你的身体反应，持续为你优化方案，你只管执行。"
            )
        ])
        stackView.axis = .vertical
        stackView.spacing = kFitWidth(26)
        return stackView
    }()
}

private extension AIGuidanceElaProIntroVM {
    func initUI() {
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(featureStackView)

        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(105))
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(40))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(45))
        }

        featureStackView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(25))
            make.bottom.lessThanOrEqualTo(safeAreaLayoutGuide.snp.bottom).offset(-kFitWidth(110))
        }
    }

    func makeTitleText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = kFitWidth(4)

        return NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}

private final class FeatureItemView: UIView {

    private let iconImageName: String
    private let titleText: String
    private let detailText: String

    init(iconImageName: String, title: String, detail: String) {
        self.iconImageName = iconImageName
        self.titleText = title
        self.detailText = detail
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: iconImageName))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleText
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeDetailText(detailText)
        return label
    }()

    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = kFitWidth(8)
        return stackView
    }()

    private func setupUI() {
        backgroundColor = .clear

        addSubview(headerStackView)
        addSubview(detailLabel)

        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(24))
        }

        headerStackView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }

        detailLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(kFitWidth(31))
            make.right.equalToSuperview()
            make.top.equalTo(headerStackView.snp.bottom).offset(kFitWidth(10))
            make.bottom.equalToSuperview()
        }
    }

    private func makeDetailText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = kFitWidth(5)

        return NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,//.withAlphaComponent(0.78),
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}
