//
//  SportCustomVC.swift
//  lns
//
//  Created by Elavatine on 2024/11/25.
//

import MCToast

class SportCustomVC: WHBaseViewVC {
    
    var model = SportCatogaryItemModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        //监听textField内容改变通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.greetingTextFieldChanged),
                                               name:NSNotification.Name(rawValue:"UITextFieldTextDidChangeNotification"),
                                               object: self.nameTextField)
    }
    
    lazy var confirmButton : FeedBackButton = {
        let button = FeedBackButton()
        button.setTitle("完成", for: .normal)
        button.setTitleColor(.THEME, for: .normal)
        button.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return button
    }()
    lazy var nameLab: UILabel = {
        let lab = UILabel()
        lab.text = "运动名称"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        
        return lab
    }()
    lazy var nameTextField: UITextField = {
        let text = UITextField()
        text.placeholder = "请输入"
        text.text = self.model.name
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 16, weight: .bold)
        text.textAlignment = .right
        text.delegate = self
        
        return text
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var timeVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.getNavigationBarHeight()+kFitWidth(56), width: 0, height: 0))
        vm.leftTitleLabel.text = "时长"
        vm.unitLabel.text = "分钟"
        vm.textField.placeholder = "请输入数值"
        vm.textField.text = self.model.minute
        vm.dataChangeBlock = {(text)in
//            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
    lazy var caloriesVm : DataAddItemVM = {
        let vm = DataAddItemVM.init(frame: CGRect.init(x: 0, y: self.timeVm.frame.maxY, width: 0, height: 0))
        vm.leftTitleLabel.text = "热量"
        vm.unitLabel.text = "千卡"
        vm.textField.placeholder = "请输入数值"
        vm.textField.text = self.model.calories
        vm.dataChangeBlock = {(text)in
//            self.changeSubmitButtonStatus(text:text)
        }
        return vm
    }()
}

extension SportCustomVC{
    @objc func saveAction() {
        if self.nameTextField.text?.count == 0 || self.nameTextField.text == ""{
            MCToast.mc_text("请输入运动名称",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        var timeNum = timeVm.textField.text ?? ""
        timeNum = timeNum.replacingOccurrences(of: ",", with: ".")
        if timeNum == ""  || timeNum.floatValue == 0 || timeNum.floatValue >= 1000 {
            MCToast.mc_text("时长数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        var caloriesNum = caloriesVm.textField.text ?? ""
        caloriesNum = caloriesNum.replacingOccurrences(of: ",", with: ".")
        if (caloriesNum.floatValue == 0 || caloriesNum.floatValue >= 1000) && caloriesNum.count > 0 {
            MCToast.mc_text("热量数据错误",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        caloriesNum = WHUtils.convertStringToString("\(60/timeNum.floatValue*caloriesNum.floatValue)") ?? ""
        
        if self.model.id.count > 0 {
            sendSportUpdateRequest(name: self.nameTextField.text ?? "", duration: "60", calories: caloriesNum)
        }else{
            sendSportAddRequest(name: self.nameTextField.text ?? "", duration: "60", calories: caloriesNum)
        }
    }
}

extension SportCustomVC{
    func initUI() {
        initNavi(titleStr: "自定义运动")
        self.navigationView.addSubview(confirmButton)
        
        view.addSubview(nameLab)
        view.addSubview(nameTextField)
        view.addSubview(lineView)
        
        view.addSubview(timeVm)
        view.addSubview(caloriesVm)
        
        setConstrait()
        
        if self.model.id.count > 0 {
            self.caloriesVm.textField.becomeFirstResponder()
        }
    }
    
    func setConstrait() {
        confirmButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-10))
            make.height.equalTo(kFitWidth(44))
            make.centerY.lessThanOrEqualTo(self.naviTitleLabel)
            make.width.equalTo(kFitWidth(52))
        }
        nameTextField.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.left.equalTo(nameLab.snp.right).offset(kFitWidth(20))
            make.top.equalTo(getNavigationBarHeight())
            make.height.equalTo(kFitWidth(56))
        }
        nameLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.centerY.lessThanOrEqualToSuperview()
            make.top.equalTo(getNavigationBarHeight())
            make.height.equalTo(kFitWidth(56))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(0.5))
            make.top.equalTo(getNavigationBarHeight()+kFitWidth(55.5))
        }
    }
}

extension SportCustomVC{
    func sendSportAddRequest(name:String,duration:String,calories:String) {
        let param = ["name":"\(name)",
                     "duration":"\(duration)".replacingOccurrences(of: ",", with: "."),
                     "calories":"\(calories)".replacingOccurrences(of: ",", with: ".")]
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_catogary_add, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendSportAddRequest:\(responseObject)")
            
            self.backTapAction()
        }
    }
    func sendSportUpdateRequest(name:String,duration:String,calories:String) {
        let param = ["id":"\(self.model.id)",
                     "name":"\(name)",
                     "duration":"\(duration)".replacingOccurrences(of: ",", with: "."),
                     "calories":"\(calories)".replacingOccurrences(of: ",", with: ".")]
        WHNetworkUtil.shareManager().POST(urlString: URL_sport_catogary_update, parameters: param as [String : AnyObject]) { responseObject in
            DLLog(message: "sendSportAddRequest:\(responseObject)")
            
            self.backTapAction()
        }
    }
}

extension SportCustomVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        
        if textField.text?.count ?? 0 >= 80{
            return false
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
    }
    //textField内容改变通知响应
    @objc func greetingTextFieldChanged(obj: Notification) {
        //非markedText才继续往下处理
        guard let _: UITextRange = nameTextField.markedTextRange else{
            //当前光标的位置（后面会对其做修改）
            let cursorPostion = nameTextField.offset(from: nameTextField.endOfDocument,
                                                 to: nameTextField.selectedTextRange!.end)
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9\\u0020\\u4E00-\\u9FA5]"//判断非中文非字母非数字的正则表达式
            var str = self.nameTextField.text!.pregReplace(pattern: pattern, with: "")
            if str.count > 30 {
                str = String(str.prefix(30))
            }
            self.nameTextField.text = str
             
            //让光标停留在正确位置
            let targetPostion = nameTextField.position(from: nameTextField.endOfDocument,
                                                   offset: cursorPostion)!
            nameTextField.selectedTextRange = nameTextField.textRange(from: targetPostion,
                                                              to: targetPostion)
            return
        }
    }
}
