//
//  DataAddVC.swift
//  lns
//
//  Created by LNS2 on 2024/4/17.
//

import Foundation
import MCToast
import IQKeyboardManagerSwift
import UMCommon
import HealthKit

class DataAddVC : WHBaseViewVC {
    
    var imgUrlString = ""
    var originY = kFitWidth(0)
    
    var msgDict = NSDictionary()
    var isUpdate = false
    
    /// Whether this controller is pushed from OverView page
    var isFromOverview = false
    
    var deleteBlock:(()->())?
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        MobClick.beginLogPageView("添加身体数据")
        NotificationCenter.default.addObserver(self, selector: #selector(dealsWidgetTapAction), name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = true
        MobClick.beginLogPageView("添加身体数据")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "widgetAddFoods"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let cTime = isUpdate ? msgDict.stringValueForKey(key: "ctime") : self.dateFilterAlertVm.dateStringYear
//        if !self.isUpdate && !BodyDataSQLiteManager.getInstance().queryTable(sDate: Date().todayDate){
//            BodyDataSQLiteManager.getInstance().insertDataUseSql(cTime: Date().todayDate, imgurl: "", hipsData: "", weightData: "", waistlineData: "", armcircumferenceData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", images: "", upload: false)
//        }
        
        initUI()
        if !isUpdate {
            loadDataForSelectedDate()
        }
        sendOssStsRequest()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: "updateBodyDataSetting"), object: nil)
        
        
    }
    lazy var customButton : FeedBackButton = {
        let button = FeedBackButton()
//        button.setImage(UIImage(named: "data_custom_icon"), for: .normal)
        button.setTitle("更多", for: .normal)
        button.setTitleColor(.THEME, for: .normal)
        button.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        button.addTarget(self, action: #selector(customAction), for: .touchUpInside)
        return button
    }()
    lazy var topFilterVm : DataAddFilterVM = {
        let vm = DataAddFilterVM.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: 0, height: 0))
        vm.timeButton.addTarget(self, action: #selector(showDateAlertAction), for: .touchUpInside)
        return vm
    }()
    lazy var imgVm: DataAddImageVM = {
        let vm = DataAddImageVM.init(frame: CGRect.init(x: 0, y: self.topFilterVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
        vm.controller = self
        vm.cTime = isUpdate ? msgDict.stringValueForKey(key: "ctime") : self.dateFilterAlertVm.dateStringYear
        vm.imgTapBlock = {()in
            self.changeSubmitButtonStatusForImg()
        }
        return vm
    }()
//    lazy var imgVm : DataAddItemImageVM = {
//        let vm = DataAddItemImageVM.init(frame: CGRect.init(x: 0, y: self.topFilterVm.frame.maxY+kFitWidth(12), width: 0, height: 0))
//        vm.leftTitleLabel.text = "照片"
//        vm.imgTapBlock = {()in
//            self.takePickture()
//        }
//        vm.clearImgBlock = {()in
//            self.imgUrlString = ""
//        }
//        return vm
//    }()
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var weightVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.imgVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "体重"
        if UserInfoModel.shared.weightUnit == 1{
            vm.unitLabel.text = "kg"
        }else{
            vm.unitLabel.text = "\(UserInfoModel.shared.weightUnitName)"
        }
        
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var yaoweiVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.weightVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "腰围"
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var tunweiVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.yaoweiVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "臀围"
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var biweiVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.tunweiVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "手臂"
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var shoulderVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.biweiVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "肩宽"
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var bustVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.shoulderVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "胸围"
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var thighVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.bustVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "大腿围"
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var calfVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.thighVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "小腿围"
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var bfpVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.calfVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "体脂率"
        vm.unitLabel.text = "%"
        vm.maxNumber = 2
        vm.decimalNum = 2
        vm.unitLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        vm.dataChangeBlock = {(text)in
            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var clearWhiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: self.biweiVm.frame.maxY, width: SCREEN_WIDHT, height: kFitWidth(50)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        return vi
    }()
    lazy var clearLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: kFitWidth(16), y: 0, width: kFitWidth(50), height: kFitWidth(50)))
        lab.text = "重置"
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        
        return lab
    }()
    lazy var clearTapView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(100), height: kFitWidth(50)))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(clearTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var saveBottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-getBottomSafeAreaHeight()-kFitWidth(102), width: SCREEN_WIDHT, height: kFitWidth(96)))
        vi.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var saveButton : UIButton = {
//        let btn = UIButton.init(frame: CGRect.init(x: kFitWidth(20), y: self.calfVm.frame.maxY+kFitWidth(40), width: kFitWidth(335), height: kFitWidth(56)))
//        let btn = UIButton.init(frame: CGRect.init(x: kFitWidth(20), y: SCREEN_HEIGHT-getBottomSafeAreaHeight()-kFitWidth(102), width: kFitWidth(335), height: kFitWidth(56)))
        let btn = UIButton.init(frame: CGRect.init(x: kFitWidth(20), y: kFitWidth(0), width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(56)))
        btn.setTitle("保存", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.isEnabled = false
        btn.backgroundColor = .THEME
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "- 以上数据均可选填 -"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var dateFilterAlertVm : DataAddDateAlertVM = {
        let vm = DataAddDateAlertVM.init(frame: .zero)
        vm.datePicker.maximumDate = Date()
        vm.confirmBlock = {(weekDay)in
            self.topFilterVm.setTime(time: weekDay)
//            self.imgVm.cTime = self.dateFilterAlertVm.dateStringYear
//            if !BodyDataSQLiteManager.getInstance().queryTable(sDate: self.dateFilterAlertVm.dateStringYear){
//                BodyDataSQLiteManager.getInstance().insertDataUseSql(cTime: self.dateFilterAlertVm.dateStringYear, imgurl: "", hipsData: "", weightData: "", waistlineData: "", armcircumferenceData: "", shoulderData: "", bustData: "", thighData: "", calfData: "", images: "", upload: false)
//            }
            self.loadDataForSelectedDate()
        }
        return vm
    }()
    lazy var typeSettingAlertVm: DataDetailTypeSettingAlertVM = {
        let vm = DataDetailTypeSettingAlertVM.init(frame: .zero)
        vm.choiceBlock = {(dict)in
//            self.dataType = dict["type"]as? DATA_TYPE ?? .weight
//            self.changeType()
        }
        return vm
    }()
}

extension DataAddVC{
    @objc func showDateAlertAction(){
        self.weightVm.textField.resignFirstResponder()
        self.yaoweiVm.textField.resignFirstResponder()
        self.tunweiVm.textField.resignFirstResponder()
        self.biweiVm.textField.resignFirstResponder()
        self.dateFilterAlertVm.showView()
    }
    @objc func clearTapAction()  {
        self.presentAlertVc(confirmBtn: "确定", message: "", title: "是否清空当前数据？", cancelBtn: "取消", handler: { aciton in
            self.weightVm.textField.text = ""
            self.yaoweiVm.textField.text = ""
            self.tunweiVm.textField.text = ""
            self.biweiVm.textField.text = ""
            self.shoulderVm.textField.text = ""
            self.bustVm.textField.text = ""
            self.thighVm.textField.text = ""
            self.calfVm.textField.text = ""
            self.bfpVm.textField.text = ""
        }, viewController:self)
    }
    @objc func customAction(){
        typeSettingAlertVm.showView()
    }
    @objc func saveAction() {
        if imgVm.imgUrlOne == "" && imgVm.imgUrlTwo == "" && imgVm.imgUrlThree == "" && weightVm.textField.text?.count == 0 && yaoweiVm.textField.text?.count == 0 && tunweiVm.textField.text?.count == 0 && biweiVm.textField.text?.count == 0 && shoulderVm.textField.text?.count == 0
            && bustVm.textField.text?.count == 0 && thighVm.textField.text?.count == 0 && calfVm.textField.text?.count == 0 && bfpVm.textField.text?.count == 0{
            
            if self.deleteBlock != nil{
                self.deleteBlock?()
            }else{
                BodyDataSQLiteManager.shared.deleteTableData(cTime: self.dateFilterAlertVm.dateStringYear)
                self.sendDeleteDataRequest()
            }
            
//            if isUpdate{
//                self.deleteBlock?()
                self.backTapAction()
//            }else{
//                MCToast.mc_text("请至少输入一个测量数值或上传照片",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
//            }
            return
        }
//        if imgUrlString == "" && weightVm.textField.text?.count == 0 && yaoweiVm.textField.text?.count == 0 && tunweiVm.textField.text?.count == 0 && biweiVm.textField.text?.count == 0 && shoulderVm.textField.text?.count == 0
//            && bustVm.textField.text?.count == 0 && thighVm.textField.text?.count == 0 && calfVm.textField.text?.count == 0{
//            MCToast.mc_text("请至少输入一个测量数值或上传照片",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
//            return
//        }
        var weightNum = weightVm.textField.text ?? ""
        weightNum = weightNum.replacingOccurrences(of: ",", with: ".")
        if (weightNum.floatValue == 0 || weightNum.floatValue >= 1000) && weightNum.count > 0{
            MCToast.mc_text("体重数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        var yaoweiNum = yaoweiVm.textField.text ?? ""
        yaoweiNum = yaoweiNum.replacingOccurrences(of: ",", with: ".")
        if (yaoweiNum.floatValue == 0 || yaoweiNum.floatValue >= 1000) && yaoweiNum.count > 0 {
            MCToast.mc_text("腰围数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        var tunweiNum = tunweiVm.textField.text ?? ""
        tunweiNum = tunweiNum.replacingOccurrences(of: ",", with: ".")
        if (tunweiNum.floatValue == 0 || tunweiNum.floatValue >= 1000) && tunweiNum.count > 0 {
            MCToast.mc_text("臀围数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        var biweiNum = biweiVm.textField.text ?? ""
        biweiNum = biweiNum.replacingOccurrences(of: ",", with: ".")
        if (biweiNum.floatValue == 0 || biweiNum.floatValue >= 1000) && biweiNum.count > 0 {
            MCToast.mc_text("手臂数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        var shoulderNum = shoulderVm.textField.text ?? ""
        shoulderNum = shoulderNum.replacingOccurrences(of: ",", with: ".")
        if (shoulderNum.floatValue == 0 || shoulderNum.floatValue >= 1000) && shoulderNum.count > 0 {
            MCToast.mc_text("肩宽数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        var bustNum = bustVm.textField.text ?? ""
        bustNum = bustNum.replacingOccurrences(of: ",", with: ".")
        if (bustNum.floatValue == 0 || bustNum.floatValue >= 1000) && bustNum.count > 0 {
            MCToast.mc_text("胸围数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        var thighNum = thighVm.textField.text ?? ""
        thighNum = thighNum.replacingOccurrences(of: ",", with: ".")
        if (thighNum.floatValue == 0 || thighNum.floatValue >= 1000) && thighNum.count > 0 {
            MCToast.mc_text("大腿围数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        var calfNum = calfVm.textField.text ?? ""
        calfNum = calfNum.replacingOccurrences(of: ",", with: ".")
        if (calfNum.floatValue == 0 || calfNum.floatValue >= 1000) && calfNum.count > 0 {
            MCToast.mc_text("小腿围数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        var bfpNum = bfpVm.textField.text ?? ""
        bfpNum = bfpNum.replacingOccurrences(of: ",", with: ".")
        if (bfpNum.floatValue == 0 || bfpNum.floatValue >= 70) && bfpNum.count > 0 {
            MCToast.mc_text("体脂率数据错误(0%~70%)",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        MobClick.event("addData")
        sendSaveDataRequest()
    }
    func changeSubmitButtonStatus(text:String) {
        saveButton.isEnabled = true
        
//        if text.count > 0{
//            saveButton.isEnabled = true
//            return
//        }
//        if imgUrlString == "" && weightVm.textField.text?.count == 0 && yaoweiVm.textField.text?.count == 0 && tunweiVm.textField.text?.count == 0 && biweiVm.textField.text?.count == 0  && shoulderVm.textField.text?.count == 0
//            && bustVm.textField.text?.count == 0  && thighVm.textField.text?.count == 0  && calfVm.textField.text?.count == 0   && bfpVm.textField.text?.count == 0 {
//            if isUpdate {
//                saveButton.isEnabled = true
//            }else{
//                saveButton.isEnabled = false
//            }
//        }else{
//            saveButton.isEnabled = true
//        }
    }
    func changeSubmitButtonStatusForImg() {
        saveButton.isEnabled = true
//        if imgVm.imgUrlOne == "" && imgVm.imgUrlTwo == "" && imgVm.imgUrlThree == "" && weightVm.textField.text?.count == 0 && yaoweiVm.textField.text?.count == 0 && tunweiVm.textField.text?.count == 0 && biweiVm.textField.text?.count == 0  && shoulderVm.textField.text?.count == 0
//            && bustVm.textField.text?.count == 0  && thighVm.textField.text?.count == 0  && calfVm.textField.text?.count == 0  && bfpVm.textField.text?.count == 0{
//            if isUpdate {
//                saveButton.isEnabled = true
//            }else{
//                saveButton.isEnabled = false
//            }
//        }else{
//            saveButton.isEnabled = true
//        }
    }
}

extension DataAddVC{
    func initUI() {
        initNavi(titleStr: "编辑数据")
//        initNavi(titleStr: "添加数据")
        view.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        self.navigationView.addSubview(customButton)
        
        view.addSubview(topFilterVm)
        
        let scrollViewHeight = SCREEN_HEIGHT-self.bottomView.frame.minY
        scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: saveBottomView.frame.minY)
        scrollViewBase.bounces = false
        
        view.insertSubview(bottomView, belowSubview: self.navigationView)
        bottomView.addSubview(scrollViewBase)
        
        scrollViewBase.addSubview(imgVm)
        scrollViewBase.addSubview(weightVm)
        scrollViewBase.addSubview(yaoweiVm)
        scrollViewBase.addSubview(tunweiVm)
        scrollViewBase.addSubview(biweiVm)
        scrollViewBase.addSubview(clearWhiteView)
        
        clearWhiteView.addSubview(clearLabel)
        clearWhiteView.addSubview(clearTapView)
        
        bottomView.addSubview(saveBottomView)
        saveBottomView.addSubview(saveButton)
        saveBottomView.addSubview(tipsLabel)
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: clearWhiteView.frame.maxY)
        
        view.addSubview(dateFilterAlertVm)
        
        topFilterVm.setTime(time: dateFilterAlertVm.weekDay)
        
        setConstrait()
        
        view.addSubview(typeSettingAlertVm)
        updateUI()
    }
    
    func setConstrait()  {
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(saveButton.snp.bottom).offset(kFitWidth(20))
        }
        customButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.height.equalTo(kFitWidth(44))
            make.centerY.lessThanOrEqualTo(self.naviTitleLabel)
            make.width.equalTo(kFitWidth(64))
        }
    }
    
    @objc func updateUI() {
        originY = self.biweiVm.frame.maxY
        let settingMsgDict = UserDefaults().getBodyDataSetting()
        
        if settingMsgDict.stringValueForKey(key: "shoulder") == "1"{
            scrollViewBase.addSubview(shoulderVm)
            shoulderVm.isHidden = false
            shoulderVm.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: self.biweiVm.selfHeight)
            originY = originY + self.biweiVm.selfHeight
        }else{
            shoulderVm.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "bust") == "1"{
            scrollViewBase.addSubview(bustVm)
            bustVm.isHidden = false
            bustVm.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: self.biweiVm.selfHeight)
            originY = originY + self.biweiVm.selfHeight
        }else{
            bustVm.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "thigh") == "1"{
            scrollViewBase.addSubview(thighVm)
            thighVm.isHidden = false
            thighVm.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: self.biweiVm.selfHeight)
            originY = originY + self.biweiVm.selfHeight
        }else{
            thighVm.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "calf") == "1"{
            scrollViewBase.addSubview(calfVm)
            calfVm.isHidden = false
            calfVm.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: self.biweiVm.selfHeight)
            originY = originY + self.biweiVm.selfHeight
        }else{
            calfVm.isHidden = true
        }
        if settingMsgDict.stringValueForKey(key: "bfp") == "1"{
            scrollViewBase.addSubview(bfpVm)
            bfpVm.isHidden = false
            bfpVm.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: self.biweiVm.selfHeight)
            originY = originY + self.biweiVm.selfHeight
        }else{
            bfpVm.isHidden = true
        }
        
        if isUpdate {
            clearWhiteView.frame = CGRect.init(x: 0, y: originY, width: SCREEN_WIDHT, height: kFitWidth(50))
            originY = originY + kFitWidth(50)
        }
        
        scrollViewBase.contentSize = CGSize.init(width: 0, height: originY)
    }
    
    //更新数据页面  回显数据
    func updateUIForUpdate() {
        isUpdate = true
        self.naviTitleLabel.text = "编辑数据"
        DLLog(message: "updateUIForUpdate:\(msgDict)")
        
        if (msgDict["images"]as? String ?? "").count > 0 {
            imgVm.updateUIForUpdate(images: msgDict.stringValueForKey(key: "images"))
        }else{
            let imageArr = msgDict["image"]as? NSArray ?? []
            imgVm.updateUIForUpdate(images: self.getJSONStringFromArray(array: imageArr))
        }
        
        let ctime = msgDict.stringValueForKey(key: "ctime")
        let cDate = Date().changeDateStringToDate(dateString: ctime,formatter: "yyyy-MM-dd")
        
//        dateFilterAlertVm.changeDate(date: cDate)
        dateFilterAlertVm.setDate(dateString: ctime)
//        topFilterVm.updateUIForUpdate(date: dateFilterAlertVm.weekDay)
//        self.topFilterVm.setTime(time: dateFilterAlertVm.weekDay)
        
        if msgDict.stringValueForKey(key: "weight").count > 0 && msgDict.doubleValueForKey(key: "weight") > 0{
            var num = (msgDict.doubleValueForKey(key: "weight") * UserInfoModel.shared.weightCoefficient)
//            num = String(format: "%.1f",num.rounded()).doubleValue
            num = String(format: "%.1f", (num * 10).rounded()/10).doubleValue
            weightVm.textField.text = "\(WHUtils.convertStringToStringOneDigit("\(num)") ?? "")"
        }else{
            weightVm.textField.text = ""
        }
        
        yaoweiVm.textField.text = msgDict.stringValueForKey(key: "waistline").doubleValue == 0 ? "" : msgDict.stringValueForKey(key: "waistline")
        tunweiVm.textField.text = msgDict.stringValueForKey(key: "hips").doubleValue == 0 ? "" : msgDict.stringValueForKey(key: "hips")
        biweiVm.textField.text = msgDict.stringValueForKey(key: "armcircumference").doubleValue == 0 ? "" : msgDict.stringValueForKey(key: "armcircumference")
        shoulderVm.textField.text = msgDict.stringValueForKey(key: "shoulder").doubleValue == 0 ? "" : msgDict.stringValueForKey(key: "shoulder")
        bustVm.textField.text = msgDict.stringValueForKey(key: "bust").doubleValue == 0 ? "" : msgDict.stringValueForKey(key: "bust")
        thighVm.textField.text = msgDict.stringValueForKey(key: "thigh").doubleValue == 0 ? "" : msgDict.stringValueForKey(key: "thigh")
        calfVm.textField.text = msgDict.stringValueForKey(key: "calf").doubleValue == 0 ? "" : msgDict.stringValueForKey(key: "calf")
        bfpVm.textField.text = msgDict.stringValueForKey(key: "bfp").doubleValue == 0 ? "" : msgDict.stringValueForKey(key: "bfp")
        
        clearWhiteView.isHidden = false

        changeSubmitButtonStatusForImg()
   }
}

extension DataAddVC{
    func loadDataForSelectedDate() {
       let cTime = self.dateFilterAlertVm.dateStringYear
       let dict = BodyDataSQLiteManager.getInstance().queryBodyData(sDate: cTime)
       if dict.allKeys.count > 0 {
           self.msgDict = dict
           self.updateUIForUpdate()
       } else {
           resetUIForNewData()
       }
        updateUI()
    }

    func resetUIForNewData() {
       isUpdate = false
       self.naviTitleLabel.text = "添加数据"
       imgVm.imgUrlOne = ""
       imgVm.imgUrlTwo = ""
       imgVm.imgUrlThree = ""
       imgVm.firstImgVm.clearImgAction()
       imgVm.secondImgVm.clearImgAction()
       imgVm.thirdImgVm.clearImgAction()
       weightVm.textField.text = ""
       yaoweiVm.textField.text = ""
       tunweiVm.textField.text = ""
       biweiVm.textField.text = ""
       shoulderVm.textField.text = ""
       bustVm.textField.text = ""
       thighVm.textField.text = ""
       calfVm.textField.text = ""
       bfpVm.textField.text = ""
       clearWhiteView.isHidden = true
       changeSubmitButtonStatusForImg()
    }
}

extension DataAddVC{
    func sendSaveDataRequest() {
        let weightData = "\(self.weightVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".")
        //将体重数据转换成 单位  kg 保存
        var dataNum = weightData.floatValue
        dataNum = dataNum/Float(UserInfoModel.shared.weightCoefficient)
        
        let imagesArray = [["sn":"1","alias":"","url":"\(imgVm.imgUrlOne)"],
                           ["sn":"2","alias":"","url":"\(imgVm.imgUrlTwo)"],
                           ["sn":"3","alias":"","url":"\(imgVm.imgUrlThree)"]] as NSArray
        
        let imgArr = isUpdate ? imagesArray : dealDataImages()
        let cTime = isUpdate ? msgDict.stringValueForKey(key: "ctime") : self.dateFilterAlertVm.dateStringYear
        
        var hasData = false
        if isUpdate == false{//} || BodyDataSQLiteManager.getInstance().queryTable(sDate: cTime) == false{
            if BodyDataSQLiteManager.getInstance().queryTable(sDate: cTime) == false{
//                hasData = false
                BodyDataSQLiteManager.getInstance().updateData(cTime: cTime,
                                                               imgurl: "\(imgUrlString)",
                                                               hipsData: "\(self.tunweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."),
                                                               weightData: "\(dataNum)",
                                                               waistlineData: "\(self.yaoweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."),
                                                               shoulderData: "\(self.shoulderVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."),
                                                               bustData: "\(self.bustVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."),
                                                               thighData: "\(self.thighVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."),
                                                               calfData: "\(self.calfVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), bfpData: "\(self.bfpVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."),
                                                               images: self.getJSONStringFromArray(array: imgArr),
    //                                                           images: "",
                                                               armcircumferenceData: "\(self.biweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."))
            }else{
                hasData = true
            }
        }else{
            if weightData.count > 0{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(WHUtils.convertStringToString("\(dataNum)") ?? "")", cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "0", cTime: cTime)
            }
            if "\(self.tunweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "hips", data: "\(self.tunweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "hips", data: "0", cTime: cTime)
            }
            if "\(self.yaoweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "waistline", data: "\(self.yaoweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "waistline", data: "0", cTime: cTime)
            }
            if "\(self.shoulderVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "shoulder", data: "\(self.shoulderVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "shoulder", data: "0", cTime: cTime)
            }
            if "\(self.bustVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "bust", data: "\(self.bustVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "bust", data: "0", cTime: cTime)
            }
            if "\(self.thighVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "thigh", data: "\(self.thighVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "thigh", data: "0", cTime: cTime)
            }
            if "\(self.calfVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "calf", data: "\(self.calfVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "calf", data: "0", cTime: cTime)
            }
            if "\(self.bfpVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "bfp", data: "\(self.bfpVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "bfp", data: "0", cTime: cTime)
            }
            if "\(self.biweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "armcircumference", data: "\(self.biweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }else{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "armcircumference", data: "0", cTime: cTime)
            }
            //2025年04月09日11:30:36   上传图片修改，注释掉
            BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "images", data: self.getJSONStringFromArray(array: imgArr), cTime: cTime)
        }
        if hasData{
            if weightData.count > 0{
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "weight", data: "\(WHUtils.convertStringToString("\(dataNum)") ?? "")", cTime: cTime)
            }
            if "\(self.tunweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "hips", data: "\(self.tunweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }
            if "\(self.yaoweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "waistline", data: "\(self.yaoweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }
            if "\(self.shoulderVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "shoulder", data: "\(self.shoulderVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }
            if "\(self.bustVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "bust", data: "\(self.bustVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }
            if "\(self.thighVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "thigh", data: "\(self.thighVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }
            if "\(self.calfVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "calf", data: "\(self.calfVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }
            if "\(self.bfpVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "bfp", data: "\(self.bfpVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }
            if "\(self.biweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").count > 0 {
                BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "armcircumference", data: "\(self.biweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: "."), cTime: cTime)
            }
            //2025年04月09日11:30:36   上传图片修改，注释掉
            BodyDataSQLiteManager.getInstance().updateSingleData(columnName: "images", data: self.getJSONStringFromArray(array: imgArr), cTime: cTime)
        }
        
        let healthManager = HealthKitManager()
//        //如果有输入体重数据
        if weightData.count > 0{
            let weight = HKQuantity(unit: HKUnit(from: "kg"), doubleValue: Double(dataNum))
            healthManager.saveWeight(weight: weight, sdate: cTime) { t, err in
                if t {
                    DLLog(message: "体重数据保存:  -》  Health App")
                }else{
                    DLLog(message: "体重数据保存:\(String(describing: err))")
                }
            }
        }else if isUpdate{
            healthManager.saveWeight(value: 0, sdate: cTime)
        }
        if "\(self.bfpVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").doubleValue > 0 {
            healthManager.saveBodyFatPercentage(value: "\(self.bfpVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").doubleValue*0.01, sdate: cTime)
        }else if isUpdate{
            healthManager.saveBodyFatPercentage(value: 0, sdate: cTime)
        }
        if "\(self.yaoweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").doubleValue > 0 {
            healthManager.saveWaistCircumference(value: "\(self.yaoweiVm.textField.text ?? "")".replacingOccurrences(of: ",", with: ".").doubleValue, sdate: cTime)
        }else if isUpdate{
            healthManager.saveWaistCircumference(value: 0, sdate: cTime)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
            BodyDataUploadManager().sendBodyData(sDate: cTime)
            
            if self.isFromOverview {
                let vc = BodyDataDetailVC()
                vc.popToOverview = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.backTapAction()
            }
//            self.backTapAction()
        })
    }
    func sendOssStsRequest() {
        WHNetworkUtil.shareManager().GET(urlString: URL_OSS_sts) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            UserInfoModel.shared.updateOssParams(dict: self.getDictionaryFromJSONString(jsonString: dataString ?? ""))
        }
    }
    func sendDeleteDataRequest() {
        let sdate = self.dateFilterAlertVm.dateStringYear
//        BodyDataSQLiteManager.getInstance().deleteTableData(cTime: "\(dict["ctime"]as? String ?? "")")
        let param = ["ctime":"\(sdate)"]
        WHNetworkUtil.shareManager().POST(urlString: URL_bodystat_delete, parameters: param as [String : AnyObject],isNeedToast: true,vc: self) { responseObject in
//            DLLog(message: responseObject)
            UserDefaults.deleteWeightDate(sdate: "\(sdate)")
            
            let healthManager = HealthKitManager()
            healthManager.saveWeight(value: 0, sdate: "\(sdate)")
            healthManager.saveBodyFatPercentage(value: 0, sdate: "\(sdate)")
            healthManager.saveWaistCircumference(value: 0, sdate: "\(sdate)")
        }
    }
    func dealDataImages() -> NSArray {
        let cTime = isUpdate ? msgDict.stringValueForKey(key: "ctime") : self.dateFilterAlertVm.dateStringYear
        let imagesArray = [["sn":"1","alias":"","url":"\(imgVm.imgUrlOne)"],
                           ["sn":"2","alias":"","url":"\(imgVm.imgUrlTwo)"],
                           ["sn":"3","alias":"","url":"\(imgVm.imgUrlThree)"]]
        let dict = BodyDataSQLiteManager.getInstance().queryBodyData(sDate: cTime)
        let images = dict.stringValueForKey(key: "images")
        
//        var imagesString = self.getJSONStringFromArray(array: imagesArray as NSArray)
        if imgVm.imgUrlOne == "" && imgVm.imgUrlTwo == "" && imgVm.imgUrlThree == ""{
//            imagesString = ""
            return self.getArrayFromJSONString(jsonString: images)
        }else{
            if images.count > 0 {
                let imagesArr = self.getArrayFromJSONString(jsonString: images)
                let submitImgArr = NSMutableArray()
                if imgVm.imgUrlOne == "" && imagesArr.count > 0{
                    let dict = imagesArr[0]as? NSDictionary ?? [:]
                    submitImgArr.add(dict)
                }else{
                    submitImgArr.add(["sn":"1","alias":"","url":"\(imgVm.imgUrlOne)"])
                }
                
                if imgVm.imgUrlTwo == "" && imagesArr.count > 1{
                    let dict = imagesArr[1]as? NSDictionary ?? [:]
                    submitImgArr.add(dict)
                }else{
                    submitImgArr.add(["sn":"2","alias":"","url":"\(imgVm.imgUrlTwo)"])
                }
                if imgVm.imgUrlThree == "" && imagesArr.count > 2{
                    let dict = imagesArr[2]as? NSDictionary ?? [:]
                    submitImgArr.add(dict)
                }else{
                    submitImgArr.add(["sn":"3","alias":"","url":"\(imgVm.imgUrlThree)"])
                }
                
                return submitImgArr
            }else{
                return imagesArray as NSArray
            }
        }
    }
}

extension DataAddVC{
    @objc func keyboardWillShow(notification: NSNotification) {
        var vm = DataAddItemVM()
        
        if self.tunweiVm.textField.isEditing{
            vm = self.tunweiVm
        }else if self.biweiVm.textField.isEditing{
            vm = self.biweiVm
        }else if self.shoulderVm.textField.isEditing{
            vm = self.shoulderVm
        }else if self.bustVm.textField.isEditing{
            vm = self.bustVm
        }else if self.thighVm.textField.isEditing{
            vm = self.thighVm
        }else if self.calfVm.textField.isEditing{
            vm = self.calfVm
        }else if self.weightVm.textField.isEditing{
            vm = self.weightVm
        }else if self.yaoweiVm.textField.isEditing{
            vm = self.yaoweiVm
        }else if self.bfpVm.textField.isEditing{
            vm = self.bfpVm
        }else{
//            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let carboVmBottomGap = (SCREEN_HEIGHT-self.bottomView.frame.maxY)
//            if carboVmBottomGap < keyboardSize.size.height{
                UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//                    self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5-(keyboardSize.size.height-carboVmBottomGap))
//                    let scrollHeight = SCREEN_HEIGHT - self.getBottomSafeAreaHeight() - kFitWidth(102) - keyboardSize.size.height
//                    self.scrollViewBase.frame = CGRect.init(x: 0, y:-self.bottomView.frame.minY, width: SCREEN_WIDHT, height: scrollHeight)
                    self.saveBottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-keyboardSize.size.height-self.saveBottomView.frame.height*0.5)
//
                    let scrollHeight = SCREEN_HEIGHT - keyboardSize.size.height - self.saveBottomView.frame.height
                    self.scrollViewBase.frame = CGRect.init(x: 0, y:0, width: SCREEN_WIDHT, height: scrollHeight)
                }completion: { t in
                    self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.originY)
                    let offsetY = vm.frame.maxY - self.scrollViewBase.frame.height
                    if offsetY > 0 {
                        self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: offsetY), animated: true)
                    }
                }
//            }250  75  78
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
//            self.scrollViewBase.contentOffset = CGPoint.init(x: 0, y: 0)
            self.saveBottomView.frame = CGRect.init(x: 0, y: SCREEN_HEIGHT-self.getBottomSafeAreaHeight()-kFitWidth(102), width: SCREEN_WIDHT, height: kFitWidth(96))
        }
        self.scrollViewBase.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        self.scrollViewBase.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: self.saveBottomView.frame.minY)
//        self.scrollViewBase.contentSize = CGSize.init(width: 0, height: self.calfVm.frame.maxY)
    }
}
