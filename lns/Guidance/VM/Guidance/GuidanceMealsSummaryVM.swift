//
//  GuidanceMealsSummaryVM.swift
//  lns
//
//  Created by Codex on 2026/3/17.
//

class GuidanceMealsSummaryVM: UIView {

    struct DisplayContent {
        let title: String
        let message: String
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
        vi.backgroundColor = .COLOR_WHITE_65//UIColor.white.withAlphaComponent(0.9)
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderWidth = 1
        vi.layer.borderColor = UIColor.COLOR_CARD_BG_WHITE.cgColor
        vi.clipsToBounds = true
        return vi
    }()

    lazy var titleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var messageLabel: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 16, weight: .regular)
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
}

extension GuidanceMealsSummaryVM {
    @objc func nextTapAction() {
        nextBlock?()
    }

    func refreshContentFromModel() {
        let content = contentForMealsPerDayType(QuestinonaireMsgModel.shared.guidanceMealsPerDayType)
        titleLabel.customLineHeight = titleLabel.font.lineHeight * 1.1
        titleLabel.attributedText = makeAttributedText(
            text: content.title,
            font: titleLabel.font,
            textColor: titleLabel.textColor
        )
        messageLabel.setLineHeightMultiple(
            attr: makeAttributedText(
                text: content.message,
                font: messageLabel.font,
                textColor: messageLabel.textColor
            ),
            lineHeightMultiple: 1.2
        )
    }

    private func contentForMealsPerDayType(_ type: String) -> DisplayContent {
        switch type {
        case "2":
            return DisplayContent(
                title: "每天 1-2 餐",
                
                message: "每天吃1-2餐能够在最短的时间内解决饮食，但是可能会造成比较高的血糖和胃口波动。当然，只要你觉得舒服好坚持，就是最适合你的安排。"
            )
        case "3":
            return DisplayContent(
                title: "每天 3 餐",
                message: "每天 3 餐是最通用省心的安排，更符合大多数人的作息，也能稳稳推进你的健身目标。"
            )
        case "4":
            return DisplayContent(
                title: "每天 4 餐",
                message: "这是很好的第一步，每天 4 餐是非常均衡的安排，能让全天摄入更均匀，血糖更稳定，也更容易把增肌或减脂稳稳推进。"
            )
        case "5":
            return DisplayContent(
                title: "每天 5 餐",
                message: "每天 5 餐是非常成熟的饮食安排，对血糖和食欲控制都很友好，也能更稳更快地推进你的目标。"
            )
        case "6+":
            return DisplayContent(
                title: "每天 6+ 餐",
                message: "每天 6 +餐已经是硬核健身老炮的水平了，向你致敬。无论是胃口控制，还是增肌或减脂计划的执行，你都更容易把细节做满，效果也更稳。"
            )
        default:
            return DisplayContent(
                title: "每天 3 餐",
                message: "每天 3 餐是最通用省心的安排，更符合大多数人的作息，也能稳稳推进你的健身目标。"
            )
        }
    }
}
extension GuidanceMealsSummaryVM {
    func initUI() {
        addSubview(bgImgView)
        addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(nextButton)

        bgImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(25))
            make.right.equalTo(kFitWidth(-25))
            make.centerY.equalToSuperview().offset(kFitWidth(-70))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(30))
            make.height.equalTo(kFitWidth(36))
            make.centerX.equalToSuperview()
        }

        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }

        nextButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(kFitWidth(50))
            make.centerX.equalToSuperview()
            make.width.equalTo(kFitWidth(232))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(kFitWidth(-30))
        }
    }
}
