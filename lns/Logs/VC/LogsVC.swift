//
//  LogsVC.swift
//  lns
//  1.jxx1561.cc
//  Created by LNS2 on 2024/3/21.
//

import Foundation
import MJRefresh
import MCToast

class LogsVC : WHBaseViewVC {
    
    var dataSourceArray = NSArray()
    var currentDayMsg = NSDictionary()
    var queryDay = Date().nextDay(days: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendPlanActiveDetailRequest()
    }
    lazy var bgView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var naviVm : LogsNaviVM = {
        let vm = LogsNaviVM.init(frame: .zero)
        vm.choiceTimeBlock = {()in
            self.dateFilterAlertVm.showView()
        }
        return vm
    }()
    lazy var goalVm: LogsNaturalGoalVM = {
        let vm = LogsNaturalGoalVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        
        return vm
    }()
    lazy var remarkVm : LogsRemarkVM = {
        let vm = LogsRemarkVM.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-getTabbarHeight()-LogsRemarkVM().selfHeight-kFitWidth(86), width: 0, height: 0))
        vm.tapBlock = {()in
            self.remarkAlertVm.showView()
        }
        return vm
    }()
    lazy var detailButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: kFitWidth(8), y: self.remarkVm.frame.maxY+kFitWidth(8), width: kFitWidth(359), height: kFitWidth(48)))
        btn.backgroundColor = .white
        btn.addShadow()
        btn.layer.cornerRadius = kFitWidth(12)
        btn.setTitle("营养详情", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setImage(UIImage(named: "logs_natural_icon"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        return btn
    }()
    lazy var dateFilterAlertVm : DataAddDateAlertVM = {
        let vm = DataAddDateAlertVM.init(frame: .zero)
        vm.isWeekDay = false
        vm.confirmBlock = {(weekDay)in
//            self.topFilterVm.setTime(time: weekDay)
            self.naviVm.setDate(time: weekDay)
        }
        return vm
    }()
    lazy var remarkAlertVm : LogsRemarkAlertVM = {
        let vm = LogsRemarkAlertVM.init(frame: .zero)
        
        return vm
    }()
}

extension LogsVC{
    func initUI(){
        view.addSubview(bgView)
        view.addSubview(naviVm)
        self.navigationView.backgroundColor = .clear
        
        view.addSubview(scrollViewBase)
        scrollViewBase.frame = CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: self.remarkVm.frame.minY - getNavigationBarHeight())
        scrollViewBase.backgroundColor = .clear//WHColor_16(colorStr: "FAFAFA")
        view.backgroundColor = .clear//WHColor_16(colorStr: "FAFAFA")
        
        scrollViewBase.addSubview(goalVm)  
        
        view.addSubview(remarkVm)
        view.addSubview(detailButton)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(dateFilterAlertVm)
        appDelegate.getKeyWindow().addSubview(remarkAlertVm)
    }
}

extension LogsVC{
    func dealData() {
        for i in 0..<self.dataSourceArray.count{
            let dict = self.dataSourceArray[i]as? NSDictionary ?? [:]
            if dict["sdate"]as? String ?? "" == self.queryDay{
                self.currentDayMsg = dict
                break
            }
        }
        
        goalVm.updateUI(dict: self.currentDayMsg)
        
        let measlArray = self.currentDayMsg["meals"]as? NSArray ?? []
        
        var originY = self.goalVm.frame.maxY + kFitWidth(8)
        
        if measlArray.count == 0 {
            let vm = LogsMealsMsgVM.init(frame: CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: kFitWidth(70)))
            scrollViewBase.addSubview(vm)
            return
        }
        
        for i in 0..<measlArray.count{
            let arrTemp = measlArray[i]as? NSArray ?? []
            let vm = LogsMealsMsgVM.init(frame: CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: kFitWidth(154)+kFitWidth(40)*CGFloat(arrTemp.count)))
            if arrTemp.count == 0 {
                vm.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: kFitWidth(70))
            }
            scrollViewBase.addSubview(vm)
            
            vm.updateUI(array: measlArray[i]as? NSArray ?? [])
            vm.titleLabel.text = "第 \(i+1) 餐"
            
            originY = originY + vm.frame.height + kFitWidth(8)
        }
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: originY)
    }
    
}

extension LogsVC{
    func sendPlanActiveDetailRequest() {
        MCToast.mc_loading()
        let param = ["uid":"\(UserInfoModel.shared.uId)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_dietplan_detail_active, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: responseObject)
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
            self.dataSourceArray = dataObj
            self.dealData()
        }
    }
}
