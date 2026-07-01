//
//  GuidanceProDietRecordVM.swift
//  lns
//
//  Created by Codex on 2026/6/30.
//

import UIKit
import SnapKit

class GuidanceProDietRecordVM: UIView {

    var nextTapBlock: (() -> Void)?

    private lazy var bgImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.setImgLocal(imgName: "ela_pro_progress_bg")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_expired_alert_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "你只用记录饮食，剩下的交给我们"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.82
        return label
    }()

    private lazy var dottedLineView: DottedLineView = {
        let view = DottedLineView()
        view.lineColor = .COLOR_TEXT_TITLE_0f1214_20
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeDescriptionText()
        return label
    }()

    private lazy var bulletStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            makeBulletLabel("帮助你更好坚持"),
            makeBulletLabel("防止偏离目标"),
            makeBulletLabel("在平台期及时调整方向")
        ])
        stackView.axis = .vertical
        stackView.spacing = kFitWidth(7)
        stackView.alignment = .leading
        return stackView
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.layer.cornerRadius = kFitWidth(24)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GuidanceProDietRecordVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(dottedLineView)
        addSubview(descriptionLabel)
        addSubview(bulletStackView)
        addSubview(nextButton)

        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(230))
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(20))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(logoImageView)
            make.right.equalTo(kFitWidth(-28))
            make.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(15))
        }

        dottedLineView.snp.makeConstraints { make in
            make.left.equalTo(logoImageView)
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(30))
            make.height.equalTo(kFitWidth(1))
        }

        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(logoImageView)
            make.right.equalTo(dottedLineView)
            make.top.equalTo(dottedLineView.snp.bottom).offset(kFitWidth(28))
        }

        bulletStackView.snp.makeConstraints { make in
            make.left.equalTo(descriptionLabel).offset(kFitWidth(8))
            make.right.lessThanOrEqualTo(descriptionLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(kFitWidth(18))
        }

        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
        }
    }

    func makeDescriptionText() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = kFitWidth(7)

        return NSAttributedString(
            string: "AI 教练会根据你的饮食执行情况和体重变化\n持续帮你调整每日摄入",
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
    }

    func makeBulletLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeBulletText(text)
        return label
    }

    func makeBulletText(_ text: String) -> NSAttributedString {
        let bulletPrefix = "•  "
        let fullText = bulletPrefix + text
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        let bulletRange = NSRange(location: 0, length: 1)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.18

        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: font,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
                .paragraphStyle: paragraphStyle
            ]
        )
        attributedText.addAttributes([
            .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], range: bulletRange)

        return attributedText
    }

    @objc func nextButtonTapAction() {
        nextTapBlock?()
    }
}
