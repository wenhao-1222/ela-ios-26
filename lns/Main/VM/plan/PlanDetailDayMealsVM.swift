//
//  PlanDetailDayMealsVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import UIKit
import MCToast

class PlanDetailDayMealsVM: UIView{
    
    var selfHeight = kFitWidth(60)
    var controller = WHBaseViewVC()
    
    var daysIndex = 0
    var updateBlock:((CGFloat)->())?
    var numberUpdateBlock:((NSDictionary)->())?
    
    var isUpdate = false
    var sid = ""
    var mealsDataArray = NSMutableArray()
    var mealsDataArrayForShow = NSMutableArray()
    var mealsDataArrayForUpdate = NSMutableArray()
    
    var selectMealsIndex = -1
    var selectFoodsIndex = -1
    
    var caloriesTotalNum = Float(0)
    var carboTotalNum = Float(0)
    var proteinTotalNum = Float(0)
    var fatTotalNum = Float(0)
    
    var isTapFoodsDetail = false
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var tableView: UITableView = {
        let vi = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight), style: .plain)
        
        vi.register(PlanDetailFoodsTableViewCell.classForCoder(), forCellReuseIdentifier: "PlanDetailFoodsTableViewCell")
        vi.delegate = self
        vi.dataSource = self
        vi.bounces = false
        vi.separatorStyle = .none
        
        if #available(iOS 15.0, *) {
            vi.sectionHeaderTopPadding = 0
            vi.sectionFooterHeight = 0
        }
        
        return vi
    }()
    func removeNotifiCenter() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: nil)
    }
}

extension PlanDetailDayMealsVM:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if isUpdate{
            return mealsDataArray.count
        }else{
            return mealsDataArrayForShow.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isUpdate{
            let mealsFoodsArray = self.mealsDataArray[section]as? NSArray ?? []
            return mealsFoodsArray.count > 0 ? mealsFoodsArray.count : 1
        }else{
            let mealsFoodsDict = self.mealsDataArrayForShow[section]as? NSDictionary ?? [:]
            let mealsFoodsArray = mealsFoodsDict["meals"]as? NSArray ?? []
            return mealsFoodsArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PlanDetailFoodsTableViewCell") as? PlanDetailFoodsTableViewCell
        
        if cell == nil{
            cell = PlanDetailFoodsTableViewCell.init(style: .default, reuseIdentifier: "PlanDetailFoodsTableViewCell")
        }
        
        cell?.updateConstrait(isUpdate: self.isUpdate)
        if isUpdate{
            let mealsFoodsArray = self.mealsDataArray[indexPath.section]as? NSArray ?? []
            if mealsFoodsArray.count > 0 {
                let foodsDict = mealsFoodsArray[indexPath.row]as? NSDictionary ?? [:]
                cell?.updateUI(dict: foodsDict)
            }else{
                cell?.updateUIForNoFoods()
            }
        }else{
            let mealsFoodsDict = self.mealsDataArrayForShow[indexPath.section]as? NSDictionary ?? [:]
            let foodsArray = mealsFoodsDict["meals"]as? NSArray ?? []
            let foodsDict = foodsArray[indexPath.row]as? NSDictionary ?? [:]
            cell?.updateUI(dict: foodsDict)
        }
        
        return cell ?? PlanDetailFoodsTableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isUpdate{
            self.selectMealsIndex = indexPath.section
            self.selectFoodsIndex = indexPath.row
            let mealsFoodsArray = self.mealsDataArray[indexPath.section]as? NSArray ?? []
            if mealsFoodsArray.count > 0 {
                let dict = mealsFoodsArray[indexPath.row]as? NSDictionary ?? [:]
                if dict["fname"]as? String ?? "" == "快速添加"{
                    let vc = FoodsCreateFastVC()
                    vc.setNumber(dict: dict)
                    vc.sourceType = .plan_update
                    NotificationCenter.default.addObserver(self, selector: #selector(addFoodsNotifi(notify: )), name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: nil)
                    self.controller.navigationController?.pushViewController(vc, animated: true)
                    return
                }
                
                self.sendFoodsDetailRequest(foodsDict: dict)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(56)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleVm = PlanDetailDayMealsTitleVM.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        titleVm.addBlock = {()in
            NotificationCenter.default.addObserver(self, selector: #selector(self.addFoodsNotifi(notify: )), name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: nil)
            
            self.selectMealsIndex = section
            self.selectFoodsIndex = -1
            let vc = FoodsListNewVC()
            vc.sourceType = .plan_update
            self.controller.navigationController?.pushViewController(vc, animated: true)
        }
        if isUpdate{
            if section == 0 {
                caloriesTotalNum = Float(0)
                carboTotalNum = Float(0)
                proteinTotalNum = Float(0)
                fatTotalNum = Float(0)
            }
            
            let dict = NSMutableDictionary()
            let mealsFoodsArray = self.mealsDataArray[section]as? NSArray ?? []
            if mealsFoodsArray.count > 0 {
                var caloriNum = Float(0)
                
                for j in 0..<mealsFoodsArray.count{
                    let foodsDict = mealsFoodsArray[j]as? NSDictionary ?? [:]
                    
                    caloriNum = caloriNum + Float(foodsDict.doubleValueForKey(key: "calories"))
                    
                    caloriesTotalNum = caloriesTotalNum + Float(foodsDict.doubleValueForKey(key: "calories"))
                    carboTotalNum = carboTotalNum + Float(foodsDict.doubleValueForKey(key: "carbohydrate"))
                    proteinTotalNum = proteinTotalNum + Float(foodsDict.doubleValueForKey(key: "protein"))
                    fatTotalNum = fatTotalNum + Float(foodsDict.doubleValueForKey(key: "fat"))
                }
                titleVm.titleLabel.text = "第\(section+1)餐  \(String(format: "%.0f", caloriNum.rounded()))千卡"
            }else{
                titleVm.titleLabel.text = "第\(section+1)餐"
            }
            titleVm.addFoodsButton.isHidden = false
            
            if section == mealsDataArray.count - 1{
                if self.numberUpdateBlock != nil{
                    self.numberUpdateBlock!(["calories":"\(caloriesTotalNum)",
                                             "carbohydrate":"\(carboTotalNum)",
                                             "protein":"\(proteinTotalNum)",
                                             "fat":"\(fatTotalNum)"])
                }
            }
        }else{
            let dict = self.mealsDataArrayForShow[section]as? NSDictionary ?? [:]
            let mealsFoodsArray = dict["meals"]as? NSArray ?? []
            if mealsFoodsArray.count > 0 {
                var caloriNum = Int(0)
                for j in 0..<mealsFoodsArray.count{
                    let foodsDict = mealsFoodsArray[j]as? NSDictionary ?? [:]
                    
                    caloriNum = caloriNum + Int(foodsDict.doubleValueForKey(key: "calories"))
                }
                titleVm.titleLabel.text = "第\(dict.stringValueForKey(key: "mealsIndex"))餐  \(caloriNum)千卡"
            }else{
                titleVm.titleLabel.text = "第\(dict.stringValueForKey(key: "mealsIndex"))餐"
            }
            titleVm.addFoodsButton.isHidden = true
        }
        return titleVm
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFitWidth(52)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            self.selectMealsIndex = indexPath.section
            self.selectFoodsIndex = indexPath.row
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.deleteFoods()
            self.refresSelfFrame()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isUpdate {
            let mealsFoodsArray = self.mealsDataArray[indexPath.section]as? NSArray ?? []
            if mealsFoodsArray.count > 0 {
                return true
            }else{
                return false
            }
        }else{
            return false
        }
//        return isUpdate
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

extension PlanDetailDayMealsVM{
    func setDataSource(dict:NSDictionary,index:Int) {
        self.sid = dict.stringValueForKey(key: "sid")
        let mealsArray = dict["meals"]as? NSArray ?? []
        if mealsArray.count < 6 {
            self.mealsDataArray = NSMutableArray(array: dict["meals"]as? NSArray ?? [])
//            self.mealsDataArrayForUpdate = NSMutableArray(array: dict["meals"]as? NSArray ?? [])
            for i in self.mealsDataArray.count..<6{
                self.mealsDataArray.add(NSArray())
            }
        }else{
            self.mealsDataArray = NSMutableArray(array: dict["meals"]as? NSArray ?? [])
//            self.mealsDataArrayForUpdate = NSMutableArray(array: dict["meals"]as? NSArray ?? [])
        }
        
        self.dealDataSource()
//        self.tableView.reloadData()
//        self.mealsDataArrayForShow = NSMutableArray()
        /*
        let mealsArray = dict["meals"]as? NSArray ?? []
        
        var originY = kFitWidth(0)
        for i in 0..<mealsArray.count{
            let foodsArray = mealsArray[i]as? NSArray ?? []
            if foodsArray.count > 0 {
//                let titleVm = PlanDetailDayMealsTitleVM.init(frame: CGRect.init(x: 0, y: originY, width: 0, height: 0))
//                addSubview(titleVm)
                originY = originY + PlanDetailDayMealsTitleVM().selfHeight
                
//                var caloriNum = Int(0)
                for j in 0..<foodsArray.count{
                    let foodsDict = foodsArray[j]as? NSDictionary ?? [:]
                    
//                    let foodsVm = PlanDetailDayMealsFoodsVM.init(frame: CGRect.init(x: 0, y: originY, width: 0, height: 0))
//                    addSubview(foodsVm)
                    
//                    foodsVm.updateUI(dict: foodsDict)
                    originY = originY + PlanDetailDayMealsFoodsVM().selfHeight
                    
//                    caloriNum = caloriNum + Int(foodsDict.doubleValueForKey(key: "calories"))
                }
                
//                titleVm.titleLabel.text = "第\(i+1)餐  \(caloriNum)千卡"
            }
        }
        
        selfHeight = originY
        
        let selfFrame = self.frame
        self.frame = CGRect.init(x: selfFrame.origin.x, y: selfFrame.origin.y, width: SCREEN_WIDHT, height: selfHeight)
        
        if self.updateBlock != nil{
            self.updateBlock!(self.selfHeight)
        }
         */
    }
    
    func dealDataSource() {
        let mealsArray = self.mealsDataArray
        self.mealsDataArrayForShow = NSMutableArray()
        
        var originY = kFitWidth(0)
        for i in 0..<mealsArray.count{
            let foodsArray = mealsArray[i]as? NSArray ?? []
            if foodsArray.count > 0 {
                self.mealsDataArrayForShow.add(["mealsIndex":"\(i+1)",
                                                "meals":foodsArray])
                originY = originY + PlanDetailDayMealsTitleVM().selfHeight
                
                for j in 0..<foodsArray.count{
                    originY = originY + PlanDetailDayMealsFoodsVM().selfHeight
                }
            }
        }
        
        selfHeight = originY
        
        let selfFrame = self.frame
        self.frame = CGRect.init(x: selfFrame.origin.x, y: selfFrame.origin.y, width: SCREEN_WIDHT, height: selfHeight)
        self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight)
        self.tableView.reloadData()
        if self.updateBlock != nil{
            self.updateBlock!(self.selfHeight)
        }
    }
    func refresSelfFrame() {
        if self.isUpdate{
            var originY = kFitWidth(0)
            for i in 0..<self.mealsDataArray.count{
                let foodsArray = self.mealsDataArray[i]as? NSArray ?? []
                originY = originY + PlanDetailDayMealsTitleVM().selfHeight
                if foodsArray.count > 0 {
                    for j in 0..<foodsArray.count{
                        originY = originY + PlanDetailDayMealsFoodsVM().selfHeight
                    }
                }else{
                    originY = originY + PlanDetailDayMealsFoodsVM().selfHeight
                }
            }
            selfHeight = originY
        }else{
            var originY = kFitWidth(0)
            for i in 0..<self.mealsDataArrayForShow.count{
                let mealsDict = self.mealsDataArrayForShow[i]as? NSDictionary ?? [:]
                let foodsArray = mealsDict["meals"]as? NSArray ?? []
                if foodsArray.count > 0 {
                    originY = originY + PlanDetailDayMealsTitleVM().selfHeight
                    for j in 0..<foodsArray.count{
                        originY = originY + PlanDetailDayMealsFoodsVM().selfHeight
                    }
                }
            }
            selfHeight = originY
        }
        let selfFrame = self.frame
        self.frame = CGRect.init(x: selfFrame.origin.x, y: selfFrame.origin.y, width: SCREEN_WIDHT, height: selfHeight)
        self.tableView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight)
        self.tableView.reloadData()
        if self.updateBlock != nil{
            self.updateBlock!(self.selfHeight)
        }
    }
    func changeUpdate(isUpdate:Bool) {
        self.isUpdate = isUpdate
        self.refresSelfFrame()
        self.tableView.reloadData()
    }
}

extension PlanDetailDayMealsVM{
    @objc func addFoodsNotifi(notify:Notification) {
        let foodsDict = notify.object ?? [:]
        DLLog(message: "\(foodsDict)")
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
            self.dealFoodsMsg(foodsMsg: foodsDict as! NSDictionary)
//        }
    }
    func dealFoodsMsg(foodsMsg:NSDictionary) {
        let foodsArray = NSMutableArray.init(array: mealsDataArray[self.selectMealsIndex] as? NSArray ?? [])
        
        var hasFoods = false
        
        if selectFoodsIndex == -1 {
            for i in 0..<foodsArray.count{
                let dict = foodsArray[i]as? NSDictionary ?? [:]
                let dictFid = dict["fid"]as? String ?? "\(dict["fid"]as? Int ?? -1)"
                
                if dictFid != "-1" &&  dictFid == foodsMsg["fid"]as? String ?? "\(foodsMsg["fid"]as? Int ?? -2)" && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                    let foodsDict = NSMutableDictionary.init(dictionary: dict)
                    
                    let specNum = foodsMsg["qty"]as? Double ?? 0
                    var dictNum = dict["qty"]as? Double ?? 0
                    if dictNum == 0 {
                        dictNum = ((dict["qty"]as? String ?? "0") as NSString).doubleValue
                    }
                    let num = dictNum + specNum
                    
                    foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                    foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                    
                    let caloriesNumber = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                    let calories = caloriesNumber/specNum * num
                    
                    let calori = calories
                    
//                    let calori = foodsDict.doubleValueForKey(key: "calories") + foodsMsg.doubleValueForKey(key: "caloriesNumber")
                    let carbo = foodsDict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                    let protein = foodsDict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "proteinNumber")
                    let fat = foodsDict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fatNumber")
                    
                    foodsDict.setValue("\(WHUtils.convertStringToString("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                    foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                    foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                    foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                    foodsDict.setValue("\(self.selectMealsIndex+1)", forKey: "sn")
                    
                    foodsArray.replaceObject(at: i, with: foodsDict)
                    hasFoods = true
                    break
                }
            }
            
            if hasFoods == false{
                let dict = NSMutableDictionary(dictionary: foodsMsg)
                dict.setValue("\(self.selectMealsIndex+1)", forKey: "sn")
                foodsArray.add(dict)
            }
        }else{
            for i in 0..<foodsArray.count{
                let dict = foodsArray[i]as? NSDictionary ?? [:]
                
                let dictFid = dict["fid"]as? String ?? "\(dict["fid"]as? Int ?? -1)"
                
                if dictFid != "-1" &&  dictFid == foodsMsg["fid"]as? String ?? "\(foodsMsg["fid"]as? Int ?? -2)" && dict["spec"]as? String ?? "" == foodsMsg["spec"]as? String ?? ""{
                    let foodsDict = NSMutableDictionary.init(dictionary: dict)
                    
                    if self.selectFoodsIndex == i {
                        foodsDict.setValue("\(foodsMsg["qty"]as? Double ?? 0)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                        foodsDict.setValue("\(foodsMsg["qty"]as? Double ?? 0)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                        foodsDict.setValue("\(WHUtils.convertStringToString("\(foodsMsg.doubleValueForKey(key: "caloriesNumber"))") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                        foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "carbohydrateNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                        foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "proteinNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                        foodsDict.setValue("\(foodsMsg.doubleValueForKey(key: "fatNumber"))".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                        dict.setValue("\(self.selectMealsIndex+1)", forKey: "sn")
                        foodsArray.replaceObject(at: i, with: foodsDict)
                    }else{
                        let specNum = foodsMsg["qty"]as? Double ?? 0
                        var dictNum = dict["qty"]as? Double ?? 0
                        if dictNum == 0 {
                            dictNum = ((dict["qty"]as? String ?? "0") as NSString).doubleValue
                        }
                        let num = dictNum + specNum
                        
                        foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "qty")
                        foodsDict.setValue("\(num)".replacingOccurrences(of: ",", with: "."), forKey: "specNum")
                        
                        let caloriesNumber = foodsMsg.doubleValueForKey(key: "caloriesNumber")
                        let calories = caloriesNumber/specNum * num
                        let calori = calories
                        
//                        let calori = foodsDict.doubleValueForKey(key: "calories") + foodsMsg.doubleValueForKey(key: "caloriesNumber")
                        let carbo = foodsDict.doubleValueForKey(key: "carbohydrate") + foodsMsg.doubleValueForKey(key: "carbohydrateNumber")
                        let protein = foodsDict.doubleValueForKey(key: "protein") + foodsMsg.doubleValueForKey(key: "proteinNumber")
                        let fat = foodsDict.doubleValueForKey(key: "fat") + foodsMsg.doubleValueForKey(key: "fatNumber")
                        
                        foodsDict.setValue("\(WHUtils.convertStringToString("\(calori)") ?? "0")".replacingOccurrences(of: ",", with: "."), forKey: "calories")
                        foodsDict.setValue("\(carbo)".replacingOccurrences(of: ",", with: "."), forKey: "carbohydrate")
                        foodsDict.setValue("\(protein)".replacingOccurrences(of: ",", with: "."), forKey: "protein")
                        foodsDict.setValue("\(fat)".replacingOccurrences(of: ",", with: "."), forKey: "fat")
                        dict.setValue("\(self.selectMealsIndex+1)", forKey: "sn")
                        foodsArray.replaceObject(at: i, with: foodsDict)
                        if foodsArray.count > self.selectFoodsIndex {
                            foodsArray.removeObject(at: self.selectFoodsIndex)
                        }
                    }
                    hasFoods = true
                    break
                }
            }
            if hasFoods == false && foodsArray.count > self.selectFoodsIndex && self.selectFoodsIndex >= 0{
                let dict = NSMutableDictionary(dictionary: foodsMsg)
                dict.setValue("\(self.selectMealsIndex+1)", forKey: "sn")
                foodsArray.replaceObject(at: self.selectFoodsIndex, with: dict)
            }
        }
        mealsDataArray.replaceObject(at: self.selectMealsIndex, with: foodsArray)
        self.tableView.reloadData()
        self.refresSelfFrame()
    }
    func deleteFoods() {
        let foodsArray = NSMutableArray.init(array: mealsDataArray[self.selectMealsIndex] as? NSArray ?? [])
        foodsArray.removeObject(at: self.selectFoodsIndex)
        mealsDataArray.replaceObject(at: self.selectMealsIndex, with: foodsArray)
        self.tableView.reloadData()
    }
}

extension PlanDetailDayMealsVM{
    func initUI() {
        addSubview(tableView)
    }
}

extension PlanDetailDayMealsVM{
    func sendFoodsDetailRequest(foodsDict:NSDictionary){
//        MCToast.mc_loading()
        if self.isTapFoodsDetail == true{
            return
        }
        self.isTapFoodsDetail = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.isTapFoodsDetail = false
        })
        let param = ["fid":"\(foodsDict.stringValueForKey(key: "fid"))"]
        
        let vc = FoodsMsgDetailsVC()
        vc.sourceType = .plan_update
        vc.specNum = foodsDict.stringValueForKey(key: "qty")
        vc.specName = foodsDict["spec"]as? String ?? "g"
        vc.confirmButton.setTitle("保存", for: .normal)
        vc.deleteButton.isHidden = true
        
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_query_id, parameters: param as [String : AnyObject],isNeedToast: true,vc: self.controller) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let foodsMsgDict = self.controller.getDictionaryFromJSONString(jsonString: dataString ?? "")
            vc.foodsDetailDict = foodsMsgDict
            DLLog(message: "\(foodsMsgDict)")
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.addFoodsNotifi(notify: )), name: NSNotification.Name(rawValue: "foodsUpdateForPlan"), object: nil)
            self.controller.navigationController?.pushViewController(vc, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                vc.deleteButton.isHidden = true
            })
        }
    }
    
}
