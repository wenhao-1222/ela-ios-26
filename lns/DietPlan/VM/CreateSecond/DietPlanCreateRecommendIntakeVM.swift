//
//  DietPlanCreateRecommendIntakeVM.swift
//  lns
//
//  Created by Codex on 2026/3/16.
//

class DietPlanCreateRecommendIntakeVM: UIView {

    var editTargetBlock: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .COLOR_BG_F2
        isUserInteractionEnabled = true
        clipsToBounds = true

        initUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 2
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var cardView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var caloriesLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .THEME
        lab.font = UIFont().DDInFontSemiBold(fontSize: 50)
        lab.text = "--"
        return lab
    }()

    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "千卡(kcal) "
//        lab.text = "kcal"
        return lab
    }()

    lazy var targetDescLabel: UILabel = {
        let lab = UILabel()
        lab.textAlignment = .center
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .regular)
        lab.text = "预计每月保持稳定"
        return lab
    }()

    lazy var editButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("编辑目标", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        if let image = UIImage(systemName: "square.and.pencil") {
            btn.setImage(image, for: .normal)
            btn.tintColor = .THEME
            btn.imageView?.contentMode = .scaleAspectFit
            btn.semanticContentAttribute = .forceLeftToRight
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -kFitWidth(6), bottom: 0, right: kFitWidth(6))
        }
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(editButtonTapAction), for: .touchUpInside)
        return btn
    }()
}

extension DietPlanCreateRecommendIntakeVM {
    func initUI() {
        addSubview(titleLabel)
        addSubview(cardView)
        cardView.addSubview(caloriesLabel)
        cardView.addSubview(unitLabel)
        cardView.addSubview(targetDescLabel)
        cardView.addSubview(editButton)

        titleLabel.text = "根据你的情况\n我们建议每天摄入"
//        titleLabel.setLineHeight(
//            textString: "根据你的情况\n我们建议每天摄入",
//            lineHeight: titleLabel.font.lineHeight //* 1.15
//        )

        setConstraint()
        refreshContent()
    }

    func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(72))
        }

        cardView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(45))
            make.height.equalTo(kFitWidth(234))
        }

        caloriesLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(30))
        }

        unitLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(caloriesLabel.snp.bottom).offset(kFitWidth(6))
        }

        targetDescLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(unitLabel.snp.bottom).offset(kFitWidth(14))
        }

        editButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.bottom.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(39))
        }
    }

    func refreshContent() {
        let caloriesText = QuestinonaireMsgModel.shared.caloriesNumber
        if caloriesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            caloriesLabel.text = "--"
        } else {
            caloriesLabel.text = caloriesText
        }
        targetDescLabel.text = buildMonthlyTargetDescription()
    }

    func updateCalories(_ caloriesText: String) {
        QuestinonaireMsgModel.shared.caloriesNumber = caloriesText
        refreshContent()
    }

    func buildMonthlyTargetDescription() -> String {
        let currentWeight = Double(QuestinonaireMsgModel.shared.weight) ?? 0
        let targetWeight = Double(QuestinonaireMsgModel.shared.targetWeight) ?? 0
        let delta = targetWeight - currentWeight
        if abs(delta) < 0.05 {
            return "预计每月保持稳定"
        }

        let monthlyRate: Double
        switch QuestinonaireMsgModel.shared.paceLevel {
        case "1", "slight":
            monthlyRate = 1.0
        case "3", "major":
            monthlyRate = 2.8
        default:
            monthlyRate = 2.0
        }

        let displayValue = min(abs(delta), monthlyRate)
        let displayText = formatRate(displayValue)
        return delta < 0 ? "预计每月减少 \(displayText)kg" : "预计每月增加 \(displayText)kg"
    }

    func formatRate(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        let integer = Int(rounded)
        if abs(rounded - Double(integer)) < 0.001 {
            return "\(integer)"
        }
        return String(format: "%.1f", rounded)
    }

    @objc func editButtonTapAction() {
        editTargetBlock?()
    }
}
