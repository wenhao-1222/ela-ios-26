//
//  MealAdviceVC.swift
//  lns
//  下餐规划
//  Created by LNS2 on 2026/8/5.
//

import UIKit
import MCToast


class MealAdviceVC: WHBaseViewVC, UIGestureRecognizerDelegate {
    
    /// 当前所处的步骤编号。
    private var currentStep = 0
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
    /// 返回上一页或回退到上一步。
    @objc func backAction() {
        if currentStep > 0 {
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
        view.addSubview(backImg)
        view.addSubview(backTapView)
        view.addGestureRecognizer(backToMealsNumPanGesture)
        
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
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: changes)
        } else {
            changes()
        }
        updatePopGestureState()
    }

    /// 校验第二步结果并直接进入下餐规划骨架页。
    /// - Parameter selectedFoods: 当前勾选的食物。
    func handleMealPlanConfirm(selectedFoods: NSArray) {
        let restMealNum = Int(QuestinonaireMsgModel.shared.mealsPerDay) ?? 0
        let fidList = mealPlanFidList(from: selectedFoods)
        guard restMealNum > 0, fidList.count > 0 else {
            MCToast.mc_text("请先完成餐数和食物选择")
            return
        }

        let vc = MealAdviceNextSkeletonVC(selectedFoods: selectedFoods, sDate: sDate, mealIndex: mealIndex)
        navigationController?.pushViewController(vc, animated: true)
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
            updateInteractivePopGestureBlocked(false)
        } else {
            updateInteractivePopGestureBlocked(false)
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
