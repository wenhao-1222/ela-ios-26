//
//  GuidanceNutritionGoalsProgressVC.swift
//  lns
//
//  Nutrition goal generation page shown after GuidanceGoalPlanVC.
//

import UIKit
import SnapKit

/// Displays the nutrition-goal generation progress and requests the v3 goals API.
final class GuidanceNutritionGoalsProgressVC: WHBaseViewVC {
    struct Configuration {
        var fakeProgressTarget: Int = 88
        var fakeProgressDuration: TimeInterval = 3.0
        /// Total time used to cycle through all three status messages.
        var stageCycleDuration: TimeInterval = 5.0
        /// Cross-dissolve duration when switching status messages.
        var stageTransitionDuration: TimeInterval = 0.35
        /// Minimum time from page appearance before the final transition may start.
        var minimumDisplayDuration: TimeInterval = 6.0
        var completionAnimationDuration: TimeInterval = 1.0

        func normalized() -> Configuration {
            var value = self
            value.fakeProgressTarget = min(max(value.fakeProgressTarget, 1), 99)
            value.fakeProgressDuration = max(value.fakeProgressDuration, 0.1)
            value.stageCycleDuration = max(value.stageCycleDuration, 0.3)
            value.stageTransitionDuration = max(value.stageTransitionDuration, 0.1)
            value.minimumDisplayDuration = max(value.minimumDisplayDuration, 0.3)
            value.completionAnimationDuration = max(value.completionAnimationDuration, 0.1)
            return value
        }
    }

    struct NutritionGoalsResult {
        let protein: Double
        let carbohydrate: Double
        let fat: Double
        let calories: Double
    }

    var configuration = Configuration()
    var finishBlock: ((NutritionGoalsResult?) -> Void)?

    private let flowState: GuidanceGoalPlanFlowState
    private var displayedProgress: Double = 0
    private var fakeTimer: Timer?
    private var stageTimer: Timer?
    private var readinessTimer: Timer?
    private var pageShownAt: CFTimeInterval = 0
    private var fakeProgressReached = false
    private var stageCycleCompleted = false
    private var requestFinished = false
    private var hasFinishedAnimation = false
    private var nutritionResult: NutritionGoalsResult?
    private var activeStageIndex = 0

    private let stageTexts = [
        "正在结合你的身体信息...",
        "正在纳入日常活动与训练...",
        "正在确定第一阶段营养方向..."
    ]

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setImgLocal(imgName: "ela_pro_progress_bg")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setImgLocal(imgName: "guide_first_page_logo_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let logoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = nil
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 60, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "正在为你确定初始营养目标"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ELA 正在综合你的身体情况、日常活动和目标，\n为第一阶段建立一个可靠起点"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let footerHintLabel: UILabel = {
        let label = UILabel()
        label.text = "你的数据仅用于建立和持续校准个人营养目标"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = .COLOR_CARD_BG_WHITE
        view.layer.cornerRadius = kFitWidth(6)
        view.clipsToBounds = true
        return view
    }()

    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = .THEME
        view.layer.cornerRadius = kFitWidth(6)
        view.clipsToBounds = true
        return view
    }()

    private let stageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = kFitWidth(16)
        stack.alignment = .fill
        return stack
    }()

    private var stageLabels: [UILabel] = []
    private var progressWidthConstraint: Constraint?

    init(flowState: GuidanceGoalPlanFlowState, configuration: Configuration = Configuration()) {
        self.flowState = flowState
        self.configuration = configuration.normalized()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates timing/progress knobs before presenting (or while idle).
    func updateConfiguration(_ configuration: Configuration) {
        self.configuration = configuration.normalized()
    }

    deinit {
        fakeTimer?.invalidate()
        stageTimer?.invalidate()
        readinessTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildInterface()
        updateProgressUI(animated: false)
        pageShownAt = CACurrentMediaTime()
        startStageCycle()
        startFakeProgress()
        requestNutritionGoals()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fakeTimer?.invalidate()
        stageTimer?.invalidate()
        readinessTimer?.invalidate()
    }
}

private extension GuidanceNutritionGoalsProgressVC {
    func buildInterface() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
        view.addSubview(logoTitleLabel)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(footerHintLabel)
        view.addSubview(progressPercentLabel)
        view.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        view.addSubview(stageStackView)

        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(kFitWidth(170))
            $0.width.equalTo(kFitWidth(170))
            $0.height.equalTo(kFitWidth(42))
        }
        logoTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(8))
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(kFitWidth(28))
        }
        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.equalTo(kFitWidth(24))
            $0.right.equalTo(kFitWidth(-24))
            $0.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(12))
        }
        footerHintLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.equalTo(kFitWidth(20))
            $0.right.equalTo(kFitWidth(-20))
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(kFitWidth(-64))
        }
        progressPercentLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(42))
        }
        progressTrackView.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(62))
            $0.right.equalTo(kFitWidth(-62))
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(24))
            $0.height.equalTo(kFitWidth(4))
        }
        progressFillView.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
            progressWidthConstraint = $0.width.equalTo(0).constraint
        }
        stageTexts.forEach { text in
            let label = UILabel()
            label.text = text
            label.textColor = .COLOR_TEXT_TITLE_0f1214_50
            label.font = .systemFont(ofSize: 17, weight: .regular)
            stageStackView.addArrangedSubview(label)
            stageLabels.append(label)
        }
        stageStackView.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(50))
            $0.right.equalTo(kFitWidth(-34))
            $0.top.equalTo(progressTrackView.snp.bottom).offset(kFitWidth(16))
        }
        progressPercentLabel.isHidden = true
        logoTitleLabel.isHidden = true
    }

    func startFakeProgress() {
        fakeTimer?.invalidate()
        let interval = 1.0 / 60.0
        let startedAt = CACurrentMediaTime()
        fakeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            let elapsed = CACurrentMediaTime() - startedAt
            let ratio = min(max(elapsed / self.configuration.fakeProgressDuration, 0), 1)
            self.displayedProgress = ratio * Double(self.configuration.fakeProgressTarget)
            self.updateProgressUI(animated: true)
            if ratio >= 1 {
                self.fakeTimer?.invalidate()
                self.fakeTimer = nil
                self.fakeProgressReached = true
                self.tryFinishIfReady()
            }
        }
        if let fakeTimer { RunLoop.main.add(fakeTimer, forMode: .common) }
    }

    /// Cycles through the three requested messages during the first five seconds.
    func startStageCycle() {
        stageTimer?.invalidate()
        activeStageIndex = 0
        updateProgressUI(animated: false)
        updateStageText(animated: false)
        let interval = max(configuration.stageCycleDuration / Double(stageTexts.count), 0.1)
        let startedAt = CACurrentMediaTime()
        stageTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let elapsed = CACurrentMediaTime() - startedAt
            let stage = min(Int(elapsed / interval), self.stageTexts.count - 1)
            if stage != self.activeStageIndex {
                self.activeStageIndex = stage
                self.updateStageText(animated: true)
            }
            if elapsed >= self.configuration.stageCycleDuration {
                self.activeStageIndex = self.stageTexts.count - 1
                self.stageCycleCompleted = true
                self.stageTimer?.invalidate()
                self.stageTimer = nil
                self.tryFinishIfReady()
            }
        }
        if let stageTimer { RunLoop.main.add(stageTimer, forMode: .common) }
    }

    func updateProgressUI(animated: Bool) {
        let percent = Int(displayedProgress.rounded(.down))
        progressPercentLabel.text = "\(percent)%"
        let trackWidth = SCREEN_WIDHT - kFitWidth(124)
        progressWidthConstraint?.update(offset: trackWidth * CGFloat(displayedProgress / 100.0))
        if animated {
            UIView.animate(withDuration: 0.08, delay: 0, options: [.beginFromCurrentState, .curveEaseOut]) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }

    func updateStageText(animated: Bool) {
        let updates = {
            for (index, label) in self.stageLabels.enumerated() {
                label.isHidden = index != self.activeStageIndex
                label.alpha = index == self.activeStageIndex ? 1 : 0
            }
        }
        guard animated else {
            updates()
            return
        }
        UIView.transition(with: stageStackView,
                          duration: configuration.stageTransitionDuration,
                          options: [.transitionCrossDissolve, .beginFromCurrentState, .allowAnimatedContent],
                          animations: updates)
    }

    func tryFinishIfReady() {
        guard requestFinished, fakeProgressReached, stageCycleCompleted, !hasFinishedAnimation else {
            scheduleReadinessCheckIfNeeded()
            return
        }
        let elapsed = CACurrentMediaTime() - pageShownAt
        let remainingDisplayTime = configuration.minimumDisplayDuration - elapsed
        if remainingDisplayTime > 0 {
            scheduleReadinessCheck(after: remainingDisplayTime)
            return
        }
        hasFinishedAnimation = true
        readinessTimer?.invalidate()
        readinessTimer = nil
        UIView.animate(withDuration: configuration.completionAnimationDuration, delay: 0, options: [.curveEaseInOut]) {
            self.displayedProgress = 100
            self.updateProgressUI(animated: false)
            self.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self else { return }
            self.finishBlock?(self.nutritionResult)
        }
    }

    func scheduleReadinessCheckIfNeeded() {
        guard requestFinished, fakeProgressReached, stageCycleCompleted else { return }
        let remaining = max(configuration.minimumDisplayDuration - (CACurrentMediaTime() - pageShownAt), 0)
        scheduleReadinessCheck(after: remaining)
    }

    func scheduleReadinessCheck(after delay: TimeInterval) {
        guard !hasFinishedAnimation else { return }
        readinessTimer?.invalidate()
        readinessTimer = Timer.scheduledTimer(withTimeInterval: max(delay, 0.01), repeats: false) { [weak self] _ in
            self?.readinessTimer = nil
            self?.tryFinishIfReady()
        }
        if let readinessTimer { RunLoop.main.add(readinessTimer, forMode: .common) }
    }

    func requestNutritionGoals() {
        let parameters = makeRequestParameters()
        logNutritionGoalsParameters(parameters)
        
        WHNetworkUtil.shareManager().POST(urlString: URL_question_nutrition_goals_v3,
                                          parameters: parameters,
                                          isNeedToast: true,
                                          vc: self) { [weak self] response in
            guard let self else { return }
            let result = Self.parseResult(response)
            self.nutritionResult = result
            self.requestFinished = true
            self.tryFinishIfReady()
        } failure: { [weak self] _ in
            self?.requestFinished = false
        }
    }

    /// Prints raw business parameters and their Chinese meanings before the
    /// network layer adds device fields and encrypts the payload.
    func logNutritionGoalsParameters(_ parameters: [String: AnyObject]) {
        let meanings: [String: String] = [
            "fitnessGoal": "健身目标（1=减脂，2=增肌）",
            "calories": "热量目标/TDEE（千卡）",
            "highProteinDietFamiliarity": "高蛋白饮食习惯程度（1=比较习惯，2=一般，3=不太习惯）",
            "fatLossApproach": "减脂速度（1=更快速度减脂，2=相对快速减脂，3=平稳持续减脂）",
            "fatLossTrainingProfile": "减脂者画像（1=日常训练者，2=规律健身者，3=健美运动员，4=HYROX运动员，5=耐力运动员）",
            "fatLossDietBarrier": "减脂饮食阻碍（0=不确定，1=高碳水食物，2=高脂食物）",
            "muscleGainApproach": "增肌速度（1=更注重增肌质量，2=平衡增肌质量与速度，3=更注重增肌速度）",
            "muscleGainTrainingProfile": "增肌者画像（1=日常训练者，2=规律健身者，3=健美运动员，4=HYROX运动员，5=耐力运动员）",
            "muscleGainDietBarrier": "增肌饮食阻碍（0=不确定，1=消化较慢，2=单餐食量较小）"
        ]
        let lines = parameters.keys.sorted().map { key in
            let value = parameters[key].map { String(describing: $0) } ?? "nil"
            return "- \(key)（\(meanings[key] ?? "未定义")）= \(value)"
        }
        DLLog(message: "\(URL_question_nutrition_goals_v3) 业务参数:\n\(lines.joined(separator: "\n"))")
    }

    func makeRequestParameters() -> [String: AnyObject] {
        let isMuscleGain = flowState.target == .muscleGain
        var parameters: [String: AnyObject] = [
            "fitnessGoal": NSNumber(value: isMuscleGain ? 2 : 1),
            "calories": NSNumber(value: caloriesValue),
            "highProteinDietFamiliarity": NSNumber(value: familiarityValue)
        ]
        if isMuscleGain {
            parameters["muscleGainApproach"] = NSNumber(value: muscleGainApproachValue)
            parameters["muscleGainTrainingProfile"] = NSNumber(value: profileValue(flowState.muscleGainProfile))
            parameters["muscleGainDietBarrier"] = NSNumber(value: muscleGainBarrierValue)
        } else {
            parameters["fatLossApproach"] = NSNumber(value: fatLossApproachValue)
            parameters["fatLossTrainingProfile"] = NSNumber(value: profileValue(flowState.fatLossProfile))
            parameters["fatLossDietBarrier"] = NSNumber(value: fatLossBarrierValue)
        }
        return parameters
    }

    var caloriesValue: Int {
        let text = Guide0820ProgressStorage.lifeProfileCaloriesNumber ?? Guide0820Model.shared.caloriesNumber
        return max(Int(Double(text) ?? 0), 0)
    }

    var familiarityValue: Int {
        let value = flowState.target == .muscleGain ? flowState.muscleGainProteinHabit : flowState.fatLossProteinHabit
        return ["high": 1, "medium": 2, "low": 3][value] ?? 2
    }

    var fatLossApproachValue: Int { ["fast": 1, "moderate": 2, "steady": 3][flowState.fatLossMode] ?? 2 }
    var fatLossBarrierValue: Int { ["uncertain": 0, "high_carb": 1, "high_fat": 2][flowState.fatLossFoodFluctuation] ?? 0 }
    var muscleGainApproachValue: Int { ["quality": 1, "balanced": 2, "speed": 3][flowState.muscleGainMode] ?? 2 }
    var muscleGainBarrierValue: Int { ["uncertain": 0, "slow_digestion": 1, "small_meal_capacity": 2][flowState.muscleGainBarrier] ?? 0 }

    func profileValue(_ value: String) -> Int {
        switch value {
        case "daily_training": return 1
        case "regular_fitness": return 2
        case "bodybuilder": return 3
        case "hyrox": return 4
        case "endurance_athlete", "strength_athlete": return 5
        default: return 1
        }
    }

    static func parseResult(_ response: [String: AnyObject]) -> NutritionGoalsResult? {
        var data: NSDictionary = response as NSDictionary
        if let object = response["data"] as? NSDictionary {
            data = object
        }
        if let encrypted = response["data"] as? String,
           let decrypted = AESEncyptUtil.aesDecrypt(hexString: encrypted) {
            data = WHUtils.getDictionaryFromJSONString(jsonString: decrypted)
        }
        
        DLLog(message: "\(data)")
        func number(_ key: String) -> Double {
            if let number = data[key] as? NSNumber { return number.doubleValue }
            return Double(data[key] as? String ?? "") ?? 0
        }
        return NutritionGoalsResult(protein: number("protein"), carbohydrate: number("carbohydrate"), fat: number("fat"), calories: number("calories"))
    }

}
