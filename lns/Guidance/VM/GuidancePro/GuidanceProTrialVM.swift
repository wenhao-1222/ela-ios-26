//
//  GuidanceProTrialVM.swift
//  lns
//
//  Created by Codex on 2026/3/20.
//

import UIKit
import SnapKit

class GuidanceProTrialVM: UIView {

    private lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_3_guidance_icon"))
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
            "我们为新用户\n免费开放使用 3 天",
            font: .systemFont(ofSize: 24, weight: .medium),
            color: .COLOR_TEXT_TITLE_0f1214,
            lineSpacing: kFitWidth(2)
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
            "让你亲自体验科学高效的饮食管理",
            font: .systemFont(ofSize: 16, weight: .regular),
            color: .COLOR_TEXT_TITLE_0f1214_50,
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

private extension GuidanceProTrialVM {
    func initUI() {
        addSubview(bubbleImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        bubbleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(6))
            make.width.equalTo(kFitWidth(300))
            make.height.equalTo(kFitWidth(415))
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bubbleImageView.snp.bottom).offset(kFitWidth(40))
            make.height.equalTo(kFitWidth(77))
//            make.left.equalTo(kFitWidth(32))
//            make.right.equalTo(kFitWidth(-32))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
//            make.left.equalTo(kFitWidth(24))
//            make.right.equalTo(kFitWidth(-24))
//            make.bottom.equalToSuperview()
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
