//
//  GuideTotalProNoticeVM.swift
//  lns
//
//  Created by Codex on 2026/7/7.
//

import UIKit
import SnapKit

class GuideTotalProNoticeVM: UIView {

    var nextBlock: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ela_pro_ai_attention_icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "注意事项"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "在开始使用 AI 教练之前"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 14, weight: .regular)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        paragraphStyle.alignment = .center

        label.attributedText = NSAttributedString(
            string: "请尽量把每天的饮食、体重、力量训练记录完整数据越完整，AI 教练给到你的反馈就越精准",
            attributes: [
                .font: label.font as Any,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
                .paragraphStyle: paragraphStyle
            ]
        )
        return label
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = kFitWidth(8)
        button.clipsToBounds = true
        button.enablePressEffect()
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return button
    }()
}

private extension GuideTotalProNoticeVM {
    func initUI() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(detailLabel)
        addSubview(nextButton)

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(105))
            make.width.height.equalTo(kFitWidth(205))
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(kFitWidth(52))
            make.left.greaterThanOrEqualTo(kFitWidth(24))
            make.right.lessThanOrEqualTo(kFitWidth(-24))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
            make.left.greaterThanOrEqualTo(kFitWidth(24))
            make.right.lessThanOrEqualTo(kFitWidth(-24))
        }

        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(9))
        }

        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(10))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(302))
            make.height.equalTo(kFitWidth(48))
        }
    }

    @objc func nextButtonAction() {
        nextBlock?()
    }
}

extension GuideTotalProNoticeVM {
    func prepareEntranceAnimation() {
        iconImageView.alpha = 0
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        detailLabel.alpha = 0
        nextButton.alpha = 0
    }

    func startEntranceAnimation() {
        UIView.animate(withDuration: 0.55, delay: 0, options: .curveLinear) {
            self.iconImageView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.55, delay: 0.1, options: .curveLinear) {
                self.titleLabel.alpha = 1
                self.subtitleLabel.alpha = 1
                self.detailLabel.alpha = 1
                self.nextButton.alpha = 1
            }
        }
    }
}
