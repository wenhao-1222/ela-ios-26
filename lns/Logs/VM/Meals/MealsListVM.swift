//
//  MealsListVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/22.
//

import Foundation
import UIKit
import UMCommon

class MealsListVM: UIView {
    
    var fname = ""
    var fNameChanged = false
    
    var selfHeight = kFitWidth(119)
    var dataArray = NSMutableArray()
    
    var isFromPlan = false
    var canAdd = true
    var controller = WHBaseViewVC()
    var sourceType = ADD_FOODS_SOURCE.other
    
    var scrollBlock:(()->())?
    var deleteFoodsBlock:((NSDictionary)->())?
    var searchNoDataBlocK:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        selfHeight = SCREEN_HEIGHT-frame.origin.y
        
        initUI()
        sendMyMealsRequest()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendMyMealsRequest), name: NSNotification.Name(rawValue: "mealsSaveSuccess"), object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.selfHeight), style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.register(MealsTableViewCell.classForCoder(), forCellReuseIdentifier: "MealsTableViewCell")
        table.tableHeaderView = UIView()
        
        return table
    }()
    lazy var noDataView : TableViewNoDataVM = {
        let vi = TableViewNoDataVM.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: 0))
        vi.isHidden = true
        return vi
    }()
    lazy var footerVm: FoodsListFooterVM = {
        let vm = FoodsListFooterVM.init(frame: .zero)
        return vm
    }()
}

extension MealsListVM{
    func initUI() {
        addSubview(tableView)
        
        tableView.addSubview(noDataView)
        noDataView.center = CGPoint.init(x: self.tableView.frame.width * 0.5, y: kFitWidth(134))
        
        initSkeletonData()
    }
    func initSkeletonData() {
        dataArray.removeAllObjects()
        dataArray.addObjects(from: [[:],[:],[:],[:],[:],[:],[:],[:]])
        self.tableView.reloadData()
    }
    func searchFoods(fName:String) {
        self.fname = fName
        self.isHidden = false
        self.sendMyMealsRequest()
    }
    func addFoodsToLogs(dict:NSDictionary) {
        let foodsArray = dict["foods"]as? NSArray ?? []
        if self.sourceType == .logs{
            ADD_FOODS_FOR_HEALTHKIT_NATURAL = foodsArray.count
        }
        for i in 0..<foodsArray.count{
            let foodsMsgDict = foodsArray[i]as? NSDictionary ?? [:]
            var foodMsg = NSMutableDictionary.init(dictionary: foodsMsgDict)
            foodMsg.setValue("1", forKey: "state")
            foodMsg.setValue("1", forKey: "select")
            
            if foodsMsgDict.stringValueForKey(key: "fname") == "快速添加"{
                if self.sourceType == .logs{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoods"), object: foodMsg)
                }else if self.sourceType == .plan{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fastAddFoodsForPlan"), object: foodMsg)
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
            if self.sourceType == .logs{
                MobClick.event("journalAddMeals")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForLogs"), object: foodMsg)
            }else if self.sourceType == .plan{
                MobClick.event("planAddMeals")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "foodsAddForPlan"), object: foodMsg)
            }
        }
    }
}

extension MealsListVM:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noDataView.isHidden = dataArray.count > 0 ? true : false
        footerVm.isHidden = dataArray.count == 0 ? true : false
        if dataArray.count == 0 && self.searchNoDataBlocK != nil{
            self.searchNoDataBlocK!()
        }
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealsTableViewCell") as? MealsTableViewCell
        let dict = self.dataArray[indexPath.row]as? NSDictionary ?? [:]

        cell?.updateUI(dict: dict,keywords: self.fname)
        cell?.addButtonVm.tapBlock = {()in
            self.addFoodsToLogs(dict: dict)
        }
        
        cell?.imgTapBlock = {()in
            if dict["image"]as? String ?? "" == "" {
                
            }else{
                let showController = ShowBigImgController(urls: [dict["image"]as? String ?? ""], url: dict["image"]as? String ?? "",isNavi: true)
//                showController.modalPresentationStyle = .overFullScreen
//                self.controller.present(showController, animated: false, completion: nil)
                self.controller.navigationController?.pushViewController(showController, animated: true)
            }
        }
        
        if self.sourceType != .logs && self.sourceType != .plan{
            cell?.addButtonVm.isHidden = true
            cell?.arrowImgView.isHidden = false
            
            cell?.foodsNameLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(81))
                make.top.equalTo(kFitWidth(18))
                make.right.equalTo(kFitWidth(-10))
            }
        }
        
        return cell ?? MealsTableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFitWidth(70)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        TouchGenerator.shared.touchGenerator()
        let vc = MealsDetailsVC()
        vc.sourceType =  self.sourceType
        vc.topImgView.cameraButton.isHidden = true
        self.controller.navigationController?.pushViewController(vc, animated: true)
        vc.setDataSource(dict: self.dataArray[indexPath.row]as? NSDictionary ?? [:])
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let dict = self.dataArray[indexPath.row]as? NSDictionary ?? [:]
            self.controller.presentAlertVc(confirmBtn: "删除", message: "是否删除“\(dict["name"]as? String ?? "")”", title: "温馨提示", cancelBtn: "取消", handler: { action in
                self.sendDeleteFoodsRequest(indexPath:indexPath,foodsMsg: dict)
            }, viewController: self.controller)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.scrollBlock != nil{
            self.scrollBlock!()
        }
    }
}

extension MealsListVM{
    @objc func sendMyMealsRequest() {
        if fNameChanged == true{
            self.dataArray.removeAllObjects()
            self.tableView.reloadData()
            initSkeletonData()
        }
        fNameChanged = false
        
        let param = ["name":"\(fname)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_meals_list, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataArr = WHUtils.getArrayFromJSONString(jsonString: dataString ?? "")
            
//            UserDefaults.set(value: WHUtils.getJSONStringFromArray(array: dataArr), forKey: .myFoodsList)
            DLLog(message: "sendMyMealsRequest:\(dataArr)")
//            DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: {
                self.dataArray = NSMutableArray.init(array: dataArr)
                self.tableView.reloadData()
                if self.dataArray.count > 0{
                    self.tableView.tableFooterView = self.footerVm
                }else{
                    self.tableView.tableFooterView = nil
                }
//            })
        }
    }
    func sendDeleteFoodsRequest(indexPath:IndexPath,foodsMsg:NSDictionary) {
        let param = ["id":"\(foodsMsg.stringValueForKey(key: "id"))"]
        WHNetworkUtil.shareManager().POST(urlString: URL_meals_delete, parameters: param as [String:AnyObject]) { responseObject in
            self.dataArray.removeObject(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            if self.dataArray.count > 0{
                self.tableView.tableFooterView = self.footerVm
            }else{
                self.tableView.tableFooterView = nil
            }
        }
    }
}
