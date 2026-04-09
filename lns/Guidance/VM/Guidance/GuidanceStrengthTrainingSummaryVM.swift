//
//  GuidanceStrengthTrainingSummaryVM.swift
//  lns
//
//  Created by Codex on 2026/3/17.
//

class GuidanceStrengthTrainingSummaryVM: UIView {

    struct DisplayContent {
        let title: String
        let primaryMessage: String
        let secondaryMessage: String
    }

    var nextBlock: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true

        initUI()
        refreshContentFromModel()
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

    lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_WHITE_65
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderWidth = 1
        vi.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
        vi.clipsToBounds = true
        return vi
    }()

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var primaryMessageLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textAlignment = .left
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()

    lazy var secondaryMessageLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textAlignment = .left
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        return lab
    }()

    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextTapAction), for: .touchUpInside)
        return btn
    }()

    lazy var footerLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textAlignment = .left
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()
}

extension GuidanceStrengthTrainingSummaryVM {
    @objc func nextTapAction() {
        nextBlock?()
    }

    func refreshContentFromModel() {
        let content = contentForStrengthType(QuestinonaireMsgModel.shared.guidanceStrengthTrainingFrequencyType)
        titleLabel.text = content.title
        primaryMessageLabel.text = content.primaryMessage
        secondaryMessageLabel.text = content.secondaryMessage
        primaryMessageLabel.setLineHeightMultiple(lineHeightMultiple: 1.2)
        secondaryMessageLabel.setLineHeightMultiple(lineHeightMultiple: 1.2)
//        primaryMessageLabel.setLineHeight(
//            textString: content.primaryMessage,
//            lineHeight: primaryMessageLabel.font.lineHeight * 1
//        )
//        secondaryMessageLabel.setLineHeight(
//            textString: content.secondaryMessage,
//            lineHeight: secondaryMessageLabel.font.lineHeight * 1
//        )
        footerLabel.attributedText = footerAttributedText()
    }

    private func contentForStrengthType(_ type: String) -> DisplayContent {
        switch type {
        case "0-2":
            return DisplayContent(
                title: "每周 0-2 次",
                primaryMessage: "如果你每周能再增加 1 到 2 次力量训练，通常就可以获得很好的效果。",
                secondaryMessage: "历史上有许多顶尖运动员（例如 Dorian Yates 和 Mike Mentzer）仅靠每周 3 到 4 次训练，就达到了世界上最好的体型之一。"
            )
        case "3-4":
            return DisplayContent(
                title: "每周 3-4 次",
                primaryMessage: "每周 3 到 4 次力量训练能确保你在使用极高强度训练时，仍然有充足的时间让身体恢复。",
                secondaryMessage: "历史上有许多顶尖运动员（例如 Dorian Yates 和 Mike Mentzer）都依靠这样的方式达到了世界上最好的体型之一。"
            )
        case "5-6":
            return DisplayContent(
                title: "每周 5-6 次",
                primaryMessage: "每周5-6次是最稳健的力量训练安排，在饮食得到保障的前提下，你可以非常好地兼顾训练强度、容量与恢复。",
                secondaryMessage: "大部分顶尖健美运动员（Phil Heath，Jay Cutler 等）都是使用这种方式。"
            )
        case "7+":
            return DisplayContent(
                title: "每周 7+ 次",
                primaryMessage: "这是非常挑战恢复能力的训练安排，不仅需要极致的饮食，更需要很强的恢复条件与天赋。",
                secondaryMessage: "历史上仅有少数优秀健美运动员（例如阿诺·施瓦辛格）能够用这种方式并获得收益。"
            )
        default:
            return DisplayContent(
                title: "每周 3-4 次",
                primaryMessage: "每周 3 到 4 次力量训练能确保你在使用极高强度训练时，仍然有充足的时间让身体恢复。",
                secondaryMessage: "历史上有许多顶尖运动员（例如 Dorian Yates 和 Mike Mentzer）都依靠这样的方式达到了世界上最好的体型之一。"
            )
        }
    }

    private func footerAttributedText() -> NSAttributedString {
        let fullText = "当然，训练频率不存在通用最优解。你可以用我们提供的“力量训练标签”记录每周训练/休息次数，并结合身体变化与训练表现持续复盘和微调，逐步确定你的最佳训练安排。"
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214_50
            ]
        )
        let boldText = "你可以用我们提供的“力量训练标签”记录每周训练/休息次数"
        let range = (fullText as NSString).range(of: boldText)
        if range.location != NSNotFound {
            attributed.addAttributes(
                [
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                    .foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214
                ],
                range: range
            )
        }
        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.minimumLineHeight = kFitWidth(14)
//        paragraphStyle.maximumLineHeight = kFitWidth(14)
//        paragraphStyle.lineHeightMultiple = 1
        paragraphStyle.lineSpacing = kFitWidth(4)
        attributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullText.count))
        return attributed
    }
}

extension GuidanceStrengthTrainingSummaryVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(cardView)
        addSubview(footerLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(primaryMessageLabel)
        cardView.addSubview(secondaryMessageLabel)
        cardView.addSubview(nextButton)

        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.right.equalTo(kFitWidth(-25))
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(115))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(30))
            make.height.equalTo(kFitWidth(36))
            make.centerX.equalToSuperview()
        }

        primaryMessageLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }

        secondaryMessageLabel.snp.makeConstraints { make in
            make.left.right.equalTo(primaryMessageLabel)
            make.top.equalTo(primaryMessageLabel.snp.bottom).offset(kFitWidth(12))
        }

        nextButton.snp.makeConstraints { make in
            make.top.equalTo(secondaryMessageLabel.snp.bottom).offset(kFitWidth(40))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(232))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-30))
        }

        footerLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-45))
            make.top.equalTo(cardView.snp.bottom).offset(kFitWidth(45))
        }
    }
}
