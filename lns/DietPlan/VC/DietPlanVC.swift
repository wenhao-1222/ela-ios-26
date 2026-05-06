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
    var buylistData = NSArray()
    var buylistEndDate = ""
    private var planStartDate = ""
    private var planEndDate = ""
    private var shouldAnimatePlanListRefreshAfterCreateSuccess = false
    
    private lazy var buyListDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NOTIFI_NAME_REFRESH_DIET_PLAN_STATUS, object: nil)
        NotificationCenter.default.removeObserver(self, name: NOTIFI_NAME_REFRESH_VIP_STATUS, object: nil)
        NotificationCenter.default.removeObserver(self, name: NOTIFI_NAME_DIET_PLAN_CREATE_SUCCESS, object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.fd_interactivePopDisabled = false
        self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true

//        appDelegate.getKeyWindow().addSubview(elaExpiredAlertVm)
//        self.elaExpiredAlertVm.showSelf()
        sendProVipMsgRequest()
        sendBuyListRequest()
        sendUserCenterRequest()
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshVipStatusAfterIAPBindSuccess),
                                               name: NOTIFI_NAME_REFRESH_VIP_STATUS,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(markPlanListRefreshAfterCreateSuccess),
                                               name: NOTIFI_NAME_DIET_PLAN_CREATE_SUCCESS,
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
            vc.planStartDate = self.planStartDate
            vc.planEndDate = self.planEndDate
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
            vc.priceBizType = "3"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return vm
    }()
}

extension DietPlanVC{
    @objc func refreshDietPlanAfterSubscriptionSuccess() {
        sendDietPlanMsgRequest()
    }

    @objc func refreshVipStatusAfterIAPBindSuccess() {
        sendProVipMsgRequest()
    }

    @objc func markPlanListRefreshAfterCreateSuccess() {
        shouldAnimatePlanListRefreshAfterCreateSuccess = true
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
//        let vc = ElaProVC()
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
        if self.buylistData.count > 0 && Date().daysDifference(from: self.buylistEndDate) ?? 0 <= 0{
            self.openHistoryBuyListDetailPage()
        } else {
            self.openBuyListDateSelectionPage()
        }
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
    
    func openBuyListDateSelectionPage() {
        let availableDates = listVm.buyListDateStringsFromToday()
        guard !availableDates.isEmpty else {
            MCToast.mc_text("当前没有可用的购物清单日期")
            return
        }
        let vc = DietPlanBuyListDateVC(dateStrings: availableDates)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openHistoryBuyListDetailPage() {
        let vc = DietPlanBuyListVC()
        vc.showCreateButton = true
        vc.createDateStrings = listVm.buyListDateStringsFromToday()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func hasValidHistoryBuyList(_ dataObj: NSDictionary) -> Bool {
        let foodsArray = dataObj["shoppingList"] as? NSArray ?? []
        let endDate = dataObj.stringValueForKey(key: "endDate")
        let today = buyListDateFormatter.string(from: Date())
        return foodsArray.count > 0 && endDate.count > 0 && endDate <= today
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
        let planDateRange = dateRange(from: dataObj, mealPlanItemList: mealPlanItemList)
        planStartDate = planDateRange.startDate
        planEndDate = planDateRange.endDate
        let shouldAnimateListRefresh = shouldAnimatePlanListRefreshAfterCreateSuccess
        shouldAnimatePlanListRefreshAfterCreateSuccess = false
        
        if status == "1" {//无问卷
            if emptyVm.superview == nil {
                removeStateViews()
                view.addSubview(emptyVm)
            }
            return
        }
        
        if status == "2" {//做过问卷，未生成计划
            if VIPModel.shared.status == .invalid{//从未购买过会员，重新进问卷
                if emptyVm.superview == nil {
                    removeStateViews()
                    view.addSubview(emptyVm)
                }
            }else{//以前购买过会员
                if nonePlanVm.superview == nil {
                    removeStateViews()
                    view.addSubview(nonePlanVm)
                }
            }
            return
        }
        
        if listVm.superview == nil {
            removeStateViews()
            view.addSubview(listVm)
        }
        if status == "3"{//有问卷，计划过期   buyListButton不可点
            listVm.buyListButton.isEnabled = false
        }else{//有问卷，计划且在有效期内
            listVm.buyListButton.isEnabled = true
        }
        listVm.updatePlanList(mealPlanItemList: mealPlanItemList,
                              preservingScrollOffset: preservingListOffset,
                              animatedTransition: shouldAnimateListRefresh)
         
    }
    
    func sendDietPlanMsgRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_msg, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDietPlanMsgRequest:\(dataObj)")
            self.applyDietPlanResponse(dataObj)
        }
    }

    func dateRange(from dataObj: NSDictionary, mealPlanItemList: NSArray) -> (startDate: String, endDate: String) {
        let responseStartDate = dataObj.stringValueForKey(key: "startDate")
        let responseEndDate = dataObj.stringValueForKey(key: "endDate")
        let listRange = dateRange(from: mealPlanItemList)
        
        let startDate = responseStartDate.isEmpty ? listRange.startDate : responseStartDate
        let endDate = responseEndDate.isEmpty ? listRange.endDate : responseEndDate
        
        return (startDate, endDate)
    }
    
    func dateRange(from mealPlanItemList: NSArray) -> (startDate: String, endDate: String) {
        var dates: [String] = []
        
        for item in mealPlanItemList {
            let dict = item as? NSDictionary ?? [:]
            let sdate = dict.stringValueForKey(key: "sdate")
            if buyListDateFormatter.date(from: sdate) != nil {
                dates.append(sdate)
            }
        }
        
        let sortedDates = dates.sorted()
        return (sortedDates.first ?? "", sortedDates.last ?? "")
    }
    func sendProVipMsgRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_pro_info, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            let vipModel = VIPModel.shared.update(with: dataDict)
            DLLog(message: "sendProVipMsgRequest:\(dataDict)")
            DLLog(message: "sendProVipMsgRequest model: uid=\(vipModel.uid), status=\(vipModel.status?.rawValue ?? 0), isLifetime=\(vipModel.isLifetime)  ,expireTime=\(vipModel.expireTime)")
            
        }
    }
    func sendBuyListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_shopping_list, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendBuyListRequest:\(dataObj)")
            self.buylistData = dataObj["shoppingList"]as? NSArray ?? []
            self.buylistEndDate = dataObj.stringValueForKey(key: "endDate")
        }
    }
    func sendUserCenterRequest() {
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_Center, parameters: param as [String : AnyObject]) { responseObject in
//            DLLog(message: "sendUserCenterRequest:\(responseObject)")
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            UserInfoModel.shared.updateMsg(dict: dataObj)
        }
    }
}
