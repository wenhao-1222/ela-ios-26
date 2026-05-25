//
//  AICoachPreVC.swift
//  lns
//  AI教练报告 前置页
//  Created by LNS2 on 2026/3/25.
//

import UIKit
import SwiftUI
import SnapKit

class AICoachPreVC: WHBaseViewVC, UIGestureRecognizerDelegate {

    var reportId = ""
    var dataDict = NSDictionary()
    private var reportList: [AICoachReportListItem] = []
    private let shouldPlayFirstEntryAnimation = AICoachPreVC.consumeFirstEntryAnimationFlag()
    private var userGoal: Int = 0
    private var aiCoachIntensityPreference: Int = 0
    private var isUpdatingAICoachProfile = false
    private var hasPlayedCircleEntranceAnimation = false
    private var hasPlayedRemainingEntranceAnimation = false
    private var hasFinishedCircleEntranceAnimation = false
    private var isWaitingForCoachLaunchResponse = false
    private var aiCoachOrbHostController: UIHostingController<AICoachPreOrbRootView>?
    private let entranceAnimationDurationA: TimeInterval = 0.75
    private let entranceAnimationDurationB: TimeInterval = 0.35
    private let entranceAnimationDurationC: TimeInterval = 0.7
    
    private lazy var preDaysVM: AICoachPreDaysVM = {
        let view = AICoachPreDaysVM(frame: .zero)
        return view
    }()

    private lazy var preInfoVM: AICoachPreInfoVM = {
        let view = AICoachPreInfoVM(frame: .zero)
        view.rowTapBlock = { [weak self] field in
            self?.showInfoSelectPopup(for: field)
        }
        return view
    }()

    private lazy var infoSelectPopupVM: AICoachPreInfoSelectPopupVM = {
        let view = AICoachPreInfoSelectPopupVM(frame: .zero)
        view.confirmBlock = { [weak self] field, value in
            self?.updateAICoachProfile(field: field, value: value)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if dataDict.stringValueForKey(key: "has7CompleteDays").count > 0{
            isWaitingForCoachLaunchResponse = false
        }else{
            isWaitingForCoachLaunchResponse = true
        }

        initUI()
        if isWaitingForCoachLaunchResponse {
            sendCoachLaunchRequest()
        } else {
            self.updatePreDaysUI(dataDict: dataDict)
        }
        sendReportListRequest()
        
        if let nav = navigationController {
            var controllers = nav.viewControllers
            if let index = controllers.firstIndex(where: { $0 is AIGuidanceVC }){
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
            if let index = controllers.firstIndex(where: { $0 is ElaProVC }){
                controllers.remove(at: index)
                nav.viewControllers = controllers
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trimNavigationStackToRootAndSelfIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldPlayEntranceAnimation {
            startCircleEntranceAnimationIfNeeded()
        } else {
            syncVisiblePresentationStateIfNeeded()
        }
    }

    override func backTapAction() {
        navigationController?.popToRootViewController(animated: true)
    }

    lazy var tipsButton: ElaExpandedTapButton = {
        let btn = ElaExpandedTapButton(type: .custom)
        btn.hitTestEdgeInsets = .init(top: -12, left: -12, bottom: -12, right: -12)
        btn.setImage(UIImage(named: "tips_black_icon"), for: .normal)
        
        btn.addTarget(self, action: #selector(tipsTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var bgImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_pro_ai_pre_bg")
        img.contentMode = .scaleAspectFit
        img.alpha = 0
        return img
    }()
    
    lazy var circleImgView: CoachAnimationV3View = {
        let orbView = CoachAnimationV3View(diameter: kFitWidth(250))
        orbView.backgroundColor = .clear
        return orbView
    }()
//    private lazy var aiCoachOrbContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .clear
//        view.isOpaque = false
//        return view
//    }()
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("查看报告", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.white, for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(22)
        btn.clipsToBounds = true
        btn.alpha = 0
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)

        return btn
    }()

    private lazy var dismissPopupTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopupTapAction))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()
    lazy var katchAlertVm : QuestionnaireBodyFatAlertVM = {
        let vm = QuestionnaireBodyFatAlertVM.init(frame: .zero)
        vm.titleLabel.text = "AI教练是如何运作的？"
        vm.contentLabelOne.text = "当你开启 AI 教练，系统将主动观察你的饮食摄入、体重波动及每周进展。待系统积累完整的周期数据后，教练将为你提供一份全面的诊断报告，并给出针对性的饮食与营养素调整建议。\n\n每一次调整，AI 都会更深度地了解你，使后续方案愈发精准。\n\n不同于只按绝对标准执行、缺乏灵活性的机械公式，AI 教练能根据你的个人实际情况与摄入数据进行灵活调优，并给出针对性的解决方案。"
        vm.contentLabelTwo.text = ""
        vm.contentLabelThree.text = ""
        return vm
    }()
}

extension AICoachPreVC{
    @objc func nextButtonTapAction() {
        guard reportId.isEmpty == false else { return }
        let reportStatus = currentReportStatus

        if canOpenReport(for: reportStatus) {
            let vc = AICoachReportPDFDemoVC()
            vc.reportId = self.reportId
            vc.reportList = reportList
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func dismissPopupTapAction() {
        preDaysVM.dismissPopup()
    }
    
    @objc func tipsTapAction() {
        katchAlertVm.showView()
    }
    
}

extension AICoachPreVC{
    func initUI() {
        view.addSubview(bgImgView)
        initNavi(titleStr: "AI教练")
        
        navigationView.addSubview(tipsButton)
        view.backgroundColor = .COLOR_BG_F2
        navigationView.backgroundColor = .clear
        view.addGestureRecognizer(dismissPopupTapGesture)
        // 原 CoachAnimationV3View 保留，暂不加入层级；当前改用 SwiftUI AICoachLoopOrb。
         view.addSubview(circleImgView)
//        view.addSubview(aiCoachOrbContainerView)
//        installAICoachOrbIfNeeded()

        view.addSubview(preDaysVM)
        view.addSubview(preInfoVM)
        view.addSubview(nextButton)
        view.addSubview(infoSelectPopupVM)
        
        view.addSubview(katchAlertVm)
        
        setConstrait()
        configureInitialPresentationState()
    }
    func setConstrait() {
        tipsButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(naviTitleLabel)
            make.width.height.equalTo(kFitWidth(20))
        }
        bgImgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        // 原 circleImgView 约束保留，回退 CoachAnimationV3View 时可恢复。
        circleImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(133.5))
            make.width.height.equalTo(kFitWidth(250))
        }
//        aiCoachOrbContainerView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(kFitWidth(133.5))
//            make.width.height.equalTo(kFitWidth(250))
//        }
        preDaysVM.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(circleImgView.snp.bottom).offset(kFitWidth(50))
            make.height.equalTo(preDaysVM.selfHeight)
        }

        preInfoVM.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(preDaysVM.snp.bottom).offset(kFitWidth(16))
            make.height.equalTo(preInfoVM.selfHeight)
        }
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(kFitWidth(-20))
            make.height.equalTo(kFitWidth(44))
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
        }

        infoSelectPopupVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AICoachPreVC {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return preDaysVM.isTouchInsideDayItem(touch.view) == false
    }
}

extension AICoachPreVC{
    func sendCoachLaunchRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_launch, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsMsgDict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCoachLaunchRequest:\(foodsMsgDict)")
            self.isWaitingForCoachLaunchResponse = false
            self.dataDict = foodsMsgDict
            self.updatePreDaysUI(dataDict: foodsMsgDict)
            if self.shouldPlayEntranceAnimation {
                self.startCircleEntranceAnimationIfNeeded()
            } else {
                self.syncVisiblePresentationStateIfNeeded(force: true)
            }
        }
    }
    func sendReportListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_report_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = self.getArrayFromJSONString(jsonString: dataString ?? "")
            self.reportList = AICoachReportDateTextBuilder.buildList(from: dataArray)
            
            DLLog(message: "sendReportListRequest:\(dataArray)")
        }
    }
}

private extension AICoachPreVC {
    func trimNavigationStackToRootAndSelfIfNeeded() {
        guard let navigationController = navigationController else { return }
        guard navigationController.topViewController === self else { return }
        guard let rootViewController = navigationController.viewControllers.first else { return }
        if navigationController.viewControllers.count > 2 {
            navigationController.setViewControllers([rootViewController, self], animated: false)
        }
    }

    func applyNextButtonState(animated: Bool = false, updatesMessage: Bool = true) {
        let reportStatus = currentReportStatus
        let shouldEnableReportButton = canOpenReport(for: reportStatus)

        if shouldEnableReportButton {
            applyNextButtonPresentation(title: "查看报告",
                                        isEnabled: true,
                                        backgroundColor: .THEME,
                                        animated: animated)
            preDaysVM.messageLabel.alpha = 0
            preDaysVM.messageLabel.isHidden = false
            UIView.animate(withDuration: 0.35) {
                self.preDaysVM.messageLabel.alpha = 1
            }
            if updatesMessage {
                preDaysVM.showConfiguredMessage(animated: animated)
            }
            preDaysVM.setShouldAnimateSweep(false)
            return
        }

        applyNextButtonPresentation(title: "查看报告",
                                    isEnabled: false,
                                    backgroundColor: .COLOR_BUTTON_DISABLE_BG_THEME,
                                    animated: animated)
        preDaysVM.messageLabel.isHidden = false
        if updatesMessage {
            preDaysVM.showConfiguredMessage(animated: animated)
        }
        preDaysVM.setShouldAnimateSweep(false)
    }

    func canOpenReport(for reportStatus: Int) -> Bool {
        reportStatus == 2 || reportStatus == 4
    }

    func applyNextButtonPresentation(title: String,
                                     isEnabled: Bool,
                                     backgroundColor: UIColor,
                                     animated: Bool) {
        let currentTitle = nextButton.title(for: nextButton.isEnabled ? .normal : .disabled)
        let shouldAnimate = animated && nextButton.alpha > 0
        let applyTitle = {
            self.nextButton.setTitle(title, for: .normal)
            self.nextButton.setTitle(title, for: .disabled)
        }

        nextButton.isEnabled = isEnabled

        if shouldAnimate, currentTitle != title {
            UIView.transition(with: nextButton.titleLabel ?? nextButton,
                              duration: 0.35,
                              options: [.transitionCrossDissolve, .allowUserInteraction],
                              animations: applyTitle)
        } else {
            applyTitle()
        }

        if shouldAnimate {
            UIView.animate(withDuration: 0.35) {
                self.nextButton.backgroundColor = backgroundColor
            }
        } else {
            nextButton.backgroundColor = backgroundColor
        }
    }

    func updatePreDaysUI(dataDict: NSDictionary) {
        self.dataDict = dataDict
//        nextButton.isHidden = dataDict.stringValueForKey(key: "has7CompleteDays") == "0"
        let latestReportDict = dataDict["latestReport"]as? NSDictionary ?? [:]

        self.reportId = latestReportDict.stringValueForKey(key: "id")
        let reportStatus = latestReportDict.stringValueForKey(key: "reportStatus").intValue
        let remainingDays = max(0, dataDict.stringValueForKey(key: "remainingDays").intValue)
        var isFirstReport = dataDict.floatValueForKey(key: "reportCount") <= 1//是否为首报
        
        let userGoal = dataDict["userGoal"] as? Int ?? 0
        let aiCoachIntensityPreference = dataDict["aiCoachIntensityPreference"] as? Int ?? 0
        self.userGoal = userGoal
        self.aiCoachIntensityPreference = aiCoachIntensityPreference

        guard let progressBar = dataDict["progressBar"] as? [NSDictionary], progressBar.isEmpty == false else {
            DispatchQueue.main.async {
                var items:[AICoachPreDaysVM.DayItem] = []
                for i in 0..<7{
                    if i < dataDict.stringValueForKey(key: "completeDays").intValue{
                        items.append(AICoachPreDaysVM.DayItem(title: "", state: .completed, completeStatus: 2))
                    }else{
                        items.append(AICoachPreDaysVM.DayItem(title: "", state: .pending, completeStatus: 0))
                    }
                }
                self.preDaysVM.configure(items: items,
                                         reportAfterDays: remainingDays,
                                         isFirstReport:isFirstReport,
                                         completeDays: dataDict.stringValueForKey(key: "completeDays").intValue,
                                         shouldAnimateSweep: self.shouldAnimateProgressHighlights(reportAfterDays: remainingDays),
                                         temporaryMessage: nil,
                                         animateMessageChange: self.shouldAnimateStateTransition)
                self.preInfoVM.configure(
                    userGoal: userGoal,
                    aiCoachIntensityPreference: aiCoachIntensityPreference
                )
                self.applyNextButtonState(animated: self.shouldAnimateStateTransition, updatesMessage: false)
                self.syncVisiblePresentationStateIfNeeded(force: self.shouldForceVisiblePresentationAfterDataUpdate)
            }
            return
        }
        
        //首报
        if isFirstReport{
            //已查看的状态   progressBar 有值
            if latestReportDict.stringValueForKey(key: "reportStatus") == "4"{
                isFirstReport = false
            }
        }

        let sortedProgressBar = progressBar.sorted { left, right in
            let leftDate = Date().changeDateStringToDate(dateString: left["date"] as? String ?? "", formatter: "yyyy-MM-dd")
            let rightDate = Date().changeDateStringToDate(dateString: right["date"] as? String ?? "", formatter: "yyyy-MM-dd")
            return leftDate < rightDate
        }

        let todayDateString = Date().todayDate
        let items = sortedProgressBar.map { item -> AICoachPreDaysVM.DayItem in
            let dateString = item["date"] as? String ?? ""
            let completeStatus = item["completeStatus"] as? Int ?? (item["completeStatus"] as? String ?? "0").intValue
            let state = dayState(for: dateString, todayDateString: todayDateString)

            return .init(title: weekdayShortText(from: dateString), state: state, completeStatus: completeStatus)
        }

        DispatchQueue.main.async {
            self.preDaysVM.configure(items: items,
                                     reportAfterDays: remainingDays,
                                     isFirstReport:isFirstReport,
                                     completeDays: dataDict.stringValueForKey(key: "completeDays").intValue,
                                     shouldAnimateSweep: self.shouldAnimateProgressHighlights(reportAfterDays: remainingDays),
                                     temporaryMessage: nil,
                                     animateMessageChange: self.shouldAnimateStateTransition)
            self.preInfoVM.configure(
                userGoal: userGoal,
                aiCoachIntensityPreference: aiCoachIntensityPreference
            )
            self.applyNextButtonState(animated: self.shouldAnimateStateTransition, updatesMessage: false)
            self.syncVisiblePresentationStateIfNeeded(force: self.shouldForceVisiblePresentationAfterDataUpdate)
        }
    }

    func dayState(for dateString: String, todayDateString: String = Date().todayDate) -> AICoachPreDaysVM.DayState {
        let normalizedDateString = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalizedDateString == todayDateString {
            return .current
        }

        guard let date = preDayDate(from: normalizedDateString),
              let todayDate = preDayDate(from: todayDateString) else {
            return .pending
        }

        return date < todayDate ? .completed : .pending
    }

    func preDayDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString)
    }

    func weekdayShortText(from dateString: String) -> String {
        let date = Date().changeDateStringToDate(dateString: dateString, formatter: "yyyy-MM-dd")
        switch Calendar.current.component(.weekday, from: date) {
        case 1: return "日"
        case 2: return "一"
        case 3: return "二"
        case 4: return "三"
        case 5: return "四"
        case 6: return "五"
        case 7: return "六"
        default: return ""
        }
    }

    func showInfoSelectPopup(for field: AICoachPreInfoEditableField) {
        guard isUpdatingAICoachProfile == false else { return }
        let selectedValue = field == .goal ? userGoal : aiCoachIntensityPreference
        infoSelectPopupVM.update(field: field, selectedValue: selectedValue)
        infoSelectPopupVM.showSelf()
    }

    func updateAICoachProfile(field: AICoachPreInfoEditableField, value: Int) {
        let newUserGoal = field == .goal ? value : userGoal
        let newIntensityPreference = field == .intensity ? value : aiCoachIntensityPreference

        guard newUserGoal != userGoal || newIntensityPreference != aiCoachIntensityPreference else {
            return
        }

        let param = buildAICoachUpsertParameters(userGoal: newUserGoal,
                                                 aiCoachIntensityPreference: newIntensityPreference)
        guard param.isEmpty == false else { return }

        isUpdatingAICoachProfile = true
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_upsert,
                                          parameters: param as [String : AnyObject],
                                          isNeedToast: true,
                                          vc: self) { [weak self] responseObject in
            guard let self = self else { return }
            let code = responseObject["code"] as? Int ?? -1
            guard code == 200 else {
                let message = responseObject["message"] as? String ?? "保存失败，请稍后重试"
                self.handleProfileUpdateFailure(message: message)
                return
            }

            self.isUpdatingAICoachProfile = false
            self.userGoal = newUserGoal
            self.aiCoachIntensityPreference = newIntensityPreference
            self.preInfoVM.configure(userGoal: newUserGoal,
                                     aiCoachIntensityPreference: newIntensityPreference)
        } failure: { [weak self] _ in
            self?.handleProfileUpdateFailure(message: "保存失败，请稍后重试")
        }
    }

    func buildAICoachUpsertParameters(userGoal: Int,
                                      aiCoachIntensityPreference: Int) -> [String: Any] {
        var param: [String: Any] = [:]
        if (1...2).contains(userGoal) {
            param["userGoal"] = userGoal
        }
        if (1...5).contains(aiCoachIntensityPreference) {
            param["aiCoachIntensityPreference"] = aiCoachIntensityPreference
        }
        return param
    }

    func handleProfileUpdateFailure(message: String) {
        isUpdatingAICoachProfile = false
        let alertVc = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "确定", style: .cancel))
        present(alertVc, animated: true)
    }
}

private extension AICoachPreVC {
    static func consumeFirstEntryAnimationFlag() -> Bool {
        let uid = UserInfoModel.shared.uId.isEmpty ? "default" : UserInfoModel.shared.uId
        let key = "ai_coach_pre_first_entry_animation_shown_\(uid)"
        let hasShown = UserDefaults.standard.bool(forKey: key)
        if hasShown == false {
            UserDefaults.standard.set(true, forKey: key)
        }
        return hasShown == false
    }

//    func installAICoachOrbIfNeeded() {
//        guard aiCoachOrbHostController == nil else { return }
//
//        let hostController = UIHostingController(rootView: AICoachPreOrbRootView())
//        hostController.view.backgroundColor = .clear
//        hostController.view.isOpaque = false
//
//        addChild(hostController)
//        aiCoachOrbContainerView.addSubview(hostController.view)
//        hostController.view.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        hostController.didMove(toParent: self)
//        aiCoachOrbHostController = hostController
//    }

    func prepareEntranceAnimation() {
        let initialTransform = CGAffineTransform(translationX: 0, y: -kFitWidth(12))
        bgImgView.alpha = 1
        bgImgView.transform = .identity
        // 原 circleImgView 状态保留，当前动画由 aiCoachOrbContainerView 承载。
//        circleImgView.alpha = 1
//        circleImgView.transform = .identity
//        aiCoachOrbContainerView.alpha = 1
//        aiCoachOrbContainerView.transform = .identity
        preDaysVM.prepareEntranceAnimation()
        preInfoVM.prepareTextEntranceAnimation()
        infoSelectPopupVM.alpha = 1
        infoSelectPopupVM.transform = .identity
        nextButton.isHidden = true
        nextButton.alpha = 0
        nextButton.transform = initialTransform
    }

    func configureInitialPresentationState() {
        if isWaitingForCoachLaunchResponse {
            prepareEntranceAnimation()
        } else if shouldPlayEntranceAnimation {
            prepareEntranceAnimation()
        } else {
            syncVisiblePresentationStateIfNeeded()
        }
    }

    func startCircleEntranceAnimationIfNeeded() {
        guard hasPlayedCircleEntranceAnimation == false else { return }
        hasPlayedCircleEntranceAnimation = true
        view.layoutIfNeeded()
        hasFinishedCircleEntranceAnimation = true
        startRemainingEntranceAnimationIfNeeded()
    }

    func startRemainingEntranceAnimationIfNeeded() {
        guard hasFinishedCircleEntranceAnimation else { return }
        guard hasPlayedRemainingEntranceAnimation == false else { return }
        guard isWaitingForCoachLaunchResponse == false else { return }

        hasPlayedRemainingEntranceAnimation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if self.shouldPlayParallelHalfEntranceAnimation {
                self.playParallelEntranceAnimation()
            } else {
                self.playSequentialEntranceAnimation()
            }
        }
    }

    func playSequentialEntranceAnimation() {
        preDaysVM.playDaysEntranceAnimation(duration: entranceAnimationDurationA)
        preInfoVM.playEntranceAnimation(duration: entranceAnimationDurationA) { [weak self] in
            self?.playMessageAndButtonEntranceAnimation()
        }
    }

    func playParallelEntranceAnimation() {
        let durationA = entranceAnimationDurationA * 0.5
        let durationB = entranceAnimationDurationB * 0.5
        let durationC = entranceAnimationDurationC * 0.5
        let shouldShowNextButton = self.shouldShowNextButton

        if shouldShowNextButton {
            nextButton.isHidden = false
        }

        preDaysVM.playDaysEntranceAnimation(duration: durationA)
        preInfoVM.playEntranceAnimation(duration: durationA)
        preDaysVM.playMessageEntranceAnimation(duration: durationB)
        animateEntrance(view: nextButton,
                        duration: durationC,
                        delay: 0,
                        shouldFadeIn: shouldShowNextButton) { [weak self] in
            self?.updateNextButtonVisibility(animated: false)
        }
    }

    func playMessageAndButtonEntranceAnimation() {
        preDaysVM.playMessageEntranceAnimation(duration: entranceAnimationDurationB) { [weak self] in
            guard let self = self else { return }
            let shouldShowNextButton = self.shouldShowNextButton
            if shouldShowNextButton {
                self.nextButton.isHidden = false
            }
            self.animateEntrance(view: self.nextButton,
                                 duration: self.entranceAnimationDurationC,
                                 delay: 0,
                                 shouldFadeIn: shouldShowNextButton) { [weak self] in
                self?.updateNextButtonVisibility(animated: false)
            }
        }
    }

    func animateEntrance(view: UIView,
                         duration: TimeInterval,
                         delay: TimeInterval,
                         shouldFadeIn: Bool = true,
                         completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: .curveLinear) {
            view.transform = .identity
            if shouldFadeIn {
                view.alpha = 1
            }
        } completion: { _ in
            if shouldFadeIn == false {
                view.alpha = 0
            }
            completion?()
        }
    }

    func updateNextButtonVisibility(animated: Bool) {
        let shouldShow = shouldShowNextButton
        let targetAlpha: CGFloat = shouldShow ? 1 : 0
        guard animated else {
            nextButton.isHidden = !shouldShow
            nextButton.alpha = targetAlpha
            return
        }
        if shouldShow {
            nextButton.isHidden = false
        }
        UIView.animate(withDuration: 0.35) {
            self.nextButton.alpha = targetAlpha
        } completion: { _ in
            if shouldShow == false {
                self.nextButton.isHidden = true
            }
        }
    }

    func syncVisiblePresentationStateIfNeeded(force: Bool = false) {
        guard force || shouldPlayEntranceAnimation == false || hasPlayedRemainingEntranceAnimation else { return }
        guard force || isWaitingForCoachLaunchResponse == false else { return }

        bgImgView.alpha = 1
        bgImgView.transform = .identity
        // 原 circleImgView 状态保留，当前动画由 aiCoachOrbContainerView 承载。
        circleImgView.alpha = 1
        circleImgView.transform = .identity
//        aiCoachOrbContainerView.alpha = 1
//        aiCoachOrbContainerView.transform = .identity
        preDaysVM.applyFinalPresentationState()
        preInfoVM.applyFinalPresentationState()
        infoSelectPopupVM.alpha = 1
        infoSelectPopupVM.transform = .identity
        updateNextButtonVisibility(animated: false)
        nextButton.transform = .identity
    }

    func shouldAnimateProgressHighlights(reportAfterDays: Int) -> Bool {
        shouldPlayFirstEntryAnimation && currentReportStatus == 2 && reportAfterDays == 0
    }

    var currentReportStatus: Int {
        let latestReportDict = dataDict["latestReport"] as? NSDictionary ?? [:]
        return latestReportDict.stringValueForKey(key: "reportStatus").intValue
    }

    var currentReportAfterDays: Int {
        max(0, dataDict.stringValueForKey(key: "remainingDays").intValue)
    }

    var shouldAnimateStateTransition: Bool {
        hasPlayedRemainingEntranceAnimation && nextButton.alpha > 0
    }

    var shouldShowNextButton: Bool {
        let has7CompleteDays = dataDict.stringValueForKey(key: "has7CompleteDays")
        return has7CompleteDays.count > 0 && has7CompleteDays != "0"
    }

    var shouldForceVisiblePresentationAfterDataUpdate: Bool {
        currentReportStatus == 4 && shouldPlayEntranceAnimation == false
    }

    var shouldPlayParallelHalfEntranceAnimation: Bool {
        shouldPlayFirstEntryAnimation == false && currentReportStatus == 4
    }

    var shouldPlayEntranceAnimation: Bool {
        shouldPlayFirstEntryAnimation || currentReportStatus == 1 || currentReportStatus == 2 || currentReportStatus == 4
    }
}

private struct AICoachPreOrbRootView: View {
    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            AICoachLoopOrb(
                level: .level7,
                size: side,
                showsLevelLabel: false,
                includesBackground: false
            )
            .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.5)
        }
        .background(Color.clear)
    }
}
