//
//  FoodsMsgDetailsVC.swift
//  lns
//
//  Created by LNS2 on 2024/5/13.
//

import Foundation
import UMCommon
import MCToast

enum ADD_FOODS_SOURCE {
    case plan
    case logs
    case main
    case meals_create
    case plan_update
    case merge//融合食物
    case other
}

class FoodsMsgDetailsVC : WHBaseViewVC{
    
    var foodsDetailDict = NSDictionary()
    var specNum = ""
    var specName   = ""
    var canAdd = true
    var isFromDetail = false
    var sourceType = ADD_FOODS_SOURCE.other
    
    var deleteBlock:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if foodsDetailDict.doubleValueForKey(key: "qty") > 0{
//            self.specNum = foodsDetailDict.stringValueForKey(key: "qty")
//            self.specName = foodsDetailDict["spec"]as? String ?? "g"
//        }
        
        initUI()
        sendFoodsDetailRequest()
    }
    lazy var deleteButton : GJVerButton = {
        let button = GJVerButton()
        button.setImage(UIImage(named: "plan_detail_delete_icon"), for: .normal)
        button.setTitle("删除", for: .normal)
        button.setTitleColor(.THEME, for: .normal)
        button.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        return button
    }()
    lazy var foodsNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
//        lab.minimumScaleFactor = 0.5
//        lab.numberOfLines = 2
//        lab.lineBreakMode = .byWordWrapping
        if self.foodsDetailDict["verified"]as? String ?? "\(self.foodsDetailDict["verified"]as? Int ?? 0)" == "1"{
            let img = UIImage(named: "question_foods_verify_icon")
            lab.attributedText = createAttributedStringWithImage(image: img!, text: "\(foodsDetailDict["fname"]as? String ?? "")")
        }else{
            lab.text = "\(foodsDetailDict["fname"]as? String ?? "")"
        }
        
        
        return lab
    }()
    lazy var foodsVerifyImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_foods_verify_icon")
        if self.foodsDetailDict["verified"]as? String ?? "\(self.foodsDetailDict["verified"]as? Int ?? 0)" == "1"{
            img.isHidden = false
        }else{
            img.isHidden = true
        }
        return img
    }()
    lazy var topVm : FoodsMsgDetailsVM = {
        let vm = FoodsMsgDetailsVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight()+kFitWidth(60), width: 0, height: 0))
        vm.specNum = self.specNum
        vm.specName = self.specName
        vm.foodsMsgDict = self.foodsDetailDict
        vm.specTapBlock = {()in
            self.specAlertVm.showSelf()
            self.topVm.textField.resignFirstResponder()
        }
        vm.changeBlock = {(dict)in
//            DLLog(message: "changeBlock:\(dict)")
//            self.caloriDetailVm.updateUI(dict: dict)
        }
        return vm
    }()
    lazy var caloriDetailVm: FoodsDetailCaloriVM = {
        let vm = FoodsDetailCaloriVM.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.calculatePercent(dict: self.foodsDetailDict)
        return vm
    }()
    lazy var confirmButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("添加", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        
        if self.canAdd == false{
            btn.isHidden = true
        }

        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var specAlertVm: FoodsDetailSpecAlertVM = {
        let vm = FoodsDetailSpecAlertVM.init(frame: .zero)
        vm.specName = self.specName
        vm.selectBlock = {(dict)in
//            DLLog(message: "\(dict)")
            self.topVm.specDict = dict
            self.topVm.updateUnitButton()
            self.topVm.updateNumber(num: self.topVm.textField.text ?? "0",isUpdateSpec: true)
        }
        return vm
    }()
}

extension FoodsMsgDetailsVC{
    @objc func addAction(){
        if topVm.calories >= 100000 {
            MCToast.mc_text("食物热量数据错误！")
            return
        }
        if topVm.carbohydrate >= 100000 {
            MCToast.mc_text("食物碳水数据错误！")
            return
        }
        if topVm.protein >= 100000 {
            MCToast.mc_text("食物蛋白质数据错误！")
            return
        }
        if topVm.fat >= 100000 {
            MCToast.mc_text("食物脂肪数据错误！")
            return
        }
        var number = topVm.textField.text ?? ""
        number = number.replacingOccurrences(of: ",", with: ".")
        
        specName = self.topVm.specName
        if (number == ""){
            if specName == "g" || specName == "克" || specName == "ml" || specName == "毫升" || specName == ""{
                number = "100"
            }else{
                number = "1"
            }
        }
        
        UserInfoModel.shared.isAddFoods = true
        number = number.replacingOccurrences(of: ",", with: ".")
        let foodMsg = NSMutableDictionary.init(dictionary: self.foodsDetailDict)
        foodMsg.setValue("\(number)", forKey: "weight")
        foodMsg.setValue("\(number)", forKey: "specNum")
        foodMsg.setValue(Double(number), forKey: "qty")
        foodMsg.setValue("\(topVm.protein)".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
        foodMsg.setValue("\(topVm.carbohydrate)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
        foodMsg.setValue("\(topVm.fat)".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
        foodMsg.setValue("\(WHUtils.convertStringToString("\(topVm.calories)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
        foodMsg.setValue("1", forKey: "select")
        foodMsg.setValue(self.foodsDetailDict, forKey: "foods")
        foodMsg.setValue("\(topVm.specName)", forKey: "specName")
        foodMsg.setValue("\(topVm.specName)", forKey: "spec")
        foodMsg.setValue("\(topVm.protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
        foodMsg.setValue("\(topVm.carbohydrate)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
        foodMsg.setValue("\(topVm.fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
        foodMsg.setValue("\(WHUtils.convertStringToString("\(topVm.calories)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
        foodMsg.setValue("1", forKey: "state")
        
        if number.doubleValue > 0 {
            UserDefaults.saveFoods(foodsDict: foodMsg)
        }
        
        switch self.sourceType {
        case .logs:
            MobClick.event("journalEditFoods")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: foodMsg)
            self.navigationController?.popToRootViewController(animated: true)
        case .plan:
            MobClick.event("planEditFoods")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForPlan"), object: foodMsg)
            if let viewControllers = navigationController?.viewControllers, viewControllers.count > 2 {
                for vc in viewControllers{
                    if vc.isKind(of: PlanCreateVC.self){
                        navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        case .plan_update:
            MobClick.event("planUpdateFoods")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: foodMsg)
            if let viewControllers = navigationController?.viewControllers{
                for vc in viewControllers{
                    if vc.isKind(of: PlanDetailVC.self){
                        navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        case .meals_create:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: foodMsg)
            if let viewControllers = navigationController?.viewControllers {
                for vc in viewControllers{
                    if vc.isKind(of: MealsDetailsVC.self){
                        navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        case .merge:
            DLLog(message: "融合食物")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForMerge"), object: foodMsg)
            if let viewControllers = self.navigationController?.viewControllers {
                for vc in viewControllers{
                    if vc.isKind(of: FoodsMergeVC.self){
                        self.navigationController?.popToViewController(vc, animated: true)
                        break
                    }
                }
            }
        case .other:
//            if self.selectBlock != nil{
//                self.selectBlock!(foodMsg)
//            }
            self.backTapAction()
        case .main:
            break
        }
    }
    func createAttributedStringWithImage(image: UIImage, text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .medium).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        let string = NSMutableAttributedString(string: text)
        string.append(attachmentString)
        
        return string
    }
    @objc func deleteAction() {
        self.presentAlertVc(confirmBtn: "删除", message: "是否删除食物“\(foodsDetailDict["fname"]as? String ?? "")”", title: "温馨提示", cancelBtn: "取消", handler: { action in
            self.sendDeleteFoodsRequest()
        }, viewController: self)
    }
}

extension FoodsMsgDetailsVC{
    func initUI(){
        initNavi(titleStr: "食物详情")
        self.navigationView.backgroundColor = .clear
        self.navigationView.addSubview(deleteButton)
        
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        view.addSubview(foodsNameLabel)
//        view.addSubview(foodsVerifyImgView)
        view.addSubview(topVm)
        view.addSubview(caloriDetailVm)
        view.addSubview(confirmButton)
        
        view.addSubview(specAlertVm)
        
        topVm.calculateSpecWeight()
        specAlertVm.setDataArray(specArr: self.topVm.specArray)
        
        if self.foodsDetailDict.stringValueForKey(key: "uid") != UserInfoModel.shared.uId{
            deleteButton.isHidden = true
        }
        
        setConstrait()
    }
    
    func setConstrait() {
        deleteButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.width.top.height.equalTo(self.naviTitleLabel)
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(24))
            make.right.equalTo(kFitWidth(-10))
//            make.centerY.lessThanOrEqualTo(getNavigationBarHeight()+kFitWidth(24)+kFitWidth(8))
        }
//        foodsVerifyImgView.snp.makeConstraints { make in
//            make.left.equalTo(foodsNameLabel.snp.right).offset(kFitWidth(2))
//            make.centerY.lessThanOrEqualTo(foodsNameLabel)
//            make.width.height.equalTo(kFitWidth(16))
//        }
        confirmButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(48))
            make.bottom.equalTo(kFitWidth(-12)-WHUtils().getBottomSafeAreaHeight())
        }
    }
}

extension FoodsMsgDetailsVC{
    func sendDeleteFoodsRequest() {
        MCToast.mc_loading()
        let param = ["fname":"\(foodsDetailDict.stringValueForKey(key: "fname"))"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_delete, parameters: param as [String:AnyObject]) { responseObject in
            UserDefaults.delFoods(foodsDict: self.foodsDetailDict, forKey: .myFoodsList)
            
            if self.deleteBlock != nil{
                self.deleteBlock!()
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    func sendFoodsDetailRequest(){
        let param = ["fid":"\(foodsDetailDict.stringValueForKey(key: "fid"))"]
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_query_id, parameters: param as [String : AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataDict = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "\(dataDict)")
            if self.foodsDetailDict.stringValueForKey(key: "uid") != UserInfoModel.shared.uId{
                self.deleteButton.isHidden = true
            }else{
                self.deleteButton.isHidden = false
            }
        }
    }
}
