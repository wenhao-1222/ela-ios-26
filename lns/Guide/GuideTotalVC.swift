//
//  GuideTotalVC.swift
//  lns
//  新的引导页
//  Created by Elavatine on 2025/6/4.
//

class GuideTotalVC: WHBaseViewVC {
    
    /// Called when the guide is finished
    var finishBlock:(() -> Void)?
    
    /// Current displayed page index
    private var currentIndex: Int = 0
    private var isSubmittingAICoachProfile = false
    private let pageBackgroundView = UIView()
    private var solidPageBackgroundViews: [Int: UIView] = [:]
    private let flowingBackgroundPageIndexes: Set<Int> = [8, 12, 13]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    /// Remove guide view controller and notify caller
    func dismissGuide() {
        finishBlock?()
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    lazy var progressVm: GuideTotalProgressVM = {
        let vm = GuideTotalProgressVM.init(frame: .zero)
        vm.backBlock = {[weak self] in
            guard let self = self else { return }
            if self.currentIndex > 0 {
                self.showStep(self.currentIndex - 1, animated: true)
            }
        }
        return vm
    }()
    lazy var goalStageInfoAlertVm: AIGuidanceGoalStageInfoAlertVM = {
        let vm = AIGuidanceGoalStageInfoAlertVM(frame: .zero)
        return vm
    }()
    lazy var bodyImpactVm: GuideTotalBodyImpactVM = {
        let vm = GuideTotalBodyImpactVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 1)
        }
        return vm
    }()
    lazy var dietRecordVm: GuideTotalDietRecordVM = {
        let vm = GuideTotalDietRecordVM.init(frame: .zero)
        vm.shouldAutoStartChartAnimation = false
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 2)
        }
        vm.backBlock = { [weak self] in
            self?.showStep(0, animated: true)
        }
        return vm
    }()
    lazy var proVm: GuideTotalProVM = {
        let vm = GuideTotalProVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 8)
        }
        return vm
    }()
    lazy var proReadyStartVm: GuideTotalProReadyStartVM = {
        let vm = GuideTotalProReadyStartVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 9)
        }
        return vm
    }()
    lazy var proGoalVm: GuideTotalProGoalVM = {
        let vm = GuideTotalProGoalVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.handleAICoachQuestionnaireSelectionChanged()
        }
        vm.nextBlock = { [weak self] in
            guard let self = self else { return }
            self.proGoalStageVm.refreshContentForCurrentGoal()
            self.proCoachStrictnessVm.refreshContentForCurrentGoal()
            self.animateTransition(to: 10)
        }
        return vm
    }()
    lazy var proGoalStageVm: GuideTotalProGoalStageVM = {
        let vm = GuideTotalProGoalStageVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.handleAICoachQuestionnaireSelectionChanged()
        }
        vm.infoButtonTapBlock = { [weak self] content in
            self?.showGoalStageInfoAlert(content: content)
        }
        vm.nextBlock = { [weak self] in
            guard let self = self else { return }
            self.proCoachStrictnessVm.refreshContentForCurrentGoal()
            self.animateTransition(to: 11)
        }
        return vm
    }()
    lazy var proCoachStrictnessVm: GuideTotalProCoachStrictnessVM = {
        let vm = GuideTotalProCoachStrictnessVM.init(frame: .zero)
        vm.selectedBlock = { [weak self] in
            self?.handleAICoachQuestionnaireSelectionChanged()
        }
        vm.nextBlock = { [weak self] in
            self?.submitAICoachProfile()
        }
        return vm
    }()
    lazy var proNoticeVm: GuideTotalProNoticeVM = {
        let vm = GuideTotalProNoticeVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 13)
        }
        return vm
    }()
    lazy var proCompleteVm: GuideTotalProCompleteVM = {
        let vm = GuideTotalProCompleteVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.finishBlock?()
        }
        return vm
    }()
    lazy var thirdVm: GuideTotalThirdVM = {
        let vm = GuideTotalThirdVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 3)
        }
        return vm
    }()
    lazy var fourthVm: GuideTotalFourVM = {
        let vm = GuideTotalFourVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 4)
        }
        return vm
    }()
    
    lazy var fifthVm: GuideTotalFifthVM = {
        let vm = GuideTotalFifthVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.sevenVm.caloriesCircleVm.setData(currentNumber: 266)
            self?.animateTransition(to: 5)
        }
        return vm
    }()
    lazy var sixthVm: GuideTotalSixthVM = {
        let vm = GuideTotalSixthVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 6)
        }
        return vm
    }()
    lazy var sevenVm: GuideTotalSevenVM = {
        let vm = GuideTotalSevenVM.init(frame: .zero)
        vm.nextBlock = { [weak self] in
            self?.animateTransition(to: 7)
        }
        return vm
    }()

    private var guidePages: [UIView] {
        return [
            bodyImpactVm,
            dietRecordVm,
            thirdVm,
            fourthVm,
            fifthVm,
            sixthVm,
            sevenVm,
            proVm,
            proReadyStartVm,
            proGoalVm,
            proGoalStageVm,
            proCoachStrictnessVm,
            proNoticeVm,
            proCompleteVm
        ]
    }

    private func showsFlowingBackground(at index: Int) -> Bool {
        return flowingBackgroundPageIndexes.contains(index)
    }

    private func resetSolidPageBackgroundAlphas(except excludedView: UIView? = nil) {
        for backgroundView in solidPageBackgroundViews.values where backgroundView !== excludedView {
            backgroundView.alpha = 1
        }
    }

    private func updateProgressForCurrentStep(animated: Bool = true) {
        let progressStartIndex = 2
        let wasProgressHidden = progressVm.isHidden
        if currentIndex == 0 {
            progressVm.isHidden = true
            return
        }
        if currentIndex == 1 {
            progressVm.setBackOnlyMode(true, animated: animated && !wasProgressHidden)
            progressVm.isHidden = false
            return
        }
        if currentIndex >= 8 {
            progressVm.setBackOnlyMode(true, animated: animated && !wasProgressHidden)
            progressVm.isHidden = false
            return
        }
        progressVm.isHidden = false
        progressVm.setStep(step: currentIndex - progressStartIndex,
                           animated: animated,
                           showsBackButton: currentIndex >= progressStartIndex)
    }
}

extension GuideTotalVC{
    /// Animates transition between guide pages
    func animateTransition(to index: Int) {
        guard index != currentIndex else { return }
        guard index >= 0, index < guidePages.count else { return }
        self.progressVm.isUserInteractionEnabled = false
        let fromView = guidePages[currentIndex]
        let toView = guidePages[index]
        let fadingBackgroundView: UIView?
        if !showsFlowingBackground(at: currentIndex), showsFlowingBackground(at: index) {
            fadingBackgroundView = solidPageBackgroundViews[currentIndex]
        } else {
            fadingBackgroundView = nil
        }
        resetSolidPageBackgroundAlphas(except: fadingBackgroundView)
        // Prepare entrance animations for upcoming view
        switch index {
        case 0: bodyImpactVm.prepareEntranceAnimation()
        case 1: dietRecordVm.prepareEntranceAnimation()
        case 2: thirdVm.prepareEntranceAnimation()
        case 3: fourthVm.prepareEntranceAnimation()
        case 4: fifthVm.prepareEntranceAnimation()
        case 5: sixthVm.prepareEntranceAnimation()
        case 6: sevenVm.prepareEntranceAnimation()
        case 7: proVm.prepareEntranceAnimation()
        case 8: proReadyStartVm.prepareEntranceAnimation()
        case 9: proGoalVm.prepareEntranceAnimation()
        case 10: proGoalStageVm.prepareEntranceAnimation()
        case 11: proCoachStrictnessVm.prepareEntranceAnimation()
        case 12: proNoticeVm.prepareEntranceAnimation()
        case 13: proCompleteVm.prepareEntranceAnimation()
        default: break
        }

        toView.alpha = 0
        UIView.animate(withDuration: 0.75, delay: 0,options: .curveEaseInOut) {
            fromView.alpha = 0
            fadingBackgroundView?.alpha = 0
        }completion: { _ in
            self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: false)
            fadingBackgroundView?.alpha = 1
        }
        let duration = 0.01
        
        UIView.animate(withDuration: duration, delay: 0.6,options: .curveEaseInOut) {
            toView.alpha = 1
        }completion: { _ in
            switch index {
            case 0: self.bodyImpactVm.startEntranceAnimation()
            case 1: self.dietRecordVm.startEntranceAnimation()
            case 2: self.thirdVm.startEntranceAnimation()
            case 3: self.fourthVm.startEntranceAnimation()
            case 4: self.fifthVm.startEntranceAnimation()
            case 5: self.sixthVm.startEntranceAnimation()
            case 6: self.sevenVm.startEntranceAnimation()
            case 7: self.proVm.startEntranceAnimation()
            case 8: self.proReadyStartVm.startEntranceAnimation()
            case 9: self.proGoalVm.startEntranceAnimation()
            case 10: self.proGoalStageVm.startEntranceAnimation()
            case 11: self.proCoachStrictnessVm.startEntranceAnimation()
            case 12: self.proNoticeVm.startEntranceAnimation()
            case 13: self.proCompleteVm.startEntranceAnimation()
            default: break
            }
            self.progressVm.isUserInteractionEnabled = true
        }
//        UIView.animate(withDuration: 0.25, animations: {
//            fromView.alpha = 0
//        }) { _ in
//            self.scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: false)
//            UIView.animate(withDuration: 0.25) {
//                toView.alpha = 1
//            }
//            self.progressVm.isUserInteractionEnabled = true
//        }

        currentIndex = index
        updateProgressForCurrentStep()
        EventLogUtils().sendEventLogRequest(eventName: .PAGE_VIEW,
                                            scenarioType: .guide_view,
                                            text: "\(currentIndex+1)")
    }
    /// Display a specific step without cross-fade animation
    func showStep(_ index: Int, animated: Bool) {
        guard index != currentIndex else { return }
        guard index >= 0, index < guidePages.count else { return }

        // Ensure all pages are visible when switching without animation
        guidePages.forEach { $0.alpha = 1 }
        resetSolidPageBackgroundAlphas()

        scrollViewBase.setContentOffset(CGPoint(x: SCREEN_WIDHT * CGFloat(index), y: 0), animated: true)

        currentIndex = index
        updateProgressForCurrentStep(animated: animated)
    }
}

extension GuideTotalVC{
    func layoutGuidePages() {
        pageBackgroundView.frame = CGRect(x: 0,
                                          y: 0,
                                          width: SCREEN_WIDHT * CGFloat(guidePages.count),
                                          height: SCREEN_HEIGHT)
        for (index, backgroundView) in solidPageBackgroundViews {
            backgroundView.frame = CGRect(x: SCREEN_WIDHT * CGFloat(index),
                                          y: 0,
                                          width: SCREEN_WIDHT,
                                          height: SCREEN_HEIGHT)
        }
        for (index, page) in guidePages.enumerated() {
            page.frame = CGRect(x: SCREEN_WIDHT * CGFloat(index), y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
    }

    func configurePageBackgrounds() {
        pageBackgroundView.backgroundColor = .clear
        for index in guidePages.indices where !showsFlowingBackground(at: index) {
            let backgroundView = UIView()
            backgroundView.backgroundColor = .COLOR_BG_F5
            pageBackgroundView.addSubview(backgroundView)
            solidPageBackgroundViews[index] = backgroundView
        }
    }

    func initUI() {
        addELAFlowingBackground()
        view.addSubview(scrollViewBase)
        view.addSubview(progressVm)
        
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        scrollViewBase.bounces = false
        scrollViewBase.delegate = self
        scrollViewBase.isScrollEnabled = false
        scrollViewBase.showsHorizontalScrollIndicator = false
        scrollViewBase.isPagingEnabled = true
        scrollViewBase.addSubview(pageBackgroundView)
        configurePageBackgrounds()
        scrollViewBase.addSubview(bodyImpactVm)
        scrollViewBase.addSubview(dietRecordVm)
        scrollViewBase.addSubview(thirdVm)
        scrollViewBase.addSubview(fourthVm)
        scrollViewBase.addSubview(fifthVm)
        scrollViewBase.addSubview(sixthVm)
        scrollViewBase.addSubview(sevenVm)
        scrollViewBase.addSubview(proVm)
        scrollViewBase.addSubview(proReadyStartVm)
        scrollViewBase.addSubview(proGoalVm)
        scrollViewBase.addSubview(proGoalStageVm)
        scrollViewBase.addSubview(proCoachStrictnessVm)
        scrollViewBase.addSubview(proNoticeVm)
        scrollViewBase.addSubview(proCompleteVm)
        view.addSubview(goalStageInfoAlertVm)
        
        layoutGuidePages()
        scrollViewBase.contentSize = CGSize.init(width: SCREEN_WIDHT * CGFloat(guidePages.count), height: 0)
//        scrollViewBase.backgroundColor = UIColor(named: "color_card_bg_f5_guide")
        scrollViewBase.backgroundColor = .clear//.COLOR_BG_F5
        self.scrollViewBase.layoutIfNeeded()
        self.view.layoutIfNeeded()
        goalStageInfoAlertVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        updateProgressForCurrentStep(animated: false)
    }
}

extension GuideTotalVC {
    func showGoalStageInfoAlert(content: AIGuidanceGoalStageInfoContent) {
        view.bringSubviewToFront(goalStageInfoAlertVm)
        goalStageInfoAlertVm.show(content: content)
    }

    func handleAICoachQuestionnaireSelectionChanged() {
        isSubmittingAICoachProfile = false
        proCoachStrictnessVm.nextButton.isEnabled = proCoachStrictnessVm.hasSelection
    }

    func submitAICoachProfile() {
        guard !isSubmittingAICoachProfile else { return }
        isSubmittingAICoachProfile = true
        proCoachStrictnessVm.nextButton.isEnabled = false

        let param = buildAICoachUpsertParameters()
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
            self.proCoachStrictnessVm.nextButton.isEnabled = self.proCoachStrictnessVm.hasSelection
            self.animateTransition(to: 12)
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
        proCoachStrictnessVm.nextButton.isEnabled = proCoachStrictnessVm.hasSelection

        guard let message = message, !message.isEmpty else {
            return
        }

        let alertVc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "确定", style: .cancel)
        alertVc.addAction(confirmAction)
        present(alertVc, animated: true)
    }

}

extension GuideTotalVC:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x/SCREEN_WIDHT)
        updateProgressForCurrentStep()
    }
}
