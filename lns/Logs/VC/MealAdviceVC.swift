//
//  MealAdviceVC.swift
//  lns
//  下餐规划
//  Created by LNS2 on 2026/8/5.
//

import UIKit
import MCToast


class MealAdviceVC: WHBaseViewVC, UIGestureRecognizerDelegate {
    
    /// 下餐规划失败 toast 显示时间。
    private let mealPlanFailureToastDuration: CGFloat = 3
    /// 当前所处的步骤编号。
    private var currentStep = 0
    /// 下餐规划请求的版本号，用来忽略过期回包。
    private var mealPlanRequestVersion = 0
    /// 当前是否正在请求下餐规划接口。
    private var isRequestingMealPlan = false
    /// 下餐规划进度是否已经自然走完。
    private var isMealPlanProgressCompleted = false
    /// 已返回但还在等待进度走完的下餐规划数据。
    private var pendingMealPlanNextPlanDict: NSDictionary?
    /// 缓存下餐规划数据所属的请求版本号。
    private var pendingMealPlanNextRequestVersion = 0
    /// 当前日志页对应的日期。
    var sDate = Date().todayDate
    /// 当前日志页点击的餐序号，1 开始，0 表示未指定。
    var mealIndex = 0
    /// 第二步页面的右滑返回手势。
    private lazy var backToMealsNumPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleBackToMealsNumPan(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePopGestureState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreFullscreenInteractivePopGesture()
        backToMealsNumPanGesture.isEnabled = false
    }

    /// 左上角返回图标。
    lazy var backImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "habit_guide_back_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    /// 返回按钮的点击热区。
    lazy var backTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(backAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    
    /// 第一步的餐数选择页面。
    lazy var mealsNumVm: MealsNumVM = {
        let vm = MealsNumVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.configureDefaultSelection(sDate: sDate)
        vm.nextBlock = { [weak self] in
            self?.showSecondStep()
        }
        
        return vm
    }()
    /// 第二步的食物选择页面。
    lazy var secondVm: MealAdviceFoodsVM = {
        let vm = MealAdviceFoodsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.controller = self
        vm.confirmBlock = { [weak self] selectedFoods in
            self?.handleMealPlanConfirm(selectedFoods: selectedFoods)
        }
        
        return vm
    }()
    /// 生成中的进度页面。
    lazy var progressVm: ElaProProgressVM = {
        let vm = ElaProProgressVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vm.showsStepTexts = false
        vm.currentStageLabel.text = "正在规划本餐摄入量..."
        vm.generatingTitleLabel.isHidden = true
        vm.progressCompleteBlock = { [weak self] in
            guard let self = self else { return }
            let completedRequestVersion = self.mealPlanRequestVersion
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                guard completedRequestVersion == self.mealPlanRequestVersion else { return }
                self.isMealPlanProgressCompleted = true
                self.tryFinishMealPlanNextIfReady()
            }
        }
        return vm
    }()
    
    /// 返回上一页或回退到上一步。
    @objc func backAction() {
        if currentStep == 2 {
            cancelMealPlanRequest()
            showSecondStep()
        } else if currentStep > 0 {
            showMealsNumStep()
        } else {
            self.backTapAction()
        }
    }
    
}

extension MealAdviceVC{
    /// 初始化页面视图。
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(mealsNumVm)
        view.addSubview(secondVm)
        view.addSubview(progressVm)
        view.addSubview(backImg)
        view.addSubview(backTapView)
        view.addGestureRecognizer(backToMealsNumPanGesture)
        
        progressVm.resetProgressState()
        updatePopGestureState()
        setConstrait()
    }
    
    /// 约束返回按钮及其点击热区。
    func setConstrait() {
        backImg.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(statusBarHeight+kFitWidth(4))
            make.width.height.equalTo(kFitWidth(35))
        }
        backTapView.snp.makeConstraints { make in
//            make.left.equalToSuperview()
            make.center.lessThanOrEqualTo(backImg)
            make.width.height.equalTo(kFitWidth(48))
        }
    }

    /// 控制左上角返回按钮显隐。
    func setBackButtonVisible(_ visible: Bool) {
        backImg.isHidden = !visible
        backTapView.isHidden = !visible
    }
    
    /// 展示第一步的餐数选择页面。
    func showMealsNumStep(animated: Bool = true) {
        currentStep = 0
        setBackButtonVisible(true)
        let changes = {
            self.mealsNumVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.secondVm.frame = CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.progressVm.frame = CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: changes)
        } else {
            changes()
        }
        updatePopGestureState()
    }
    
    /// 展示第二步的食物选择页面。
    func showSecondStep(animated: Bool = true) {
        currentStep = 1
        setBackButtonVisible(true)
        let changes = {
            self.mealsNumVm.frame = CGRect.init(x: -SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.secondVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.progressVm.frame = CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: changes)
        } else {
            changes()
        }
        updatePopGestureState()
    }

    /// 展示生成中的进度页面。
    func showProgressStep() {
        currentStep = 2
        setBackButtonVisible(false)
        progressVm.resetProgressState()
        progressVm.startProgressAnimation()
        UIView.animate(withDuration: 0.25) {
            self.mealsNumVm.frame = CGRect.init(x: -SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.secondVm.frame = CGRect.init(x: -SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.progressVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
        updatePopGestureState()
    }

    /// 校验第二步结果并开始请求下餐规划接口。
    /// - Parameter selectedFoods: 当前勾选的食物。
    func handleMealPlanConfirm(selectedFoods: NSArray) {
        guard !isRequestingMealPlan else { return }

        let restMealNum = Int(QuestinonaireMsgModel.shared.mealsPerDay) ?? 0
        let fidList = mealPlanFidList(from: selectedFoods)
        guard restMealNum > 0, fidList.count > 0 else {
            MCToast.mc_text("请先完成餐数和食物选择")
            return
        }

        sendMealPlanNextRequest(restMealNum: restMealNum, fidList: fidList)
    }

    /// 请求下餐规划接口，并根据结果进入下一页。
    /// - Parameters:
    ///   - restMealNum: 剩余餐数。
    ///   - fidList: 当前勾选的食物 fid 列表。
    func sendMealPlanNextRequest(restMealNum: Int, fidList: [Int]) {
        mealPlanRequestVersion += 1
        let requestVersion = mealPlanRequestVersion
        isRequestingMealPlan = true
        isMealPlanProgressCompleted = false
        pendingMealPlanNextPlanDict = nil
        pendingMealPlanNextRequestVersion = 0
        showProgressStep()

        let param: [String: Any] = [
            "sdate": sDate,
            "restMealNum": restMealNum,
            "fidList": fidList
        ]
        DLLog(message: "sendMealPlanNextRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_next, parameters: param as [String : AnyObject]) { [weak self] responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "sendMealPlanNextRequest:\(dataString)")
            guard let self = self else { return }
            guard requestVersion == self.mealPlanRequestVersion else { return }

            let code = responseObject["code"] as? Int ?? -1
            let planDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            if code == 200 {
                self.handleMealPlanNextSuccess(planDict: planDict, requestVersion: requestVersion)
            } else {
                let responseMessage = (responseObject["message"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let message = responseMessage.isEmpty ? "生成失败，请稍后重试" : responseMessage
                self.handleMealPlanNextFailure(message: message, requestVersion: requestVersion)
            }
        } failure: { [weak self] isError in
            guard let self = self else { return }
            guard requestVersion == self.mealPlanRequestVersion else { return }
            if isError {
                self.handleMealPlanNextFailure(message: "网络异常，请稍后重试", requestVersion: requestVersion)
            }
        }
    }

    /// 进入下餐规划结果页。
    /// - Parameters:
    ///   - planDict: 接口返回的规划数据。
    ///   - requestVersion: 本次请求版本号。
    func handleMealPlanNextSuccess(planDict: NSDictionary, requestVersion: Int) {
        guard requestVersion == mealPlanRequestVersion else { return }
        pendingMealPlanNextPlanDict = planDict
        pendingMealPlanNextRequestVersion = requestVersion
        tryFinishMealPlanNextIfReady()
    }

    /// 数据和进度都完成后，进入下餐规划结果页。
    func tryFinishMealPlanNextIfReady() {
        guard isMealPlanProgressCompleted else { return }
        guard pendingMealPlanNextRequestVersion == mealPlanRequestVersion,
              let planDict = pendingMealPlanNextPlanDict else {
            return
        }
        isRequestingMealPlan = false
        progressVm.pauseProgressAnimation()
        showSecondStep(animated: false)
        progressVm.resetProgressState()
        isMealPlanProgressCompleted = false
        pendingMealPlanNextPlanDict = nil
        pendingMealPlanNextRequestVersion = 0

        let vc = MealAdviceNextVC(planDict: planDict, sDate: sDate, mealIndex: mealIndex)
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 处理下餐规划接口失败。
    /// - Parameters:
    ///   - message: 后台返回的错误信息。
    ///   - requestVersion: 本次请求版本号。
    func handleMealPlanNextFailure(message: String, requestVersion: Int) {
        guard requestVersion == mealPlanRequestVersion else { return }
        isRequestingMealPlan = false
        pendingMealPlanNextPlanDict = nil
        pendingMealPlanNextRequestVersion = 0
        progressVm.pauseProgressAnimation()
        MCToast.mc_text(message, duration: mealPlanFailureToastDuration)
        showSecondStep()
        progressVm.resetProgressState()
    }

    /// 取消当前请求并重置进度页状态。
    func cancelMealPlanRequest() {
        mealPlanRequestVersion += 1
        isRequestingMealPlan = false
        isMealPlanProgressCompleted = false
        pendingMealPlanNextPlanDict = nil
        pendingMealPlanNextRequestVersion = 0
        progressVm.pauseProgressAnimation()
        progressVm.resetProgressState()
    }

    /// 从选中的食物里提取 fid 列表。
    /// - Parameter selectedFoods: 当前选中的食物数组。
    func mealPlanFidList(from selectedFoods: NSArray) -> [Int] {
        var fidList: [Int] = []
        for case let rawDict as NSDictionary in selectedFoods {
            let foodsDict = rawDict["foods"] as? NSDictionary ?? rawDict
            let fidString = foodsDict["fid"] as? String ?? "\(foodsDict["fid"] as? Int ?? -1)"
            if let fid = Int(fidString), fid > 0 {
                fidList.append(fid)
            }
        }
        return fidList
    }

    /// 根据当前步骤切换系统返回和页内右滑返回的可用性。
    private func updatePopGestureState() {
        guard isViewLoaded else { return }

        let shouldAllowSystemPop = currentStep == 0
        let shouldAllowBackSwipe = currentStep == 1

        if shouldAllowSystemPop {
            canEdgeBack = true
            fd_forceDisableInteractivePopGesture = false
            fd_interactivePopDisabled = false
            navigationController?.fd_interactivePopDisabled = false
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            canEdgeBack = false
            fd_forceDisableInteractivePopGesture = true
            fd_interactivePopDisabled = true
            navigationController?.fd_interactivePopDisabled = true
            navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }

        backToMealsNumPanGesture.isEnabled = shouldAllowBackSwipe
    }

    /// 第二步右滑返回到餐数选择页。
    @objc private func handleBackToMealsNumPan(_ gesture: UIPanGestureRecognizer) {
        guard currentStep == 1 else { return }
        guard let gestureView = gesture.view else { return }

        let translation = gesture.translation(in: gestureView)
        let velocity = gesture.velocity(in: gestureView)
        let isHorizontal = abs(translation.x) > abs(translation.y) || abs(velocity.x) > abs(velocity.y)
        guard isHorizontal else { return }

        let isBackSwipe: Bool
        if UIView.userInterfaceLayoutDirection(for: gestureView.semanticContentAttribute) == .rightToLeft {
            isBackSwipe = velocity.x < 0 || translation.x < 0
        } else {
            isBackSwipe = velocity.x > 0 || translation.x > 0
        }
        guard isBackSwipe else { return }

        let progress = min(max(translation.x, 0), SCREEN_WIDHT)

        switch gesture.state {
        case .began, .changed:
            mealsNumVm.frame = CGRect.init(x: -SCREEN_WIDHT + progress, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            secondVm.frame = CGRect.init(x: progress, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            progressVm.frame = CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        case .ended:
            if progress > SCREEN_WIDHT * 0.3 || velocity.x > kFitWidth(500) {
                showMealsNumStep()
            } else {
                showSecondStep()
            }
        case .cancelled, .failed:
            showSecondStep()
        default:
            break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === backToMealsNumPanGesture,
              currentStep == 1,
              let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
              let gestureView = panGesture.view else {
            return false
        }

        let translation = panGesture.translation(in: gestureView)
        let velocity = panGesture.velocity(in: gestureView)
        let isHorizontal = abs(translation.x) > abs(translation.y) || abs(velocity.x) > abs(velocity.y)
        guard isHorizontal else { return false }

        if UIView.userInterfaceLayoutDirection(for: gestureView.semanticContentAttribute) == .rightToLeft {
            return velocity.x < 0 || translation.x < 0
        }
        return velocity.x > 0 || translation.x > 0
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
