//
//  AICoachPreVC.swift
//  lns
//  AI教练报告 前置页
//  Created by LNS2 on 2026/3/25.
//

import UIKit
import SwiftUI
import SnapKit
import MCToast
import DeviceKit

class AICoachPreVC: WHBaseViewVC, UIGestureRecognizerDelegate {

    var reportId = ""
    var dataDict = NSDictionary()
    var askCoachButtonTapBlock: (() -> Void)?
    private var reportList: [AICoachReportListItem] = []
    private let shouldPlayFirstEntryAnimation = AICoachPreVC.consumeFirstEntryAnimationFlag()
    private var userGoal: Int = 0
    private var aiCoachIntensityPreference: Int = 0
    private var aiCoachTone: Int = 0
    private var isUpdatingAICoachProfile = false
    private var hasPlayedCircleEntranceAnimation = false
    private var hasPlayedRemainingEntranceAnimation = false
    private var hasFinishedCircleEntranceAnimation = false
    private var aiCoachOrbHostController: UIHostingController<AICoachPreOrbRootView>?
    private var bgImgViewBottomConstraint: Constraint?
    private var lastBgImgViewBottomOffset: CGFloat = -1
    private let shouldEnableToneFeedbackFeature = true
    // Measured from the original ela_pro_ai_pre_bg asset in pixels.
    private let bgImagePixelSize = CGSize(width: 1500.0, height: 3248.0)
    private let bgCircleCenterYPixels: CGFloat = 1058.0
    private let entranceAnimationDurationA: TimeInterval = 0.75
    private let entranceAnimationDurationB: TimeInterval = 0.75
    private let entranceAnimationDurationC: TimeInterval = 0.7
    // reportCount = 1 且 latestReport.reportStatus = 2 时，readyMessageVM 渐现时长，可按视觉节奏调节。
    private let firstReportReadyMessageFadeDuration: TimeInterval = 0.32
    // reportCount = 1 且 latestReport.reportStatus = 2 时，feedbackGlassVM（不含底部操作按钮）渐现时长，可按视觉节奏调节。
    private let firstReportFeedbackGlassFadeDuration: TimeInterval = 0.32
    // reportCount = 1 且 latestReport.reportStatus = 2 时，底部操作按钮最后单独渐现时长，可按视觉节奏调节。
    private let firstReportFeedbackButtonFadeDuration: TimeInterval = 0.28
    
//    private lazy var preDaysVM: AICoachPreDaysVM = {
//        let view = AICoachPreDaysVM(frame: .zero)
//        view.isHidden = true
//        return view
//    }()
//
//    private lazy var preInfoVM: AICoachPreInfoVM = {
//        let view = AICoachPreInfoVM(frame: .zero)
//        view.isHidden = true
//        view.rowTapBlock = { [weak self] field in
//            self?.showInfoSelectPopup(for: field)
//        }
//        return view
//    }()

    private lazy var readyMessageVM: AICoachPreReadyMessageVM = {
        let view = AICoachPreReadyMessageVM(frame: .zero)
        return view
    }()

    private lazy var feedbackGlassVM: AICoachPreFeedbackGlassVM = {
        let view = AICoachPreFeedbackGlassVM(frame: .zero,
                                             shouldShowToneItemView: self.shouldEnableToneFeedbackFeature)
        view.feedbackButtonTapBlock = { [weak self] in
            self?.nextButtonTapAction()
        }
        view.askCoachButtonTapBlock = { [weak self] in
            self?.askCoachButtonTapBlock?()
        }
        view.goalTapBlock = { [weak self] in
            self?.showInfoSelectPopup(for: .goal)
        }
        view.intensityTapBlock = { [weak self] in
            self?.showInfoSelectPopup(for: .intensity)
        }
        if self.shouldEnableToneFeedbackFeature {
            view.toneTapBlock = { [weak self] in
                self?.showToneStylePopup()
            }
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

    private lazy var toneStylePopupVM: AICoachPreToneStylePopupVM = {
        let view = AICoachPreToneStylePopupVM(frame: .zero)
        view.willShowBlock = { [weak self] in
            self?.setToneStylePopupNavigationGesturesEnabled(false)
        }
        view.didHideBlock = { [weak self] in
            self?.setToneStylePopupNavigationGesturesEnabled(true)
        }
        view.confirmBlock = { [weak self] value in
            self?.updateAICoachProfile(field: .tone, value: value)
        }
        return view
    }()

    private lazy var elaExpiredAlertVm: ElaProExpiredAlertVM = {
        let vm = ElaProExpiredAlertVM(frame: .zero)
        vm.updateContentForAiCoach()
        vm.upgradeBlock = { [weak self] in
            guard let self = self else { return }
            self.elaExpiredAlertVm.dismissSelf(notifiesDismiss: false)
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            let vc = ElaProVC()
            vc.showPriceOnly = true
            vc.priceBizType = "2"
            vc.popToRootOnClose = true
            self.pushElaProVCWhenReady(vc)
        }
        vm.dismissBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateInteractivePopGestureBlocked(false)
        initUI()
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
        updateInteractivePopGestureBlocked(false)
        trimNavigationStackToRootAndSelfIfNeeded()
        sendCoachLaunchRequest()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInteractivePopGestureBlocked(false)
        guard dataDict.count > 0 else { return }
        if shouldPlayEntranceAnimation {
            startCircleEntranceAnimationIfNeeded()
        } else {
            syncVisiblePresentationStateIfNeeded()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBackgroundCircleAlignmentIfNeeded()
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
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        img.alpha = 0
        return img
    }()
    
    lazy var circleImgView: CoachAnimationV3View = {
        let orbView = CoachAnimationV3View(diameter: self.aiCoachCircleDiameter)
        orbView.backgroundColor = .clear
        return orbView
    }()

    private lazy var clearPDFReportsButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(hex: "0F1214")
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.setTitle("清PDF", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(clearPDFReportsButtonTapAction), for: .touchUpInside)
        return btn
    }()
//    private lazy var aiCoachOrbContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .clear
//        view.isOpaque = false
//        return view
//    }()
//    lazy var nextButton: UIButton = {
//        let btn = UIButton(type: .custom)
//        btn.setTitle("查看报告", for: .normal)
//        btn.setTitleColor(.white, for: .normal)
//        btn.setTitleColor(.white, for: .disabled)
//        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
//        btn.backgroundColor = .THEME
//        btn.layer.cornerRadius = kFitWidth(22)
//        btn.clipsToBounds = true
//        btn.alpha = 0
//        btn.isHidden = true
//        btn.enablePressEffect()
//        btn.addTarget(self, action: #selector(nextButtonTapAction), for: .touchUpInside)
//
//        return btn
//    }()

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
//        preDaysVM.dismissPopup()
    }
    
    @objc func tipsTapAction() {
        katchAlertVm.showView()
    }

    @objc func clearPDFReportsButtonTapAction() {
        let alertVc = UIAlertController(title: "清除本地PDF报告？",
                                        message: "会删除本机已生成的AI教练PDF缓存，下次查看报告时会重新生成。",
                                        preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "取消", style: .cancel))
        alertVc.addAction(UIAlertAction(title: "清除", style: .destructive) { [weak self] _ in
            self?.clearLocalPDFReports()
        })
        present(alertVc, animated: true)
    }

    func clearLocalPDFReports() {
        do {
            let removedCount = try AICoachReportPDFGenerator.clearAllCachedReports()
            if removedCount > 0 {
                MCToast.mc_success("已清除\(removedCount)份PDF报告")
            } else {
                MCToast.mc_text("暂无本地PDF报告")
            }
        } catch {
            MCToast.mc_failure("清除失败，请稍后重试")
        }
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

//        view.addSubview(preDaysVM)
//        view.addSubview(preInfoVM)
//        view.addSubview(nextButton)
        view.addSubview(readyMessageVM)
        view.addSubview(feedbackGlassVM)
//        view.addSubview(clearPDFReportsButton)
        view.addSubview(infoSelectPopupVM)
        if shouldEnableToneFeedbackFeature {
            view.addSubview(toneStylePopupVM)
        }
        
        view.addSubview(katchAlertVm)
        view.addSubview(elaExpiredAlertVm)
        
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
            make.left.top.right.equalToSuperview()
            bgImgViewBottomConstraint = make.bottom.equalToSuperview().constraint
        }
        // 原 circleImgView 约束保留，回退 CoachAnimationV3View 时可恢复。
        circleImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(aiCoachCircleTop)
            make.width.height.equalTo(aiCoachCircleDiameter)
//            make.top.equalTo(kFitWidth(147))
//            make.width.height.equalTo(kFitWidth(223))
        }
//        aiCoachOrbContainerView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(kFitWidth(133.5))
//            make.width.height.equalTo(kFitWidth(250))
//        }
//        preDaysVM.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(circleImgView.snp.bottom).offset(kFitWidth(50))
//            make.height.equalTo(preDaysVM.selfHeight)
//        }
//
//        preInfoVM.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(preDaysVM.snp.bottom).offset(kFitWidth(16))
//            make.height.equalTo(preInfoVM.selfHeight)
//        }
//        nextButton.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(20))
//            make.right.equalTo(kFitWidth(-20))
//            make.height.equalTo(kFitWidth(44))
//            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight()-kFitWidth(10))
//        }
        readyMessageVM.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(feedbackGlassVM.snp.top).offset(kFitWidth(-35))
            make.height.equalTo(kFitWidth(100))
//            make.height.equalTo(readyMessageVM.selfHeight)
        }

        feedbackGlassVM.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(feedbackGlassVM.selfHeight)
            make.bottom.equalTo(-WHUtils().getBottomSafeAreaHeight() - kFitWidth(15))
        }

//        clearPDFReportsButton.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(kFitWidth(-20))
//            make.bottom.equalTo(feedbackGlassVM.snp.top).offset(kFitWidth(-18))
//            make.width.equalTo(kFitWidth(66))
//            make.height.equalTo(kFitWidth(48))
//        }

        infoSelectPopupVM.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if shouldEnableToneFeedbackFeature {
            toneStylePopupVM.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        elaExpiredAlertVm.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AICoachPreVC {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        return preDaysVM.isTouchInsideDayItem(touch.view) == false
        return false
    }
}

extension AICoachPreVC{
    func sendCoachLaunchRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_ai_coach_launch, parameters: nil) { responseObject in
            let code = responseObject["code"] as? Int ?? -1
            guard code == 200 else {
                if code == 403 {
                    self.showVMWithFade(self.elaExpiredAlertVm) {
                        self.elaExpiredAlertVm.showSelf()
                    }
                }
                return
            }

            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsMsgDict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendCoachLaunchRequest:\(foodsMsgDict)")
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
    func updateBackgroundCircleAlignmentIfNeeded() {
        let bottomOffset = backgroundBottomOffsetForCircleAlignment()
        guard abs(bottomOffset - lastBgImgViewBottomOffset) > 0.5 else { return }

        lastBgImgViewBottomOffset = bottomOffset
        bgImgViewBottomConstraint?.update(offset: bottomOffset)
    }

    func backgroundBottomOffsetForCircleAlignment() -> CGFloat {
        guard shouldAlignBackgroundCircleWithOrb,
              view.bounds.width > 0,
              view.bounds.height > 0 else {
            return 0
        }

        let targetCircleCenterY = aiCoachCircleCenterY
        guard backgroundCircleCenterY(bottomOffset: 0) < targetCircleCenterY else {
            return 0
        }

        var low: CGFloat = 0
        var high: CGFloat = max(view.bounds.height, targetCircleCenterY * 2.0)
        while backgroundCircleCenterY(bottomOffset: high) < targetCircleCenterY,
              high < view.bounds.height * 4.0 {
            high *= 2.0
        }

        for _ in 0..<18 {
            let mid = (low + high) / 2.0
            if backgroundCircleCenterY(bottomOffset: mid) < targetCircleCenterY {
                low = mid
            } else {
                high = mid
            }
        }

        return high
    }

    var shouldAlignBackgroundCircleWithOrb: Bool {
        guard isIpad() == false else { return true }
        guard UIDevice.current.userInterfaceIdiom == .phone,
              needsLegacyPlusCircleAdjustment,
              view.safeAreaInsets.bottom <= 0.5 else {
            return false
        }

        let size = view.bounds.size
        let isStandardPlusViewport = abs(size.width - 414.0) <= 0.5
            && abs(size.height - 736.0) <= 0.5
        let isZoomedPlusViewport = abs(size.width - 375.0) <= 0.5
            && abs(size.height - 667.0) <= 0.5
        return isStandardPlusViewport || isZoomedPlusViewport
    }

    var needsLegacyPlusCircleAdjustment: Bool {
        switch Device.current {
        case .iPhone6Plus, .iPhone7Plus,
             .simulator(.iPhone6Plus), .simulator(.iPhone7Plus):
            return true
        default:
            return false
        }
    }

    func backgroundCircleCenterY(bottomOffset: CGFloat) -> CGFloat {
        let imageViewHeight = view.bounds.height + bottomOffset
        let scale = max(view.bounds.width / bgImagePixelSize.width,
                        imageViewHeight / bgImagePixelSize.height)
        let displayedHeight = bgImagePixelSize.height * scale
        let verticalCrop = max(0, (displayedHeight - imageViewHeight) / 2.0)
        return bgCircleCenterYPixels * scale - verticalCrop
    }

    var aiCoachCircleTop: CGFloat {
        kFitWidth(needsLegacyPlusCircleAdjustment ? 147.0 : 133.5)
    }

    var aiCoachCircleDiameter: CGFloat {
        kFitWidth(needsLegacyPlusCircleAdjustment ? 223.0 : 250.0)
    }

    var aiCoachCircleCenterY: CGFloat {
        aiCoachCircleTop + aiCoachCircleDiameter / 2.0
    }

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
        feedbackGlassVM.setFeedbackButtonEnabled(shouldEnableReportButton)

        guard animated, feedbackGlassVM.alpha > 0 else { return }
        UIView.animate(withDuration: 0.35) {
            self.feedbackGlassVM.alpha = 1
        }
    }

    func canOpenReport(for reportStatus: Int) -> Bool {
        reportStatus == 2 || reportStatus == 4
    }

    func applyNextButtonPresentation(title: String,
                                     isEnabled: Bool,
                                     backgroundColor: UIColor,
                                     animated: Bool) {
        feedbackGlassVM.setFeedbackButtonEnabled(isEnabled)
    }

    func updatePreDaysUI(dataDict: NSDictionary) {
        self.dataDict = dataDict
        let latestReportDict = dataDict["latestReport"]as? NSDictionary ?? [:]

        self.reportId = latestReportDict.stringValueForKey(key: "id")
        
        let userGoal = dataDict["userGoal"] as? Int ?? 0
        let aiCoachIntensityPreference = dataDict["aiCoachIntensityPreference"] as? Int ?? 0
        let aiCoachTone = dataDict["aiCoachTone"] as? Int ?? 0
        self.userGoal = userGoal
        self.aiCoachIntensityPreference = aiCoachIntensityPreference
        self.aiCoachTone = aiCoachTone

        DispatchQueue.main.async {
            self.feedbackGlassVM.configure(userGoal: userGoal,
                                           aiCoachIntensityPreference: aiCoachIntensityPreference,
                                           aiCoachTone: aiCoachTone)
            self.readyMessageVM.updateContent(msgDict: dataDict)
            self.applyNextButtonState(animated: self.shouldAnimateStateTransition, updatesMessage: false)
            self.syncVisiblePresentationStateIfNeeded(force: self.shouldForceVisiblePresentationAfterDataUpdate)
        }
    }

//    func dayState(for dateString: String, todayDateString: String = Date().todayDate) -> AICoachPreDaysVM.DayState {
//        let normalizedDateString = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
//        if normalizedDateString == todayDateString {
//            return .current
//        }
//
//        guard let date = preDayDate(from: normalizedDateString),
//              let todayDate = preDayDate(from: todayDateString) else {
//            return .pending
//        }
//
//        return date < todayDate ? .completed : .pending
//    }

//    func preDayDate(from dateString: String) -> Date? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.calendar = Calendar(identifier: .gregorian)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone.current
//        return formatter.date(from: dateString)
//    }

//    func weekdayShortText(from dateString: String) -> String {
//        let date = Date().changeDateStringToDate(dateString: dateString, formatter: "yyyy-MM-dd")
//        switch Calendar.current.component(.weekday, from: date) {
//        case 1: return "日"
//        case 2: return "一"
//        case 3: return "二"
//        case 4: return "三"
//        case 5: return "四"
//        case 6: return "五"
//        case 7: return "六"
//        default: return ""
//        }
//    }

    func showInfoSelectPopup(for field: AICoachPreInfoEditableField) {
        guard isUpdatingAICoachProfile == false else { return }
        let selectedValue: Int
        switch field {
        case .goal:
            selectedValue = userGoal
        case .intensity:
            selectedValue = aiCoachIntensityPreference
        case .tone:
            selectedValue = aiCoachTone
        }
        infoSelectPopupVM.update(field: field, selectedValue: selectedValue)
        showVMWithFade(infoSelectPopupVM) {
            infoSelectPopupVM.showSelf()
        }
    }

    func showToneStylePopup() {
        guard shouldEnableToneFeedbackFeature else { return }
        guard isUpdatingAICoachProfile == false else { return }
        toneStylePopupVM.update(selectedValue: aiCoachTone)
        showVMWithFade(toneStylePopupVM) {
            toneStylePopupVM.showSelf()
        }
    }

    func setToneStylePopupNavigationGesturesEnabled(_ enabled: Bool) {
        updateInteractivePopGestureBlocked(!enabled)
    }

    func updateAICoachProfile(field: AICoachPreInfoEditableField, value: Int) {
        guard shouldEnableToneFeedbackFeature || field != .tone else { return }
        let newUserGoal = field == .goal ? value : userGoal
        let newIntensityPreference = field == .intensity ? value : aiCoachIntensityPreference
        let newAICoachTone = field == .tone ? value : aiCoachTone

        guard newUserGoal != userGoal
                || newIntensityPreference != aiCoachIntensityPreference
                || newAICoachTone != aiCoachTone else {
            return
        }

        let param = buildAICoachUpsertParameters(userGoal: newUserGoal,
                                                 aiCoachIntensityPreference: newIntensityPreference,
                                                 aiCoachTone: newAICoachTone)
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
            self.aiCoachTone = newAICoachTone
            self.feedbackGlassVM.configure(userGoal: newUserGoal,
                                           aiCoachIntensityPreference: newIntensityPreference,
                                           aiCoachTone: newAICoachTone)
        } failure: { [weak self] _ in
            self?.handleProfileUpdateFailure(message: "保存失败，请稍后重试")
        }
    }

    func buildAICoachUpsertParameters(userGoal: Int,
                                      aiCoachIntensityPreference: Int,
                                      aiCoachTone: Int) -> [String: Any] {
        var param: [String: Any] = [:]
        if (1...2).contains(userGoal) {
            param["userGoal"] = userGoal
        }
        if (1...5).contains(aiCoachIntensityPreference) {
            param["aiCoachIntensityPreference"] = aiCoachIntensityPreference
        }
        if shouldEnableToneFeedbackFeature && (1...4).contains(aiCoachTone) {
            param["aiCoachTone"] = aiCoachTone
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
        bgImgView.alpha = 1
        bgImgView.transform = .identity
        // 原 circleImgView 状态保留，当前动画由 aiCoachOrbContainerView 承载。
//        circleImgView.alpha = 1
//        circleImgView.transform = .identity
//        aiCoachOrbContainerView.alpha = 1
//        aiCoachOrbContainerView.transform = .identity
//        preDaysVM.prepareEntranceAnimation()
//        preInfoVM.prepareTextEntranceAnimation()
        readyMessageVM.prepareEntranceAnimation()
        feedbackGlassVM.prepareEntranceAnimation()
        applyHiddenPopupPresentationState()
//        nextButton.isHidden = true
//        nextButton.alpha = 0
//        nextButton.transform = initialTransform
    }

    func configureInitialPresentationState() {
        if dataDict.count == 0 || shouldPlayEntranceAnimation {
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
//        preDaysVM.playDaysEntranceAnimation(duration: entranceAnimationDurationA)
//        preInfoVM.playEntranceAnimation(duration: entranceAnimationDurationA) { [weak self] in
//            self?.playMessageAndButtonEntranceAnimation()
//        }
        guard shouldPlayFirstReportReadyFeedbackButtonFade == false else {
            playFirstReportReadyFeedbackButtonFade()
            return
        }

        readyMessageVM.playEntranceAnimation(duration: entranceAnimationDurationA)
        feedbackGlassVM.playEntranceAnimation(duration: entranceAnimationDurationA)
    }

    func playParallelEntranceAnimation() {
        let durationA = entranceAnimationDurationA * 0.5
        let durationB = entranceAnimationDurationB * 0.5
        let durationC = entranceAnimationDurationC * 0.5
//        let shouldShowNextButton = self.shouldShowNextButton
//
//        if shouldShowNextButton {
//            nextButton.isHidden = false
//        }
//
//        preDaysVM.playDaysEntranceAnimation(duration: durationA)
//        preInfoVM.playEntranceAnimation(duration: durationA)
//        preDaysVM.playMessageEntranceAnimation(duration: durationB)
//        animateEntrance(view: nextButton,
//                        duration: durationC,
//                        delay: 0,
//                        shouldFadeIn: shouldShowNextButton) { [weak self] in
//            self?.updateNextButtonVisibility(animated: false)
//        }
        readyMessageVM.playEntranceAnimation(duration: durationB)
        feedbackGlassVM.playEntranceAnimation(duration: durationC)
    }

    func playMessageAndButtonEntranceAnimation() {
//        preDaysVM.playMessageEntranceAnimation(duration: entranceAnimationDurationB) { [weak self] in
//            guard let self = self else { return }
//            let shouldShowNextButton = self.shouldShowNextButton
//            if shouldShowNextButton {
//                self.nextButton.isHidden = false
//            }
//            self.animateEntrance(view: self.nextButton,
//                                 duration: self.entranceAnimationDurationC,
//                                 delay: 0,
//                                 shouldFadeIn: shouldShowNextButton) { [weak self] in
//                self?.updateNextButtonVisibility(animated: false)
//            }
//        }
        readyMessageVM.playEntranceAnimation(duration: entranceAnimationDurationB)
        feedbackGlassVM.playEntranceAnimation(duration: entranceAnimationDurationC)
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
//        let shouldShow = shouldShowNextButton
//        let targetAlpha: CGFloat = shouldShow ? 1 : 0
//        guard animated else {
//            nextButton.isHidden = !shouldShow
//            nextButton.alpha = targetAlpha
//            return
//        }
//        if shouldShow {
//            nextButton.isHidden = false
//        }
//        UIView.animate(withDuration: 0.35) {
//            self.nextButton.alpha = targetAlpha
//        } completion: { _ in
//            if shouldShow == false {
//                self.nextButton.isHidden = true
//            }
//        }
        if animated {
            feedbackGlassVM.applyFeedbackButtonVisibleState()
            fadeInVMIfNeeded(feedbackGlassVM)
        } else {
            feedbackGlassVM.applyFinalPresentationState()
        }
    }

    func syncVisiblePresentationStateIfNeeded(force: Bool = false) {
        guard force || shouldPlayEntranceAnimation == false || hasPlayedRemainingEntranceAnimation else { return }

        bgImgView.alpha = 1
        bgImgView.transform = .identity
        // 原 circleImgView 状态保留，当前动画由 aiCoachOrbContainerView 承载。
        circleImgView.alpha = 1
        circleImgView.transform = .identity
//        aiCoachOrbContainerView.alpha = 1
//        aiCoachOrbContainerView.transform = .identity
//        preDaysVM.applyFinalPresentationState()
//        preInfoVM.applyFinalPresentationState()
        applyReadyAndFeedbackPresentationState(animated: true)
        applyHiddenPopupPresentationState()
//        nextButton.transform = .identity
    }

    func applyReadyAndFeedbackPresentationState(animated: Bool) {
        guard animated else {
            readyMessageVM.applyFinalPresentationState()
            updateNextButtonVisibility(animated: false)
            return
        }

        guard shouldPlayFirstReportReadyFeedbackButtonFade == false else {
            playFirstReportReadyFeedbackButtonFade()
            return
        }

        let shouldFadeReadyMessage = readyMessageVM.alpha < 1
        let shouldFadeFeedback = feedbackGlassVM.alpha < 1
        readyMessageVM.transform = .identity
        feedbackGlassVM.transform = .identity
        feedbackGlassVM.applyFeedbackButtonVisibleState()

        if shouldFadeReadyMessage {
            fadeInVMIfNeeded(readyMessageVM)
        } else {
            readyMessageVM.applyFinalPresentationState()
        }

        if shouldFadeFeedback {
            fadeInVMIfNeeded(feedbackGlassVM)
        } else {
            updateNextButtonVisibility(animated: false)
        }
    }

    func playFirstReportReadyFeedbackButtonFade() {
        view.layoutIfNeeded()
        readyMessageVM.layer.removeAllAnimations()
        feedbackGlassVM.layer.removeAllAnimations()
        readyMessageVM.alpha = 0
        readyMessageVM.transform = .identity
        feedbackGlassVM.alpha = 0
        feedbackGlassVM.transform = .identity
        feedbackGlassVM.prepareFeedbackButtonHiddenState()

        UIView.animate(withDuration: firstReportReadyMessageFadeDuration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.readyMessageVM.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: self.firstReportFeedbackGlassFadeDuration,
                           delay: 0,
                           options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.feedbackGlassVM.alpha = 1
            } completion: { _ in
                self.feedbackGlassVM.playFeedbackButtonFadeIn(duration: self.firstReportFeedbackButtonFadeDuration)
            }
        }
    }

    func applyHiddenPopupPresentationState() {
        infoSelectPopupVM.alpha = infoSelectPopupVM.isHidden ? 0 : 1
        infoSelectPopupVM.transform = .identity
        if shouldEnableToneFeedbackFeature {
            toneStylePopupVM.alpha = toneStylePopupVM.isHidden ? 0 : 1
            toneStylePopupVM.transform = .identity
        }
        katchAlertVm.alpha = katchAlertVm.isHidden ? 0 : 1
        katchAlertVm.transform = .identity
        elaExpiredAlertVm.alpha = elaExpiredAlertVm.isHidden ? 0 : 1
        elaExpiredAlertVm.transform = .identity
    }

    func showVMWithFade(_ vm: UIView, show: () -> Void) {
        vm.layer.removeAllAnimations()
        vm.alpha = 0
        show()
        UIView.animate(withDuration: 0.28,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            vm.alpha = 1
        }
    }

    func fadeInVMIfNeeded(_ vm: UIView) {
        let shouldAnimate = vm.alpha < 1
        vm.layer.removeAllAnimations()
        vm.transform = .identity
        guard shouldAnimate else {
            vm.alpha = 1
            return
        }

        vm.alpha = 0
        UIView.animate(withDuration: 0.32,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState]) {
            vm.alpha = 1
        }
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
        hasPlayedRemainingEntranceAnimation && feedbackGlassVM.alpha > 0
    }

//    var shouldShowNextButton: Bool {
//        let completeDays = dataDict.stringValueForKey(key: "completeDays").intValue
//        return completeDays >= 7
//    }

    var shouldForceVisiblePresentationAfterDataUpdate: Bool {
        currentReportStatus == 4 && shouldPlayEntranceAnimation == false
    }

    var shouldPlayParallelHalfEntranceAnimation: Bool {
        shouldPlayFirstEntryAnimation == false && currentReportStatus == 4
    }

    var shouldPlayEntranceAnimation: Bool {
        shouldPlayFirstEntryAnimation || currentReportStatus == 1 || currentReportStatus == 2 || currentReportStatus == 4
    }

    var shouldPlayFirstReportReadyFeedbackButtonFade: Bool {
        //判断为首报    且  未读   ，控制渐现的顺序
        //2026年06月04日17:11:52  不需要特殊处理，都是一起显示
//        dataDict.doubleValueForKey(key: "reportCount") == 1 && currentReportStatus == 2
        false
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
