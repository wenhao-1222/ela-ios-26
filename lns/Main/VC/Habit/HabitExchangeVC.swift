//
//  HabitExchangeVC.swift
//  lns
//
//  Created by LNS2 on 2025/12/25.
//


class HabitExchangeVC: WHBaseViewVC {
    
    var msgDict = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    lazy var elaIconImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "ela_clear_icon")
        
        return img
    }()
    lazy var topMsgVm: HabitExchangeMsgVM = {
        let vm = HabitExchangeMsgVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(61), width: 0, height: 0))
        vm.updateUI(dict: self.msgDict)
        vm.exchangeButton.addTarget(self, action: #selector(exchangeTapAction), for: .touchUpInside)
        
        return vm
    }()
    
    lazy var exchangeAlertVm: HabitExchangeAlertVM = {
        let vm = HabitExchangeAlertVM.init(frame: .zero)
        vm.updateUI(dict: self.msgDict)
        vm.exchangeBlock = {()in
            self.sendHabitDonateRequest()
        }
        return vm
    }()
}

extension HabitExchangeVC{
    @objc func exchangeTapAction() {
        self.exchangeAlertVm.showSelf()
    }
}

extension HabitExchangeVC{
    func initUI() {
        initNavi(titleStr: "兑换")
        navigationView.backgroundColor = .COLOR_BG_F2
        view.backgroundColor = .COLOR_BG_F2
        
        view.addSubview(elaIconImgView)
        view.addSubview(topMsgVm)
        
        view.addSubview(exchangeAlertVm)
        
        setConstrait()
    }
    func setConstrait() {
        elaIconImgView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(278))
            make.height.equalTo(kFitWidth(50))
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(20))
        }
    }
}


extension HabitExchangeVC{
    func sendHabitDonateRequest() {
        let param = ["qty":"\(self.exchangeAlertVm.num)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_user_habit_donate, parameters: param as [String:AnyObject],isNeedToast: true,vc:self) { responseObject in
            DLLog(message: responseObject)
        }
    }
}
