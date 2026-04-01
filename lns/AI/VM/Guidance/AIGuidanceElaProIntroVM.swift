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
        let imageView = UIImageView(image: UIImage(named: "guidance_pro_intro_img"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ai教练会基于"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
//        label.text = "你以往的饮食、训练与身体变化，系统化复盘进度"
//        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 16, weight: .regular)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5

        label.attributedText = NSAttributedString(
            string: "你以往的饮食、训练与身体变化，系统化复盘进度",
            attributes: [
                .font: label.font as Any,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214,
                .paragraphStyle: paragraphStyle
            ]
        )
        return label
    }()

    private lazy var pointOneLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeBulletText(
            normalText: "从多维数据里提前发现你还没意识到的卡点，在瓶颈期出现之前就先介入，并给出下一步最小动作。",
            boldTexts: ["提前发现", "最小动作"]
        )
        return label
    }()

    private lazy var pointTwoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeBulletText(
            normalText: "区分哪些体重波动是真正的进度阻碍，哪些只是短期噪音，避免结果焦虑。",
            boldTexts: ["进度阻碍", "短期噪音"]
        )
        return label
    }()

    private lazy var pointThreeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.attributedText = makeBulletText(
            normalText: "随着使用去更加解你的身体反应，持续优化方案并快速微调，让你只需执行。",
            boldTexts: ["身体反应", "快速微调"]
        )
        return label
    }()
}

private extension AIGuidanceElaProIntroVM {
    func initUI() {
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(pointOneLabel)
        addSubview(pointTwoLabel)
        addSubview(pointThreeLabel)

        logoImageView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(105))
//            make.width.equalTo(kFitWidth(139))
//            make.height.equalTo(kFitWidth(36))
            make.width.equalTo(kFitWidth(165))
            make.height.equalTo(kFitWidth(29))
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(45))
            make.right.equalTo(kFitWidth(-32))
        }

        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
        }

        pointOneLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.right.equalTo(kFitWidth(-32))
            make.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(35))
        }

        pointTwoLabel.snp.makeConstraints { make in
            make.left.right.equalTo(pointOneLabel)
            make.top.equalTo(pointOneLabel.snp.bottom).offset(kFitWidth(16))
        }

        pointThreeLabel.snp.makeConstraints { make in
            make.left.right.equalTo(pointOneLabel)
            make.top.equalTo(pointTwoLabel.snp.bottom).offset(kFitWidth(16))
        }
    }

    func makeBulletText(normalText: String, boldTexts: [String]) -> NSAttributedString {
        let bullet = "•"
        let bulletSpacing = "  "
        let bulletPrefix = bullet + bulletSpacing
        let bulletFont = UIFont.systemFont(ofSize: 15, weight: .medium)
        let contentFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let bulletIndent = (bulletPrefix as NSString).size(withAttributes: [.font: contentFont]).width

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.45
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = bulletIndent
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: bulletIndent)]

        let attributed = NSMutableAttributedString(
            string: "\(bullet)\t\(normalText)",
            attributes: [
                .font: contentFont,
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50,
                .paragraphStyle: paragraphStyle
            ]
        )

        attributed.addAttributes([
            .foregroundColor: UIColor.THEME,
            .font: bulletFont
        ], range: NSRange(location: 0, length: (bullet as NSString).length))

        for boldText in boldTexts {
            let nsString = attributed.string as NSString
            let range = nsString.range(of: boldText)
            if range.location != NSNotFound {
                attributed.addAttributes([
                    .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                    .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214
                ], range: range)
            }
        }

        return attributed
    }
}
