//
//  AIGuidanceVC.swift
//  lns
//  AI教练  问卷
//  Created by LNS2 on 2026/3/24.
//

import UIKit
import SnapKit

class AIGuidanceVC: WHBaseViewVC {

    enum FlowStep: Hashable {
        case goal
        case goalStage
        case coachStrictness
    }

    var currentIndex: Int = 0
    private var mountedSteps = Set<FlowStep>()
    private let totalSteps = 3
    private var isSubmittingAICoachProfile = false

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    lazy var naviVm: DietPlanCreateNaviVM = {
        let vm = DietPlanCreateNaviVM.init(frame: .zero)
        vm.backButton.isHidden = false
        vm.backTapBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex == 0 {
                self.backTapAction()
                return
            }
            self.moveToStep(index: self.currentIndex - 1, animated: true)
        }
        return vm
    }()
    lazy var stepsArray: [Int] = [1,1,1]
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("下一步", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.isHidden = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)

        return btn
    }()
    lazy var goalVm: AIGuidanceGoalVM = {
        let vm = AIGuidanceGoalVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.goalStageVm.refreshContentForCurrentGoal()
            self?.coachStrictnessVm.refreshContentForCurrentGoal()
            self?.moveToStep(index: 1, animated: true)
        }
        return vm
    }()
    lazy var goalStageVm: AIGuidanceGoalStageVM = {
        let vm = AIGuidanceGoalStageVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
    lazy var coachStrictnessVm: AIGuidanceCoachStrictnessVM = {
        let vm = AIGuidanceCoachStrictnessVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.updateNextButtonForCurrentStep()
        }
        return vm
    }()
}

extension AIGuidanceVC{
    @objc func nextButtonTapAction() {
        guard let currentStep = flowStep(for: currentIndex) else {
            return
        }

        switch currentStep {
        case .goal:
            break
        case .goalStage:
            moveToStep(index: 2, animated: true)
        case .coachStrictness:
            submitAICoachProfile()
        }
    }

    func flowStep(for index: Int) -> FlowStep? {
        switch index {
        case 0:
            return .goal
        case 1:
            return .goalStage
        case 2:
            return .coachStrictness
        default:
            return nil
        }
    }

    func stepView(for step: FlowStep) -> UIView? {
        switch step {
        case .goal:
            return goalVm
        case .goalStage:
            return goalStageVm
        case .coachStrictness:
            return coachStrictnessVm
        }
    }

    func installStepViewsIfNeeded(indexes: [Int]) {
        for index in indexes {
            guard let step = flowStep(for: index),
                  let stepView = stepView(for: step) else {
                continue
            }
            mountedSteps.insert(step)
            stepView.isHidden = false
            stepView.frame = CGRect(x: SCREEN_WIDHT * CGFloat(index), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            guard stepView.superview == nil else {
                continue
            }
            scrollViewBase.addSubview(stepView)
        }
    }

    func moveToStep(index: Int, animated: Bool) {
        let targetIndex = max(0, index)
        currentIndex = targetIndex
        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(targetIndex), y: 0), animated: animated)
        naviVm.updateStep(steps: stepsArray, currentStep: targetIndex)
        updateNextButtonForCurrentStep()
    }

    func updateNextButtonForCurrentStep() {
        guard let currentStep = flowStep(for: currentIndex) else {
            nextButton.isEnabled = false
            return
        }
        if isSubmittingAICoachProfile {
            nextButton.isHidden = false
            nextButton.isEnabled = false
            return
        }

        switch currentStep {
        case .goal:
            nextButton.isHidden = true
            nextButton.isEnabled = false
        case .goalStage:
            nextButton.isHidden = false
            nextButton.isEnabled = goalStageVm.hasSelection
        case .coachStrictness:
            nextButton.isHidden = false
            nextButton.isEnabled = coachStrictnessVm.hasSelection
        }
    }

    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(scrollViewBase)
        view.addSubview(naviVm)
        view.addSubview(nextButton)

        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.backgroundColor = .clear
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.contentSize = CGSize(width: SCREEN_WIDHT * CGFloat(totalSteps), height: SCREEN_HEIGHT)

        installStepViewsIfNeeded(indexes: [0, 1, 2])
        setConstrait()
        moveToStep(index: 0, animated: false)
    }

    func setConstrait() {
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }
    }
}

extension AIGuidanceVC {
    func submitAICoachProfile() {
        if isSubmittingAICoachProfile {
            return
        }

        let param = buildAICoachUpsertParameters()
        isSubmittingAICoachProfile = true
        updateNextButtonForCurrentStep()

        DLLog(message: "submitAICoachProfile:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_upsert,
                                          parameters: param as [String : AnyObject],
                                          isNeedToast: true,
                                          vc: self) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"] as? Int ?? -1
            guard code == 200 else {
                let msg = responseObject["message"] as? String ?? "保存失败，请稍后重试"
                self.handleAICoachSubmitFailure(message: msg)
                return
            }
            self.isSubmittingAICoachProfile = false
            self.backTapAction()
        } failure: { [weak self] _ in
            self?.handleAICoachSubmitFailure(message: nil)
        }
    }

    func buildAICoachUpsertParameters() -> [String: Any] {
        let isMuscleGainGoal = ["4", "5", "7"].contains(QuestinonaireMsgModel.shared.goal)
        var param: [String: Any] = [
            "userGoal": isMuscleGainGoal ? 2 : 1
        ]

        if isMuscleGainGoal {
            if let muscleGainPhase = buildMuscleGainPhaseValue() {
                param["muscleGainPhase"] = muscleGainPhase
            }
        } else {
            if let fatLossPhase = buildFatLossPhaseValue() {
                param["fatLossPhase"] = fatLossPhase
            }
        }

        if let intensityPreference = buildAICoachIntensityPreferenceValue() {
            param["aiCoachIntensityPreference"] = intensityPreference
        }

        return param
    }

    func buildMuscleGainPhaseValue() -> Int? {
        let mapping: [String: Int] = [
            "gain_prepare": 1,
            "gain_less_1_month": 2,
            "gain_1_3_months": 3,
            "gain_3_12_months": 4,
            "gain_over_1_year": 5
        ]
        return mapping[QuestinonaireMsgModel.shared.aiGuidanceGoalStageType]
    }

    func buildFatLossPhaseValue() -> Int? {
        let mapping: [String: Int] = [
            "fat_prepare": 1,
            "fat_less_2_weeks": 2,
            "fat_2_6_weeks": 3,
            "fat_7_12_weeks": 4,
            "fat_over_12_weeks": 5
        ]
        return mapping[QuestinonaireMsgModel.shared.aiGuidanceGoalStageType]
    }

    func buildAICoachIntensityPreferenceValue() -> Int? {
        let mapping: [String: Int] = [
            "very_relaxed": 1,
            "relaxed": 2,
            "normal": 3,
            "enthusiast": 4,
            "athlete": 5
        ]
        return mapping[QuestinonaireMsgModel.shared.aiGuidanceCoachStrictnessType]
    }

    func handleAICoachSubmitFailure(message: String?) {
        isSubmittingAICoachProfile = false
        updateNextButtonForCurrentStep()

        guard let message = message, !message.isEmpty else {
            return
        }

        let alertVc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "确定", style: .cancel)
        alertVc.addAction(confirmAction)
        present(alertVc, animated: true)
    }
}
