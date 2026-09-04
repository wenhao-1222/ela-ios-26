//
//  GuidanceNutritionGoalsProgressVC.swift
//  lns
//
//  营养目标规划页之后展示的营养目标生成页面。
//

import SwiftUI
import UIKit
import SnapKit

/// 展示营养目标生成进度，并请求第三版目标接口。
final class GuidanceNutritionGoalsProgressVC: WHBaseViewVC {
    struct Configuration {
        /// 除最后一条外，每条状态文案完成淡入后保持完整显示的时长。
        var stageTextDisplayDuration: TimeInterval = 1.65
        /// 第一条文案相对普通文案缩短的展示时长。
        var firstStageTextDisplayDurationReduction: TimeInterval = 0.4
        /// 最后一条状态文案完成淡入后保持完整显示的时长。
        var finalStageTextDisplayDuration: TimeInterval = 3.0
        /// 切换状态文案时的淡入淡出时长。
        var stageTransitionDuration: TimeInterval = 0.25
        /// 接口返回后结束阶段动画的最短时长。
        var completionAnimationDuration: TimeInterval = 3.0
        /// 限制完整加载动画的最短总时长，避免过快结束。
        var minimumTotalAnimationDuration: TimeInterval = 10.0

        func normalized() -> Configuration {
            var value = self
            value.stageTextDisplayDuration = max(value.stageTextDisplayDuration, 1.0)
            value.firstStageTextDisplayDurationReduction = min(
                max(value.firstStageTextDisplayDurationReduction, 0),
                value.stageTextDisplayDuration - 0.1
            )
            value.finalStageTextDisplayDuration = max(value.finalStageTextDisplayDuration, 3.0)
            value.stageTransitionDuration = max(value.stageTransitionDuration, 0.1)
            value.completionAnimationDuration = max(value.completionAnimationDuration, 0.1)
            value.minimumTotalAnimationDuration = max(value.minimumTotalAnimationDuration, 0.1)
            return value
        }
    }

    struct NutritionGoalsResult {
        struct TextSection {
            let title: String
            let content: String
        }

        struct ActionSection {
            let title: String
            let items: [TextSection]
        }

        struct CoachSuggestion {
            let judgment: TextSection?
            let actionPlan: ActionSection?
            let conclusion: TextSection?
        }

        let protein: Double
        let carbohydrate: Double
        let fat: Double
        let calories: Double
        let coachSuggestion: CoachSuggestion?

        init(protein: Double,
             carbohydrate: Double,
             fat: Double,
             calories: Double,
             coachSuggestion: CoachSuggestion? = nil) {
            self.protein = protein
            self.carbohydrate = carbohydrate
            self.fat = fat
            self.calories = calories
            self.coachSuggestion = coachSuggestion
        }
    }

    var configuration = Configuration()
    var finishBlock: ((NutritionGoalsResult?) -> Void)?

    private let flowState: GuidanceGoalPlanFlowState
    private var stageTimer: Timer?
    /// 接口完成后继续展示球动画的延时任务。
    private var completionWorkItem: DispatchWorkItem?
    private var animationStartedAt: CFTimeInterval = 0
    private var hasStartedStageCycle = false
    private var hasCompletedStageCycle = false
    private var hasScheduledCompletion = false
    private var requestFinished = false
    private var hasFinishedAnimation = false
    private var hasDeliveredResult = false
    private var nutritionResult: NutritionGoalsResult?
    private var activeStageIndex = 0

    private let stageTexts = [
//        "正在结合你的身体信息...",
//        "正在纳入日常活动与训练...",
//        "正在确定第一阶段营养方向..."
        
//        "先从你的身体基础看起…",
//        "再看看你平时怎么活动和训练…",
//        "结合你现在最想达到的目标…",
//        "判断第一阶段该从哪里开始…",
//        "先把每天该吃多少定下来…",
//        "再把碳水、蛋白质和脂肪搭配好…",
//        "再替你过一遍，看看是否适合现在的你…",
//        "你的第一阶段目标和建议，马上就好…"
        
//        "正在了解你的身体基础...",
//        "正在结合你的日常活动与训练...",
//        "正在把你的目标一起考虑进来...",
//        "正在判断你现阶段更需要什么...",
//        "正在为你找到更合适的热量起点...",
//        "正在调整三大营养素的分配方向...",
//        "正在梳理你第一阶段该先做好的事...",
//        "正在为你定下第一阶段营养目标..."
        
//        "正在先了解你的身体基础...",
//        "正在结合你的日常活动与训练...",
//        "正在把你的目标一起放进来考虑...",
//        "正在判断你现阶段最需要优先解决什么...",
//        "正在为你找到更合适的热量起点...",
//        "正在把三大营养素调整到更适合你的方向...",
//        "正在梳理你第一阶段最该先做的几件事...",
//        "正在为你定下第一阶段营养目标..."
        
//        "让我先结合你的身体基础情况...",
//        "再把日常活动与训练考虑进去...",
//        "然后结合你现在想达到的目标...",
//        "我需要判断你现阶段最需要优先解决什么...",
//        "正在为你找到更合适的热量起点...",
//        "让我把三大营养素调整到更适合你的方向...",
//        "正在梳理你第一阶段最该先做的几件事...",
//        "最后，为你定下第一阶段营养目标..."
        
//        "让我先分析你的身体基础情况...",
//        "再把日常活动与训练考虑进去...",
//        "正在结合你的目标...",
//        "我需要先确定你这一阶段的重点...",
//        "正在为你找到更合适的热量起点...",
//        "让我把三大营养素调整到更适合你的方向...",
//        "正在梳理你第一阶段最该先做的几件事...",
//        "最后，为你定下第一阶段营养目标..."
        
        "先从你的身体基础算起...",
        "再把日常活动与训练考虑进去...",
        "然后根据你的目标确定调整方向...",
        "这样，就能判断这一阶段该优先什么...",
        "接下来，把热量起点定下来...",
        "有了这个起点，再把三大营养素配好...",
        "然后梳理第一阶段最该先做的几件事...",
        "最后，为你定下第一阶段营养目标..."
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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "正在为你确定初始营养目标"
        label.textColor = .COLOR_TEXT_TITLE_0f1214
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    /// 承载压缩包中 SwiftUI 点阵球动画的 UIKit 容器。
    private var thinkingOrbHostController: UIHostingController<ThinkingOrbsPill>?

    private let footerHintLabel: UILabel = {
        let label = UILabel()
        label.text = "你的数据仅用于建立和持续校准个人营养目标"
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private let stageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .COLOR_TEXT_TITLE_0f1214_50
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        return label
    }()

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
        stageTimer?.invalidate()
        completionWorkItem?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildInterface()
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
        startStageCycleAfterRenderingIfNeeded()
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
        view.addSubview(footerHintLabel)
        view.addSubview(stageLabel)

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
        footerHintLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.equalTo(kFitWidth(20))
            $0.right.equalTo(kFitWidth(-20))
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(kFitWidth(-64))
        }
        let orbHostController = embedThinkingOrb()
        stageLabel.snp.makeConstraints {
            $0.left.equalTo(kFitWidth(50))
            $0.right.equalTo(kFitWidth(-34))
            $0.height.equalTo(kFitWidth(20))
            $0.top.equalTo(orbHostController.view.snp.bottom).offset(kFitWidth(12))
        }
        stageLabel.text = stageTexts.first
        logoTitleLabel.isHidden = true
    }

    /// 将附件中的球动画嵌入当前 UIKit 页面。
    @discardableResult
    func embedThinkingOrb() -> UIHostingController<ThinkingOrbsPill> {
        let side = kFitWidth(100)
        let hostController = UIHostingController(
            rootView: ThinkingOrbsPill(
                showsPill: false,
                showsLabel: false,
                ballSize: side
            )
        )
        hostController.view.backgroundColor = .clear
        hostController.view.isOpaque = false
        hostController.view.isUserInteractionEnabled = false
        hostController.view.accessibilityIdentifier = "guidanceNutritionGoalsThinkingOrb"

        addChild(hostController)
        view.addSubview(hostController.view)
        hostController.view.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(16))
            $0.width.height.equalTo(side)
        }
        hostController.didMove(toParent: self)
        thinkingOrbHostController = hostController
        return hostController
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

    /// 页面完成展示后再开始计时，避免导航转场占用首条文案的展示时长。
    func startStageCycleAfterRenderingIfNeeded() {
        guard !hasStartedStageCycle else { return }
        hasStartedStageCycle = true
        animationStartedAt = CACurrentMediaTime()
        startStageCycle()
        // 接口可能在页面完成展示前已经返回，此时从真正的动画起点重新计算结束时间。
        tryFinishIfReady()
    }

    func startStageCycle() {
        stageTimer?.invalidate()
        activeStageIndex = 0
        updateStageText(animated: false)
        hasCompletedStageCycle = false

        guard stageTexts.count > 1 else {
            scheduleStageCycleCompletion(after: configuration.finalStageTextDisplayDuration)
            return
        }

        scheduleNextStage(after: firstStageTextDisplayDuration)
    }

    /// 基于上一次实际切换完成的时间继续调度，主线程短暂繁忙时不会追赶并压缩后续文案。
    func scheduleNextStage(after delay: TimeInterval) {
        let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            guard let self else { return }
            let nextIndex = self.activeStageIndex + 1
            guard self.stageTexts.indices.contains(nextIndex) else { return }

            self.activeStageIndex = nextIndex
            self.updateStageText(animated: true)

            if nextIndex == self.stageTexts.count - 1 {
                self.scheduleStageCycleCompletion(
                    after: self.configuration.stageTransitionDuration
                        + self.configuration.finalStageTextDisplayDuration
                )
            } else {
                self.scheduleNextStage(
                    after: self.configuration.stageTransitionDuration
                        + self.configuration.stageTextDisplayDuration
                )
            }
        }
        stageTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func scheduleStageCycleCompletion(after delay: TimeInterval) {
        let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.stageTimer = nil
            self.hasCompletedStageCycle = true
            self.completeProgressIfNeeded()
        }
        stageTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func updateStageText(animated: Bool) {
        let text = stageTexts[activeStageIndex]
        guard animated else {
            stageLabel.layer.removeAllAnimations()
            stageLabel.text = text
            stageLabel.alpha = 1
            return
        }

        UIView.transition(with: stageLabel,
                          duration: configuration.stageTransitionDuration,
                          options: [.transitionCrossDissolve, .beginFromCurrentState, .allowAnimatedContent],
                          animations: {
                              self.stageLabel.text = text
                          })
    }

    func tryFinishIfReady() {
        guard requestFinished,
              hasStartedStageCycle,
              !hasScheduledCompletion,
              !hasFinishedAnimation else { return }
        hasScheduledCompletion = true

        // 状态文案计时器仍需继续运行，避免接口过快返回，
        // 导致后续状态文案没有机会完整展示。
        let elapsed = CACurrentMediaTime() - animationStartedAt
        let remainingStageCycleDuration = max(stageCycleDuration - elapsed, 0)
        let completionDuration = max(configuration.completionAnimationDuration,
                                     configuration.minimumTotalAnimationDuration - elapsed,
                                     remainingStageCycleDuration)
        let completionWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.hasFinishedAnimation = true
            self.completeProgressIfNeeded()
        }
        self.completionWorkItem?.cancel()
        self.completionWorkItem = completionWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + completionDuration,
                                      execute: completionWorkItem)
    }

    /// 根据当前文案数量动态计算完整轮播时长：
    /// 普通文案展示时长 + 最后一条展示时长 + 相邻文案之间的淡入淡出时长。
    var stageCycleDuration: TimeInterval {
        guard !stageTexts.isEmpty else { return 0 }
        let regularStageCount = stageTexts.count - 1
        return Double(regularStageCount) * configuration.stageTextDisplayDuration
            - (regularStageCount > 0 ? configuration.firstStageTextDisplayDurationReduction : 0)
            + configuration.finalStageTextDisplayDuration
            + Double(regularStageCount) * configuration.stageTransitionDuration
    }

    var firstStageTextDisplayDuration: TimeInterval {
        configuration.stageTextDisplayDuration
            - configuration.firstStageTextDisplayDurationReduction
    }

    /// 球动画的最短展示时长和业务跳页在这里一次性汇合。
    func completeProgressIfNeeded() {
        guard requestFinished,
              hasFinishedAnimation,
              hasCompletedStageCycle,
              !hasDeliveredResult else { return }
        hasDeliveredResult = true
        completionWorkItem?.cancel()
        completionWorkItem = nil
        stageTimer?.invalidate()
        stageTimer = nil
        activeStageIndex = stageTexts.count - 1
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

        func dictionary(_ value: Any?) -> NSDictionary? {
            if let dictionary = value as? NSDictionary { return dictionary }
            if let dictionary = value as? [String: Any] { return dictionary as NSDictionary }
            return nil
        }

        func text(_ key: String, in dictionary: NSDictionary) -> String? {
            guard let value = dictionary[key] as? String else { return nil }
            let normalized = value
                .replacingOccurrences(of: "\r\n", with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return normalized.isEmpty ? nil : normalized
        }

        func textSection(_ value: Any?) -> NutritionGoalsResult.TextSection? {
            guard let section = dictionary(value),
                  let title = text("title", in: section),
                  let content = text("content", in: section) else {
                return nil
            }
            return .init(title: title, content: content)
        }

        var coachSuggestion: NutritionGoalsResult.CoachSuggestion?
        if let suggestion = dictionary(data["coachSuggestion"]) {
            let judgment = textSection(suggestion["section1"])
            let conclusion = textSection(suggestion["section3"])

            var actionPlan: NutritionGoalsResult.ActionSection?
            if let section = dictionary(suggestion["section2"]),
               let title = text("title", in: section) {
                let values = section["content"] as? [Any] ?? []
                let items = values.compactMap(textSection)
                if !items.isEmpty {
                    actionPlan = .init(title: title, items: items)
                }
            }

            if judgment != nil || actionPlan != nil || conclusion != nil {
                coachSuggestion = .init(judgment: judgment,
                                        actionPlan: actionPlan,
                                        conclusion: conclusion)
            }
        }

        return NutritionGoalsResult(protein: number("protein"),
                                    carbohydrate: number("carbohydrate"),
                                    fat: number("fat"),
                                    calories: number("calories"),
                                    coachSuggestion: coachSuggestion)
    }

}
