//
//  DietPlanFoodsDetailVC.swift
//  lns
//
//  Created by LNS2 on 2026/3/13.
//

class DietPlanFoodsDetailVC: WHBaseViewVC {
    
    var sdate = ""
    var mealId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendFoodsDetaiLRequest()
    }
    
}

extension DietPlanFoodsDetailVC{
    func initUI() {
        initNavi(titleStr: "")
    }
}

extension DietPlanFoodsDetailVC{
    func sendFoodsDetaiLRequest() {
        let param = ["mealId":mealId]
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_foods_detail, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"] as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendFoodsDetaiLRequest:\(dataObj)")
        }
    }
}
