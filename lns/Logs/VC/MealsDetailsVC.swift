//
//  MealsDetailsVC.swift
//  lns
//
//  Created by LNS2 on 2024/7/24.
//

import Foundation
import MCToast
import UMCommon

class MealsDetailsVC : WHBaseViewVC{
    
    let foodsDataArray = NSMutableArray()
    var updateFoodsIndex = -1
    var totalCalories = Double(0)
    var totalCarbohydrate = Double(0)
    var totalProtein = Double(0)
    var totalFat = Double(0)
    var sourceType = ADD_FOODS_SOURCE.logs
    
    var isEdit = true
    var selectNum = 0
    
    var mealsId = ""
    var mealsName = ""
    var remark = ""
    
    var remarkContentHeight = kFitWidth(60)
    
//    var dispathcGroup = DispatchGroup()
        
    override func viewDidAppear(_ animated: Bool) {
//        self.nameVm.textField.startCountdown()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        self.nameVm.textField.disableTimer()
        self.nameVm.textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        sendOssStsRequest()
//        NotificationCenter.default.addObserver(self, selector: #selector(changeFoods(notify: )), name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: nil)
    }
    lazy var topImgView: MealsCreatePhotoVM = {
        let vm = MealsCreatePhotoVM.init(frame: .zero)
        vm.controller = self
//        vm.cameraButton.isHidden = true
        return vm
    }()
    lazy var editVm: MealsNaviEditButton = {
        let vm = MealsNaviEditButton.init(frame: .zero)
        vm.saveButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        vm.editButton.addTarget(self, action: #selector(editBtnAction), for: .touchUpInside)
        vm.delButton.addTarget(self, action: #selector(delBtnAction), for: .touchUpInside)
        return vm
    }()
    lazy var nameVm: MealsNameVM = {
        let vm = MealsNameVM.init(frame: CGRect.init(x: 0, y: self.topImgView.frame.maxY, width: 0, height: 0))
        vm.textField.returnKeyType = .done
        return vm
    }()
    lazy var caloriesVm: MealsCaloriesDetailVM = {
        let vm = MealsCaloriesDetailVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        return vm
    }()
    lazy var headView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.topImgView.selfHeight+self.nameVm.selfHeight))
//        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.topImgView.selfHeight+self.nameVm.selfHeight+self.caloriesVm.selfHeight))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getBottomSafeAreaHeight()-kFitWidth(56)), style: .grouped)
        vi.backgroundColor = .white
        vi.separatorStyle = .none
        vi.separatorInset = .zero
        vi.bounces = false
//        vi.register(MealsCaloriesTableViewCell.classForCoder(), forCellReuseIdentifier: "MealsCaloriesTableViewCell")
        vi.register(MealsRemarkTableViewCell.classForCoder(), forCellReuseIdentifier: "MealsRemarkTableViewCell")
        vi.register(PlanCreateFoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanCreateFoodsTableViewCell")
        
        vi.delegate = self
        vi.dataSource = self
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
        }
        vi.contentInsetAdjustmentBehavior = .never
        return vi
    }()
    lazy var remarkVm : LogsRemarkVM = {
        let vm = LogsRemarkVM.init(frame: CGRect.init(x: 0, y: kFitWidth(8), width: 0, height: 0))
        vm.placeHoldLabel.text = "这里输入食谱制作教程"
        vm.tapBlock = {()in
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
            self.remarkAlertVm.showView()
        }
        return vm
    }()
    lazy var remarkAlertVm : LogsRemarkAlertVM = {
        let vm = LogsRemarkAlertVM.init(frame: .zero)
        vm.placeHoldLabel.text = "这里输入食谱制作教程"
        vm.remarkBlock = {(text)in
            self.remarkVm.updateContent(text: text)
            self.remark = text
        }
        return vm
    }()
    lazy var footView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: LogsRemarkVM().selfHeight+kFitWidth(20)))
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.addSubview(remarkVm)
        
        return vi
    }()
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.setTitle("添加食物", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(6)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(addBtnAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var eatButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        if self.sourceType == .logs{
            btn.setTitle("添加到日志", for: .normal)
        }else if self.sourceType == .plan || self.sourceType == .plan_update{
            btn.setTitle("添加到计划", for: .normal)
        }
        
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(6)
        btn.clipsToBounds = true
        btn.isHidden = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(eatAction), for: .touchUpInside)
        
        return btn
    }()
    
}

extension MealsDetailsVC{
    @objc func addBtnAction() {
        if selectNum > 0 {
            self.delFoods()
        }else{
            self.updateFoodsIndex = -1
            
            NotificationCenter.default.addObserver(self, selector: #selector(changeFoods(notify: )), name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: nil)
            let vc = FoodsListNewVC()
            vc.topTypeVM.myMealsButton.isHidden = true
            vc.sourceType = .meals_create
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @objc func eatAction(){
//        dispathcGroup = DispatchGroup()
        if self.sourceType == .logs{
            ADD_FOODS_FOR_HEALTHKIT_NATURAL = foodsDataArray.count
        }
        
        for i in 0..<foodsDataArray.count{
//            dispathcGroup.enter()
            let foodsMsgDict = foodsDataArray[i]as? NSDictionary ?? [:]
            var foodMsg = NSMutableDictionary.init(dictionary: foodsMsgDict)
            foodMsg.setValue("1", forKey: "state")
            foodMsg.setValue("1", forKey: "select")
            
            if foodsMsgDict.stringValueForKey(key: "fname") == "快速添加"{
                if self.sourceType == .logs{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoods"), object: foodMsg)
                }else if self.sourceType == .plan{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoodsForPlan"), object: foodMsg)
                }else if self.sourceType == .plan_update{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: foodMsg)
                }
                continue
            }
            
            let foodsDict = foodsMsgDict["foods"]as? NSDictionary ?? [:]

            if foodMsg.stringValueForKey(key: "qty") == "" || foodMsg.stringValueForKey(key: "qty") == "0"{
                foodMsg = NSMutableDictionary.init(dictionary: foodsDict)
                
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "protein"))".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "carbohydrate"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "fat"))".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "calories"))".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "protein"))".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "carbohydrate"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "fat"))".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                foodMsg.setValue("\(foodsDict.stringValueForKey(key: "calories"))".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                foodMsg.setValue(foodsDict, forKey: "foods")
//                foodMsg.setValue("1", forKey: "select")
//                foodMsg.setValue("1", forKey: "state")
                
                let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsDict)
                foodMsg.setValue("\(specDefault.stringValueForKey(key: "specName"))", forKey: "specName")
                foodMsg.setValue("\(specDefault.stringValueForKey(key: "specName"))", forKey: "spec")
                foodMsg.setValue("\(specDefault.stringValueForKey(key: "specNum"))".replacingOccurrences(of: ",", with: "."), forKey: "weight")
                foodMsg.setValue("\(specDefault.stringValueForKey(key: "specNum"))".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                foodMsg.setValue(specDefault.doubleValueForKey(key: "specNum"), forKey: "qty")
            }else{
                if (foodsDict["fname"]as? String ?? "").count > 0{
                    foodMsg.setValue("\(foodsDict.stringValueForKey(key: "fname"))", forKey: "fname")
                }
                
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "qty"))".replacingOccurrences(of: ",", with: "."), forKey: "weight")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "qty"))".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                foodMsg.setValue(foodsMsgDict.doubleValueForKey(key: "qty"), forKey: "qty")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "protein"))".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "carbohydrate"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "fat"))".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "calories"))".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "protein"))".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "carbohydrate"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "fat"))".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "calories"))".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                foodMsg.setValue("\(foodsMsgDict.stringValueForKey(key: "spec"))", forKey: "specName")
//                foodMsg.setValue("1", forKey: "select")
//                foodMsg.setValue("1", forKey: "state")
            }
            
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.05*Double(i), execute: {
//                self.dispathcGroup.leave()
                if self.sourceType == .logs{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: foodMsg)
                }else if self.sourceType == .plan{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForPlan"), object: foodMsg)
                }else if self.sourceType == .plan_update{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: foodMsg)
                }
            UserDefaults.saveFoods(foodsDict: foodMsg)
//            })
        }
//        dispathcGroup.notify(queue: .main) {
            if self.sourceType == .logs{
                MobClick.event("journalAddMeals")
                self.navigationController?.popToRootViewController(animated: true)
            }else if self.sourceType == .plan{
                MobClick.event("planAddMeals")
                if let viewControllers = self.navigationController?.viewControllers{
                    for vc in viewControllers{
                        if vc.isKind(of: PlanCreateVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            }else if self.sourceType == .plan_update{
                MobClick.event("planUpdateFoods")
                if let viewControllers = self.navigationController?.viewControllers{
                    for vc in viewControllers{
                        if vc.isKind(of: PlanDetailVC.self){
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            }
//        }
    }
    @objc func editBtnAction() {
        changeEditStatus(isEdit: true)
        self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getBottomSafeAreaHeight()-kFitWidth(56))
        self.tableView.reloadData()
    }
    func changeEditStatus(isEdit:Bool) {
        self.isEdit = isEdit
        self.topImgView.isUserInteractionEnabled = isEdit
        self.editVm.showSave(isSave: isEdit)
        self.addButton.isHidden = !isEdit
        self.topImgView.cameraButton.isHidden = !isEdit
        if self.sourceType == .logs || self.sourceType == .plan || self.sourceType == .main || self.sourceType == .plan_update{
            self.eatButton.isHidden = true
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }else{
            self.eatButton.isHidden = isEdit
        }
        
        self.nameVm.isUserInteractionEnabled = isEdit
        self.remarkAlertVm.textView.isEditable = isEdit
        
    }
    @objc func delBtnAction() {
        self.nameVm.textField.resignFirstResponder()
        self.presentAlertVc(confirmBtn: "删除", message: "是否删除“\(mealsName)”", title: "温馨提示", cancelBtn: "取消", handler: { action in
            self.sendDeleteRequest()
        }, viewController: self)
    }
}

extension MealsDetailsVC{
    @objc func submitAction() {
        if self.nameVm.textField.text?.count == 0 {
            MCToast.mc_text("请输入食谱/餐食名称",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if self.nameVm.textField.text?.count ?? 0 > 15 {
            MCToast.mc_text("食谱/餐食名称不能超过15个字符",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        self.nameVm.textField.resignFirstResponder()
        if self.foodsDataArray.count == 0 {
            MCToast.mc_text("请添加食物",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if self.mealsId.count > 0 {
            sendUpdateMealsRequest()
        }else{
            sendCreateMealsRequest()
        }
    }
    @objc func changeFoods(notify:Notification) {
        let foodsDict = notify.object as? NSDictionary ?? [:]
        DLLog(message: "MealsDetailsVC:\(foodsDict)")
        
        if foodsDict.stringValueForKey(key: "fname") == "快速添加"{
            if self.updateFoodsIndex == -1 {
                self.foodsDataArray.add(foodsDict)
            }else{
                if self.foodsDataArray.count > self.updateFoodsIndex{
                    self.foodsDataArray.replaceObject(at: self.updateFoodsIndex, with: foodsDict)
                }
            }
        }else{
            if self.updateFoodsIndex == -1{//如果是点击的添加食物
                addFoods(foodsMsg: foodsDict)
                
                WHUtils().sendAddFoodsForCountRequest(fids: [foodsDict.stringValueForKey(key: "fid")])
                WHUtils().sendAddHistoryFoods(foodsMsgArray: [foodsDict])
            }else{//如果是点击的食物
                if self.foodsDataArray.count > self.updateFoodsIndex{
                    let touchFoods = self.foodsDataArray[self.updateFoodsIndex]as? NSDictionary ?? [:]
                    if touchFoods.stringValueForKey(key: "fid") == foodsDict.stringValueForKey(key: "fid") &&
                        touchFoods.stringValueForKey(key: "spec") == foodsDict.stringValueForKey(key: "spec"){
                        self.foodsDataArray.replaceObject(at: self.updateFoodsIndex, with: foodsDict)
                    }else{
                        self.foodsDataArray.removeObject(at: self.updateFoodsIndex)
                        self.addFoods(foodsMsg: foodsDict)
                    }
                }
            }
        }
        self.tableView.reloadData()
        self.calculateNum()
        self.judgeSelectFoods()
    }
    func addFoods(foodsMsg:NSDictionary){
        var hasFoods = false
        for i in 0..<self.foodsDataArray.count{
            let dict = self.foodsDataArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "fid") == foodsMsg.stringValueForKey(key: "fid") &&
                dict.stringValueForKey(key: "spec") == foodsMsg.stringValueForKey(key: "spec"){
                hasFoods = true
                
                let foodsDict = NSMutableDictionary.init(dictionary: dict)
                let specNum = foodsMsg.doubleValueForKey(key: "qty")
                let dictNum = foodsDict.doubleValueForKey(key: "qty")
                let num = dictNum + specNum
                
                foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                
                let caloriesNumber = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                let calories = caloriesNumber/specNum * num
                
                let calori = calories
                let carbo = foodsDict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                let protein = foodsDict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "proteinNumber")
                let fat = foodsDict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fatNumber")
                
                foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                
                self.foodsDataArray.replaceObject(at: i, with: foodsDict)
                break
            }
        }
        if hasFoods == false{
            self.foodsDataArray.add(foodsMsg)
        }
    }

    func calculateNum() {
        totalCalories = Double(0)
        totalCarbohydrate = Double(0)
        totalProtein = Double(0)
        totalFat = Double(0)
        
        for i in 0..<foodsDataArray.count{
            let foodsDict = foodsDataArray[i]as? NSDictionary ?? [:]
            
            totalCalories = totalCalories + foodsDict.doubleValueForKey(key: "calories")
            totalCarbohydrate = totalCarbohydrate + foodsDict.doubleValueForKey(key: "carbohydrate")
            totalProtein = totalProtein + foodsDict.doubleValueForKey(key: "protein")
            totalFat = totalFat + foodsDict.doubleValueForKey(key: "fat")
        }
        
        let detailDict = ["carbohydrate":"\(self.totalCarbohydrate)",
                          "fat":"\(self.totalFat)",
                          "protein":"\(self.totalProtein)",
                          "calories":"\(self.totalCalories)"]
        caloriesVm.updateUI(dict: detailDict as NSDictionary)
//        let indexPath = IndexPath(row: 0, section: 0)
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MealsCaloriesTableViewCell") as! MealsCaloriesTableViewCell
//        cell.updateUI(dict: detailDict as NSDictionary)
    }
    func setDataSource(dict:NSDictionary) {
        self.foodsDataArray.addObjects(from: (dict["foods"]as? NSArray ?? []) as! [Any])
//        self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        self.topImgView.updateUI(dict: dict)
        self.topImgView.isUserInteractionEnabled = false
        self.editVm.showSave(isSave: false)
        self.addButton.isHidden = true
        
        self.isEdit = false
        self.remarkVm.updateContent(text: dict.stringValueForKey(key: "notes"))
        self.remarkAlertVm.updateContext(text: dict.stringValueForKey(key: "notes"))
        self.calculateNum()
        self.nameVm.textField.text = dict.stringValueForKey(key: "name")
        self.mealsId = dict.stringValueForKey(key: "id")
        self.mealsName = dict.stringValueForKey(key: "name")
        
        self.nameVm.isUserInteractionEnabled = false
        self.remarkAlertVm.textView.isEditable = false
        self.remark = dict.stringValueForKey(key: "notes")
        
        if self.sourceType == .logs || self.sourceType == .plan || self.sourceType == .plan_update{
            self.eatButton.isHidden = false
        }else{
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT)
        }
    }
    func setFoodsArray(foodsArray:NSArray) {
        self.dealDataArray(dataSourceArray: foodsArray)
    }
    func dealDataArray(dataSourceArray:NSArray) {
        for i in 0..<dataSourceArray.count{
            if let mealsFoodsArray = dataSourceArray[i]as? NSArray{//判断要复制的某一餐，是否有食物
                for j in 0..<mealsFoodsArray.count{
                    let dict = mealsFoodsArray[j]as? NSDictionary ?? [:]
                    if dict.stringValueForKey(key: "isSelect") == "1"{
                        let dictFid = dict.stringValueForKey(key: "fid")
                        var hasSameFoods = false
                        for k in 0..<foodsDataArray.count{
                            let foodsMsg = foodsDataArray[k]as? NSDictionary ?? [:]
                            
                            //有相同规格的食物
                            if dictFid != "-1" &&  dictFid == foodsMsg["fid"]as? String ?? "\(foodsMsg["fid"]as? Int ?? -2)" && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                                hasSameFoods = true
                                let foodsDict = NSMutableDictionary.init(dictionary: dict)
                                
                                let calories = dict.doubleValueForKey(key: "calories") + foodsMsg.doubleValueForKey(key: "calories")
                                let carbohydrate = dict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrate")
                                let protein = dict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "protein")
                                let fat = dict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fat")
                                let qty = dict.doubleValueForKey(key: "qty") + foodsMsg.doubleValueForKey(key: "qty")
                                
                                foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calories)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                                foodsDict.setValue("\(carbohydrate)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                                foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                                foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                                foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calories)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "caloriesNumber")
                                foodsDict.setValue("\(carbohydrate)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateNumber")
                                foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "proteinNumber")
                                foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fatNumber")
                                foodsDict.setValue("\(qty)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                                foodsDict.setValue("\(qty)".replacingOccurrences(of: ",", with: "."), forKey: "weight")
                                foodsDict.setValue("\(qty)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                                foodsDict.setValue("1", forKey: "state")
                                foodsDict.setValue("0", forKey: "isSelect")
                                
                                foodsDataArray.replaceObject(at: k, with: foodsDict)
                                
                                totalCalories = totalCalories + calories
                                totalCarbohydrate = totalCarbohydrate + carbohydrate
                                totalProtein = totalProtein + protein
                                totalFat = totalFat + fat
                            }
                        }
                        if hasSameFoods == false{
                            let foodsDict = NSMutableDictionary.init(dictionary: dict)
                            foodsDict.setValue("1", forKey: "state")
                            foodsDict.setValue("0", forKey: "isSelect")
                            foodsDataArray.add(foodsDict)
                            
                            totalCalories = totalCalories + foodsDict.doubleValueForKey(key: "calories")
                            totalCarbohydrate = totalCarbohydrate + foodsDict.doubleValueForKey(key: "carbohydrate")
                            totalProtein = totalProtein + foodsDict.doubleValueForKey(key: "protein")
                            totalFat = totalFat + foodsDict.doubleValueForKey(key: "fat")
                        }
                    }
                }
            }
        }
        
        let detailDict = ["carbohydrate":"\(self.totalCarbohydrate)",
                          "fat":"\(self.totalFat)",
                          "protein":"\(self.totalProtein)",
                          "calories":"\(self.totalCalories)"]
        caloriesVm.updateUI(dict: detailDict as NSDictionary)
    }
    
    func changeFoodsSelectStatus(foodsIndex:Int,isSelect:Bool) {
        let dict = NSMutableDictionary(dictionary: self.foodsDataArray[foodsIndex]as? NSDictionary ?? [:])
        if isSelect {
            dict.setValue("1", forKey: "isSelect")
        }else{
            dict.setValue("0", forKey: "isSelect")
        }
        self.foodsDataArray.replaceObject(at: foodsIndex, with: dict)
//        self.tableView.reloadRows(at: [IndexPath(row: foodsIndex, section: 1)], with: .bottom)
        judgeSelectFoods()
    }
    func judgeSelectFoods() {
        selectNum = 0
        for i in 0..<self.foodsDataArray.count{
            let dict = self.foodsDataArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "isSelect") == "1"{
                selectNum = selectNum + 1
            }
        }
        if selectNum > 0 {
            addButton.setTitle("移除（\(selectNum)）", for: .normal)
        }else{
            addButton.setTitle("添加食物", for: .normal)
        }
    }
    func delFoods() {
        let foodsArrTemp = NSMutableArray()
        for i in 0..<self.foodsDataArray.count{
            let dict = self.foodsDataArray[i]as? NSDictionary ?? [:]
            if dict.stringValueForKey(key: "isSelect") == "1"{
                
            }else{
                foodsArrTemp.add(dict)
            }
        }
        self.foodsDataArray.removeAllObjects()
        self.foodsDataArray.addObjects(from: foodsArrTemp as! [Any])
        self.tableView.reloadData()
        self.selectNum = 0
        addButton.setTitle("添加食物", for: .normal)
    }
}
extension MealsDetailsVC{
    func initUI() {
        view.addSubview(tableView)
        
        initNavi(titleStr: "食谱/餐食",isWhite: true)
        self.backArrowButton.setImgName(imgName: "back_arrow_white_icon")
        self.navigationView.backgroundColor = WHColorWithAlpha(colorStr: "001833", alpha: 0.04)
        self.navigationView.addSubview(editVm)
        
        headView.addSubview(self.topImgView)
        headView.addSubview(self.nameVm)
//        headView.addSubview(self.caloriesVm)
//        tableView.tableHeaderView = headView
//        tableView.tableFooterView = footView
        
        view.addSubview(addButton)
        view.addSubview(eatButton)
        view.addSubview(remarkAlertVm)
        
        setConstrait()
    }
    func setConstrait() {
        addButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(-getBottomSafeAreaHeight()-kFitWidth(8))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(40))
        }
        eatButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(-getBottomSafeAreaHeight()-kFitWidth(8))
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(40))
        }
    }
}

extension MealsDetailsVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.remark == "" && self.isEdit == false{
                return 0
            }
            return 1
        }else{
            return foodsDataArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MealsRemarkTableViewCell", for: indexPath) as? MealsRemarkTableViewCell
            cell?.heightChangeBlock = {(remark)in
                self.remark = remark
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            cell?.updateContentString(content: self.remark)
            cell?.remarkTextField.isEditable = self.isEdit
            return cell ?? MealsRemarkTableViewCell()
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell", for: indexPath) as? PlanCreateFoodsTableViewCell
            let dict = foodsDataArray[indexPath.row]as? NSDictionary ?? [:]
            cell?.updateUIForMeals(dict: dict,isEdit:self.isEdit)
            
            cell?.selectTapBlock = {(isSelec)in
                self.changeFoodsSelectStatus(foodsIndex: indexPath.row, isSelect: isSelec)
            }
            return cell ?? PlanCreateFoodsTableViewCell()
        }
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return remarkContentHeight
//        }
//        return kFitWidth(55)
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.headView
        }else{
            return self.caloriesVm
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.topImgView.selfHeight+self.nameVm.selfHeight
        }else{
            return self.caloriesVm.selfHeight
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.nameVm.textField.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 || self.isEdit == false{
            return
        }
        
        let dict = foodsDataArray[indexPath.row]as? NSDictionary ?? [:]
        
        self.updateFoodsIndex = indexPath.row
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            NotificationCenter.default.addObserver(self, selector: #selector(changeFoods(notify: )), name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: nil)
            let vc = FoodsCreateFastVC()
            vc.setNumber(dict: dict)
            vc.sourceType = .meals_create
//            vc.saveButton.isHidden = true
            if self.isEdit {
                vc.saveButton.setTitle("保存", for: .normal)
            }else{
                vc.saveButton.isHidden = true
            }
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let foodsDict = dict["foods"]as? NSDictionary ?? [:]
        
        if foodsDict.stringValueForKey(key: "fname").count > 0{
            NotificationCenter.default.addObserver(self, selector: #selector(changeFoods(notify: )), name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: nil)
            let vc = FoodsMsgDetailsVC()
            vc.sourceType = .meals_create
            vc.foodsDetailDict = foodsDict
//            vc.deleteButton.isHidden = true
            
            let qtyStr = dict.stringValueForKey(key: "qty")
            if qtyStr == "" || qtyStr.count == 0 || qtyStr == "0.0" || qtyStr == "0"{
                vc.specNum = dict.stringValueForKey(key: "weight")
                vc.specName = "g"
            }else{
                vc.specNum = dict.stringValueForKey(key: "qty")
                vc.specName = dict["spec"]as? String ?? "g"
            }
            if self.isEdit {
                vc.confirmButton.setTitle("保存", for: .normal)
            }else{
                vc.confirmButton.isHidden = true
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                vc.deleteButton.isHidden = true
            })
        }else{
//            MCToast.mc_text("该食物已删除！",respond: .respond)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            self.foodsDataArray.removeObject(at: indexPath.row)
            let indexPath = IndexPath(row: indexPath.row, section: 1)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.calculateNum()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return isEdit// true//indexPath.row > 0 ? true : false
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView{
            if scrollView.contentOffset.y > 0{
                let percent = scrollView.contentOffset.y/self.topImgView.selfHeight
                self.navigationView.backgroundColor = WHColorWithAlpha(colorStr: "001833", alpha: percent)
//                DLLog(message: "scrollViewDidScroll:\(percent)   contentOffset : \(scrollView.contentOffset.y)")
            }else{
                self.navigationView.backgroundColor = WHColorWithAlpha(colorStr: "001833", alpha: 0.04)
//                DLLog(message: "scrollViewDidScroll:000000")
            }
        }
    }
}

extension MealsDetailsVC{
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
    func sendCreateMealsRequest() {
//        MCToast.mc_loading()
        let param = ["name":"\(self.nameVm.textField.text ?? "")",
                     "image":"\(self.topImgView.imgUrlString)",
                     "carbohydrate":self.totalCarbohydrate,
                     "fat":self.totalFat,
                     "protein":self.totalProtein,
                     "calories":self.totalCalories,
                     "notes":"\(self.remark)",
                     "foods":self.foodsDataArray] as [String : Any]
        DLLog(message: "sendCreateMealsRequest:\(param)")
        WHNetworkUtil.shareManager().POST(urlString: URL_meals_add, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            
            DLLog(message: "sendCreateMealsRequest:\(dataObj)")
            self.mealsId = dataObj.stringValueForKey(key: "id")
            
            self.changeEditStatus(isEdit: false)
            self.tableView.reloadData()
//            MCToast.mc_text("“\(self.nameVm.textField.text ?? "")” 保存成功")
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mealsSaveSuccess"), object: nil)
//                self.backTapAction()
//            })
        }
    }
    func sendUpdateMealsRequest() {
//        MCToast.mc_loading()
        let param = ["name":"\(self.nameVm.textField.text ?? "")",
                     "id":"\(mealsId)",
                     "image":"\(self.topImgView.imgUrlString)",
                     "carbohydrate":self.totalCarbohydrate,
                     "fat":self.totalFat,
                     "protein":self.totalProtein,
                     "calories":self.totalCalories,
                     "notes":"\(self.remark)",
                     "foods":self.foodsDataArray] as [String : Any]
        WHNetworkUtil.shareManager().POST(urlString: URL_meals_update, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
            self.changeEditStatus(isEdit: false)
            self.tableView.reloadData()
//            MCToast.mc_text("“\(self.nameVm.textField.text ?? "")” 修改成功")
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mealsSaveSuccess"), object: nil)
//                self.backTapAction()
//            })
        }
    }
    @objc func sendDeleteRequest() {
        let param = ["id":"\(mealsId)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_meals_delete, parameters: param as [String:AnyObject]) { responseObject in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mealsSaveSuccess"), object: nil)
            self.backTapAction()
        }
    }
}
