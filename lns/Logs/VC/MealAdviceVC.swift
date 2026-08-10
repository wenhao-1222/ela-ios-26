//
//  MealAdviceVC.swift
//  lns
//  下餐规划
//  Created by LNS2 on 2026/8/5.
//

import UIKit
import MCToast


class MealAdviceVC: WHBaseViewVC {
    
    private var currentStep = 0
    private var mealPlanRequestVersion = 0
    private var isRequestingMealPlan = false
    var sDate = Date().todayDate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInteractivePopGestureBlocked(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreFullscreenInteractivePopGesture()
    }

    lazy var backImg: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "habit_guide_back_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var backTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(backAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    
    lazy var mealsNumVm: MealsNumVM = {
        let vm = MealsNumVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.nextBlock = { [weak self] in
            self?.showSecondStep()
        }
        
        return vm
    }()
    lazy var secondVm: MealAdviceFoodsVM = {
        let vm = MealAdviceFoodsVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: 0, height: 0))
        vm.controller = self
        vm.confirmBlock = { [weak self] selectedFoods in
            self?.handleMealPlanConfirm(selectedFoods: selectedFoods)
        }
        
        return vm
    }()
    lazy var progressVm: ElaProProgressVM = {
        let vm = ElaProProgressVM.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        return vm
    }()
    
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
    func initUI() {
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(mealsNumVm)
        view.addSubview(secondVm)
        view.addSubview(progressVm)
        view.addSubview(backImg)
        view.addSubview(backTapView)
        
        progressVm.resetProgressState()
        setConstrait()
    }
    
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
    
    func showMealsNumStep(animated: Bool = true) {
        currentStep = 0
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
    }
    
    func showSecondStep(animated: Bool = true) {
        currentStep = 1
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
    }

    func showProgressStep() {
        currentStep = 2
        progressVm.resetProgressState()
        progressVm.startProgressAnimation()
        UIView.animate(withDuration: 0.25) {
            self.mealsNumVm.frame = CGRect.init(x: -SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.secondVm.frame = CGRect.init(x: -SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
            self.progressVm.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
    }

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

    func sendMealPlanNextRequest(restMealNum: Int, fidList: [Int]) {
        mealPlanRequestVersion += 1
        let requestVersion = mealPlanRequestVersion
        isRequestingMealPlan = true
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
            if code == 200 {
                self.handleMealPlanNextSuccess(requestVersion: requestVersion)
            } else {
                let message = responseObject["message"] as? String ?? "生成失败，请稍后重试"
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

    func handleMealPlanNextSuccess(requestVersion: Int) {
        guard requestVersion == mealPlanRequestVersion else { return }
        isRequestingMealPlan = false
        progressVm.pauseProgressAnimation()
        showSecondStep(animated: false)
        progressVm.resetProgressState()

        let vc = MealAdviceNextVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    func handleMealPlanNextFailure(message: String, requestVersion: Int) {
        guard requestVersion == mealPlanRequestVersion else { return }
        isRequestingMealPlan = false
        progressVm.pauseProgressAnimation()
        MCToast.mc_text(message)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            guard requestVersion == self.mealPlanRequestVersion else { return }
            self.showSecondStep()
            self.progressVm.resetProgressState()
        }
    }

    func cancelMealPlanRequest() {
        mealPlanRequestVersion += 1
        isRequestingMealPlan = false
        progressVm.pauseProgressAnimation()
        progressVm.resetProgressState()
    }

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
}
