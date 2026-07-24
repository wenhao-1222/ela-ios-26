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
    var canEdit = true
    var isFromDetail = false
    var sourceType = ADD_FOODS_SOURCE.other
    private var hasLoadedFoodsDetail = false

    var deleteBlock:(()->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        sendFoodsDetailRequest()
    }
    lazy var editButton : GJVerButton = {
        let button = GJVerButton()
        button.setImage(UIImage(named: "element_edit_icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
//        button.contentEdgeInsets = UIEdgeInsets(top: kFitWidth(7), left: kFitWidth(7), bottom: kFitWidth(7), right: kFitWidth(7))
        button.isHidden = true
        button.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        button.enablePressEffect()
        return button
    }()
    lazy var deleteButton : GJVerButton = {
        let button = GJVerButton()
        button.setImage(UIImage(named: "element_delete_icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
//        button.contentEdgeInsets = UIEdgeInsets(top: kFitWidth(7), left: kFitWidth(7), bottom: kFitWidth(7), right: kFitWidth(7))
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        button.enablePressEffect()
        return button
    }()
    lazy var foodsNameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        if self.foodsDetailDict["verified"]as? String ?? "\(self.foodsDetailDict["verified"]as? Int ?? 0)" == "1"{
            let img = UIImage(named: "question_foods_verify_icon")
            lab.attributedText = createAttributedStringWithImage(image: img!, text: "\(foodsDetailDict["fname"]as? String ?? "")")
        }else{
            lab.text = "\(foodsDetailDict["fname"]as? String ?? "")"
        }


        return lab
    }()
    lazy var scrollView: UIScrollView = {
        let scro = UIScrollView()
        scro.backgroundColor = .clear
        scro.showsVerticalScrollIndicator = false
        scro.keyboardDismissMode = .onDrag
        return scro
    }()
    lazy var contentView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        return vi
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
        let vm = FoodsMsgDetailsVM.init(frame: CGRect.init(x: 0, y: kFitWidth(60), width: 0, height: 0))
        vm.specNum = self.specNum
        vm.specName = self.specName
        vm.foodsMsgDict = self.foodsDetailDict
        vm.specTapBlock = {()in
            self.specAlertVm.showSelf()
            self.topVm.textField.resignFirstResponder()
        }
        vm.changeBlock = { [weak self] dict in
//            DLLog(message: "changeBlock:\(dict)")
//            self.caloriDetailVm.updateUI(dict: dict)
            self?.refreshScaledNutritionDetails(countString: dict.stringValueForKey(key: "countString"))
        }
        return vm
    }()
    lazy var caloriDetailVm: FoodsDetailCaloriVM = {
        let vm = FoodsDetailCaloriVM.init(frame: CGRect.init(x: 0, y: self.topVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.calculatePercent(dict: self.foodsDetailDict)
        return vm
    }()
    lazy var nutritionDetailVm: FoodsNutritionDetailsVM = {
        let vm = FoodsNutritionDetailsVM.init(frame: CGRect.init(x: 0, y: self.caloriDetailVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.foodsDetailDict = self.foodsDetailDict
        vm.detailTapBlock = { [weak self] in
            self?.showTodayNutritionReportAction()
        }
        vm.heightChangeBlock = { [weak self] in
            self?.refreshScrollContentSize(animated: true)
        }
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
        applyScaledNutritionDetails(to: foodMsg, countString: number)

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
    func applyScaledNutritionDetails(to foodMsg: NSMutableDictionary, countString: String) {
        guard let scaleDecimal = nutritionDetailScaleDecimal(countString: countString) else { return }

        for item in FoodsNutritionCatalog.shared.flatItems {
            let rawValue = self.foodsDetailDict[item.key]
            guard rawValue != nil, !(rawValue is NSNull) else { continue }

            let baseDecimal = decimalValue(rawValue)
            let scaledDecimal = baseDecimal * scaleDecimal
            let scaledString = WHUtils.convertStringToString(
                NSDecimalNumber(decimal: scaledDecimal).stringValue,
                digitNumer: item.maximumInputFractionDigits
            ) ?? "0"
            foodMsg.setValue(scaledString.replacingOccurrences(of: ",", with: "."), forKey: item.key)
        }
    }

    func refreshScaledNutritionDetails(countString: String) {
        let scaledFoodDetailDict = NSMutableDictionary(dictionary: foodsDetailDict)
        applyScaledNutritionDetails(to: scaledFoodDetailDict, countString: countString)
        nutritionDetailVm.foodsDetailDict = scaledFoodDetailDict
    }

    func nutritionDetailScaleDecimal(countString: String) -> Decimal? {
        let normalizedCountString = countString.replacingOccurrences(of: ",", with: ".")
        let countDecimal = Decimal(string: normalizedCountString) ?? 0
        let specDefault = WHUtils.getSpecDefaultFromFoods(foodsDict: foodsDetailDict)
        let unitQty = decimalValue(specDefault["specNum"])
        if NSDecimalNumber(decimal: unitQty).compare(NSDecimalNumber.zero) == .orderedSame {
            return nil
        }

        var specQty = decimalValue(topVm.specDict["specNum"])
        let selectedSpecName = topVm.specDict.stringValueForKey(key: "specName")
        if selectedSpecName == "g" ||
            selectedSpecName == "克" ||
            selectedSpecName == "ml" ||
            selectedSpecName == "毫升" ||
            topVm.specArray.count == 1 {
            specQty = 1
        }

        return specQty / unitQty * countDecimal
    }

    func decimalValue(_ value: Any?) -> Decimal {
        if let number = value as? NSNumber {
            return number.decimalValue
        }
        if let stringValue = value as? String {
            let normalized = stringValue.replacingOccurrences(of: ",", with: ".")
            return Decimal(string: normalized) ?? 0
        }
        return 0
    }
//    func createAttributedStringWithImage(image: UIImage, text: String) -> NSAttributedString {
//        let attachment = NSTextAttachment()
//        attachment.image = image
//        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .medium).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
//        let attachmentString = NSAttributedString(attachment: attachment)
//
//        let string = NSMutableAttributedString(string: text)
//        string.append(attachmentString)
//
//        return string
//    }
    func createAttributedStringWithImage(image: UIImage, text: String,keywords:String? = "") -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .medium).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSAttributedString(attachment: attachment)
        let a = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.COLOR_TEXT_TITLE_0f1214]
        )
        a.append(attachmentString)

        return a
    }
    @objc func deleteAction() {
        self.presentAlertVc(confirmBtn: "删除", message: "是否删除食物“\(foodsDetailDict["fname"]as? String ?? "")”", title: "温馨提示", cancelBtn: "取消", handler: { action in
            self.sendDeleteFoodsRequest()
        }, viewController: self)
    }
    @objc func editAction() {
        let vc = FoodsCreateVC()
        vc.isEditFoods = true
        vc.editFoodsDict = self.foodsDetailDict
        vc.editSuccessBlock = { [weak self] _ in
            self?.hasLoadedFoodsDetail = false
            self?.updateOwnerActionButtonsVisibility()
            self?.sendFoodsDetailRequest()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func showTodayNutritionReportAction() {
        let vc = JournalReportVC()
        vc.detailDict = todayJournalReportDetailDict()
        vc.currentIndex = 0
        vc.shouldScrollToDailyNutritionDetail = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func todayJournalReportDetailDict() -> NSDictionary {
        let todayDate = Date().todayDate
        guard let logsModel = LogsSQLiteManager.getInstance().getLogsByDate(sDate: todayDate) else {
            return ["sdate": todayDate]
        }

        let detailDict = NSMutableDictionary(dictionary: logsModel.modelToDict())
        let sportDict = SportDataSQLiteManager.getInstance().querySportsData(sDate: todayDate)
        if UserInfoModel.shared.statSportDataToTarget == "1" {
            detailDict.setValue("\(sportDict.stringValueForKey(key: "sportCalories"))", forKey: "sportCalories")
        } else {
            detailDict.setValue("", forKey: "sportCalories")
        }
        return detailDict
    }

    func updateOwnerActionButtonsVisibility() {
        if shouldHideOwnerActionButtonsForSource() {
            self.editButton.isHidden = true
            self.deleteButton.isHidden = true
            return
        }

        let isOwner = hasLoadedFoodsDetail && self.foodsDetailDict.stringValueForKey(key: "uid") == UserInfoModel.shared.uId
        if canEdit{
            self.editButton.isHidden = !isOwner
            self.deleteButton.isHidden = !isOwner
        }
    }

    func shouldHideOwnerActionButtonsForSource() -> Bool {
        switch sourceType {
        case .merge, .meals_create, .plan, .plan_update:
            return true
        default:
            return false
        }
    }
}

extension FoodsMsgDetailsVC{
    func initUI(){
        initNavi(titleStr: "食物详情")
        self.navigationView.backgroundColor = .clear
        self.navigationView.addSubview(editButton)
        self.navigationView.addSubview(deleteButton)
        updateOwnerActionButtonsVisibility()

        view.backgroundColor = .COLOR_BG_F2//WHColor_16(colorStr: "FAFAFA")
        view.insertSubview(scrollView, belowSubview: self.navigationView)
        scrollView.addSubview(contentView)
        contentView.addSubview(foodsNameLabel)
//        view.addSubview(foodsVerifyImgView)
        contentView.addSubview(topVm)
        contentView.addSubview(caloriDetailVm)
        contentView.addSubview(nutritionDetailVm)
        view.addSubview(confirmButton)

        view.addSubview(specAlertVm)

        topVm.calculateSpecWeight()
        specAlertVm.setDataArray(specArr: self.topVm.specArray)

//        if self.foodsDetailDict.stringValueForKey(key: "uid") != UserInfoModel.shared.uId{
//            deleteButton.isHidden = true
//        }

        setConstrait()
    }

    func setConstrait() {
        deleteButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(naviTitleLabel)
            make.width.height.equalTo(kFitWidth(28))
        }
        editButton.snp.makeConstraints { make in
            make.right.equalTo(deleteButton.snp.left).offset(kFitWidth(-4))
            make.centerY.lessThanOrEqualTo(naviTitleLabel)
            make.width.height.equalTo(kFitWidth(28))
        }
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(getNavigationBarHeight())
            make.bottom.equalTo(confirmButton.snp.top).offset(kFitWidth(-12))
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(nutritionDetailVm.frame.maxY+kFitWidth(24))
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(24))
            make.top.equalTo(kFitWidth(24))
//            make.top.equalTo(getNavigationBarHeight()+kFitWidth(24))
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
        refreshScrollContentSize()
    }

    func refreshScrollContentSize(animated: Bool = false) {
        nutritionDetailVm.frame.origin.y = caloriDetailVm.frame.maxY+kFitWidth(12)
        let contentHeight = nutritionDetailVm.frame.maxY+kFitWidth(24)
        let minOffsetY = -scrollView.adjustedContentInset.top
        let maxOffsetY = max(minOffsetY, contentHeight - scrollView.bounds.height + scrollView.adjustedContentInset.bottom)
        let targetOffsetY = min(max(scrollView.contentOffset.y, minOffsetY), maxOffsetY)
        let targetOffset = CGPoint(x: scrollView.contentOffset.x, y: targetOffsetY)
        let changes = {
            self.contentView.snp.updateConstraints { make in
                make.height.equalTo(contentHeight)
            }
            self.contentView.layoutIfNeeded()
            self.scrollView.layoutIfNeeded()
            self.scrollView.contentOffset = targetOffset
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: changes)
        } else {
            UIView.performWithoutAnimation(changes)
        }
    }
}

extension FoodsMsgDetailsVC{
    func sendDeleteFoodsRequest() {
        MCToast.mc_loading()
        let param = ["fname":"\(foodsDetailDict.stringValueForKey(key: "fname"))"]

        WHNetworkUtil.shareManager().POST(urlString: URL_foods_delete, parameters: param as [String:AnyObject]) { responseObject in
            UserDefaults.delFoods(foodsDict: self.foodsDetailDict, forKey: .myFoodsList)
            UserDefaults.delFoods(foodsDict: self.foodsDetailDict, forKey: .hidsoryFoodsAdd)

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
            let foodsDict = NSMutableDictionary(dictionary: self.foodsDetailDict)
            if let detailDict = dataDict as? [AnyHashable: Any] {
                foodsDict.addEntries(from: detailDict)
            }
            self.foodsDetailDict = foodsDict
            self.hasLoadedFoodsDetail = true
            self.refreshDetailUI()
            self.updateOwnerActionButtonsVisibility()
        }
    }

    func refreshDetailUI() {
        if self.foodsDetailDict["verified"]as? String ?? "\(self.foodsDetailDict["verified"]as? Int ?? 0)" == "1"{
            if let img = UIImage(named: "question_foods_verify_icon") {
                foodsNameLabel.attributedText = createAttributedStringWithImage(image: img, text: "\(foodsDetailDict["fname"]as? String ?? "")")
            }
        }else{
            foodsNameLabel.attributedText = nil
            foodsNameLabel.text = "\(foodsDetailDict["fname"]as? String ?? "")"
        }
        topVm.foodsMsgDict = foodsDetailDict
        topVm.calculateSpecWeight()
        specAlertVm.setDataArray(specArr: topVm.specArray)
        caloriDetailVm.calculatePercent(dict: foodsDetailDict)
        refreshScrollContentSize()
    }
}
