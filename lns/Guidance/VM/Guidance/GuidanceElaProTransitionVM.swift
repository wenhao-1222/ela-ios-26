//
//  GuidanceElaProTransitionVM.swift
//  lns
//
//  Created by Codex on 2026/4/10.
//

import UIKit
import SnapKit

class GuidanceElaProTransitionVM: UIView {

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .white
        isUserInteractionEnabled = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_progress_bg")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
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
        return label
    }()
    
    lazy var dottedLineView: DottedLineView = {
        let vi = DottedLineView.init(frame: CGRect.init(x: kFitWidth(32), y: kFitWidth(290)+WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT-kFitWidth(64), height: kFitHeight(1)))
        
        return vi
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2

        label.attributedText = NSAttributedString(
            string: "AI教练会根据你的饮食执行情况和体重变化\n持续帮你调整每日摄入",
            attributes: [
                .font: label.font as Any,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
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
}

private extension GuidanceElaProTransitionVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(dottedLineView)
        addSubview(descriptionLabel)
        addSubview(bulletStackView)
        
        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(193))
            make.width.equalTo(kFitWidth(112))
            make.height.equalTo(kFitWidth(20))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(logoImageView)
            make.right.equalTo(kFitWidth(-28))
            make.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(15))
        }
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(logoImageView)
            make.right.equalTo(dottedLineView)
            make.top.equalTo(dottedLineView.snp.bottom).offset(kFitWidth(28))
        }

        bulletStackView.snp.makeConstraints { make in
            make.left.equalTo(descriptionLabel)
            make.right.lessThanOrEqualTo(descriptionLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(kFitWidth(18))
        }
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
        let font = UIFont.systemFont(ofSize: 13, weight: .regular)
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
}
