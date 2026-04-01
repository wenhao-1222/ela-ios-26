//
//  DietPlanVC.swift
//  lns
//  食谱
//  Created by LNS2 on 2026/3/6.
//

import UIKit
import MCToast

class DietPlanVC: WHBaseViewVC {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true

//        appDelegate.getKeyWindow().addSubview(elaExpiredAlertVm)
//        self.elaExpiredAlertVm.showSelf()
        sendProVipMsgRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendDietPlanMsgRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshDietPlanAfterSubscriptionSuccess),
                                               name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS,
                                               object: nil)
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
        vm.createPlanButton.addTarget(self, action: #selector(createSecondPlanAction), for: .touchUpInside)
        vm.buyListButton.addTarget(self, action: #selector(openBuyListSelectionAction), for: .touchUpInside)
        vm.sauceButton.addTarget(self, action: #selector(condimentAction), for: .touchUpInside)
        vm.mealChangeTapBlock = { [weak self] mealId,id in
            guard let self = self else { return }
            guard self.ensureValidVipForMealAction() else { return }
            self.openMealChangeList(mealId: mealId,id: id)
        }
        vm.mealTapBlock = { [weak self] (meal,sdate) in
            guard let self = self else { return }
            guard self.ensureValidVipForMealAction() else { return }
            let vc = DietPlanFoodsDetailVC()
            vc.mealId = meal.mealId
            vc.sdate = sdate
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var elaExpiredAlertVm: ElaProExpiredAlertVM = {
        let vm = ElaProExpiredAlertVM.init(frame: .zero)
        vm.upgradeBlock = {[weak self] in
            guard let self = self else { return }
            self.elaExpiredAlertVm.hiddenSelf()
            let vc = ElaProVC()
            vc.showPriceOnly = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
}

extension DietPlanVC{
    @objc func refreshDietPlanAfterSubscriptionSuccess() {
        sendDietPlanMsgRequest()
    }
    
    func ensureValidVipForMealAction() -> Bool {
        guard UserInfoModel.shared.vipModel.status == .valid else {
            showElaExpiredAlertIfNeeded()
            return false
        }
        return true
    }

    func showElaExpiredAlertIfNeeded() {
        if elaExpiredAlertVm.superview == nil {
            appDelegate.getKeyWindow().addSubview(elaExpiredAlertVm)
        }
        elaExpiredAlertVm.showSelf()
    }

    //前往问卷
    @objc func createDietPlanAction() {
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        
        let vc = DietPlanCreateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //第一次创建计划，只选择时间
    @objc func createPlanAction() {
        guard self.ensureValidVipForMealAction() else { return }
        let vc = DietPlanCreateDateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //非第一次创建计划，需要走问卷
    @objc func createSecondPlanAction() {
        self.navigationController?.fd_interactivePopDisabled = true
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
        let vc = DietPlanCreateSecondVC()
//        let vc = DietPlanCreateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //购物清单
    @objc func openBuyListSelectionAction() {
        let availableDates = listVm.buyListDateStringsFromToday()
        guard !availableDates.isEmpty else {
            MCToast.mc_text("当前没有可用的购物清单日期")
            return
        }
        let vc = DietPlanBuyListDateVC(dateStrings: availableDates)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //酱料
    @objc func condimentAction() {
        let vc = DietPlanCondimentVC()
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
//        if status == "3"{//有问卷，计划过期   buyListButton不可点
//            listVm.buyListButton.isEnabled = false
//        }else{//有问卷，计划且在有效期内
//            listVm.buyListButton.isEnabled = true
//        }
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
    func sendProVipMsgRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_info, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let vipModel = VIPModel().initWithDict(dict: dataDict)
            UserInfoModel.shared.vipModel = vipModel
            DLLog(message: "sendProVipMsgRequest:\(dataDict)")
            DLLog(message: "sendProVipMsgRequest model: uid=\(vipModel.uid), vipType=\(vipModel.vipType.rawValue), status=\(vipModel.status?.rawValue ?? 0), isLifetime=\(vipModel.isLifetime)  ,expireTime=\(vipModel.expireTime)")
            
        }
    }
}
