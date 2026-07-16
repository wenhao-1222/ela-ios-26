//
//  FoodsCreateVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import MCToast
import IQKeyboardManagerSwift
import UMCommon

class FoodsCreateVC: WHBaseViewVC {

    var carNumber = Float(0)
    var proteinNumber = Float(0)
    var fatNumber = Float(0)
    private var isMoreDataExpanded = false
    private var isKeyboardShowing = false
    private var moreDataContentBottomY: CGFloat = 0
    private var nutritionInputValues: [String: String] = [:]
    private let nutritionCatalogItems = FoodsNutritionCatalog.shared.createInputItems

    var addBlock:(()->())?
    var specArray = ["克"]
    var isEditFoods = false
    var editFoodsDict = NSDictionary()
    var editSuccessBlock:((NSDictionary)->())?

    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
        MobClick.beginLogPageView("创建食物")
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        MobClick.beginLogPageView("创建食物")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        sendSpecEnumRequest()
    }
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true

        return vi
    }()
    lazy var contentScrollView: UIScrollView = {
        let scroll = UIScrollView(frame: CGRect(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        scroll.backgroundColor = .COLOR_CARD_BG_WHITE
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.keyboardDismissMode = .interactive
        return scroll
    }()
    lazy var moreDataVm: UIView = {
        let vi = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(56)))
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(moreDataTapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var moreDataTitleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "更多数据"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_60
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        return lab
    }()
    lazy var moreDataArrowImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.setImgLocal(imgName: "arrow_down_icon")
        return img
    }()
    lazy var moreDataLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0
        return vi
    }()
    lazy var nutritionInputVms: [FoodsCreateItemVM] = {
        return nutritionCatalogItems.map { item in
            let vm = FoodsCreateItemVM(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            vm.titleLabel.text = item.title
            vm.unitLab.text = item.unit
            vm.textField.placeholder = "选填"
            vm.configureNutritionInputAccessory(title: item.title)
            vm.maxLength = 6
            vm.maximumValue = item.maximumInputValue.map { Float($0) }
            vm.maximumFractionDigits = item.maximumInputFractionDigits
            vm.isHidden = true
            vm.numberChangeBlock = { [weak self] number in
                guard let self = self else { return }
                let normalizedNumber = number.replacingOccurrences(of: ",", with: ".")
                if normalizedNumber.count == 0 {
                    self.nutritionInputValues.removeValue(forKey: item.key)
                } else {
                    self.nutritionInputValues[item.key] = normalizedNumber
                }
                self.refreshSaveButtonState()
            }
            return vm
        }
    }()
    lazy var foodsNameVm : FoodsCreateNameVM = {
        let vm = FoodsCreateNameVM.init(frame: CGRect.init(x: 0, y: kFitWidth(12), width: 0, height: 0))

        vm.numberChangeBlock = {(number)in

            self.refreshSaveButtonState(foodNameText: number)
        }
        return vm
    }()
    lazy var specVm : FoodsCreateSpecVM = {
        let vm = FoodsCreateSpecVM.init(frame: CGRect.init(x: 0, y: self.foodsNameVm.frame.maxY, width: 0, height: 0))
        vm.specBlock = {()in
            self.resignAllInputResponders()
            self.specAlertVm.showView()
        }
        return vm
    }()
    lazy var caloriVm : FoodsCreateCaloriVM = {
        let vm = FoodsCreateCaloriVM.init(frame: CGRect.init(x: 0, y: kFitWidth(163), width: 0, height: 0))
//        vm.numberLabel.isEnabled = false
        vm.numberChangeBlock = {(number)in
            DLLog(message: "热量数值输入：\(number)")
            self.judgeCaloriNum(caloriesNum: number)
            if number.count == 0 && self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
                self.caloriVm.numberLabel.text = ""
            }
            self.refreshSaveButtonState(caloriesText: number)
        }
        return vm
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: caloriVm.frame.maxY, width: SCREEN_WIDHT-kFitWidth(32), height: kFitWidth(40)))
        lab.text = "热量与营养素相差较大，建议核对数值/单位"
        lab.textColor = .COLOR_TIPS
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.alpha = 0
        lab.adjustsFontSizeToFitWidth = true

        return lab
    }()
    lazy var carboVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(232), width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        vm.maxLength = 4
        vm.configureNutritionInputAccessory(title: "碳水")
        vm.numberChangeBlock = {(number)in
            if let num = Float(number){
                self.carNumber = Float(number) ?? 0.0
            }else{
                self.carNumber = 0
                self.carboVm.textField.text = ""
            }
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.carboVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.maxLength = 4
        vm.configureNutritionInputAccessory(title: "蛋白质")
        vm.numberChangeBlock = {(number)in
            if let num = Float(number){
                self.proteinNumber = Float(number) ?? 0.0
            }else{
                self.proteinNumber = 0
                self.proteinVm.textField.text = ""
            }
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.proteinVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "脂肪"
        vm.maxLength = 4
        vm.configureNutritionInputAccessory(title: "脂肪")
        vm.numberChangeBlock = {(number)in
            if let num = Float(number){
                self.fatNumber = Float(number) ?? 0.0
            }else{
                self.fatNumber = 0
                self.fatVm.textField.text = ""
            }
            self.calculateNumber()
        }
        return vm
    }()
    lazy var saveButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.frame = CGRect.init(x: kFitWidth(20), y: SCREEN_HEIGHT-kFitWidth(60)-getBottomSafeAreaHeight(), width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(48))
        btn.backgroundColor = .THEME
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.isEnabled = false
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)

        return btn
    }()
    lazy var specAlertVm: FoodsCreateSpecAlertVM = {
        let vm = FoodsCreateSpecAlertVM.init(frame: .zero)
        vm.confirmBlock = {(spec)in
            self.specVm.specName = "\(spec)"
            self.specVm.updateButton()
        }
        return vm
    }()
}

extension FoodsCreateVC{
    @objc func saveAction(){
        let nameString = foodsNameVm.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if nameString == "" {
            MCToast.mc_text("请输入食物名称")
            return
        }
        if self.foodsNameVm.textField.text?.count ?? 0 > 30{
            MCToast.mc_text("食物名称不能超过30个字符")
            return
        }
        let number = self.specVm.numberTextField.text ?? ""
        if number.isNumber() == false{
            self.presentAlertVcNoAction(title: "请输入正确的规格数量", viewController: self)
            return
        }
        if number.count == 0 || number.floatValue == 0{
            MCToast.mc_text("请输入食物规格数量")
            return
        }

        if ("\(self.carNumber)").isNumber() == false{
            self.presentAlertVcNoAction(title: "请输入正确的碳水数量", viewController: self)
            return
        }
        if ("\(self.proteinNumber)").isNumber() == false{
            self.presentAlertVcNoAction(title: "请输入正确的蛋白质数量", viewController: self)
            return
        }
        if ("\(self.fatNumber)").isNumber() == false{
            self.presentAlertVcNoAction(title: "请输入正确的脂肪数量", viewController: self)
            return
        }
        for (index, item) in nutritionCatalogItems.enumerated() {
            guard let inputValue = nutritionInputValue(at: index, item: item), inputValue.count > 0 else { continue }
            guard let doubleValue = Double(inputValue), doubleValue >= item.minimumInputValue else {
                self.presentAlertVcNoAction(title: "请输入正确的\(item.title)数量", viewController: self)
                return
            }
            if let maximumInputValue = item.maximumInputValue, doubleValue > maximumInputValue {
                self.presentAlertVcNoAction(title: "\(item.title)不能超过\(WHUtils.convertStringToString("\(maximumInputValue)") ?? "\(maximumInputValue)")\(item.unit)", viewController: self)
                return
            }
        }
//        if self.specVm.specName == "克" && Int32(self.carNumber + self.proteinNumber + self.fatNumber) > (self.specVm.numberTextField.text! as NSString).intValue{
//            MCToast.mc_text("蛋白质+脂肪+碳水 不能超过\(self.specVm.numberTextField.text ?? "100")g")
//            return
//        }
        MobClick.event("createFoods")
        sendAddFoodsRequest()
    }
    func calculateNumber() {
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            caloriVm.numberLabel.text = ""
        }
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9

        if caloriVm.unit == "kcal"{
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(number.rounded())") ?? "")"
            self.judgeCaloriNum(caloriesNum: "\(number)")
        }else{
            let numberKj = number * 4.18585
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(numberKj.rounded())") ?? "")"
            self.judgeCaloriNum(caloriesNum: "\(numberKj)")
        }
        refreshSaveButtonState()
    }
    //用户输入的卡路里 如果小于计算值的70% 或 大于计算值的130%，且两者绝对值超过20千卡时，提示用户
    func judgeCaloriNum(caloriesNum:String) {
        var caloNumTemp = (proteinNumber + carNumber) * 4 + fatNumber * 9
        if caloriVm.unit == "kcal"{

        }else{
            caloNumTemp = caloNumTemp * 4.18585
        }

        var carboCenterY = kFitWidth(232) + self.carboVm.selfHeight*0.5
        if (caloriesNum.floatValue < caloNumTemp * 0.7 || caloriesNum.floatValue > caloNumTemp * 1.3) && abs(caloriesNum.floatValue - caloNumTemp) > 20{
            carboCenterY = self.tipsLabel.frame.maxY + self.carboVm.selfHeight*0.5
            UIView.animate(withDuration: 0.35, animations: {
                self.tipsLabel.alpha = 1
            })
        }else{
            UIView.animate(withDuration: 0.25, animations: {
                self.tipsLabel.alpha = 0
            })
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.carboVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: carboCenterY)
            self.proteinVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: carboCenterY+self.carboVm.selfHeight)
            self.fatVm.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: carboCenterY+self.carboVm.selfHeight*2)
            self.layoutMoreDataViews()
        })
    }

    @objc func moreDataTapAction() {
        resignAllInputResponders()
        isMoreDataExpanded.toggle()
        moreDataArrowImageView.setImgLocal(imgName: isMoreDataExpanded ? "arrow_up_icon" : "arrow_down_icon")
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState]) {
            self.layoutMoreDataViews()
        }
    }

    func layoutMoreDataViews() {
        moreDataVm.frame = CGRect(x: 0, y: fatVm.frame.maxY, width: SCREEN_WIDHT, height: kFitWidth(56))

        var nextY = moreDataVm.frame.maxY
        for vm in nutritionInputVms {
            vm.isHidden = !isMoreDataExpanded
            vm.frame = CGRect(x: 0, y: nextY, width: SCREEN_WIDHT, height: vm.selfHeight)
            if isMoreDataExpanded {
                nextY = vm.frame.maxY
            }
        }

        moreDataContentBottomY = nextY
        updateContentScrollSize()
    }

    private func updateContentScrollSize() {
        let bottomGap = kFitWidth(132) + getBottomSafeAreaHeight()
        let keyboardBottomGap: CGFloat = contentScrollView.contentInset.bottom > 0 ? kFitWidth(1) : 0
        let contentBottomGap = isKeyboardShowing ? keyboardBottomGap : bottomGap
        contentScrollView.contentSize = CGSize(width: SCREEN_WIDHT, height: moreDataContentBottomY + contentBottomGap)
    }

    func resignAllInputResponders() {
        foodsNameVm.textField.resignFirstResponder()
        specVm.numberTextField.resignFirstResponder()
        caloriVm.numberLabel.resignFirstResponder()
        carboVm.textField.resignFirstResponder()
        proteinVm.textField.resignFirstResponder()
        fatVm.textField.resignFirstResponder()
        nutritionInputVms.forEach { $0.textField.resignFirstResponder() }
    }

    func refreshSaveButtonState(foodNameText: String? = nil, caloriesText: String? = nil) {
        let foodName = (foodNameText ?? foodsNameVm.textField.text ?? "").replacingOccurrences(of: " ", with: "")
        let calories = caloriesText ?? caloriVm.numberLabel.text ?? ""
        let hasBaseNutrition = carNumber > 0 || proteinNumber > 0 || fatNumber > 0
        let hasCalories = calories.floatValue > 0
        let hasMoreNutrition = nutritionInputValues.values.contains { $0.floatValue > 0 }
        saveButton.isEnabled = foodName.count > 0 && (hasBaseNutrition || hasCalories || hasMoreNutrition)
    }
}

extension FoodsCreateVC{
    func initUI() {
        initNavi(titleStr: isEditFoods ? "编辑食物" : "创建食物")

        view.insertSubview(bottomView, belowSubview: self.navigationView)

        bottomView.addSubview(contentScrollView)
        contentScrollView.addSubview(foodsNameVm)
        contentScrollView.addSubview(specVm)
        contentScrollView.addSubview(caloriVm)
        contentScrollView.addSubview(tipsLabel)
        contentScrollView.addSubview(proteinVm)
        contentScrollView.addSubview(fatVm)
        contentScrollView.addSubview(carboVm)
        contentScrollView.addSubview(moreDataVm)
        moreDataVm.addSubview(moreDataTitleLabel)
        moreDataVm.addSubview(moreDataArrowImageView)
        moreDataVm.addSubview(moreDataLineView)
        nutritionInputVms.forEach { contentScrollView.addSubview($0) }
        bottomView.addSubview(saveButton)

        bottomView.addSubview(specAlertVm)
        setMoreDataConstraints()
        layoutMoreDataViews()

        fillEditFoodsDataIfNeeded()
    }

    func setMoreDataConstraints() {
        moreDataTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.equalToSuperview()
        }
        moreDataArrowImageView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.equalToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
        moreDataLineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }

    func fillEditFoodsDataIfNeeded() {
        guard isEditFoods else { return }

        let defaultSpecDict = getDefaultSpecDictFromEditFoods()
        foodsNameVm.textField.text = editFoodsDict.stringValueForKey(key: "fname")
        var specName = editFoodsDict.stringValueForKey(key: "specName")
        if specName.count == 0 {
            specName = defaultSpecDict.stringValueForKey(key: "specName")
        }
        if specName.count == 0 {
            let specString = editFoodsDict.stringValueForKey(key: "spec")
            let trimSpecString = specString.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimSpecString.hasPrefix("{") == false && trimSpecString.hasPrefix("[") == false {
                specName = specString
            }
        }
        specVm.specName = specName
        if specVm.specName.count == 0 {
            specVm.specName = "克"
        }
        specVm.numberInput = true
        var specNum = editFoodsDict.stringValueForKey(key: "specNum")
        if specNum.count == 0 {
            specNum = defaultSpecDict.stringValueForKey(key: "specNum")
        }
        if specNum.count == 0 {
            specNum = editFoodsDict.stringValueForKey(key: "qty")
        }
        specVm.numberTextField.text = specNum.count > 0 ? specNum : "100"
        specVm.updateButtonForAi()

        carNumber = editFoodsDict.stringValueForKey(key: "carbohydrate").floatValue
        proteinNumber = editFoodsDict.stringValueForKey(key: "protein").floatValue
        fatNumber = editFoodsDict.stringValueForKey(key: "fat").floatValue
        caloriVm.numberLabel.text = editFoodsDict.stringValueForKey(key: "calories")
        carboVm.textField.text = WHUtils.convertStringToString("\(carNumber)") ?? ""
        proteinVm.textField.text = WHUtils.convertStringToString("\(proteinNumber)") ?? ""
        fatVm.textField.text = WHUtils.convertStringToString("\(fatNumber)") ?? ""
        fillNutritionInputDataFromEditFoods()
        saveButton.isEnabled = true
    }

    private func fillNutritionInputDataFromEditFoods() {
        for (index, item) in nutritionCatalogItems.enumerated() {
            guard index < nutritionInputVms.count else { continue }
            let rawValue = editFoodsDict.stringValueForKey(key: item.key)
            guard rawValue.count > 0, rawValue != "0" else { continue }
            let displayValue = WHUtils.convertStringToString(rawValue, digitNumer: item.maximumInputFractionDigits) ?? rawValue
            nutritionInputVms[index].textField.text = displayValue
            nutritionInputValues[item.key] = displayValue.replacingOccurrences(of: ",", with: ".")
        }
    }

    private func getDefaultSpecDictFromEditFoods() -> NSDictionary {
        if let specDict = editFoodsDict["spec"] as? NSDictionary {
            return specDict
        }

        let specString = editFoodsDict.stringValueForKey(key: "spec")
        guard specString.count > 0,
              let jsonData = specString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) else {
            return [:]
        }

        if let specDict = jsonObject as? NSDictionary {
            return specDict
        }
        if let specArray = jsonObject as? NSArray,
           let specDict = specArray.firstObject as? NSDictionary {
            return specDict
        }
        return [:]
    }
}

extension FoodsCreateVC{
    func sendAddFoodsRequest() {
        MCToast.mc_loading(text: isEditFoods ? "食物保存中..." : "食物创建中...")
        let spec = [["specNum":"\(self.specVm.numberTextField.text ?? "1")",
                     "specName":"\(self.specVm.specName)"]]
        var calories = self.caloriVm.numberLabel.text

        if calories == "" {
            calories = "0"
        }
        if self.caloriVm.unit == "kj"{
            let caloriesFLoat = (calories?.floatValue ?? 0)/4.18585
            calories = "\(WHUtils.convertStringToString("\(caloriesFLoat.rounded())") ?? "0")"
        }
        let param = ["fname":"\(foodsNameVm.textField.text ?? "".trimmingCharacters(in: .whitespacesAndNewlines))",
                     "calories":"\(calories ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "protein":"\(WHUtils.convertStringToString("\(self.proteinNumber)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "fat":"\(WHUtils.convertStringToString("\(self.fatNumber)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "carbohydrate":"\(WHUtils.convertStringToString("\(self.carNumber)") ?? "0")".replacingOccurrences(of: ",", with: "."),
                     "spec":self.getJSONStringFromArray(array: spec as NSArray)] as NSMutableDictionary
        appendNutritionInputValues(to: param)
        if isEditFoods {
            param.setValue(editFoodsDict.stringValueForKey(key: "fid"), forKey: "fid")
        }
        WHNetworkUtil.shareManager().POST(urlString: URL_foods_save, parameters: param as? [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: "\(responseObject)")
            MCToast.mc_text("“\(self.foodsNameVm.textField.text ?? "")”\(self.isEditFoods ? "保存" : "创建")成功",respond: .allow)

            let dataStrig = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")

            let fid = self.isEditFoods ? self.editFoodsDict.stringValueForKey(key: "fid") : "\(dataStrig ?? "")"
            param.setValue(fid, forKey: "fid")
            param.setValue("\(self.specVm.specName)", forKey: "specName")
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "specNum")
            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "qty")
            if self.isEditFoods {
                UserDefaults.delFoods(foodsDict: self.editFoodsDict, forKey: .myFoodsList)
                UserDefaults.delFoods(foodsDict: self.editFoodsDict, forKey: .hidsoryFoodsAdd)
            }
            UserDefaults.saveFoods(foodsDict: param as NSDictionary,forKey: .myFoodsList)
//            WHUtils().sendAddFoodsForCountRequest(fids: ["\(dataStrig ?? "")"])

            param.setValue("\(self.specVm.specName)", forKey: "spec")
//            param.setValue("\(self.specVm.numberTextField.text ?? "1")", forKey: "qty")
            WHUtils().sendAddHistoryFoods(foodsMsgArray: [param])
            if self.isEditFoods {
                self.editSuccessBlock?(param)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createFoodsSuccess"), object: nil)
                self.backTapAction()
                return
            }
            if self.addBlock != nil{
                self.addBlock!()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createFoodsSuccess"), object: nil)
            self.backTapAction()
        }
    }

    private func appendNutritionInputValues(to param: NSMutableDictionary) {
        for (index, item) in nutritionCatalogItems.enumerated() {
            guard let inputValue = nutritionInputValue(at: index, item: item), inputValue.count > 0 else { continue }
            let formattedValue = WHUtils.convertStringToString(inputValue, digitNumer: item.maximumInputFractionDigits) ?? inputValue
            param.setValue(formattedValue.replacingOccurrences(of: ",", with: "."), forKey: item.key)
        }
    }

    private func nutritionInputValue(at index: Int, item: FoodsNutritionCatalog.Item) -> String? {
        let textFieldValue: String
        if index < nutritionInputVms.count {
            textFieldValue = nutritionInputVms[index].textField.text ?? ""
        } else {
            textFieldValue = nutritionInputValues[item.key] ?? ""
        }
        let normalizedValue = textFieldValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        if normalizedValue.count == 0 {
            nutritionInputValues.removeValue(forKey: item.key)
            return nil
        }
        nutritionInputValues[item.key] = normalizedValue
        return normalizedValue
    }

    func sendSpecEnumRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_foods_spec_enum) { responseObject in
//            let dict = responseObject["data"]as? NSDictionary ?? [:]

            let dataObj = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            DLLog(message: "\(dataObj ?? "")")
            let arr = self.getArrayFromJSONString(jsonString: dataObj ?? "[]")
            if arr.count > 0 {
                self.specArray = arr as! [String]
            }else{
                self.specArray = ["克"]
            }
//            self.specArray = responseObject["data"]as? [String] ?? ["克"]
//            self.specArray = arr
            self.specAlertVm.setSpecArr(arr: self.specArray)
        }
    }
}

extension FoodsCreateVC{
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        isKeyboardShowing = true
        let keyboardObscuredHeight = keyboardSize.size.height + activeInputAccessoryHeight()
        contentScrollView.contentInset.bottom = keyboardObscuredHeight + kFitWidth(16)
        contentScrollView.scrollIndicatorInsets = contentScrollView.contentInset
        updateContentScrollSize()

        guard let activeInputView = activeInputView() else { return }
        let activeFrame = activeInputView.convert(activeInputView.bounds, to: contentScrollView)
        let visibleHeight = SCREEN_HEIGHT - keyboardObscuredHeight - getBottomSafeAreaHeight()
        let targetBottom = activeFrame.maxY + kFitWidth(16)
        if targetBottom > contentScrollView.contentOffset.y + visibleHeight {
            let keyboardContentBottomY = max(moreDataContentBottomY, activeFrame.maxY) + kFitWidth(16)
            let maxOffsetY = max(keyboardContentBottomY - visibleHeight, 0)
            let offsetY = min(targetBottom - visibleHeight, maxOffsetY)
            contentScrollView.setContentOffset(CGPoint(x: 0, y: max(offsetY, 0)), animated: true)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboardShowing = false
        contentScrollView.contentInset.bottom = 0
        contentScrollView.scrollIndicatorInsets = .zero
        updateContentScrollSize()
    }

    private func activeInputView() -> UIView? {
        if foodsNameVm.textField.isEditing { return foodsNameVm }
        if specVm.numberTextField.isEditing { return specVm }
        if caloriVm.numberLabel.isEditing { return caloriVm }
        if carboVm.textField.isEditing { return carboVm }
        if proteinVm.textField.isEditing { return proteinVm }
        if fatVm.textField.isEditing { return fatVm }
        return nutritionInputVms.first { $0.textField.isEditing }
    }

    private func activeInputAccessoryHeight() -> CGFloat {
        if carboVm.textField.isEditing || proteinVm.textField.isEditing || fatVm.textField.isEditing {
            return NutritionInputAccessoryView.preferredHeight
        }
        if nutritionInputVms.contains(where: { $0.textField.isEditing }) {
            return NutritionInputAccessoryView.preferredHeight
        }
        return 0
    }
}
