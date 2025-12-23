//
//  HabitVC.swift
//  lns
//
//  Created by LNS2 on 2025/12/23.
//

class HabitVC: WHBaseViewVC {
    
    var dataObj = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendDataRequest()
    }
    lazy var topTypeVm: HabitTopTypeVM = {
        let vm = HabitTopTypeVM.init(frame: .zero)
        
        return vm
    }()
    lazy var progressVm: HabitProgressVM = {
        let vm = HabitProgressVM.init(frame: CGRect.init(x: 0, y: self.topTypeVm.frame.maxY, width: 0, height: 0))
        return vm
    }()
}

extension HabitVC{
    func initUI() {
        initNavi(titleStr: "自律习惯养成")
        self.navigationView.backgroundColor = .COLOR_BG_F2
        view.backgroundColor = .COLOR_BG_F2
        view.addSubview(topTypeVm)
        view.addSubview(progressVm)
        
    }
}

extension HabitVC{
    func sendDataRequest(){
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_dashboard, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendDataRequest:\(dataDict)")
            
            self.dataObj = dataDict
            self.progressVm.updateUI(dict: self.dataObj)
        }
    }
}
