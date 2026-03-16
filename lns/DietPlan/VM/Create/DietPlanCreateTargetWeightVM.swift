//
//  DietPlanCreateTargetWeightVM.swift
//  lns
//
//  Created by Codex on 2026/2/26.
//

class DietPlanCreateTargetWeightVM: UIView {

    /*
     ●（1. 体重上限 150kg，下限 40kg，超过提示：请更新体重目标；你填写的体重可能会不利于你的健康。你可以选择跳过这一步，我们会为你推荐一个更合理的默认目标。）
     ●（2. 选择了：降低血脂
     提示：这个体重可能会不利于你达到降低血脂的目标。你可以选择跳过这一步，我们会为你推荐一个更合理的默认目标。）

     ●目标低于最低：取 40kg
     ●目标超过最高：取 150kg
     ●选降低血脂：取现在体重 90%

     默认目标 / 维持，跳过问题 8、9
     */
    private let minWeight = 30.0
    private let maxWeight = 180.0
    private let stepWeight = 0.1
    private let alertMinWeight = 40.0
    private let alertMaxWeight = 150.0

    var currentWeightValue = 60.0
    var currentTargetWeight = 60.0
    
    var valueChanged = false

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        backgroundColor = .clear
        isUserInteractionEnabled = true
        initUI()
        applyInitialValue()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "你的目标体重是?"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        return lab
    }()

    lazy var targetWeightLabel: YYLabel = {
        let lab = YYLabel()
        lab.textAlignment = .center
        return lab
    }()

    lazy var rulerView: DietPlanTargetWeightRulerView = {
        let v = DietPlanTargetWeightRulerView()
        v.minValue = minWeight
        v.maxValue = maxWeight
        v.stepValue = stepWeight
        v.onValueChanged = { [weak self] value in
            self?.updateTargetWeight(value: value)
        }
        return v
    }()

    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        lab.alpha = 0
        return lab
    }()

    lazy var currentWeightCard: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_05
        vi.layer.cornerRadius = kFitWidth(12)
        vi.clipsToBounds = true
        return vi
    }()

    lazy var currentWeightTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "当前体重"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        return lab
    }()

    lazy var currentWeightValueLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = .right
        return lab
    }()
}

extension DietPlanCreateTargetWeightVM {
    func syncWithCurrentWeight(_ weight: Double, syncTarget: Bool = true) {
        currentWeightValue = clamp(roundToTenth(weight))
        currentWeightValueLabel.text = "\(formatOneDecimal(currentWeightValue)) 公斤"
        if syncTarget {
            currentTargetWeight = currentWeightValue
            updateTargetWeightText(value: currentTargetWeight)
            QuestinonaireMsgModel.shared.targetWeight = formatOneDecimal(currentTargetWeight)
            NotificationCenter.default.post(name: .dietPlanPaceInputDidChange, object: nil)
            DispatchQueue.main.async {
                self.rulerView.setValue(self.currentTargetWeight, animated: false)
            }
        }
        updateGoalTips()
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(targetWeightLabel)
        addSubview(rulerView)
        addSubview(tipsLabel)
        addSubview(currentWeightCard)
        currentWeightCard.addSubview(currentWeightTitleLabel)
        currentWeightCard.addSubview(currentWeightValueLabel)
        setConstraint()
    }

    func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight() + kFitWidth(55))
        }

        targetWeightLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(98))
            make.height.equalTo(kFitWidth(66))
        }

        rulerView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
            make.left.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-24))
            make.top.equalTo(targetWeightLabel.snp.bottom).offset(kFitWidth(26))
            make.height.equalTo(kFitWidth(110))
        }

        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(rulerView.snp.bottom).offset(kFitWidth(14))
        }

        currentWeightCard.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(31))
            make.right.equalTo(kFitWidth(-31))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(40))
            make.height.equalTo(kFitWidth(60))
        }

        currentWeightTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.equalToSuperview()
        }

        currentWeightValueLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.centerY.equalToSuperview()
        }
    }

    func applyInitialValue() {
        let parsedWeight = parseWeight(QuestinonaireMsgModel.shared.weight) ?? 60.0
        syncWithCurrentWeight(parsedWeight, syncTarget: false)
        let targetFromModel = parseWeight(QuestinonaireMsgModel.shared.targetWeight)
        let initialTarget = targetFromModel ?? currentWeightValue
        currentTargetWeight = clamp(roundToTenth(initialTarget))
        updateTargetWeightText(value: currentTargetWeight)
        updateGoalTips()
        QuestinonaireMsgModel.shared.targetWeight = formatOneDecimal(currentTargetWeight)
        NotificationCenter.default.post(name: .dietPlanPaceInputDidChange, object: nil)

        DispatchQueue.main.async {
            self.rulerView.setValue(self.currentTargetWeight, animated: false)
        }
    }

    func updateGoalTips() {
        if valueChanged == false {
            valueChanged = true
            UIView.animate(withDuration: 0.35) {
                self.tipsLabel.alpha = 1
            }
        }
        if currentTargetWeight > currentWeightValue {
            tipsLabel.text = "你的目标是增肌"
        } else if currentTargetWeight == currentWeightValue {
            tipsLabel.text = "你的目标是维持"
        } else {
            tipsLabel.text = "你的目标是减脂"
        }
    }

    func updateTargetWeight(value: Double) {
        currentTargetWeight = clamp(roundToTenth(value))
        updateTargetWeightText(value: currentTargetWeight)
        updateGoalTips()
        QuestinonaireMsgModel.shared.targetWeight = formatOneDecimal(currentTargetWeight)
        NotificationCenter.default.post(name: .dietPlanPaceInputDidChange, object: nil)
    }

    func updateTargetWeightText(value: Double) {
        let text = NSMutableAttributedString(string: formatOneDecimal(value))
        text.yy_font = .systemFont(ofSize: 40, weight: .medium)
        text.yy_color = .THEME

        let unitText = NSMutableAttributedString(string: " 公斤")
        unitText.yy_font = .systemFont(ofSize: 16, weight: .regular)
        unitText.yy_color = .COLOR_TEXT_TITLE_0f1214
        text.append(unitText)
        targetWeightLabel.attributedText = text
    }

    func parseWeight(_ text: String) -> Double? {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return nil }
        return Double(clean)
    }

    func clamp(_ value: Double) -> Double {
        return min(max(value, minWeight), maxWeight)
    }

    func roundToTenth(_ value: Double) -> Double {
        return (value * 10).rounded() / 10
    }

    func formatOneDecimal(_ value: Double) -> String {
        return String(format: "%.1f", value)
    }

    func buildTargetWeightAlertPayload() -> DietPlanTargetWeightAlertPayload? {
        let target = roundToTenth(currentTargetWeight)
        if target < alertMinWeight {
            return DietPlanTargetWeightAlertPayload(
                type: .healthRisk,
                recommendedWeight: alertMinWeight
            )
        }
        if target > alertMaxWeight {
            return DietPlanTargetWeightAlertPayload(
                type: .healthRisk,
                recommendedWeight: alertMaxWeight
            )
        }
        if containsBloodLipidGoal() && target > QuestinonaireMsgModel.shared.weight.doubleValue{
            let bloodLipidUpperLimit = roundToTenth(currentWeightValue * 0.9)
            if target > bloodLipidUpperLimit {
                let recommend = clampToAlertRange(bloodLipidUpperLimit)
                return DietPlanTargetWeightAlertPayload(
                    type: .bloodLipidGoal,
                    recommendedWeight: recommend
                )
            }
        }
        return nil
    }

    func applyRecommendedTargetWeight(_ weight: Double) {
        let recommended = clamp(roundToTenth(weight))
        currentTargetWeight = recommended
        updateTargetWeightText(value: currentTargetWeight)
        updateGoalTips()
        QuestinonaireMsgModel.shared.targetWeight = formatOneDecimal(currentTargetWeight)
        NotificationCenter.default.post(name: .dietPlanPaceInputDidChange, object: nil)
        DispatchQueue.main.async {
            self.rulerView.setValue(self.currentTargetWeight, animated: true)
        }
    }

    private func containsBloodLipidGoal() -> Bool {
        let goals = QuestinonaireMsgModel.shared.goal
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return goals.contains(where: { $0.contains("血脂") })
    }

    private func clampToAlertRange(_ value: Double) -> Double {
        return min(max(value, alertMinWeight), alertMaxWeight)
    }
}
