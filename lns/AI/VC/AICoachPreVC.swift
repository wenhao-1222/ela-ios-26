//
//  AICoachPreVC.swift
//  lns
//  AI教练报告 前置页
//  Created by LNS2 on 2026/3/25.
//

import UIKit
import SnapKit

class AICoachPreVC: WHBaseViewVC, UIGestureRecognizerDelegate {

    var reportId = ""
    var dataDict = NSDictionary()
    private var reportList: [AICoachReportListItem] = []
    private var userGoal: Int = 0
    private var aiCoachIntensityPreference: Int = 0
    private var isUpdatingAICoachProfile = false
    private var coachLaunchRefreshTimer: Timer?
    private var hasPlayedCircleEntranceAnimation = false
    private var hasPlayedRemainingEntranceAnimation = false
    private var hasFinishedCircleEntranceAnimation = false
    private var isWaitingForCoachLaunchResponse = false
    
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

        initUI()
        if dataDict.stringValueForKey(key: "has7CompleteDays").count > 0{
            self.updatePreDaysUI(dataDict: dataDict)
        }else{
            isWaitingForCoachLaunchResponse = true
            sendCoachLaunchRequest()
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
        startCircleEntranceAnimationIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCoachLaunchRefreshTimer()
    }

    override func backTapAction() {
        navigationController?.popToRootViewController(animated: true)
    }

    deinit {
        stopCoachLaunchRefreshTimer()
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
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("查看报告", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
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
        let vc = AICoachReportPDFDemoVC()
        vc.reportId = self.reportId
        vc.reportList = reportList
        self.navigationController?.pushViewController(vc, animated: true)
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
        view.addSubview(circleImgView)

        view.addSubview(preDaysVM)
        view.addSubview(preInfoVM)
        view.addSubview(nextButton)
        view.addSubview(infoSelectPopupVM)
        
        view.addSubview(katchAlertVm)
        
        setConstrait()
        prepareEntranceAnimation()
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
        circleImgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kFitWidth(133.5))
            make.width.height.equalTo(kFitWidth(250))
        }
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
            self.startRemainingEntranceAnimationIfNeeded()
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
    func startCoachLaunchRefreshTimerIfNeeded() {
        guard coachLaunchRefreshTimer == nil else { return }
        coachLaunchRefreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refreshCoachLaunchStatusIfNeeded()
        }
    }

    func stopCoachLaunchRefreshTimer() {
//        coachLaunchRefreshTimer?.invalidate()
        coachLaunchRefreshTimer?.invalidate()
        coachLaunchRefreshTimer = nil
    }

    @objc
    func refreshCoachLaunchStatusIfNeeded() {
        let latestReportDict = dataDict["latestReport"] as? NSDictionary ?? [:]
        guard latestReportDict.stringValueForKey(key: "reportStatus") == "1" else {
            stopCoachLaunchRefreshTimer()
            return
        }
        sendCoachLaunchRequest()
    }

    func trimNavigationStackToRootAndSelfIfNeeded() {
        guard let navigationController = navigationController else { return }
        guard navigationController.topViewController === self else { return }
        guard let rootViewController = navigationController.viewControllers.first else { return }
        if navigationController.viewControllers.count > 2 {
            navigationController.setViewControllers([rootViewController, self], animated: false)
        }
    }

    func updatePreDaysUI(dataDict: NSDictionary) {
        self.dataDict = dataDict
//        nextButton.isHidden = dataDict.stringValueForKey(key: "has7CompleteDays") == "0"
        let latestReportDict = dataDict["latestReport"]as? NSDictionary ?? [:]
        
        //报告生成中
        if latestReportDict.stringValueForKey(key: "reportStatus") == "1"{
//            nextButton.setTitle("数据处理中，预计时间30min", for: .normal)
            let estimatedMinutes: Int = {
                if let value = dataDict["estimatedReportGenerationMinutes"] as? Int {
                    return value
                }
                if let value = dataDict["estimatedReportGenerationMinutes"] as? NSNumber {
                    return value.intValue
                }
                let value = dataDict.stringValueForKey(key: "estimatedReportGenerationMinutes").intValue
                return value > 0 ? value : 30
            }()
            let processingTitle = "数据处理中，预计时间\(estimatedMinutes)min"
            nextButton.setTitle(processingTitle, for: .normal)
            nextButton.setTitle(processingTitle, for: .disabled)
            nextButton.isEnabled = false
            preDaysVM.messageLabel.isHidden = true
            startCoachLaunchRefreshTimerIfNeeded()
        }else{
            stopCoachLaunchRefreshTimer()
        }

        self.reportId = latestReportDict.stringValueForKey(key: "id")
        let reportStatus = latestReportDict.stringValueForKey(key: "reportStatus").intValue
        var remainingDays = max(0, dataDict.stringValueForKey(key: "remainingDays").intValue)
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
                remainingDays = 7 - dataDict.stringValueForKey(key: "completeDays").intValue
                self.preDaysVM.configure(items: items,
                                         reportAfterDays: remainingDays,
                                         isFirstReport:isFirstReport,
                                         completeDays: dataDict.stringValueForKey(key: "completeDays").intValue)
                self.preInfoVM.configure(
                    userGoal: userGoal,
                    aiCoachIntensityPreference: aiCoachIntensityPreference
                )
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

        let items = sortedProgressBar.enumerated().map { index, item -> AICoachPreDaysVM.DayItem in
            let dateString = item["date"] as? String ?? ""
            let completeStatus = item["completeStatus"] as? Int ?? (item["completeStatus"] as? String ?? "0").intValue
            let state = dayState(for: reportStatus, index: index, totalCount: sortedProgressBar.count)

            return .init(title: weekdayShortText(from: dateString), state: state, completeStatus: completeStatus)
        }

        DispatchQueue.main.async {
            self.preDaysVM.configure(items: items,
                                     reportAfterDays: remainingDays,
                                     isFirstReport:isFirstReport,
                                     completeDays: dataDict.stringValueForKey(key: "completeDays").intValue)
            self.preInfoVM.configure(
                userGoal: userGoal,
                aiCoachIntensityPreference: aiCoachIntensityPreference
            )
        }
    }

    func dayState(for reportStatus: Int, index: Int, totalCount: Int) -> AICoachPreDaysVM.DayState {
        switch reportStatus {
        case 2, 4:
            return .completed
        case 1:
            return index == max(totalCount - 1, 0) ? .current : .completed
        default:
            return index == max(totalCount - 1, 0) ? .current : .pending
        }
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
    func prepareEntranceAnimation() {
        let initialTransform = CGAffineTransform(translationX: 0, y: -kFitWidth(12))
        circleImgView.alpha = 0
        bgImgView.alpha = 0
        circleImgView.transform = initialTransform
        preDaysVM.prepareEntranceAnimation()
        preInfoVM.alpha = 0
        preInfoVM.transform = initialTransform
        infoSelectPopupVM.alpha = 0
        infoSelectPopupVM.transform = initialTransform
        nextButton.isHidden = true
        nextButton.alpha = 0
//        nextButton.transform = initialTransform
    }

    func startCircleEntranceAnimationIfNeeded() {
        guard hasPlayedCircleEntranceAnimation == false else { return }
        hasPlayedCircleEntranceAnimation = true
        view.layoutIfNeeded()

        
        animateEntrance(view: bgImgView, duration: 0.75, delay: 0) { [weak self] in
            
        }
        animateEntrance(view: circleImgView, duration: 0.75, delay: 0) { [weak self] in
            guard let self = self else { return }
            self.hasFinishedCircleEntranceAnimation = true
            self.startRemainingEntranceAnimationIfNeeded()
        }
    }

    func startRemainingEntranceAnimationIfNeeded() {
        guard hasFinishedCircleEntranceAnimation else { return }
        guard hasPlayedRemainingEntranceAnimation == false else { return }
        guard isWaitingForCoachLaunchResponse == false else { return }

        hasPlayedRemainingEntranceAnimation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.preDaysVM.playEntranceAnimation { [weak self] in
                guard let self = self else { return }
                self.animateEntrance(view: self.preInfoVM, duration: 0.75, delay: 0.35) { [weak self] in
                    guard let self = self else { return }
                    self.animateEntrance(view: self.infoSelectPopupVM, duration: 0.75, delay: 0.15) { [weak self] in
                        guard let self = self else { return }
                        let shouldShowNextButton = self.shouldShowNextButton
                        if shouldShowNextButton {
                            self.nextButton.isHidden = false
                        }
                        self.animateEntrance(view: self.nextButton,
                                             duration: 0.7,
                                             delay: 0.25,
                                             shouldFadeIn: shouldShowNextButton) { [weak self] in
                            self?.updateNextButtonVisibility(animated: false)
                        }
                    }
                }
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

    var shouldShowNextButton: Bool {
        dataDict.stringValueForKey(key: "has7CompleteDays") != "0"
    }
}
