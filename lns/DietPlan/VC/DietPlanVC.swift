//
//  DietPlanVC.swift
//  lns
//  食谱
//  Created by LNS2 on 2026/3/6.
//


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
}

extension DietPlanVC{
    func initUI() {
//        view.addSubview(nonePlanVm)
    }
}

extension DietPlanVC{
    func sendDietPlanMsgRequest() {
        WHNetworkUtil.shareManager().POST(urlString: URL_diet_plan_msg, parameters: nil) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendDietPlanMsgRequest:\(dataObj)")
            
            let status = dataObj.stringValueForKey(key: "status")
            if status == "1"{//无问卷
                self.view.addSubview(self.emptyVm)
            }else if status == "2"{//做过问卷，未生成计划
                self.view.addSubview(self.nonePlanVm)
            }else if status == "4"{//有问卷，且在有效期内
                
            }else{//有问卷，但是计划过期   默认此选项
                
            }
        }
    }
}
