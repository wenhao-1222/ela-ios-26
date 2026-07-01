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
        let imageView = UIImageView(image: UIImage(named: "ela_pro_guidance_icon"))
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
            "我们希望Ela PRO能够真正\n帮到你，而不是引诱你付费",
            font: .systemFont(ofSize: 24, weight: .medium),
            color: .COLOR_TEXT_TITLE_0f1214,
            lineSpacing: kFitWidth(2)
        )
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.text = "我们会在试用结束前48小时提醒你"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.attributedText = centeredText(
//            "我们会在试用结束前48小时提醒你",
//            font: .systemFont(ofSize: 16, weight: .regular),
//            color: .COLOR_TEXT_TITLE_0f1214,
//            lineSpacing: 0
//        )
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
            make.top.equalToSuperview().offset(kFitWidth(150)+WHUtils().getNavigationBarHeight())
            make.width.equalTo(kFitWidth(183))
            make.height.equalTo(kFitWidth(183))
        }

        if WHUtils().getBottomSafeAreaHeight() > 0 {
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(bubbleImageView.snp.bottom).offset(kFitWidth(120))
                make.height.equalTo(kFitWidth(77))
            }
        }else{
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(bubbleImageView.snp.bottom).offset(kFitWidth(90))
                make.height.equalTo(kFitWidth(77))
            }
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(6))
            
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
