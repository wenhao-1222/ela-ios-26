//
//  DietPlanCondimentVC.swift
//  lns
//   酱料
//  Created by LNS2 on 2026/3/16.
//


class DietPlanCondimentVC: WHBaseViewVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendSauceListRequest()
    }
    
}

extension DietPlanCondimentVC{
    func initUI() {
        initNavi(titleStr: "酱料")
        view.backgroundColor = .COLOR_BG_F2
        
    }
}

extension DietPlanCondimentVC{
    func sendSauceListRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_condiment, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArray = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendSauceListRequest:\(dataArray)")
            
        }
    }
}
