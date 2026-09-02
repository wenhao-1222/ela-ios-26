//
//  GuidanceNutritionGoalsProgressVC.swift
//  lns
//
//  营养目标规划页之后展示的营养目标生成页面。
//

import UIKit
import SnapKit

/// 展示营养目标生成进度，并请求第三版目标接口。
final class GuidanceNutritionGoalsProgressVC: WHBaseViewVC {
    struct Configuration {
        var fakeProgressTarget: Int = 88
        var fakeProgressDuration: TimeInterval = 3.0
        /// 三条状态文案完整轮播一遍所需的总时长。
        var stageCycleDuration: TimeInterval = 5.0
        /// 切换状态文案时的淡入淡出时长。
        var stageTransitionDuration: TimeInterval = 0.35
        /// 接口返回后结束阶段动画的最短时长。
        var completionAnimationDuration: TimeInterval = 3.0
        /// 限制完整进度动画的最短总时长，避免过快结束。
        var minimumTotalAnimationDuration: TimeInterval = 8.0

        func normalized() -> Configuration {
            var value = self
            value.fakeProgressTarget = min(max(value.fakeProgressTarget, 1), 99)
            value.fakeProgressDuration = max(value.fakeProgressDuration, 0.1)
            value.stageCycleDuration = max(value.stageCycleDuration, 0.3)
            value.stageTransitionDuration = max(value.stageTransitionDuration, 0.1)
            value.completionAnimationDuration = max(value.completionAnimationDuration, 0.1)
            value.minimumTotalAnimationDuration = max(value.minimumTotalAnimationDuration, 0.1)
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
    /// 逻辑完成计时不能依赖 UIView 动画的 completion；手势或系统转场可能中断动画。
    private var completionWorkItem: DispatchWorkItem?
    private var progressStartedAt: CFTimeInterval = 0
    private var requestFinished = false
    private var hasFinishedAnimation = false
    private var hasDeliveredResult = false
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
        imageView.clipsToBounds = true
        return imageView
    }()

    /// 纯色 logo 副本配合移动渐变蒙层，只让高光显示在 logo 的非透明区域内。
    private lazy var logoHighlightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "guide_first_page_logo_icon")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(hex: "#003CFF")
        imageView.alpha = 0.72
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let logoHighlightMaskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        layer.locations = [-0.85, -0.45, -0.05]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private let logoShimmerAnimationKey = "guidance.logo.shimmer"

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
        view.layer.cornerRadius = kFitWidth(2)
        view.clipsToBounds = true
        return view
    }()

    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = .THEME
        view.layer.cornerRadius = kFitWidth(2)
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

    /// 在页面展示前（或空闲状态下）更新动画时长和进度配置。
    func updateConfiguration(_ configuration: Configuration) {
        self.configuration = configuration.normalized()
    }

    deinit {
        fakeTimer?.invalidate()
        stageTimer?.invalidate()
        completionWorkItem?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildInterface()
        updateProgressUI(animated: false)
        progressStartedAt = CACurrentMediaTime()
        startStageCycle()
        startFakeProgress()
        requestNutritionGoals()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 生成页没有返回操作。禁止侧滑返回，避免交互式导航转场与完成跳页同时发生。
        updateInteractivePopGestureBlocked(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInteractivePopGestureBlocked(true)
        startLogoShimmer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLogoShimmer()
        restoreFullscreenInteractivePopGesture()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        logoHighlightMaskLayer.frame = logoHighlightImageView.bounds
        CATransaction.commit()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fakeTimer?.invalidate()
        stageTimer?.invalidate()
        completionWorkItem?.cancel()
    }
}

private extension GuidanceNutritionGoalsProgressVC {
    func buildInterface() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
        logoImageView.addSubview(logoHighlightImageView)
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
        logoHighlightImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        logoHighlightImageView.layer.mask = logoHighlightMaskLayer
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
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(kFitWidth(40))
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
            label.font = .systemFont(ofSize: 13, weight: .regular)
            label.textAlignment = .center
            stageStackView.addArrangedSubview(label)
            stageLabels.append(label)
        }
        stageStackView.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(50))
            $0.right.equalTo(kFitWidth(-34))
            $0.height.equalTo(kFitWidth(20))
            $0.top.equalTo(progressTrackView.snp.bottom).offset(kFitWidth(16))
        }
        progressPercentLabel.isHidden = true
        logoTitleLabel.isHidden = true
    }

    func startLogoShimmer() {
        guard logoHighlightMaskLayer.animation(forKey: logoShimmerAnimationKey) == nil else { return }

        // 前 60% 完成扫光，后 40% 留白，让循环节奏更接近骨架屏而不过于闪烁。
        let animation = CAKeyframeAnimation(keyPath: "locations")
        animation.values = [
            [-0.85, -0.45, -0.05],
            [1.05, 1.45, 1.85],
            [1.05, 1.45, 1.85]
        ]
        animation.keyTimes = [0, 0.6, 1]
        animation.duration = 1.75
        animation.repeatCount = .infinity
        animation.calculationMode = .linear
        logoHighlightMaskLayer.add(animation, forKey: logoShimmerAnimationKey)
    }

    func stopLogoShimmer() {
        logoHighlightMaskLayer.removeAnimation(forKey: logoShimmerAnimationKey)
        logoHighlightMaskLayer.locations = [-0.85, -0.45, -0.05]
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
            }
        }
        if let fakeTimer { RunLoop.main.add(fakeTimer, forMode: .common) }
    }

    /// 在最初五秒内依次轮播三条状态文案。
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
                self.stageTimer?.invalidate()
                self.stageTimer = nil
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
        guard requestFinished, !hasFinishedAnimation else { return }
        hasFinishedAnimation = true

        // 接口返回后只停止模拟进度。状态文案计时器仍需继续运行，
        // 避免接口过快返回，导致第二、第三条状态文案没有机会展示。
        fakeTimer?.invalidate()
        fakeTimer = nil
        let elapsed = CACurrentMediaTime() - progressStartedAt
        let remainingStageCycleDuration = max(configuration.stageCycleDuration - elapsed, 0)
        let completionDuration = max(configuration.completionAnimationDuration,
                                     configuration.minimumTotalAnimationDuration - elapsed,
                                     remainingStageCycleDuration)
        let completionWorkItem = DispatchWorkItem { [weak self] in
            self?.completeProgressIfNeeded()
        }
        self.completionWorkItem?.cancel()
        self.completionWorkItem = completionWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + completionDuration,
                                      execute: completionWorkItem)

        UIView.animate(withDuration: completionDuration, delay: 0, options: [.curveEaseInOut]) {
            self.displayedProgress = 100
            self.updateProgressUI(animated: false)
            self.view.layoutIfNeeded()
        } completion: { [weak self] finished in
            guard finished else { return }
            self?.completeProgressIfNeeded()
        }
    }

    /// 进度展示和业务跳页在这里一次性汇合。
    ///
    /// UIKit 动画可能被手势、布局或导航转场打断，因此同时由独立的主线程计时兜底，
    /// 确保接口成功后一定会交付结果，而不会停留在视觉上的 100%。
    func completeProgressIfNeeded() {
        guard requestFinished, hasFinishedAnimation, !hasDeliveredResult else { return }
        hasDeliveredResult = true
        completionWorkItem?.cancel()
        completionWorkItem = nil
        fakeTimer?.invalidate()
        fakeTimer = nil
        stageTimer?.invalidate()
        stageTimer = nil
        displayedProgress = 100
        activeStageIndex = stageTexts.count - 1
        updateProgressUI(animated: false)
        updateStageText(animated: false)
        finishBlock?(nutritionResult)
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

    /// 在网络层补充设备字段并加密请求体之前，打印原始业务参数及其中文含义。
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
