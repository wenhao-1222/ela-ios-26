//
//  JounalCollectionViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/5/10.
//

import Foundation

class JounalCollectionViewCell: UICollectionViewCell {
    
    var queryDay = ""
    var logsModel = LogsModel(uid: UserInfoModel.shared.uId,
                              sdate: Date().nextDay(days: 0),
                              date: Date().changeDateStringToDate(dateString: Date().nextDay(days: 0)),
                              ctime: "", etime: Date().currentSeconds,
                              foods: "",
                              calori: "",
                              protein: "",
                              carbohydrate: "",
                              fat: "",
                              notes: "",
                              caloriTarget: "",
                              proteinTarget: "",
                              carbohydrateTarget: "",
                              fatTarget: "",
                              isUpload: false,
                              waterNum: "",
                              waterUpload: "0",
                              waterETime: "",
                              circleTag: "",
                              fitnessTag: "",
                              notesTag: "")
    var controller = WHBaseViewVC()
    var isEdit = false
    var isDelete = false
//    static var selectMealsIndex = 0
    var currentDayMsg = NSDictionary()
    var mealsArray = NSMutableArray.init(array: [[],[],[],[],[],[]])
    var mealsForUpload = NSArray()
    
    override init(frame: CGRect) {
//        selectMealsIndex = 0
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadStreakMsg), name: NSNotification.Name(rawValue: "reloadStreakMsg"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //添加食物，第 多少  餐
    static var selectMealsIndex : Int = 0{
        didSet{
            DLLog(message: "selectMealsIndex 变化了：\(selectMealsIndex)")
        }
    }
    //添加食物
    static var selectFoodsIndex : Int = -1{
        didSet{
            DLLog(message: "selectFoodsIndex 变化了：\(selectFoodsIndex)")
        }
    }
    lazy var goalVm: LogsNaturalGoalVM = {
        let vm = LogsNaturalGoalVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        vm.calcuBlock = {()in
            self.saveDataToSqlDB()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "msgCalculateEnd"), object: nil)
            self.dealParamForRequest()
        }
        vm.updateDataBlock = {()in
            let dict = NSMutableDictionary(dictionary: self.currentDayMsg)
            dict.setValue("\(self.goalVm.caloriCircleVm.currentNum)", forKey: "calories")
            dict.setValue("\(self.goalVm.carboCircleVm.currentNum)", forKey: "carbohydrate")
            dict.setValue("\(self.goalVm.proteinCircleVm.currentNum)", forKey: "protein")
            dict.setValue("\(self.goalVm.fatCircleVm.currentNum)", forKey: "fat")
            dict.setValue("\(self.goalVm.caloriCircleVm.currentNumFloat)", forKey: "caloriesDouble")
            dict.setValue("\(self.goalVm.carboCircleVm.currentNumFloat)", forKey: "carbohydrateDouble")
            dict.setValue("\(self.goalVm.proteinCircleVm.currentNumFloat)", forKey: "proteinDouble")
            dict.setValue("\(self.goalVm.fatCircleVm.currentNumFloat)", forKey: "fatDouble")
            self.currentDayMsg = dict
        }
        vm.addPlanBlock = {()in
            let vc = QuestionnairePreVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        vm.goalTapBlock = {()in
            let vc = GoalSetVC()
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        return vm
    }()
    lazy var editSelectAllVm : LogsEditHeadView = {
        let vm = LogsEditHeadView.init(frame: CGRect.init(x: 0, y: self.goalVm.frame.maxY, width: 0, height: 0))
        vm.isHidden = true
        vm.tapBlock = {(isSelect)in
            self.allTapAction(isSelect: isSelect)
        }
        return vm
    }()
    lazy var editHeadView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.goalVm.frame.maxY))
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        vi.addSubview(goalVm)
        vi.addSubview(editSelectAllVm)
//        vi.addSubview(winnerVm)
//        vi.addSubview(winnerPopView)
        
        return vi
    }()
    lazy var remarkVm : LogsRemarkVM = {
        let vm = LogsRemarkVM.init(frame: CGRect.init(x: 0, y: kFitWidth(8), width: 0, height: 0))
        vm.tapBlock = {()in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
            self.remarkAlertVm.showView()
        }
        return vm
    }()
    lazy var detailButton: GJVerButton = {
        let btn = GJVerButton.init(frame: CGRect.init(x: kFitWidth(8), y: self.remarkVm.frame.maxY+kFitWidth(8), width: kFitWidth(359), height: kFitWidth(48)))
        btn.backgroundColor = .white
        btn.addShadow(opacity: 0.08,radius: kFitWidth(12))
        btn.layer.cornerRadius = kFitWidth(12)
        btn.setTitle("营养详情", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setImage(UIImage(named: "logs_natural_icon"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(naturalDetailTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var footView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: LogsRemarkVM().selfHeight+self.detailButton.frame.height+kFitWidth(50)))
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.addSubview(remarkVm)
        vi.addSubview(detailButton)
        
        return vi
    }()
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()-WHUtils().getTabbarHeight()), style: .plain)
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.delegate = self
        vi.dataSource = self
        vi.separatorStyle = .none
        vi.register(JournalTableViewCell.classForCoder(), forCellReuseIdentifier: "JournalTableViewCell")
        vi.tableHeaderView = self.editHeadView
        vi.tableFooterView = self.footView
        
        return vi
    }()
    lazy var remarkAlertVm : LogsRemarkAlertVM = {
        let vm = LogsRemarkAlertVM.init(frame: .zero)
        vm.remarkBlock = {(text)in
            self.remarkVm.updateContent(text: text)
//            self.sendUpdateNotesReqeust()
            self.logsModel.isUpload = false
//            self.sendUpdateLogsRequest(meals: self.mealsArray)
            LogsSQLiteManager.getInstance().insertNotes(sDate: self.queryDay, notestr: text)
        }
        return vm
    }()
    
//    lazy var winnerVm: WinnerStreakVM = {
//        let vm = WinnerStreakVM.init(frame: CGRect.init(x: 0, y: kFitWidth(5), width: 0, height: 0))
//        vm.tapBlock = {()in
//            self.winnerPopView.showSelf()
//        }
//        vm.updateUI(dict: UserInfoModel.shared.streakDict)
//        return vm
//    }()
//    lazy var winnerPopView: WinnerStreakAlertVM = {
//        let vm = WinnerStreakAlertVM.init(frame: CGRect.init(x: 0, y: self.winnerVm.frame.maxY-kFitWidth(5), width: 0, height: 0))
//        vm.frame = CGRect.init(x: SCREEN_WIDHT - kFitWidth(278), y: self.winnerVm.frame.maxY-kFitWidth(5), width: kFitWidth(274), height: kFitWidth(80))
//        vm.isHidden = true
//        vm.updateUI(dict: UserInfoModel.shared.streakDict)
//        return vm
//    }()
}

extension JounalCollectionViewCell{
    func initUI() {
        contentView.addSubview(tableView)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getKeyWindow().addSubview(remarkAlertVm)
    }
    
    @objc func reloadStreakMsg() {
        goalVm.winnerVm.updateUI(dict: UserInfoModel.shared.streakDict)
        goalVm.winnerPopView.updateUI(dict: UserInfoModel.shared.streakDict)
        goalVm.winnerPopView.closeSelfAction()
    }
    func reloadTableView() {
        self.editSelectAllVm.selecImgView.setImgLocal(imgName: "logs_edit_normal")
        self.goalVm.winnerPopView.closeSelfAction()
        if self.isEdit{
            self.goalVm.winnerVm.isHidden = true
            self.editSelectAllVm.isHidden = false
            self.editHeadView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.editSelectAllVm.frame.maxY)
        }else{
//            self.goalVm.winnerVm.isHidden = false
            goalVm.winnerVm.updateUI(dict: UserInfoModel.shared.streakDict)
            self.editSelectAllVm.isHidden = true
            self.editHeadView.frame = self.goalVm.frame
            self.allTapAction(isSelect: false)
        }
        self.tableView.reloadData()
    }
    func setQueryDate(date:String,isEdit:Bool) {
        self.isEdit = isEdit
        self.queryDay = date
        self.dealData()
        goalVm.winnerVm.updateUI(dict: UserInfoModel.shared.streakDict)
        goalVm.winnerPopView.updateUI(dict: UserInfoModel.shared.streakDict)
        self.editSelectAllVm.selecImgView.setImgLocal(imgName: "logs_edit_normal")
        if self.isEdit{
            self.editSelectAllVm.isHidden = false
            self.editHeadView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.editSelectAllVm.frame.maxY)
        }else{
            self.editSelectAllVm.isHidden = true
            self.editHeadView.frame = self.goalVm.frame
        }
    }
    func addFoods(foodsMsg:NSDictionary) {
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        logsModel.isUpload = false
        
        if foodsMsg.stringValueForKey(key: "fname") != "快速添加" && foodsMsg.stringValueForKey(key: "fid").count > 0{
            WHUtils().sendAddFoodsForCountRequest(fids: [foodsMsg.stringValueForKey(key: "fid")])
        }
        
//        let foodsArray = NSMutableArray(array: mealsArray[JounalCollectionViewCell.selectMealsIndex] as? NSArray ?? [])
        let foodsArray = NSMutableArray.init(array: mealsArray[JounalCollectionViewCell.selectMealsIndex] as? NSArray ?? [])
        if JounalCollectionViewCell.selectFoodsIndex == -1 {
            if foodsMsg.stringValueForKey(key: "fname") == "快速添加"{
                foodsArray.add(foodsMsg)
            }else{
                var hasData = false
                for i in 0..<foodsArray.count{
                    let dict = foodsArray[i]as? NSDictionary ?? [:]
                    
                    let dictFid = dict.stringValueForKey(key: "fid")
                    
                    if dictFid != "-1" &&  dictFid == foodsMsg.stringValueForKey(key: "fid") && (dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? "" || (dict["spec"]as? String ?? "" == "" && foodsMsg["spec"]as? String ?? "" == "g")){
                        let foodsDict = NSMutableDictionary.init(dictionary: dict)
                        let specNum = foodsMsg.doubleValueForKey(key: "qty")
                        foodsDict.setValue("\(foodsMsg.stringValueForKey(key: "specName"))", forKey: "spec")
//                        foodsDict.setValue("\(foodsMsg.stringValueForKey(key: "specName"))", forKey: "specName")
                        
                        if dict.stringValueForKey(key: "state") == "1"{
                            var dictNum = dict.doubleValueForKey(key: "qty")
                            if dictNum == 0 {
                                dictNum = dict.doubleValueForKey(key: "weight")
                            }
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
                            foodsDict.setValue("1", forKey: "state")
                        }else{
                            foodsDict.setValue("\(specNum)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                            foodsDict.setValue("\(specNum)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                            let calori = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                            let carbo = foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                            let protein = foodsMsg.doubleValueForKey(key: "proteinNumber")
                            let fat = foodsMsg.doubleValueForKey(key: "fatNumber")
                            
                            foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                            foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                            foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                            foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                            foodsDict.setValue("1", forKey: "state")
                        }
                        if foodsArray.count > i {
                            if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                                foodsArray.replaceObject(at: i, with: foodsDict)
                            }else{
                                foodsArray.removeObject(at: i)
                            }
                            hasData = true
                        }else{
                            self.addFoods(foodsMsg:foodsMsg)
                            return
                        }
                        
                        break
                    }
                }
                if hasData == false{
                    if foodsMsg.stringValueForKey(key: "fname") == "快速添加"{
                        foodsArray.add(foodsMsg)
                    }else if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                        foodsArray.add(foodsMsg)
                    }
                }
            }
            
        }else{
            var hasData = false
            if foodsMsg.stringValueForKey(key: "fname") == "快速添加"{
                foodsArray.replaceObject(at: JounalCollectionViewCell.selectFoodsIndex, with: foodsMsg)
            }else{
                for i in 0..<foodsArray.count{
                    let dict = foodsArray[i]as? NSDictionary ?? [:]
                    
                    var dictFid = dict["fid"]as? String ?? "\(dict["fid"]as? Int ?? -1)"
                    
                    if dictFid != "-1" &&  dictFid == foodsMsg["fid"]as? String ?? "\(foodsMsg["fid"]as? Int ?? -2)" && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                        let foodsDict = NSMutableDictionary.init(dictionary: dict)
                        foodsDict.setValue("\(foodsMsg.stringValueForKey(key: "specName"))", forKey: "spec")
//                        foodsDict.setValue("\(foodsMsg.stringValueForKey(key: "specName"))", forKey: "specName")
                        
                        if JounalCollectionViewCell.selectFoodsIndex == i {
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "qty"))".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "qty"))".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                            foodsDict.setValue("\(WHUtils.convertStringToStringNoDigit("\(foodsMsg.doubleValueForKey(key: "caloriesNumber"))") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "carbohydrateNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "proteinNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                            foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "fatNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                            foodsDict.setValue("1", forKey: "state")
                            if foodsArray.count > i {
                                if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                                    foodsArray.replaceObject(at: i, with: foodsDict)
                                }else{
                                    foodsArray.removeObject(at: i)
                                }
                            }else{
                                self.addFoods(foodsMsg:foodsMsg)
                                return
                            }
                        }else{
                            let specNum = foodsMsg.doubleValueForKey(key: "qty")
                            var dictNum = dict.doubleValueForKey(key: "qty")
                            if dictNum == 0 {
                                dictNum = Double(((dict["qty"]as? String ?? "0") as NSString).intValue)
                            }
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
                            foodsDict.setValue("1", forKey: "state")
                            
                            if foodsArray.count > i{
                                if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                                    foodsArray.replaceObject(at: i, with: foodsDict)
                                    foodsArray.removeObject(at: JounalCollectionViewCell.selectFoodsIndex)
                                }else{
                                    foodsArray.removeObject(at: JounalCollectionViewCell.selectFoodsIndex)
                                }
                            }else{
                                self.addFoods(foodsMsg:foodsMsg)
                                return
                            }
                        }
                        hasData = true
                        break
                    }
                }
                if hasData == false{
                    if foodsArray.count > JounalCollectionViewCell.selectFoodsIndex{
                        if foodsMsg.doubleValueForKey(key: "specNum") > 0{
                            foodsArray.replaceObject(at: JounalCollectionViewCell.selectFoodsIndex, with: foodsMsg)
                        }else{
                            foodsArray.removeObject(at: JounalCollectionViewCell.selectFoodsIndex)
                        }
                    }else{
                        self.addFoods(foodsMsg:foodsMsg)
                        return
                    }
                }
            }
        }
        
        if mealsArray.count > JounalCollectionViewCell.selectMealsIndex{
            mealsArray.replaceObject(at: JounalCollectionViewCell.selectMealsIndex, with: foodsArray)
            saveDataToSqlDB()
            self.tableView.reloadData()
            self.calculateNaturalNum()
        }else{
            self.addFoods(foodsMsg: foodsMsg)
        }
    }
}

extension JounalCollectionViewCell:UITableViewDelegate,UITableViewDataSource{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeEditStatus"), object: nil)
        self.goalVm.winnerPopView.closeSelfAction()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealsArray.count == 0 ? 6 : mealsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalTableViewCell") as? JournalTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "JournalTableViewCell", for: indexPath) as? JournalTableViewCell
        
        if self.mealsArray.count > 0 && self.mealsArray.count > indexPath.row{
            let foodsArr = self.mealsArray[indexPath.row]as? NSArray ?? []
            cell?.updateUI(array: foodsArr,isEdit:self.isEdit, queryDate: self.queryDay)
        }else{
            cell?.updateUI(array: [],isEdit:self.isEdit, queryDate: self.queryDay)
        }
        cell?.titleLabel.text = "第 \(indexPath.row+1) 餐"
        cell?.controller = UIApplication.topViewController() ?? self.controller//self.controller
        
        cell?.addBlock = {()in
            JounalCollectionViewCell.selectMealsIndex = indexPath.row
            JounalCollectionViewCell.selectFoodsIndex = -1
            let vc = FoodsListNewVC()//FoodsListVC()
            vc.sourceType = .logs
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        cell?.deleteBlock = {(dict)in
            JounalCollectionViewCell.selectMealsIndex = indexPath.row
            self.delecteFoods(foodsMsg: dict)
        }
        cell?.deleteCellBlock = {(dict,index)in
            JounalCollectionViewCell.selectMealsIndex = indexPath.row
            self.delecteFoodsCell(foodsMsg: dict, index: index)
        }
        cell?.selectCellBlock = {(isSelect,index)in
            JounalCollectionViewCell.selectMealsIndex = indexPath.row
            self.singelCellTapAction(isSelect: isSelect, cellIndex: index)
        }
        cell?.selectBlock = {(isSelect)in
            JounalCollectionViewCell.selectMealsIndex = indexPath.row
            self.mealsSelectAction(isSelect: isSelect)
        }
        cell?.selectMeaslIndexBlock = {(foodsIndex)in
            JounalCollectionViewCell.selectMealsIndex = indexPath.row
            JounalCollectionViewCell.selectFoodsIndex = foodsIndex
        }
        cell?.eatTapBlock = {(foodsIndex)in
            JounalCollectionViewCell.selectMealsIndex = indexPath.row
            self.eatCellTapAction(cellIndex: foodsIndex)
        }
        
        return cell ?? JournalTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.mealsArray.count > 0 && self.mealsArray.count > indexPath.row{
            let foodsArr = self.mealsArray[indexPath.row]as? NSArray ?? []
            if foodsArr.count > 0 {
                return kFitWidth(159)+CGFloat(foodsArr.count)*kFitWidth(55)+kFitWidth(8)
            }else{
                return kFitWidth(78)
            }
        }else{
            return kFitWidth(78)
        }
    }
}

extension JounalCollectionViewCell{
    func editDelAction() {
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        logsModel.isUpload = false
        self.isDelete = true
        for i in 0..<self.mealsArray.count{
            if self.mealsArray.count > i{
                let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
                let saveFoodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
                for j in 0..<foodsArray.count{
                    let index = foodsArray.count-1-j
                    let foodsDi = NSMutableDictionary.init(dictionary: foodsArray[index]as? NSDictionary ?? [:])
                    if foodsDi["isSelect"]as? String ?? "" == "1"{
                        saveFoodsArray.removeObject(at: index)
                    }
                }
                mealsArray.replaceObject(at: i, with: saveFoodsArray)
            }
        }
        saveDataToSqlDB()
        self.isEdit = false
        self.editSelectAllVm.selecImgView.setImgLocal(imgName: "logs_edit_normal")
        self.editSelectAllVm.isHidden = true
        self.editHeadView.frame = self.goalVm.frame
        
        tableView.reloadData()
        calculateNaturalNum()
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
    }
}

extension JounalCollectionViewCell{
    func dealData(){
        logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: self.queryDay)!
        
        let sportDict = SportDataSQLiteManager.getInstance().queryTable(sDate: self.queryDay)
        DLLog(message: "SportDataSQLiteManager:\(sportDict)")
        
        self.currentDayMsg = logsModel.modelToDict()
//        if logsModel.foods == "[[],[],[],[],[],[]]" && logsModel.notes == "" {
//            sendLogsDetailRequest()
//        }else{
            goalVm.updateUI(dict: self.currentDayMsg,isUpload: false)
            self.remarkVm.updateContent(text: self.currentDayMsg["notes"]as? String ?? "")
            self.remarkAlertVm.updateContext(text: self.currentDayMsg["notes"]as? String ?? "")
            
            mealsArray.removeAllObjects()
            mealsArray.addObjects(from: (self.currentDayMsg["foods"]as? NSArray ?? []) as! [Any])
            if mealsArray.count == 0 {
                mealsArray = NSMutableArray.init(array: [[],[],[],[],[],[]])
            }
            self.tableView.reloadData()
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.sendLogsDetailRequest()
        })
    }
    
    func dealServerData(dict:NSDictionary) {
        let serverETime = dict.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " ")
//        let waterDict = dict["dietLogWater"]as? NSDictionary ?? [:]
//        var serverWaterETime = waterDict.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " ")
        //本地etime 小于 服务器的etime ，说明本地数据需要更新
        logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: self.queryDay)!
        self.currentDayMsg = logsModel.modelToDict()
//        if logsModel.waterETime == "" || Date().judgeMin(firstTime: logsModel.waterETime, secondTime: serverWaterETime){
//            
//        }
        
        SportDataSQLiteManager.getInstance().updateSportsNumber(sDate: dict.stringValueForKey(key: "sdate"), calories: dict.stringValueForKey(key: "sportCalories"), duration: dict.stringValueForKey(key: "sportDuration"))
        
        if Date().judgeMin(firstTime: logsModel.etime, secondTime: serverETime) || logsModel.caloriTarget == "" || logsModel.caloriTarget == "0"{
            self.currentDayMsg = dict
            goalVm.updateUI(dict: self.currentDayMsg,isUpload: false)
            self.remarkVm.updateContent(text: self.currentDayMsg["notes"]as? String ?? "")
            self.remarkAlertVm.updateContext(text: self.currentDayMsg["notes"]as? String ?? "")
            mealsArray.removeAllObjects()
            mealsArray.addObjects(from: (self.currentDayMsg["foods"]as? NSArray ?? []) as! [Any])
            if mealsArray.count == 0 {
                mealsArray = NSMutableArray.init(array: [[],[],[],[],[],[]])
            }
            self.tableView.reloadData()
            
            if self.currentDayMsg.stringValueForKey(key: "etime") == "" && (WHUtils.getJSONStringFromArray(array: self.currentDayMsg["foods"]as? NSArray ?? []) == "[]" || WHUtils.getJSONStringFromArray(array: self.currentDayMsg["foods"]as? NSArray ?? []) == ""){
                return
            }
//            let waterDict = self.currentDayMsg["dietLogWater"]as? NSDictionary ?? [:]
            let fitnessLabelArray = self.currentDayMsg["fitnessLabelArray"]as? NSArray ?? []
            var fitnessLabel = self.currentDayMsg.stringValueForKey(key: "fitnessLabel")
            if fitnessLabelArray.count > 0{
                fitnessLabel = WHUtils.getJSONStringFromArray(array: fitnessLabelArray)
            }
            LogsSQLiteManager.getInstance().updateLogs(sDate: self.queryDay,
                                                       eTime: serverETime,
                                                       calori: self.currentDayMsg.stringValueForKey(key: "calories"),
                                                       protein: self.currentDayMsg.stringValueForKey(key: "protein"),
                                                       carbohydrates: self.currentDayMsg.stringValueForKey(key: "carbohydrate"),
                                                       fats: self.currentDayMsg.stringValueForKey(key: "fat"),
                                                       notes: self.currentDayMsg.stringValueForKey(key: "notes"),
                                                       foods: WHUtils.getJSONStringFromArray(array: self.currentDayMsg["foods"]as? NSArray ?? []),
                                                       caloriTar: self.currentDayMsg.stringValueForKey(key: "caloriesden"),
                                                       proteinTar: self.currentDayMsg.stringValueForKey(key: "proteinden"),
                                                       carboTar: self.currentDayMsg.stringValueForKey(key: "carbohydrateden"),
                                                       fatsTar: self.currentDayMsg.stringValueForKey(key: "fatden"),
                                                       circleTag: self.currentDayMsg.stringValueForKey(key: "carbLabel"),
//                                                       fitnessTag: self.currentDayMsg.stringValueForKey(key: "fitnessLabel"),
                                                       fitnessTag: fitnessLabel,
                                                       notesTag: self.currentDayMsg.stringValueForKey(key: "notesLabel"))
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: true)
            logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: self.queryDay)!
        }else if logsModel.etime != serverETime{
            logsModel.isUpload = false
            goalVm.updateUI(dict: self.currentDayMsg,isUpload: true)
//            self.dealParamForRequest()
        }
    }
    //重新计算营养目标数值
    func calculateNaturalNum() {
        let dict = NSMutableDictionary(dictionary: self.currentDayMsg)
        dict.setValue(mealsArray, forKey: "foods")
        self.currentDayMsg = dict
        logsModel.isUpload = false
        goalVm.updateUI(dict: self.currentDayMsg,isUpload: true)
    }
    func dealParamForRequest() {
        let param = NSMutableArray()
        
        let dict = NSMutableDictionary(dictionary: self.currentDayMsg)
        dict.setValue("\(self.goalVm.caloriCircleVm.currentNum)".replacingOccurrences(of: ",", with: "."), forKey: "calories")
        dict.setValue("\(self.goalVm.carboCircleVm.currentNum)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
        dict.setValue("\(self.goalVm.proteinCircleVm.currentNum)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
        dict.setValue("\(self.goalVm.fatCircleVm.currentNum)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
        dict.setValue("\(self.goalVm.caloriCircleVm.currentNumFloat)".replacingOccurrences(of: ",", with: "."), forKey: "caloriesDouble")
        dict.setValue("\(self.goalVm.carboCircleVm.currentNumFloat)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrateDouble")
        dict.setValue("\(self.goalVm.proteinCircleVm.currentNumFloat)".replacingOccurrences(of: ",", with: "."), forKey: "proteinDouble")
        dict.setValue("\(self.goalVm.fatCircleVm.currentNumFloat)".replacingOccurrences(of: ",", with: "."), forKey: "fatDouble")
        self.currentDayMsg = dict
        
        for i in 0..<self.mealsArray.count{
            let foodsArray = NSMutableArray.init(array: self.mealsArray[i]as? NSArray ?? [])
            
            for j in 0..<foodsArray.count{
                let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
                let dic = NSMutableDictionary.init(dictionary: foodsDi)
                dic.setValue("\(i+1)", forKey: "sn")
                dic.setValue("\(WHUtils.convertStringToStringOneDigit(dic.stringValueForKey(key: "calories")) ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                let qty = "\(dic["specNum"]as? String ?? "")".replacingOccurrences(of: ",", with: ".")
                if qty.count > 0 {
                    dic.setValue(qty, forKey: "qty")
                    dic.setValue("\(dic["specName"]as? String ?? "")", forKey: "spec")
                }
                foodsArray.replaceObject(at: j, with: dic)
            }
            
            param.add(foodsArray)
        }
        self.mealsArray = param
//        sendUpdateLogsRequest(meals: param)
    }
    func saveDataToSqlDB(){
        let param = NSMutableArray()
        
        for i in 0..<mealsArray.count{
            let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
            
            for j in 0..<foodsArray.count{
                let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
                let dic = NSMutableDictionary.init(dictionary: foodsDi)
                dic.setValue("\(i+1)", forKey: "sn")
                
                let qty = "\(dic["specNum"]as? String ?? "")"
                if qty.count > 0 {
                    dic.setValue(qty, forKey: "qty")
                    dic.setValue("\(dic["specName"]as? String ?? "")", forKey: "spec")
                }
                
                foodsArray.replaceObject(at: j, with: dic)
            }
            
            param.add(foodsArray)
        }
        LogsSQLiteManager.getInstance().updateLogs(sDate: self.queryDay, 
                                                   eTime: Date().currentSeconds,
                                                   calori: "\(self.goalVm.caloriCircleVm.currentNumFloat)",
                                                   protein: "\(self.goalVm.proteinCircleVm.currentNumFloat)",
                                                   carbohydrates: "\(self.goalVm.carboCircleVm.currentNumFloat)",
                                                   fats: "\(self.goalVm.fatCircleVm.currentNumFloat)",
                                                   notes: self.currentDayMsg.stringValueForKey(key: "notes"),
                                                   foods: WHUtils.getJSONStringFromArray(array: param),
                                                   caloriTar: "\(self.goalVm.caloriCircleVm.totalNum)",
                                                   proteinTar: "\(self.goalVm.proteinCircleVm.totalNum)",
                                                   carboTar: "\(self.goalVm.carboCircleVm.totalNum)",
                                                   fatsTar: "\(self.goalVm.fatCircleVm.totalNum)",
                                                   circleTag: self.currentDayMsg.stringValueForKey(key: "carbLabel"),
                                                   fitnessTag: self.currentDayMsg.stringValueForKey(key: "fitnessLabel"),
                                                   notesTag: self.currentDayMsg.stringValueForKey(key: "notesLabel"))
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
    }
    //左滑删除一种食物
    func delecteFoods(foodsMsg:NSDictionary) {
        let foodsArray = NSMutableArray(array: mealsArray[JounalCollectionViewCell.selectMealsIndex] as? NSArray ?? [])
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        logsModel.isUpload = false
        for i in 0..<foodsArray.count{
            let dict = foodsArray[i]as? NSDictionary ?? [:]
            if dict["fname"]as? String ?? "" == "快速添加" &&
                (dict["calories"]as? Int ?? 0 == foodsMsg["calories"]as? Int ?? 0) &&
                (dict["carbohydrate"]as? Double ?? 0 == foodsMsg["carbohydrate"]as? Double ?? 0) &&
                (dict["protein"]as? Double ?? 0 == foodsMsg["protein"]as? Double ?? 0) &&
                (dict["fat"]as? Double ?? 0 == foodsMsg["fat"]as? Double ?? 0){
                foodsArray.removeObject(at: i)
                break
            }else{
                var fidStr = "\(dict["fid"]as? Int ?? -1)"
                if fidStr == "-1"{
                    fidStr = dict["fid"]as? String ?? "-1"
                }
                
                var foodsMsgIdStr = "\(foodsMsg["fid"]as? Int ?? -1)"
                if foodsMsgIdStr == "-1"{
                    foodsMsgIdStr = foodsMsg["fid"]as? String ?? "-1"
                }
                if fidStr == foodsMsgIdStr && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                    foodsArray.removeObject(at: i)
                    break
                }
            }
        }
        if mealsArray.count > JounalCollectionViewCell.selectMealsIndex{
            mealsArray.replaceObject(at: JounalCollectionViewCell.selectMealsIndex, with: foodsArray)
            self.tableView.reloadData()
            saveDataToSqlDB()
            self.calculateNaturalNum()
        }else{
            self.delecteFoods(foodsMsg: foodsMsg)
        }
    }
    //左滑删除一种食物
    func delecteFoodsCell(foodsMsg:NSDictionary,index:Int) {
        let foodsArray = NSMutableArray(array: mealsArray[JounalCollectionViewCell.selectMealsIndex] as? NSArray ?? [])
        LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
        logsModel.isUpload = false
        foodsArray.removeObject(at: index)
        
        if mealsArray.count > JounalCollectionViewCell.selectMealsIndex{
            mealsArray.replaceObject(at: JounalCollectionViewCell.selectMealsIndex, with: foodsArray)
            
            self.tableView.reloadData()
            saveDataToSqlDB()
            self.calculateNaturalNum()
        }else{
            self.delecteFoodsCell(foodsMsg: foodsMsg, index: index)
        }
    }
    //  某个食物  点击了“用餐”
    func eatCellTapAction(cellIndex:Int) {
        let foodsArray = NSMutableArray(array: mealsArray[JounalCollectionViewCell.selectMealsIndex] as? NSArray ?? [])
        let foodsDict = NSMutableDictionary.init(dictionary: foodsArray[cellIndex]as? NSDictionary ?? [:])
        foodsDict.setValue("1", forKey: "state")
        foodsArray.replaceObject(at: cellIndex, with: foodsDict)
        
        WHUtils().sendAddFoodsForCountRequest(fids: [foodsDict.stringValueForKey(key: "fid")])
        
        if mealsArray.count > JounalCollectionViewCell.selectMealsIndex{
            mealsArray.replaceObject(at: JounalCollectionViewCell.selectMealsIndex, with: foodsArray)
            logsModel.isUpload = false
            tableView.reloadData()
            
            let msgDict = NSMutableDictionary.init(dictionary: self.currentDayMsg)
            msgDict.setValue(mealsArray, forKey: "foods")
            self.currentDayMsg = msgDict
            
            saveDataToSqlDB()
            goalVm.updateUI(dict: self.currentDayMsg)
        }else{
            self.eatCellTapAction(cellIndex: cellIndex)
        }
        
        
//        tableView.reloadRows(at: [IndexPath(row: JounalCollectionViewCell.selectMealsIndex, section: 0)], with: .fade)
//        dealParamForRequest()
    }
    //单独选中/取消选中 一种食物
    func singelCellTapAction(isSelect:Bool,cellIndex:Int) {
        let foodsArray = NSMutableArray(array: mealsArray[JounalCollectionViewCell.selectMealsIndex] as? NSArray ?? [])
        let foodsDict = NSMutableDictionary.init(dictionary: foodsArray[cellIndex]as? NSDictionary ?? [:])
        if isSelect == true{
            foodsDict.setValue("1", forKey: "isSelect")
        }else{
            foodsDict.setValue("0", forKey: "isSelect")
        }
        foodsArray.replaceObject(at: cellIndex, with: foodsDict)
        mealsArray.replaceObject(at: JounalCollectionViewCell.selectMealsIndex, with: foodsArray)
        
        tableView.reloadData()
        judgeAllSelectStatus()
    }
    
    //某一餐  全选或取消全选
    func mealsSelectAction(isSelect:Bool) {
        let foodsArray = NSMutableArray(array: mealsArray[JounalCollectionViewCell.selectMealsIndex] as? NSArray ?? [])
        let selecStatus = isSelect ? "1" : "0"
        for i in 0..<foodsArray.count{
            let foodsDi = NSMutableDictionary.init(dictionary: foodsArray[i]as? NSDictionary ?? [:])
            foodsDi.setValue(selecStatus, forKey: "isSelect")
            foodsArray.replaceObject(at: i, with: foodsDi)
        }
        mealsArray.replaceObject(at: JounalCollectionViewCell.selectMealsIndex, with: foodsArray)
        tableView.reloadData()
        judgeAllSelectStatus()
    }
    //当天的  全选  或  取消全选
    func allTapAction(isSelect:Bool){
        let selecStatus = isSelect ? "1" : "0"
        for i in 0..<self.mealsArray.count{
            let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
            for j in 0..<foodsArray.count{
                let foodsDi = NSMutableDictionary.init(dictionary: foodsArray[j]as? NSDictionary ?? [:])
                foodsDi.setValue(selecStatus, forKey: "isSelect")
                foodsArray.replaceObject(at: j, with: foodsDi)
            }
            mealsArray.replaceObject(at: i, with: foodsArray)
        }
        tableView.reloadData()
        
        if isSelect{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFoodsHasSelect"), object: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFoodsHasSelectNone"), object: nil)
        }
    }
    //判断是否食物全选
    func judgeAllSelectStatus() {
        var isAllSelect = true
        for i in 0..<self.mealsArray.count{
            let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
            for j in 0..<foodsArray.count{
                let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
                if foodsDi["isSelect"]as? String ?? "" != "1"{
                    isAllSelect = false
                    break
                }
            }
            
            if isAllSelect == false{
                break
            }
        }
        
        self.editSelectAllVm.setSelectStatus(isAllSelect: isAllSelect)
        self.judgeHasFoodsSelect()
    }
    func judgeHasFoodsSelect() {
        var hasSelect = false
        for i in 0..<self.mealsArray.count{
            let foodsArray = NSMutableArray.init(array: mealsArray[i]as? NSArray ?? [])
            for j in 0..<foodsArray.count{
                let foodsDi = foodsArray[j]as? NSDictionary ?? [:]
                if foodsDi["isSelect"]as? String ?? "" == "1"{
                    hasSelect = true
                    break
                }
            }
            
            if hasSelect == true{
                break
            }
        }
        if hasSelect{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFoodsHasSelect"), object: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editFoodsHasSelectNone"), object: nil)
        }
    }
    @objc func naturalDetailTapAction() {
        let vc = NaturalDetailVC()
        vc.detailDict = self.currentDayMsg
        self.controller.navigationController?.pushViewController(vc, animated: true)
    }
}

extension JounalCollectionViewCell{
    func sendLogsDetailRequest() {
        let param = ["sdate":"\(queryDay)"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_detail, parameters: param as [String : AnyObject]) { responseObject in
//            DLLog(message: responseObject)
//            self.currentDayMsg = responseObject["data"]as? NSDictionary ?? [:]
            
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            self.dealServerData(dict:dataObj)
            DLLog(message: "sendLogsDetailRequest:\(dataObj)")
//            self.dealServerData(dict:responseObject["data"]as? NSDictionary ?? [:])
        }
    }
//    func sendUpdateLogsRequest(meals:NSArray) {
//        if logsModel.isUpload{
//            return
//        }
//        let param = ["sdate":"\(self.currentDayMsg["sdate"]as? String ?? "\(self.queryDay)")",
//                     "notes":"\(self.remarkAlertVm.textView.text ?? "")",
//                     "totalProteins":"\(self.goalVm.proteinCircleVm.currentNum)",
//                     "totalCarbohydrates":"\(self.goalVm.carboCircleVm.currentNum)",
//                     "totalFats":"\(self.goalVm.fatCircleVm.currentNum)",
//                     "totalCalories":"\(self.goalVm.caloriCircleVm.currentNum)",
//                     "meals":"\(self.controller.getJSONStringFromArray(array: meals))"]
//        
//        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_details, parameters: param as [String : AnyObject]) { responseObject in
//            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
//            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
//            
//            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: true)
//            LogsSQLiteManager.getInstance().updateLogsEtime(sDate: self.queryDay, endTime: dataObj["etime"]as? String ?? "\(Date().currentSeconds)")
//            self.logsModel.isUpload = true
//            if self.isDelete == true{
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancelEditStatus"), object: nil)
//                self.isDelete = false
//            }
//        }
//    }
    func sendUpdateNotesReqeust() {
        let param = ["sdate":"\(self.currentDayMsg["sdate"]as? String ?? "\(self.queryDay)")",
                     "notes":"\(self.remarkAlertVm.textView.text ?? "")"]
        
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_notes, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: responseObject)
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: true)
            self.logsModel.isUpload = true
        }
    }
}


extension JounalCollectionViewCell{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        for vi in self.subviews{
            let tp = vi.convert(point, from: self)
            let centerImgFrame = self.goalVm.winnerPopView.frame
            if CGRectContainsPoint(centerImgFrame, tp){
                
            }else{
                self.goalVm.winnerPopView.closeSelfAction()
            }
        }
        return view
    }
}
