//
//  DietPlanVC.swift
//  lns
//  食谱
//  Created by LNS2 on 2026/3/6.
//

import UIKit
import MCToast

class DietPlanVC: WHBaseViewVC {
    
    public override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendDietPlanMsgRequest()
    }
    lazy var emptyVm: PlanMainEmptyVM = {
        let vm = PlanMainEmptyVM.init(frame: .zero)
        vm.startButton.addTarget(self, action: #selector(createDietPlanAction), for: .touchUpInside)
        return vm
    }()
    lazy var nonePlanVm: PlanMainNonePlanVM = {
        let vm = PlanMainNonePlanVM.init(frame: .zero)
        vm.createPlanButton.addTarget(self, action: #selector(createPlanAction), for: .touchUpInside)
        return vm
    }()
    lazy var listVm: PlanMainPlanListVM = {
        let vm = PlanMainPlanListVM.init(frame: .zero)
        vm.createPlanButton.addTarget(self, action: #selector(createPlanAction), for: .touchUpInside)
        vm.buyListButton.addTarget(self, action: #selector(openBuyListSelectionAction), for: .touchUpInside)
        vm.mealChangeTapBlock = { [weak self] mealId,id in
            self?.openMealChangeList(mealId: mealId,id: id)
        }
        return vm
    }()
}

extension DietPlanVC{
    //前往问卷
    @objc func createDietPlanAction() {
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        
        let vc = DietPlanCreateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //创建计划，选择时间
    @objc func createPlanAction() {
        let vc = DietPlanCreateDateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openBuyListSelectionAction() {
        let availableDates = listVm.buyListDateStringsFromToday()
        guard !availableDates.isEmpty else {
            MCToast.mc_text("当前没有可用的购物清单日期")
            return
        }
        let vc = DietPlanBuyListDateVC(dateStrings: availableDates)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openMealChangeList(mealId: String,id:String) {
        guard !mealId.isEmpty else {
            MCToast.mc_text("餐食信息异常")
            return
        }
        let vc = DietPlanFoodsChangeListVC()
        vc.templateMealId = mealId
        vc.id = id
        vc.replaceSuccessBlock = { [weak self] dataObj in
            self?.applyDietPlanResponse(dataObj, preservingListOffset: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension DietPlanVC{
    func initUI() {
//        view.addSubview(nonePlanVm)
    }
}

extension DietPlanVC{
    func removeStateViews() {
        emptyVm.removeFromSuperview()
        nonePlanVm.removeFromSuperview()
        listVm.removeFromSuperview()
    }
    
    func applyDietPlanResponse(_ dataObj: NSDictionary, preservingListOffset: Bool = false) {
        let mealPlanItemList = dataObj["mealPlanItemList"] as? NSArray ?? []
        let status = dataObj.stringValueForKey(key: "status")
        
        if status == "1" {//无问卷
            if emptyVm.superview == nil {
                removeStateViews()
                view.addSubview(emptyVm)
            }
            return
        }
        
        if status == "2" {//做过问卷，未生成计划
            if nonePlanVm.superview == nil {
                removeStateViews()
                view.addSubview(nonePlanVm)
            }
            return
        }
        
        if listVm.superview == nil {
            removeStateViews()
            view.addSubview(listVm)
        }
        listVm.updatePlanList(mealPlanItemList: mealPlanItemList, preservingScrollOffset: preservingListOffset)
    }
    
    func sendDietPlanMsgRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_msg, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDietPlanMsgRequest:\(dataObj)")
            self.applyDietPlanResponse(dataObj)
        }
    }
}
