//
//  FoodsMergeFoodsSoonAlertVm.swift
//  lns
//
//  Created by Elavatine on 2025/3/17.
//

import MCToast

class FoodsMergeFoodsSoonAlertVm: UIView {
    
    var whiteViewHeight = kFitWidth(382)+kFitWidth(54)+WHUtils().getBottomSafeAreaHeight()
    var whiteViewOriginY = kFitWidth(67)
    
    var carNumber = Float(0)
    var proteinNumber = Float(0)
    var fatNumber = Float(0)
    
    var ctype = "1"
    var index = IndexPath()
    
    var updateBlock:((NSDictionary)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        initUI()
        
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
        
        //        let tap = UITapGestureRecognizer.init(target: self, action:#selector(hiddenView))
        //        self.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView : UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: kFitWidth(67) + SCREEN_HEIGHT, width: SCREEN_WIDHT, height: whiteViewHeight))
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
//        // 将手势识别器添加到view
//        vi.addGestureRecognizer(panGestureRecognizer)
        
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 17, weight: .semibold)
        
        return lab
    }()
    lazy var closeImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "date_fliter_cancel_img")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var closeTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var caloriVm : FoodsCreateCaloriVM = {
        let vm = FoodsCreateCaloriVM.init(frame: CGRect.init(x: 0, y: kFitWidth(54), width: 0, height: 0))
        vm.numberLabel.isEnabled = true
        vm.numberTapView.isUserInteractionEnabled = true
//        vm.hiddenUnitChange()
        vm.numberChangeBlock = {(number)in
            if number.count > 0 {
                self.saveButton.isEnabled = true
            }else{
                self.saveButton.isEnabled = false
                if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
                    self.caloriVm.numberLabel.text = ""
                    return
                }
                self.saveButton.isEnabled = true
            }
        }
        return vm
    }()
    lazy var carboVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(118), width: 0, height: 0))
        vm.titleLabel.text = "碳水"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            self.carNumber = Float(number) ?? 0.0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.carboVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "蛋白质"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            self.proteinNumber = Float(number) ?? 0.0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : FoodsCreateItemVM = {
        let vm = FoodsCreateItemVM.init(frame: CGRect.init(x: 0, y: self.proteinVm.frame.maxY, width: 0, height: 0))
        vm.titleLabel.text = "脂肪"
        vm.maxLength = 4
        vm.numberChangeBlock = {(number)in
            self.fatNumber = Float(number) ?? 0.0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var remarkVm: FoodsCreateFastRemarkVM = {
        let vm = FoodsCreateFastRemarkVM.init(frame: CGRect.init(x: 0, y: fatVm.frame.maxY+kFitWidth(4), width: 0, height: 0))
        
        return vm
    }()
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(20), y: self.whiteViewHeight-kFitWidth(70)-WHUtils().getBottomSafeAreaHeight(), width: SCREEN_WIDHT-kFitWidth(40), height: kFitWidth(48))
        btn.backgroundColor = .THEME
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_DISABLE_BG_THEME), for: .disabled)
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        
        return btn
    }()
}

extension FoodsMergeFoodsSoonAlertVm{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(nameLabel)
        whiteView.addSubview(closeImgView)
        whiteView.addSubview(closeTapView)
        whiteView.addSubview(caloriVm)
        whiteView.addSubview(proteinVm)
        whiteView.addSubview(fatVm)
        whiteView.addSubview(carboVm)
        whiteView.addSubview(remarkVm)
        whiteView.addSubview(saveButton)
        
        setConstrait()
    }
    func setConstrait() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(54))
            make.right.equalTo(kFitWidth(-80))
        }
        closeImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.width.height.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(nameLabel)
        }
        closeTapView.snp.makeConstraints { make in
            make.width.height.equalTo(kFitWidth(54))
            make.center.lessThanOrEqualTo(closeImgView)
        }
    }
    func updateUI(dict:NSDictionary) {
        caloriVm.unit = "kj"
        caloriVm.changeUnitAction()
        self.ctype = dict.stringValueForKey(key: "ctype")
        nameLabel.text = dict.stringValueForKey(key: "fname")
        carNumber = Float(dict.stringValueForKey(key: "carbohydrate")) ?? 0.0
        proteinNumber = Float(dict.stringValueForKey(key: "protein")) ?? 0.0
        fatNumber = Float(dict.stringValueForKey(key: "fat")) ?? 0.0
        caloriVm.numberLabel.text = dict.stringValueForKey(key: "calories")
        carboVm.textField.text = dict.stringValueForKey(key: "carbohydrate")
        proteinVm.textField.text = dict.stringValueForKey(key: "protein")
        fatVm.textField.text = dict.stringValueForKey(key: "fat")
        remarkVm.textField.text = dict.stringValueForKey(key: "remark")
        
        if self.ctype == "3"{
            self.nameLabel.text = "\(dict.stringValueForKey(key: "remark"))"
            remarkVm.isHidden = true
        }
        
        self.showView()
    }
}

extension FoodsMergeFoodsSoonAlertVm{
    @objc func saveAction(){
        var calories = self.caloriVm.numberLabel.text ?? "0"
        
        if calories == "" {
            calories = "0"
        }
        if self.caloriVm.unit == "kj"{
            let caloriesFLoat = (calories.floatValue)/4.18585
            calories = "\(WHUtils.convertStringToString("\(caloriesFLoat.rounded())") ?? "0")"
        }
        if calories != "" && calories != "0"{
            
        }else{
            if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
                MCToast.mc_text("请填写至少一种营养元素含量")
                return
            }
        }
        
        if calories.floatValue >= 100000 {
            MCToast.mc_text("食物热量数据错误！")
            return
        }
        if carNumber >= 100000 {
            MCToast.mc_text("食物碳水数据错误！")
            return
        }
        if proteinNumber >= 100000 {
            MCToast.mc_text("食物蛋白质数据错误！")
            return
        }
        if fatNumber >= 100000 {
            MCToast.mc_text("食物脂肪数据错误！")
            return
        }
        
        let foodsDict = ["proteinNumber":"\(proteinNumber)",
                         "carbohydrateNumber":"\(carNumber)",
                         "fatNumber":"\(fatNumber)",
                         "caloriesNumber":"\(calories)".replacingOccurrences(of: ",", with: "."),
                         "protein":"\(proteinNumber)",
                          "carbohydrate":"\(carNumber)",
                          "fat":"\(fatNumber)",
                         "calories":"\(calories)".replacingOccurrences(of: ",", with: "."),
                         "state":"1",
                         "ctype":self.ctype,
                         "remark":"\((self.remarkVm.textField.text ?? "").disable_emoji(text: (self.remarkVm.textField.text ?? "")as NSString))",
                         "fname":"快速添加"]
        self.updateBlock?(foodsDict as NSDictionary)
        self.hiddenView()
    }
}

extension FoodsMergeFoodsSoonAlertVm{
    @objc func nothingToDo() {
        self.caloriVm.numberLabel.resignFirstResponder()
        self.carboVm.textField.resignFirstResponder()
        self.proteinVm.textField.resignFirstResponder()
        self.fatVm.textField.resignFirstResponder()
        self.remarkVm.textField.resignFirstResponder()
    }
    func showView() {
        self.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
            self.whiteView.alpha = 1
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: (SCREEN_HEIGHT-self.whiteViewHeight*0.5+kFitWidth(16)))
        }
    }
    @objc func hiddenView() {
        self.nothingToDo()
        NotificationCenter.default.removeObserver(self)
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.0)
            self.whiteView.alpha = 0.5
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // 获取当前手势所在的view
        if let view = gesture.view {
            // 根据手势移动view的位置
            switch gesture.state {
            case .changed:
                let translation = gesture.translation(in: view)
//                DLLog(message: "translation.y:\(translation.y)")
                if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                    self.hiddenView()
                }else{
                    UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                        self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
                    }
                }
            default:
                break
            }
        }
    }
    func calculateNumber() {
        saveButton.isEnabled = false
        if self.carNumber == 0 && self.proteinNumber == 0 && self.fatNumber == 0{
            caloriVm.numberLabel.text = ""
            return
        }
        saveButton.isEnabled = true
        
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        
        if caloriVm.unit == "kcal"{
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(number.rounded())") ?? "")"
        }else{
            let numberKj = number * 4.18585
            caloriVm.numberLabel.text = "\(WHUtils.convertStringToString("\(numberKj.rounded())") ?? "")"
        }
    }
}

extension FoodsMergeFoodsSoonAlertVm{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-self.whiteViewHeight*0.5+kFitWidth(16))
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
        }
    }
}
