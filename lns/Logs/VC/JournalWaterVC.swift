//JournalWaterVC
//
//  JournalWaterVC.swift
//  lns
//
//  Created by Elavatine on 2025/5/21.
//

import IQKeyboardManagerSwift


class JournalWaterVC: WHBaseViewVC {
    
    var sDate = ""
    ///是否修改总饮水量
    var totalNum = 0
    
    var numChangeBlock:((String)->())?
    
    let topGap = WHUtils().getNavigationBarHeight()+kFitWidth(377)
    let whiteViewHeight = SCREEN_HEIGHT-WHUtils().getNavigationBarHeight()
    var waterHistoryNumArray:[String] = [String]()
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.numberTextField.becomeFirstResponder()
//    }
//
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.numberTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DLLog(message: "sDate:\(sDate)")
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    lazy var topShadowView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: getNavigationBarHeight(), width: SCREEN_WIDHT, height: SCREEN_HEIGHT-getNavigationBarHeight()))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "本次饮用"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        
        if self.totalNum > 0 {
            lab.text = "总饮水量"
        }
        return lab
    }()
    lazy var numberTextField : NumericTextField = {
        let text = NumericTextField()
        text.placeholder = ""
        text.keyboardType = .numberPad
        text.font = UIFont().DDInFontBold(fontSize: 25)
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.delegate = self
        text.textAlignment = .center
        text.textContentType = nil
        
        if self.totalNum > 0 {
            text.text = "\(self.totalNum)"
        }
        
        return text
    }()
    lazy var numberLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_TEXT_TITLE_0f1214_20
        
        return vi
    }()
    lazy var numberUnitLabel : UILabel = {
        let lab = UILabel()
        lab.text = "ml"
        lab.font = .systemFont(ofSize: 15, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        return lab
    }()
    lazy var numberTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(numTapTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var historyNumButtonOne: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BG_F5), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_TEXT_TITLE_0f1214_20), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(13)
        btn.clipsToBounds = true
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        
        btn.addTarget(self, action: #selector(buttonOneTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var historyNumButtonTwo: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BG_F5), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_TEXT_TITLE_0f1214_20), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(13)
        btn.clipsToBounds = true
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        
        btn.addTarget(self, action: #selector(buttonTwoTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var historyNumButtonThree: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BG_F5), for: .normal)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_TEXT_TITLE_0f1214_20), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(13)
        btn.clipsToBounds = true
        btn.setTitleColor(.COLOR_TEXT_TITLE_0f1214_50, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        
        btn.addTarget(self, action: #selector(buttonThreeTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT), for: .highlighted)
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(21)
        btn.clipsToBounds = true
        btn.setTitleColor(.white, for: .normal)
        
        if self.totalNum > 0 {
            btn.setTitle("确认修改", for: .normal)
        }else{
            btn.setTitle("确认添加", for: .normal)
            btn.isEnabled = false
        }
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
}

extension JournalWaterVC{
    @objc func buttonOneTapAction()  {
        if waterHistoryNumArray.count > 0 {
            numberTextField.text = waterHistoryNumArray[0]
            confirmButton.isEnabled = true
        }
    }
    @objc func buttonTwoTapAction()  {
        if waterHistoryNumArray.count > 1 {
            numberTextField.text = waterHistoryNumArray[1]
            confirmButton.isEnabled = true
        }
    }
    @objc func buttonThreeTapAction()  {
        if waterHistoryNumArray.count > 2 {
            numberTextField.text = waterHistoryNumArray[2]
            confirmButton.isEnabled = true
        }
    }
    @objc func numTapTapAction()  {
        self.numberTextField.becomeFirstResponder()
    }
    @objc func confirmAction()  {
        if numberTextField.text?.count ?? 0 > 0{
            var totalNum = LogsSQLiteManager.getInstance().addWaterNumStatus(sDate: self.sDate, num: numberTextField.text ?? "0")
            if self.totalNum > 0 {
                totalNum = numberTextField.text ?? "0"
                HealthKitNaturnalManager().saveWaterData(sdate: self.sDate, waterNum: totalNum.doubleValue, isTotal: true)
            }else{
                UserDefaults.setWaterRecord(num: numberTextField.text ?? "")
                HealthKitNaturnalManager().saveWaterData(sdate: self.sDate, waterNum: (numberTextField.text ?? "").doubleValue, isTotal: false)
            }
            self.numChangeBlock?(totalNum)
            self.sendWaterSynRequest(waterNum: totalNum)
            LogsSQLiteManager.getInstance().insertWater(sDate: self.sDate, waterNum: totalNum)
            NotificationCenter.default.post(name: NOTIFI_NAME_SHORTCUTITEMS, object: nil)
            self.backTapAction()
        }else{
            //修改总饮水量 为 0的时候
            if self.totalNum > 0 {
                HealthKitNaturnalManager().saveWaterData(sdate: self.sDate, waterNum: 0, isTotal: true)
                self.numChangeBlock?("0")
                self.sendWaterSynRequest(waterNum: "0")
                LogsSQLiteManager.getInstance().insertWater(sDate: self.sDate, waterNum: "0")
                self.backTapAction()
            }
        }
    }
}

extension JournalWaterVC{
    func initUI() {
        initNavi(titleStr: "")
        
        view.insertSubview(topShadowView, belowSubview: self.navigationView)
        view.insertSubview(bottomView, belowSubview: topShadowView)
        
        bottomView.addSubview(tipsLabel)
        bottomView.addSubview(numberLineView)
        bottomView.addSubview(numberTextField)
        bottomView.addSubview(numberUnitLabel)
        bottomView.addSubview(numberTapView)
        
        if totalNum == 0 {
            bottomView.addSubview(historyNumButtonOne)
            bottomView.addSubview(historyNumButtonTwo)
            bottomView.addSubview(historyNumButtonThree)
        }
        
        bottomView.addSubview(confirmButton)
        
        setConstrait()
        topShadowView.addShadow(opacity: 0.05,offset: CGSize(width: 0, height: kFitHeight(3)))
        
        waterHistoryNumArray = UserDefaults.getWaterRecord()
        refreshHistoryData()
    }
    func setConstrait() {
        topShadowView.snp.makeConstraints { make in
            make.left.top.width.height.equalTo(self.navigationView)
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(114))
        }
        numberLineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(68))
            make.height.equalTo(kFitWidth(1))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(50))
        }
        numberTextField.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(76))
            make.bottom.equalTo(numberLineView).offset(kFitWidth(2))
            make.height.equalTo(kFitWidth(38))
        }
        numberUnitLabel.snp.makeConstraints { make in
            make.bottom.equalTo(numberLineView).offset(kFitWidth(-3))
            make.height.equalTo(kFitWidth(22))
            make.left.equalTo(numberLineView.snp.right).offset(kFitWidth(6))
        }
        numberTapView.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(200))
            make.top.equalTo(tipsLabel)
            make.bottom.equalTo(numberLineView).offset(kFitWidth(10))
            make.centerX.lessThanOrEqualToSuperview()
        }
        
        if totalNum == 0 {
            historyNumButtonTwo.snp.makeConstraints { make in
                make.centerX.lessThanOrEqualToSuperview()
                make.top.equalTo(numberLineView).offset(kFitWidth(37))
                make.width.equalTo(kFitWidth(90))
                make.height.equalTo(kFitWidth(26))
            }
            historyNumButtonOne.snp.makeConstraints { make in
                make.right.equalTo(historyNumButtonTwo.snp.left).offset(kFitWidth(-12))
                make.centerY.lessThanOrEqualTo(historyNumButtonTwo)
                make.width.height.equalTo(historyNumButtonTwo)
            }
            historyNumButtonThree.snp.makeConstraints { make in
                make.left.equalTo(historyNumButtonTwo.snp.right).offset(kFitWidth(12))
                make.centerY.lessThanOrEqualTo(historyNumButtonTwo)
                make.width.height.equalTo(historyNumButtonTwo)
            }
        }
        
        confirmButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(160))
            make.height.equalTo(kFitWidth(42))
            make.top.equalTo(numberLineView.snp.bottom).offset(kFitWidth(145))
        }
    }
    func refreshHistoryData() {
        for i in 0..<waterHistoryNumArray.count{
            if i == 0 {
                historyNumButtonOne.setTitle("+\(waterHistoryNumArray[i])ml", for: .normal)
            }else if i == 1 {
                historyNumButtonTwo.setTitle("+\(waterHistoryNumArray[i])ml", for: .normal)
            }else if i == 2 {
                historyNumButtonThree.setTitle("+\(waterHistoryNumArray[i])ml", for: .normal)
            }
        }
    }
}

extension JournalWaterVC{
    func sendWaterSynRequest(waterNum:String) {
        let param = ["sdate":self.sDate,
                     "qty":waterNum]
        WHNetworkUtil.shareManager().POST(urlString: URL_User_logs_update_water, parameters: param as [String:AnyObject]) { responseObject in
            let dataString = AESEncyptUtil.aesDecrypt(hexString: responseObject["data"]as? String ?? "")
            let dataObj = WHUtils.getDictionaryFromJSONString(jsonString: dataString ?? "")
            DLLog(message: "sendWaterSynRequest:\(dataObj)")
            
            LogsSQLiteManager.shared.updateWaterUploadStatus(sDate: self.sDate,
                                                             update: true,
                                                             eTime: dataObj.stringValueForKey(key: "etime").replacingOccurrences(of: "T", with: " "))
        }
    }
}
extension JournalWaterVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        if string == ""{
            if text.count <= 1{
                if self.totalNum > 0 {
                    confirmButton.isEnabled = true
                }else{
                    confirmButton.isEnabled = false
                }
            }
            return true
        }else if string == "0"{
            if text.count == 0 && self.totalNum == 0{
//                if self.totalNum > 0 {
//                    return true
//                }else{
                    return false
//                }
            }else if text.count > 0 && text.doubleValue == 0 {
                return false
            }
//            else{
//                return true
//            }
        }
        
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        
        if textField.text?.count ?? 0 > 3{
            return false
        }
        confirmButton.isEnabled = true
        return true
    }
}

extension JournalWaterVC{
    @objc func keyboardWillShow(notification: NSNotification) {
        numberTapView.isHidden = true
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let commoneHeight = (SCREEN_HEIGHT-keyboardSize.origin.y) - (SCREEN_HEIGHT-self.topGap)
            if commoneHeight > 0{
                UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
                    self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y:self.getNavigationBarHeight() + self.whiteViewHeight*0.5 - commoneHeight - kFitWidth(10))
                }
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        numberTapView.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveLinear) {
            self.bottomView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.getNavigationBarHeight()+self.whiteViewHeight*0.5)
//            self.bottomView.frame = CGRect.init(x:SCREEN_WIDHT*0.5, y: self.getNavigationBarHeight(), width: SCREEN_HEIGHT, height:self.whiteViewHeight)
        }
    }
}
