//
//  FoodsDetailVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation

class FoodsDetailVC : WHBaseViewVC{
    
    var isFromLogs = false
    var fid = -1
    var foodsMsgDict = NSDictionary()
    var foodsDetailDict = NSDictionary()//食物详情
    var isFromPlanCreate = false
    var canAdd = true
    var selectBlock:((NSDictionary)->())?
    
    var unitString = "克"
    var unitWeight = "1"//单位对应的重量   g
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
//        if let foodDetail = foodsMsgDict["food"]as? NSDictionary{
//            self.foodsDetailDict = foodsMsgDict["food"]as? NSDictionary ?? [:]
//            let specArrString = self.foodsDetailDict["spec"]as? String ?? ""
//            self.specAlertVm.setDataArray(specArr: self.getArrayFromJSONString(jsonString: specArrString))
//            self.topVm.updateUI(dict: self.foodsDetailDict,isDetail: true)
//        }else{
            sendFoodsDetailRequest()
//        }
    }
    lazy var foodsNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.text = "\(foodsMsgDict["fname"]as? String ?? "")"
        
        return lab
    }()
    lazy var topVm : FoodsDetailWeightVM = {
        let vm = FoodsDetailWeightVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(60), width: 0, height: 0))
        
        vm.changeBlock = {(dict,numString)in
            self.caloriDetailVm.updateUI(dict: dict)
//            if self.topVm.textField.text?.count ?? 0 > 0 && self.topVm.textField.text != "0"{
            if numString.count > 0 && numString != "0"{
                self.confirmButton.isEnabled = true
            }else{
                self.confirmButton.isEnabled = false
            }
        }
        vm.specTapBlock = {()in
            self.specAlertVm.showSelf()
        }
        return vm
    }()
    lazy var caloriDetailVm: FoodsDetailCaloriVM = {
        let vm = FoodsDetailCaloriVM.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        
        return vm
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("添加", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.isEnabled = false
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        
        if self.canAdd == false{
            btn.isHidden = true
        }
        
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var specAlertVm: FoodsDetailSpecAlertVM = {
        let vm = FoodsDetailSpecAlertVM.init(frame: .zero)
        vm.selectBlock = {(dict)in
            DLLog(message: "\(dict)")
            self.unitString = dict["specName"]as? String ?? ""
            self.unitWeight = dict["specNum"]as? String ?? ""
            self.topVm.updateUnitButton(unit: dict["specName"]as? String ?? "",unitWeightStr: self.unitWeight)
//            self.topVm.unitWeight = self.unitWeight
        }
        return vm
    }()
}

extension FoodsDetailVC{
    @objc func addAction(){
        var number = topVm.textField.text ?? ""
        if number == "" || number == "0" {
            number = topVm.defaultNumber
        }
        
        let weight = (number as NSString).floatValue * (unitWeight as NSString).floatValue
        
        let foodMsg = NSMutableDictionary.init(dictionary: self.foodsMsgDict)
//        foodMsg.setValue("\(topVm.numberLabel.text ?? "0")", forKey: "weight")
        foodMsg.setValue("\(WHUtils.convertStringToString("\(weight)") ?? "0")", forKey: "weight")
//        foodMsg.setValue("\(self.foodsMsgDict["spec"]as? String ?? "")", forKey: "spec")
        foodMsg.setValue("\(number)", forKey: "specNum")
        foodMsg.setValue(Double(number), forKey: "qty")
        foodMsg.setValue("\(topVm.unitString)", forKey: "specName")
        foodMsg.setValue("\(topVm.unitString)", forKey: "spec")
        foodMsg.setValue("\(topVm.proteinNumberString)", forKey: "proteinNumber")
        foodMsg.setValue("\(topVm.carboNumberString)", forKey: "carbohydrateNumber")
        foodMsg.setValue("\(topVm.fatsNumberString)", forKey: "fatNumber")
        foodMsg.setValue("\(topVm.caloriNumberString)", forKey: "caloriesNumber")
        foodMsg.setValue("\(topVm.proteinNumberStringPer)", forKey: "proteinNumberPer")
        foodMsg.setValue("\(topVm.carboNumberStringPer)", forKey: "carbohydrateNumberPer")
        foodMsg.setValue("\(topVm.fatsNumberStringPer)", forKey: "fatNumberPer")
        foodMsg.setValue("\(topVm.caloriNumberStringPer)", forKey: "caloriesNumberPer")
        foodMsg.setValue("1", forKey: "select")
        foodMsg.setValue(self.foodsMsgDict, forKey: "food")
        
        if self.foodsMsgDict["fid"]as? Int ?? -1 > 0 {
            foodMsg.setValue("\(self.foodsMsgDict["fid"]as? Int ?? -1)", forKey: "fid")
        }
        UserInfoModel.shared.isAddFoods = true
        UserDefaults.saveFoods(foodsDict: foodMsg)
        
        if self.isFromPlanCreate{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForPlan"), object: foodMsg)
            if let viewControllers = navigationController?.viewControllers, viewControllers.count > 2 {
                // 假设当前是第4级视图控制器，回退到第2级
//                let targetViewController = viewControllers[viewControllers.count - 2]
                let targetViewController = viewControllers[2]
                navigationController?.popToViewController(targetViewController, animated: true)
            }
        }else  if self.isFromLogs {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: foodMsg)
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            if self.selectBlock != nil{
                self.selectBlock!(foodMsg)
            }
            self.backTapAction()
        }
    }
}

extension FoodsDetailVC{
    func initUI() {
        initNavi(titleStr: "食物详情")
        self.navigationView.backgroundColor = .clear
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        view.addSubview(foodsNameLabel)
        view.addSubview(topVm)
        view.addSubview(caloriDetailVm)
        view.addSubview(confirmButton)
        
        view.addSubview(specAlertVm)
        
//        self.topVm.updateUI(dict: self.foodsMsgDict)
//        if self.isFromPlanCreate {
//            self.topVm.updateNumber()
//        }
        
        setConstrait()
    }
    func setConstrait() {
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(24))
        }
        confirmButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(kFitWidth(-12)-WHUtils().getBottomSafeAreaHeight())
        }
    }
}


extension FoodsDetailVC{
    func sendFoodsDetailRequest(){
        let param = ["fid":"\(fid)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_query_id, parameters: param as [String : AnyObject]) { responseObject in
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            
            self.foodsMsgDict = self.getDictionaryFromJSONString(jsonString: dataString ?? "")
            self.topVm.updateUI(dict: self.foodsMsgDict)
//            self.topVm.updateNumber()
            let specArrString = self.foodsMsgDict["spec"]as? String ?? ""
            let specArray = self.getArrayFromJSONString(jsonString: specArrString)
            self.specAlertVm.setDataArray(specArr: specArray)
            
//            self.topVm.updateUI(dict: self.foodsMsgDict)
//            if self.isFromPlanCreate {
//                self.topVm.updateNumber()
//            }
        }
    }
    
}
