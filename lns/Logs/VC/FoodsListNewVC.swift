//
//  FoodsListNewVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import MCToast
import MJRefresh

class FoodsListNewVC: WHBaseViewVC {
    
    var isFromPlan = false
    var isFromMain = false
    var isFromMerge = false//是否为融合食物，融合食物没有AI识别
    var sourceType = ADD_FOODS_SOURCE.other
    
    var isFirstLoad = true
    var isSearch = false
    
//    var lastShowNum = ""
    
    override func viewDidAppear(_ animated: Bool) {
        UserInfoModel.shared.currentVcName = "FoodsListNewVC"
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
        if self.historyFoodsVm.foodsArray.count == 0 && isFirstLoad == true {
            DispatchQueue.main.async {
                self.naviVm.textField.becomeFirstResponder()
            }
            isFirstLoad = false
        }

        self.openInteractivePopGesture()
//        let showNum = UserDefaults.standard.value(forKey: guide_foods_list_search) as? String ?? ""
//        if Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2024-12-12",formatter: "yyyy-MM-dd"){
//            guideAlertVm.isHidden = true
            naviVm.updateUIForGuide(isGuide: false)
//        }else{
//            if showNum == ""{
//                lastShowNum = "1"
//                view.insertSubview(guideAlertVm, belowSubview: naviVm)
//                naviVm.updateUIForGuide(isGuide: true)
//                self.enableInteractivePopGesture()
//            }else if showNum == "1"{
//                if lastShowNum == "1"{
//                    view.bringSubviewToFront(guideAlertVm)
//                }else{
//                    view.insertSubview(guideAlertVm, aboveSubview: naviVm)
//                }
//                naviVm.updateUIForGuide(isGuide: false)
//                self.enableInteractivePopGesture()
//            }else{
//                guideAlertVm.isHidden = true
//                naviVm.updateUIForGuide(isGuide: false)
//            }
//        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserInfoModel.shared.currentVcName = ""
        self.allFoodsVm.tableView.reloadData()
        self.historyFoodsVm.tableView.reloadData()
        self.myFoodsVm.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(createFoodsNotifi), name: NSNotification.Name(rawValue: "createFoodsSuccess"), object: nil)
    }
    lazy var naviVm : FoodsSearchVM = {
        let vm = FoodsSearchVM.init(frame: .zero)
        vm.backArrowButton.addTarget(self, action: #selector(backTapAction), for: .touchUpInside)
        
        vm.inputBlock = {()in
//            self.guideAlertVm.isHidden = true
//            
//            self.hiddenGuideAlertVm()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//                self.guideAlertVm.naviVm.textField.text = self.naviVm.textField.text
//            })
        }
        vm.searchBlock = {()in
            self.isSearch = true
            let searchString = self.naviVm.textField.text?.replacingOccurrences(of: " ", with: "")
            DLLog(message: "文字变化：textChanged  -(searchBlock)-- \(searchString)")
            if self.topTypeVM.foodsType == "all"{
                self.isSearch = searchString?.count ?? 0 > 0 ? true : false
            }
            self.showFoodsListVm(foodsType: "\(self.topTypeVM.foodsType)",keywords:"\(searchString ?? "")")
            self.moveHistory(isTop: searchString?.count ?? 0 > 0 ? true : false)
        }
        vm.searchHistoryBlock = {()in
            self.isSearch = false
            self.moveHistory(isTop: true)
            self.showFoodsListVm(foodsType: "\(self.topTypeVM.foodsType)",keywords:"\(self.naviVm.textField.text ?? "")")
        }
        vm.searchKeyTapBlock = {()in
            self.hiddenGuideAlertVm()
            self.naviVm.updateUIForGuide(isGuide: false)
        }
        return vm
    }()
    lazy var topTypeVM : FoodsListTypeVM = {
        let vm = FoodsListTypeVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        
        vm.allFoodsTapBlock = {()in
            self.naviVm.textField.resignFirstResponder()
            
            let searchString = self.naviVm.textField.text?.replacingOccurrences(of: " ", with: "")
            self.isSearch = searchString?.count ?? 0 > 0 ? true : false
            self.showFoodsListVm(foodsType: "all",keywords:searchString ?? "")
            self.moveHistory(isTop: searchString?.count ?? 0 > 0 ? true : false)
            self.createVm.refreshButton(type: .all, isFromMain: self.isFromMain)
            
        }
        vm.myFoodsTapBlock = {()in
            self.naviVm.textField.resignFirstResponder()
            self.isSearch = true

            let searchString = self.naviVm.textField.text?.replacingOccurrences(of: " ", with: "")
            self.showFoodsListVm(foodsType: "my",keywords:searchString ?? "")
            self.moveHistory(isTop: searchString?.count ?? 0 > 0 ? true : false)
            
            if self.sourceType == .merge{
                self.createVm.refreshButtonFrameForMerge()
            }else{
                self.createVm.refreshButton(type: .my, isFromMain: self.isFromMain)
            }
//            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
//                MCToast.mc_text("这里是Toast改圆角,较长的文案，试试两行的效果ElavatineElavatineElavatineElavatine")
//            })
            
            
        }
        vm.myMealsTapBlock = {()in
            self.naviVm.textField.resignFirstResponder()
            self.isSearch = true
            let searchString = self.naviVm.textField.text?.replacingOccurrences(of: " ", with: "")
            self.showFoodsListVm(foodsType: "meals",keywords:searchString ?? "")
            self.moveHistory(isTop: searchString?.count ?? 0 > 0 ? true : false)
            self.createVm.refreshButton(type: .meal, isFromMain: self.isFromMain)
//            self.createVm.refreshButtonStatus(isMeals: true)
//            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
//                MCToast.mc_text("这里是Toast改圆角")
//            })
        }
        return vm
    }()
    lazy var createVm: FoodsListAddVM = {
        let vm = FoodsListAddVM.init(frame: CGRect.init(x: 0, y: self.topTypeVM.frame.maxY, width: 0, height: 0))
        vm.isFromMerge = self.isFromMerge
        vm.createFoodsButton.addTarget(self, action: #selector(createFoodsActino), for: .touchUpInside)
        vm.createFoodsSoonButton.addTarget(self, action: #selector(createFoodsFastAction), for: .touchUpInside)
        vm.createMealsButton.addTarget(self, action: #selector(createMealsAction), for: .touchUpInside)
        vm.aiFoodsButton.addTarget(self, action: #selector(aiPhotoAction), for: .touchUpInside)
        vm.mergeFoodsButton.addTarget(self, action: #selector(mergeFoodsAction), for: .touchUpInside)
        vm.refreshButton(type: .all, isFromMain: self.isFromMain)
        return vm
    }()
    lazy var historyFoodsVm: FoodsListAddListVM = {
        let vm = FoodsListAddListVM.init(frame: CGRect.init(x: 0, y: self.createVm.frame.maxY, width: 0, height: 0))
        vm.isFromPlan = self.isFromPlan
        vm.controller = self
        vm.sourceType = self.sourceType
        vm.scrollBlock = {()in
            self.naviVm.textField.resignFirstResponder()
        }
        vm.searchBlock = {(fname)in
            self.isSearch = true

            self.naviVm.textField.text = fname
//            self.view.resignFirstResponder()
            self.naviVm.textField.resignFirstResponder()
            self.showFoodsListVm(foodsType: "\(self.topTypeVM.foodsType)",keywords:"\(fname)")
            self.moveHistory(isTop: fname.count > 0 ? true : false)
        }
        return vm
    }()
    lazy var allFoodsVm: FoodsListAllListVM = {
        let vm = FoodsListAllListVM.init(frame: CGRect.init(x: 0, y: self.createVm.frame.maxY+kFitWidth(1), width: 0, height: 0))
        vm.isHidden = true
        vm.controller = self
        vm.isFromPlan = self.isFromPlan
        vm.sourceType = self.sourceType
        vm.scrollBlock = {()in
            self.naviVm.textField.resignFirstResponder()
        }
        vm.searchNoDataBlocK = {()in
            if self.topTypeVM.foodsType == "all"{
                self.moveHistory(isTop:false)
                if self.allFoodsVm.fname != ""{
                    self.naviVm.updateUIForGuide(isGuide: false)
//                    self.view.insertSubview(self.guideAlertVm, aboveSubview: self.naviVm)
//                    self.view.insertSubview(self.noFoodsCreateAlertVm, aboveSubview: self.naviVm)
                    self.noFoodsCreateAlertVm.show(in: self.view, above: self.naviVm)
//                    self.noFoodsCreateAlertVm.
//                    self.guideAlertVm.hiddenSelf()
//                    self.guideAlertVm.doneClick()
                }
            }
        }
        
        return vm
    }()
    lazy var myFoodsVm: FoodsListMyListVM = {
        let vm = FoodsListMyListVM.init(frame: CGRect.init(x: 0, y: self.createVm.frame.maxY+kFitWidth(1), width: 0, height: 0))
        vm.isHidden = true
        vm.controller = self
        vm.isFromPlan = self.isFromPlan
        vm.sourceType = self.sourceType
        vm.scrollBlock = {()in
            self.naviVm.textField.resignFirstResponder()
        }
        vm.deleteFoodsBlock = {(foodsDict)in
            self.historyFoodsVm.deleteFoods(foodsMsg: foodsDict)
        }
        vm.searchNoDataBlocK = {()in
            if self.topTypeVM.foodsType == "my"{
                self.moveHistory(isTop:false)
            }
        }
        
        return vm
    }()
    lazy var mealsVm: MealsListVM = {
        let vm = MealsListVM.init(frame: CGRect.init(x: 0, y: self.createVm.frame.maxY+kFitWidth(1), width: 0, height: 0))
        vm.isHidden = true
        vm.controller = self
        vm.sourceType = self.sourceType
        vm.scrollBlock = {()in
            self.naviVm.textField.resignFirstResponder()
        }
        vm.searchNoDataBlocK = {()in
            if self.topTypeVM.foodsType == "meals"{
                self.moveHistory(isTop:false)
            }
        }
        return vm
    }()
//    lazy var guideAlertVm: GuideFoodsListAlertVM = {
//        let vm = GuideFoodsListAlertVM.init(frame: .zero)
//        vm.hiddenBlock = {()in
//            self.naviVm.updateUIForGuide(isGuide: false)
//            self.naviVm.textField.resignFirstResponder()
//            self.view.becomeFirstResponder()
//            self.openInteractivePopGesture()
////            self.hiddenGuideAlertVm()
//        }
//        vm.searchTapBlock = {()in
////            self.naviVm.textField.becomeFirstResponder()
//        }
//        vm.createFoodsButton.addTarget(self, action: #selector(createFoodsActino), for: .touchUpInside)
//        return vm
//    }()
    lazy var noFoodsCreateAlertVm: GuideFoodsListNoDataAlertVM = {
        let vm = GuideFoodsListNoDataAlertVM.init(frame: .zero)
        vm.createFoodsButton.addTarget(self, action: #selector(createFoodsActino), for: .touchUpInside)
        return vm
    }()
}

extension FoodsListNewVC{
    func hiddenGuideAlertVm() {
//        self.guideAlertVm.hiddenSelf()
//        self.noFoodsCreateAlertVm.hiddenSelf()
        if self.sourceType == .logs{
            UserDefaults.standard.setValue("1", forKey: guide_foods_list_logs)
        }else if self.sourceType == .plan{
            UserDefaults.standard.setValue("1", forKey: guide_foods_list_plan)
        }else{
            UserDefaults.standard.setValue("1", forKey: guide_foods_list_main)
        }
    }
    @objc func createFoodsActino() {
        self.naviVm.updateUIForGuide(isGuide: false)
//        self.guideAlertVm.isHidden = true
        self.noFoodsCreateAlertVm.hiddenSelf()
        self.naviVm.textField.resignFirstResponder()
        let vc = FoodsCreateVC()
        vc.foodsNameVm.textField.text = self.naviVm.textField.text
        self.navigationController?.pushViewController(vc, animated: true)
        vc.addBlock = {()in
            self.naviVm.textField.text = ""
            self.view.becomeFirstResponder()
            self.topTypeVM.myFoodsTapAction()
        }
    }
    @objc func createFoodsFastAction(){
        self.naviVm.textField.resignFirstResponder()
        let vc = FoodsCreateFastVC()
        vc.isFromPlan = self.isFromPlan
        vc.sourceType = self.sourceType
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func createMealsAction(){
        self.naviVm.textField.resignFirstResponder()
        let vc = MealsDetailsVC()
        vc.nameVm.textField.text = self.naviVm.textField.text
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func createFoodsNotifi(){
        self.naviVm.textField.resignFirstResponder()
        if self.topTypeVM.foodsType == "my"{
            self.myFoodsVm.myFoodsArray = UserDefaults.getMyFoods()
            self.myFoodsVm.foodsArray = NSMutableArray(array: UserDefaults.getMyFoods())
            self.myFoodsVm.tableView.reloadData()
        }
        self.historyFoodsVm.historyFoodsArray = UserDefaults.getHistoryFoods()
        self.historyFoodsVm.foodsArray = NSMutableArray(array: self.historyFoodsVm.historyFoodsArray)
        self.historyFoodsVm.sortDataArray()
        self.historyFoodsVm.tableView.reloadData()
    }
    @objc func aiPhotoAction() {
        if ConstantModel.shared.ai_identify_image_status == false{
            MCToast.mc_text("AI识别升级维护中，请稍后重试")
            return
        }
        self.naviVm.textField.resignFirstResponder()
        let vc = CameraViewController()
        vc.sourceType = self.sourceType
        vc.controller = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func mergeFoodsAction() {
        self.naviVm.textField.resignFirstResponder()
        let vc = FoodsMergeVC()
        vc.sourceType = self.sourceType
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func moveHistory(isTop:Bool) {
        UIView.animate(withDuration: 0.3) {
            if isTop{
                self.historyFoodsVm.frame = CGRect.init(x: 0, y: self.topTypeVM.frame.maxY+kFitWidth(2), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY-kFitWidth(2))
                self.historyFoodsVm.tableView.frame = CGRect.init(x: 0, y: kFitWidth(44), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY-kFitWidth(44))
                
                self.allFoodsVm.frame = CGRect.init(x: 0, y: self.topTypeVM.frame.maxY+kFitWidth(2), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY-kFitWidth(2))
                self.allFoodsVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY)
                
                self.myFoodsVm.frame = CGRect.init(x: 0, y: self.topTypeVM.frame.maxY+kFitWidth(2), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY-kFitWidth(2))
                self.myFoodsVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY)
                
                self.mealsVm.frame = CGRect.init(x: 0, y: self.topTypeVM.frame.maxY+kFitWidth(2), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY-kFitWidth(2))
                self.mealsVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.topTypeVM.frame.maxY)
                
            }else{
                self.historyFoodsVm.frame = CGRect.init(x: 0, y: self.createVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY)
                self.historyFoodsVm.tableView.frame = CGRect.init(x: 0, y: kFitWidth(44), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY-kFitWidth(44))
                
                self.allFoodsVm.frame = CGRect.init(x: 0, y: self.createVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY)
                self.allFoodsVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY)
                
                self.myFoodsVm.frame = CGRect.init(x: 0, y: self.createVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY)
                self.myFoodsVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY)
                
                self.mealsVm.frame = CGRect.init(x: 0, y: self.createVm.frame.maxY, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY)
                self.mealsVm.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-self.createVm.frame.maxY)
            }
        }
    }
    func showFoodsListVm(foodsType:String,keywords:String) {
//        self.historyFoodsVm.isHidden = true
//        self.myFoodsVm.isHidden = true
//        self.allFoodsVm.isHidden = true
//        self.mealsVm.isHidden = true
        let currentView = [historyFoodsVm, allFoodsVm, myFoodsVm, mealsVm].first { !$0.isHidden }

        let fname = keywords.disable_emoji(text: keywords as NSString)
        
//        self.myFoodsVm.fname = fname
        if allFoodsVm.fname != fname{
            self.allFoodsVm.fNameChanged = true
            self.allFoodsVm.fname = fname
        }
        if myFoodsVm.fname != fname{
            self.myFoodsVm.fNameChanged = true
            self.myFoodsVm.fname = fname
        }
        if mealsVm.fname != fname{
            self.mealsVm.fNameChanged = true
            self.mealsVm.fname = fname
        }
        if fname.count > 0 {
            self.historyFoodsVm.fname = fname
            self.historyFoodsVm.searchHistoryFoodsList()
        }else{
            self.historyFoodsVm.searchHistory()
        }
        
        var targetView:UIView? = nil
        if isSearch{
            if foodsType == "all"{
                self.allFoodsVm.sendFoodsListRequest()
//                self.allFoodsVm.isHidden = false
                targetView = self.allFoodsVm
            }else if foodsType == "my"{
                self.myFoodsVm.sendMyFoodsRequest()
//                self.myFoodsVm.isHidden = false
                targetView = self.myFoodsVm
            }else if foodsType == "meals"{
                self.mealsVm.sendMyMealsRequest()
//                self.mealsVm.isHidden = false
                targetView = self.mealsVm
            }else{
//                self.historyFoodsVm.isHidden = false
                targetView = self.historyFoodsVm
            }
        }else{
            if foodsType == "my"{
                self.myFoodsVm.sendMyFoodsRequest()
//                self.myFoodsVm.isHidden = false
                targetView = self.myFoodsVm
            }else if foodsType == "meals"{
                self.mealsVm.sendMyMealsRequest()
//                self.mealsVm.isHidden = false
                targetView = self.mealsVm
            }else{
//                self.historyFoodsVm.isHidden = false
                targetView = self.historyFoodsVm
            }
        }
        applyFadeTransition(from: currentView, to: targetView)
    }
    
    private func applyFadeTransition(from current:UIView?, to target:UIView?) {
        if current === target {
            target?.isHidden = false
            target?.alpha = 1.0
            return
        }
        let views = [historyFoodsVm, allFoodsVm, myFoodsVm, mealsVm]
        views.forEach { view in
            if view === target {
                view.alpha = 0
                view.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    view.alpha = 1.0
                }
            } else if view === current {
                UIView.animate(withDuration: 0.25, animations: {
                    view.alpha = 0
                }) { _ in
                    view.isHidden = true
                }
            } else {
                view.isHidden = true
                view.alpha = 0
            }
        }
    }
}

extension FoodsListNewVC{
    func initUI() {
//        view.addSubview(naviVm)
        view.insertSubview(naviVm, at: 100)
        view.insertSubview(topTypeVM, belowSubview: naviVm)
        view.insertSubview(createVm, belowSubview: naviVm)
        view.insertSubview(historyFoodsVm, belowSubview: naviVm)
        view.insertSubview(allFoodsVm, belowSubview: naviVm)
        view.insertSubview(myFoodsVm, belowSubview: naviVm)
        view.insertSubview(mealsVm, belowSubview: naviVm)
        if self.sourceType == .merge{
            self.topTypeVM.myMealsButton.isHidden = true
        }
        let createBtnFrame = self.createVm.createFoodsButton.frame
        self.noFoodsCreateAlertVm.createFoodsButton.frame = CGRect.init(origin: CGPoint.init(x: createBtnFrame.origin.x, y: createBtnFrame.origin.y+self.createVm.frame.minY), size: createBtnFrame.size)
    }
}
