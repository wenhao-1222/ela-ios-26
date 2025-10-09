//
//  CreateMealsVC.swift
//  lns
//
//  Created by LNS2 on 2024/7/19.
//

import Foundation


class CreateMealsVC: WHBaseViewVC {
    
    var titleString = ""
    var dataSourceArray = NSArray()
    var foodsDataArray = NSMutableArray()
    
    var updateFoodsIndex = 0
    
    var totalCalories = Double(0)
    var totalCarbohydrate = Double(0)
    var totalProtein = Double(0)
    var totalFat = Double(0)
    
    override func viewDidDisappear(_ animated: Bool) {
        self.nameVm.disableTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.nameVm.startCountdown()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dealDataArray()
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(changeFoods(notify: )), name: NSNotification.Name(rawValue: "foodsAddForMeals"), object: nil)
    }
    
    lazy var nameVm : PlanCreateNameVM = {
        let vm = PlanCreateNameVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.titleLabel.text = "餐食名称"
        vm.textField.placeholder = "餐食名称15字以内"
//        vm.startCountdown()
        return vm
    }()
    lazy var caloriDetailVm: FoodsDetailCaloriVM = {
        let vm = FoodsDetailCaloriVM.init(frame: CGRect.init(x: 0, y: self.nameVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
//        vm.calculatePercent(dict: self.foodsDetailDict)
        return vm
    }()
    lazy var headView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: PlanCreateNameVM().selfHeight+self.caloriDetailVm.selfHeight+kFitWidth(26)-kFitWidth(54)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        
        return vi
    }()
    
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-kFitWidth(72)-getBottomSafeAreaHeight()-getNavigationBarHeight()), style: .plain)
        vi.backgroundColor = .white
        vi.separatorStyle = .none
        vi.separatorInset = .zero
        vi.bounces = false
        vi.register(PlanCreateFoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanCreateFoodsTableViewCell")
        
        vi.delegate = self
        vi.dataSource = self
        
        return vi
    }()
    lazy var remarkVm : LogsRemarkVM = {
        let vm = LogsRemarkVM.init(frame: CGRect.init(x: 0, y: kFitWidth(8), width: 0, height: 0))
        vm.tapBlock = {()in
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
            self.remarkAlertVm.showView()
        }
        return vm
    }()
    lazy var remarkAlertVm : LogsRemarkAlertVM = {
        let vm = LogsRemarkAlertVM.init(frame: .zero)
        vm.remarkBlock = {(text)in
            self.remarkVm.updateContent(text: text)
            
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
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("保存餐食", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
//        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        
        return btn
    }()
}

extension CreateMealsVC{
    func initUI() {
        initNavi(titleStr: "保存餐食·\(WHUtils.convertStringToStringNoDigit("\(self.totalCalories.rounded())") ?? "0")千卡")
        
        view.addSubview(tableView)
        headView.addSubview(nameVm)
        headView.addSubview(caloriDetailVm)
        view.addSubview(saveButton)
        
        tableView.tableHeaderView = headView
        tableView.tableFooterView = footView
        
        
        view.addSubview(remarkAlertVm)
        setConstrait()
    }
    func setConstrait() {
        saveButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalTo(kFitWidth(-12)-getBottomSafeAreaHeight())
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(48))
        }
    }
}

extension CreateMealsVC{
    @objc func submitAction() {
        sendCreateMealsRequest()
    }
}

extension CreateMealsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodsDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell") as? PlanCreateFoodsTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCreateFoodsTableViewCell", for: indexPath) as? PlanCreateFoodsTableViewCell
        let dict = foodsDataArray[indexPath.row]as? NSDictionary ?? [:]
        cell?.updateUIForLogs(dict: dict,isEdit:false)
        
//        cell.selectTapBlock = {(isSelec)in
//            if self.selectCellBlock != nil{
//                self.selectCellBlock!(isSelec,indexPath.row)
//            }
//        }
//        cell.delTapBlock = {()in
//            self.deleteIndex = indexPath
//            self.tableView.setEditing(true, animated: true)
//        }
//        cell.eatTapBlock = {()in
//            if self.eatTapBlock != nil{
//                self.eatTapBlock!(indexPath.row)
//            }
//        }
        
        return cell ?? PlanCreateFoodsTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(55)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.nameVm.textField.resignFirstResponder()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = foodsDataArray[indexPath.row]as? NSDictionary ?? [:]
        
        self.updateFoodsIndex = indexPath.row
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            let vc = FoodsCreateFastVC()
            vc.setNumber(dict: dict)
            vc.saveButton.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let foodsDict = dict["foods"]as? NSDictionary ?? [:]
        
        if foodsDict.stringValueForKey(key: "fname").count > 0{
            let vc = FoodsMsgDetailsVC()
            vc.sourceType = .meals_create
            vc.foodsDetailDict = foodsDict
            
            DLLog(message: "\(dict)")
            let qtyStr = dict.stringValueForKey(key: "qty")
            DLLog(message: "\(qtyStr)")
            if qtyStr == "" || qtyStr.count == 0 || qtyStr == "0.0" || qtyStr == "0"{
                vc.specNum = dict.stringValueForKey(key: "weight")
                vc.specName = "g"
            }else{
                vc.specNum = dict.stringValueForKey(key: "qty")
                vc.specName = dict["spec"]as? String ?? "g"
            }
            vc.confirmButton.setTitle("保存", for: .normal)
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
//            MCToast.mc_text("该食物已删除！",respond: .respond)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView{
            
            if scrollView.contentOffset.y >= self.caloriDetailVm.frame.minY + kFitWidth(50){
                var titleString = nameVm.textField.text
                if titleString == ""{
                    titleString = "待命名"
                }
                if titleString?.count ?? 0 > 10 {
                    titleString = "\(titleString?.mc_clipFromPrefix(to: 8) ?? "")..."
                }
                self.titleString = "\(titleString ?? "")"
                titleString = "\(titleString ?? "")·\(WHUtils.convertStringToStringNoDigit("\(self.totalCalories.rounded())") ?? "0")千卡"
                
                self.naviTitleLabel.text = "\(titleString ?? "保存餐食·\(WHUtils.convertStringToStringNoDigit("\(self.totalCalories.rounded())") ?? "0")千卡")"
            }else{
                self.naviTitleLabel.text = "保存餐食·\(WHUtils.convertStringToStringNoDigit("\(self.totalCalories.rounded())") ?? "0")千卡"
                self.titleString = ""
            }
        }
    }
}

extension CreateMealsVC{
    func dealDataArray() {
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
        self.caloriDetailVm.updateMealsDetail(dict: detailDict as NSDictionary)
    }
    @objc func changeFoods(notify:Notification) {
        let foodsDict = notify.object as? NSDictionary ?? [:]
//        updateFoodsIndex
        let dictFid = foodsDict.stringValueForKey(key: "fid")
        var hasSameFoods = false
        for i in 0..<foodsDataArray.count{
            let foodsMsg = foodsDataArray[i]as? NSDictionary ?? [:]
            
            //有相同规格的食物
            if dictFid != "-1" &&  dictFid == foodsMsg["fid"]as? String ?? "\(foodsMsg["fid"]as? Int ?? -2)" && foodsDict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                hasSameFoods = true
                let foodsDict = NSMutableDictionary.init(dictionary: foodsDict)
                
                let calories = foodsDict.doubleValueForKey(key: "calories")// + foodsMsg.doubleValueForKey(key: "calories")
                let carbohydrate = foodsDict.doubleValueForKey(key: "carbohydrate")// + foodsMsg.doubleValueForKey(key: "carbohydrate")
                let protein = foodsDict.doubleValueForKey(key: "protein")// + foodsMsg.doubleValueForKey(key: "protein")
                let fat = foodsDict.doubleValueForKey(key: "fat") //+ foodsMsg.doubleValueForKey(key: "fat")
                let qty = foodsDict.doubleValueForKey(key: "qty")// + foodsMsg.doubleValueForKey(key: "qty")
                
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
                
                foodsDataArray.replaceObject(at: i, with: foodsDict)
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .fade)
                
                if i != self.updateFoodsIndex{
                    foodsDataArray.remove(self.updateFoodsIndex)
                    self.tableView.deleteRows(at: [IndexPath(row: self.updateFoodsIndex, section: 0)], with: .fade)
                }
                
                break
            }
        }
        
        if hasSameFoods == false{
            let foodsDict = NSMutableDictionary.init(dictionary: foodsDict)
            foodsDict.setValue("1", forKey: "state")
            foodsDict.setValue("0", forKey: "isSelect")
            foodsDataArray.replaceObject(at: self.updateFoodsIndex, with: foodsDict)
            self.tableView.reloadRows(at: [IndexPath(row: self.updateFoodsIndex, section: 0)], with: .fade)
        }else{
            if foodsDict.stringValueForKey(key: "fname") != "快速添加" && foodsDict.stringValueForKey(key: "fid").count > 0{
                WHUtils().sendAddFoodsForCountRequest(fids: [foodsDict.stringValueForKey(key: "fid")])
                WHUtils().sendAddHistoryFoods(foodsMsgArray: [foodsDict])
            }
        }
        
        calculateNum()
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
        self.caloriDetailVm.updateMealsDetail(dict: detailDict as NSDictionary)
        
        if self.titleString == ""{
            self.naviTitleLabel.text = "保存餐食·\(WHUtils.convertStringToStringNoDigit("\(self.totalCalories.rounded())") ?? "0")千卡"
        }else{
            self.naviTitleLabel.text = "\(titleString)"
        }
    }
}

extension CreateMealsVC{
    func sendCreateMealsRequest() {
        let param = ["name":"\(self.nameVm.textField.text ?? "")",
                     "image":"http://lnsapp-static-o.oss-cn-shenzhen.aliyuncs.com/bodydata/body_data_2a7767c9d00f88c2609622a5532e46b9202407224346.png",
                     "carbohydrate":self.totalCarbohydrate,
                     "fat":self.totalFat,
                     "protein":self.totalProtein,
                     "calories":self.totalCalories,
                     "notes":"\(self.remarkVm.placeHoldLabel.text ?? "")",
                     "foods":self.foodsDataArray] as [String : Any]
        WHNetworkUtil.shareManager().POST(urlString: URL_meals_add, parameters: param as [String:AnyObject],isNeedToast: true,vc: self) { responseObject in
            DLLog(message: "\(responseObject)")
        }
        //URL_meals_add
    }
}
