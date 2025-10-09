//
//  JournalFuncCopyMealsAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/18.
//

import Foundation
import UIKit

class JournalFuncCopyMealsAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(256)+WHUtils().getBottomSafeAreaHeight()
    var daysArray = NSArray()
    var tomorrowIndex = 0
    var selectIndex = 0
    var queryDay = ""
    var targetDayMsg = NSDictionary()
    
    var copyBlock:(()->())?
    var updateBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenSelf))
//        self.addGestureRecognizer(tap)
                
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    private lazy var bgView: UIView = {
        let v = UIView(frame: bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 1.0)
        v.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelf))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.addClipCorner(corners: [.topLeft,.topRight], radius: kFitWidth(10))
        vi.backgroundColor = .white
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "date_fliter_cancel_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(hiddenSelf), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "复制所选食物到某餐"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var confirmBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "date_fliter_confirm_img"), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.4), for: .highlighted)
        
        btn.addTarget(self, action: #selector(confirmCopyAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
        return vi
    }()
    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView(frame: CGRect.init(x: 0, y: kFitWidth(50), width: SCREEN_WIDHT, height: kFitWidth(256)))
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    lazy var mealsArray: NSArray = {
        return ["相同餐",
                "第一餐",
                "第二餐",
                "第三餐",
                "第四餐",
                "第五餐",
                "第六餐"]
    }()
    
}

extension JournalFuncCopyMealsAlertVM{
    func showSelf() {
        self.isHidden = false
        bgView.isUserInteractionEnabled = false
        
        // 初态：whiteView 在最终停靠位，先整体下移隐藏；蒙层透明
        whiteView.transform = CGAffineTransform(translationX: 0, y: whiteViewHeight)
        bgView.alpha = 0

        UIView.animate(withDuration: 0.45,
                       delay: 0.02,
                       usingSpringWithDamping: 0.88,
                       initialSpringVelocity: 0.1,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: -kFitWidth(2))
            self.bgView.alpha = 0.25
        } completion: { _ in
            self.bgView.isUserInteractionEnabled = true
            
        }
        UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseInOut) {
            self.whiteView.transform = .identity
        }
        
//        UIView.animate(withDuration: 0.25,delay: 0,options: .curveLinear) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.whiteViewHeight, width: SCREEN_WIDHT, height: self.whiteViewHeight)
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
//        } completion: { t in
////            self.alpha = 1
//        }

    }
    @objc func hiddenSelf() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.whiteView.transform = CGAffineTransform(translationX: 0, y: self.whiteViewHeight)
            self.bgView.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
//        UIView.animate(withDuration: 0.25,delay: 0,options: .curveLinear) {
//            self.whiteView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: self.whiteViewHeight)
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
//        } completion: { t in
////            self.alpha = 0
//            self.isHidden = true
//            self.backgroundColor = .clear
//        }
    }
    func refreshPicker(selectIndex:Int) {
        pickerView.selectRow(0, inComponent: 1, animated: false)
        
        if selectIndex >= self.tomorrowIndex - 1{
            if selectIndex < self.daysArray.count - 1 {
                pickerView.selectRow(selectIndex+1, inComponent: 0, animated: false)
            }else{
                pickerView.selectRow(self.daysArray.count - 1, inComponent: 0, animated: false)
            }
        }else{
            pickerView.selectRow(self.tomorrowIndex - 1, inComponent: 0, animated: false)
        }
        
        queryDay = self.daysArray[self.tomorrowIndex]as? String ?? ""
    }
    @objc func confirmCopyAction() {
        self.hiddenSelf()
        if self.copyBlock != nil{
            self.copyBlock!()
        }
    }
    @objc func nothingToDo() {
        
    }
}
extension JournalFuncCopyMealsAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addShadow()
        
        whiteView.addSubview(cancelBtn)
        whiteView.addSubview(titleLab)
        whiteView.addSubview(confirmBtn)
        whiteView.addSubview(lineView)
        whiteView.addSubview(pickerView)
        
        layoutWhiteViewFrame()
        setConstrait()
        
        // 初始位置放在最终停靠位置，实际展示用 t
    }
    private func layoutWhiteViewFrame() {
        whiteView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - whiteViewHeight, width: SCREEN_WIDHT, height: whiteViewHeight)
        if #available(iOS 13.0, *) { whiteView.layer.cornerCurve = .continuous }
        whiteView.layer.masksToBounds = true
    }
    func setConstrait()  {
        titleLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(48))
        }
        cancelBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(48))
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(cancelBtn)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kFitWidth(48))
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension JournalFuncCopyMealsAlertVM:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return daysArray.count
        }else{
            return mealsArray.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return kFitWidth(45)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 0 {
            let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(160), height: kFitWidth(45)))
            lab.font = .systemFont(ofSize: 20, weight: .regular)
            lab.textAlignment = .center
            
            if row == self.tomorrowIndex - 1{
                lab.text =  "今天"
            }else if row == self.tomorrowIndex{
                lab.text =  "明天"
            }else{
                lab.text =  daysArray[row]as? String ?? ""
            }
            
            setUpPickerStyleRowStyle(row: row, component: component)
            
            return lab
        }else{
            let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(20), y: 0, width: kFitWidth(60), height: kFitWidth(45)))
            lab.text = mealsArray[row]as? String ?? ""
            lab.textAlignment = .center
            lab.adjustsFontSizeToFitWidth = true
            lab.font = .systemFont(ofSize: 20, weight: .regular)
            setUpPickerStyleRowStyle(row: row, component: component)
            
            return lab
        }
    }
    func setUpPickerStyleRowStyle(row:Int,component:Int) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let label = self.pickerView.view(forRow: row, forComponent: component) as? UILabel
            if label != nil{
                label?.textColor = .THEME
            }
        })
    }
}

//MARK: 复制食物的逻辑处理
extension JournalFuncCopyMealsAlertVM{
    func copyFoods(mealsArray:NSArray) {
        //取数据库中，目标日志数据
        selectIndex = self.pickerView.selectedRow(inComponent: 0)
        self.queryDay = self.daysArray[selectIndex]as? String ?? "\(Date().nextDay(days: 0))"
        let logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: self.queryDay)!
        targetDayMsg = logsModel.modelToDict()
        
        if self.pickerView.selectedRow(inComponent: 1) == 0 {
            self.copyFoodsToSameMeals(mealsArray: mealsArray)
        }else{
            self.copyFoodsToMeal(mealsArray: mealsArray, mealIndex: (self.pickerView.selectedRow(inComponent: 1) - 1))
        }
    }
    //MARK: 复制到某一个餐
    private func copyFoodsToMeal(mealsArray:NSArray,mealIndex:Int){
        //取目标日志每餐的食物
        var targetFoodsArray = NSMutableArray(array: targetDayMsg["foods"]as? NSArray ?? [])
        
        if targetFoodsArray.count == 0 {
            targetFoodsArray = [[],[],[],[],[],[]]
        }
        var foodsArray = NSMutableArray()
        for i in 0..<mealsArray.count{
            if let mealsFoodsArray = mealsArray[i]as? NSArray{//判断要复制的某一餐，是否有食物
                for j in 0..<mealsFoodsArray.count{
                    let dict = NSMutableDictionary(dictionary: mealsFoodsArray[j]as? NSDictionary ?? [:])
                    dict.setValue("\(mealIndex+1)", forKey: "sn")
                    foodsArray.add(dict)
                }
//                foodsArray.addObjects(from: mealsFoodsArray as! [Any])
            }
        }
        if targetFoodsArray.count > 0 && targetFoodsArray.count >= mealIndex{
            let targetDayMealsArray = targetFoodsArray[mealIndex]as? NSArray ?? []
            let array = self.dealTargetMealFoods(foodsArray: foodsArray, targetFoodsArray: targetDayMealsArray)
            targetFoodsArray.replaceObject(at: mealIndex, with: array)
        }else{
            targetFoodsArray.replaceObject(at: mealIndex, with: foodsArray)
        }
        
        DLLog(message: "copyFoodsToMeal:\(queryDay)")
        DLLog(message: "copyFoodsToMeal:\(targetFoodsArray)")
        
        saveDataToSqlDB(mealsArr: targetFoodsArray)
    }
    //MARK: 复制到相同餐
    private func copyFoodsToSameMeals(mealsArray:NSArray) {
        //取目标日志每餐的食物
        var targetFoodsArray = NSMutableArray(array: targetDayMsg["foods"]as? NSArray ?? [])
        
        if targetFoodsArray.count == 0 {
            targetFoodsArray = [[],[],[],[],[],[]]
        }
        
        for i in 0..<mealsArray.count{
            if let mealsFoodsArray = mealsArray[i]as? NSArray{//判断要复制的某一餐，是否有食物
                if targetFoodsArray.count > 0 && targetFoodsArray.count >= i{
                    let targetDayMealsArray = targetFoodsArray[i]as? NSArray ?? []
                    
//                    if targetDayMealsArray.count > 0 {
                        let array = self.dealTargetMealFoods(foodsArray: mealsFoodsArray, targetFoodsArray: targetDayMealsArray)
                        targetFoodsArray.replaceObject(at: i, with: array)
//                    }else{
//                        targetFoodsArray.replaceObject(at: i, with: mealsFoodsArray)
//                    }
                }else{
                    targetFoodsArray.replaceObject(at: i, with: mealsFoodsArray)
                }
            }
        }
        
        DLLog(message: "copyFoodsToSameMeals:\(queryDay)")
        DLLog(message: "copyFoodsToSameMeals:\(targetFoodsArray)")
        
        saveDataToSqlDB(mealsArr: targetFoodsArray)
    }
    
    //处理目标餐的食物
    private func dealTargetMealFoods(foodsArray:NSArray,targetFoodsArray:NSArray) -> NSArray{
        let resultFoodsArray = NSMutableArray.init(array: targetFoodsArray)
        for i in 0..<foodsArray.count{
            let dict = NSMutableDictionary(dictionary: foodsArray[i]as? NSDictionary ?? [:])
            //如果食物是选中状态
            if dict.stringValueForKey(key: "isSelect") == "1"{
                let dictFid = dict.stringValueForKey(key: "fid")
                var hasSameFoods = false
                for j in 0..<resultFoodsArray.count{
                    let foodsMsg = resultFoodsArray[j]as? NSDictionary ?? [:]
                    
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
                        
                        resultFoodsArray.replaceObject(at: j, with: foodsDict)
                        break
                    }
                }
                
                if hasSameFoods == false{
                    let foodsDict = NSMutableDictionary.init(dictionary: dict)
                    foodsDict.setValue("1", forKey: "state")
                    foodsDict.setValue("0", forKey: "isSelect")
                    resultFoodsArray.add(foodsDict)
                }
            }
        }
        return resultFoodsArray
    }
    func saveDataToSqlDB(mealsArr:NSArray){
        DispatchQueue.global(qos: .userInitiated).async {
            var caloriTotal = Double(0)
            var carboTotal = Double(0)
            var proteinTotal = Double(0)
            var fatTotal = Double(0)
            
            for i in 0..<mealsArr.count{
                let mealPerArr = mealsArr[i]as? NSArray ?? []
                for j in 0..<mealPerArr.count{
                    let dictTemp = mealPerArr[j]as? NSDictionary ?? [:]
                    if dictTemp.stringValueForKey(key: "state") == "1"{
                        let calori = dictTemp.doubleValueForKey(key: "calories")
                        let carbohydrate = dictTemp.doubleValueForKey(key: "carbohydrate")
                        let protein = dictTemp.doubleValueForKey(key: "protein")
                        let fat = dictTemp.doubleValueForKey(key: "fat")
                        
                        caloriTotal = caloriTotal + calori
                        carboTotal = carboTotal + carbohydrate
                        proteinTotal = proteinTotal + protein
                        fatTotal = fatTotal + fat
                    }
                }
            }
            
            caloriTotal = String(format: "%.0f", caloriTotal.rounded()).doubleValue
            carboTotal = String(format: "%.0f", carboTotal.rounded()).doubleValue
            proteinTotal = String(format: "%.0f", proteinTotal.rounded()).doubleValue
            fatTotal = String(format: "%.0f", fatTotal.rounded()).doubleValue
            
//            let dictTemp = ["sdate":"\(self.queryDay)",
//                            "notes":self.targetDayMsg.stringValueForKey(key: "notes"),
//                            "totalProteins":String(format: "%.0f", proteinTotal).intValue,
//                            "totalCarbohydrates":String(format: "%.0f", carboTotal).intValue,
//                            "totalFats":String(format: "%.0f", fatTotal).intValue,
//                            "totalCalories":String(format: "%.0f", caloriTotal).intValue,
//                            "meals":"\(WHUtils.getJSONStringFromArray(array: mealsArr))"]
            
            LogsSQLiteManager.getInstance().updateLogs(sDate: self.queryDay,
                                                       eTime: Date().currentSeconds,
                                                       foods: WHUtils.getJSONStringFromArray(array: mealsArr),
                                                       caloriNum: "\(caloriTotal)",
                                                       proteinNum: "\(proteinTotal)",
                                                       carboNum: "\(carboTotal)",
                                                       fatsNum: "\(fatTotal)")
            LogsSQLiteManager.getInstance().updateMealsTime(foodsArray: mealsArr, sDate: self.queryDay)
            LogsSQLiteManager.getInstance().updateUploadStatus(sDate: self.queryDay, update: false)
            LogsSQLiteUploadManager().uploadLogsBySDate(sdate: self.queryDay)
            LogsMealsAlertSetManage().refreshClockAlertMsg()
//            LogsSQLiteUploadManager().sendUpdateLogsMealsTimeRequest(sDate: self.queryDay)
            if self.updateBlock != nil{
                self.updateBlock!()
            }
        }
    }
}
