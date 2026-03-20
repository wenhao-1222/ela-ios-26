//
//  GuidanceProPromiseVM.swift
//  lns
//
//  Created by Codex on 2026/3/20.
//

import UIKit
import SnapKit

class GuidanceProPromiseVM: UIView {

    private lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_3_guidance_img"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.attributedText = centeredText(
            "我们希望Ela Pro能够真正\n帮到你，而不是引诱你付费",
            font: .systemFont(ofSize: 24, weight: .medium),
            color: .COLOR_TEXT_TITLE_0f1214,
            lineSpacing: kFitWidth(8)
        )
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.attributedText = centeredText(
            "我们会在试用结束前48小时提醒你",
            font: .systemFont(ofSize: 16, weight: .regular),
            color: .COLOR_TEXT_TITLE_0f1214,
            lineSpacing: 0
        )
        return label
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

private extension GuidanceProPromiseVM {
    func initUI() {
        addSubview(bubbleImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        bubbleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kFitWidth(6))
            make.width.equalTo(kFitWidth(322))
            make.height.equalTo(kFitWidth(296))
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bubbleImageView.snp.bottom).offset(kFitWidth(56))
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(34))
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.bottom.equalToSuperview()
        }
    }

    func centeredText(_ text: String, font: UIFont, color: UIColor, lineSpacing: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = lineSpacing

        return NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}
