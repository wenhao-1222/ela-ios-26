//
//  MainSaveNutrationAlertVM.swift
//  lns
//   保存今日目标弹窗
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import UIKit
import MCToast

class MainSaveNutrationAlertVM: UIView {
    
    var carNumber = 0
    var proteinNumber = 0
    var fatNumber = 0
    
    var saveBlock:(()->())?
    
    var whiteViewFrame = CGRect()
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .COLOR_GRAY_BLACK_85
        self.isUserInteractionEnabled = true
        
        self.isHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenView))
        self.addGestureRecognizer(tap)
        
        initUI()
        
        self.whiteViewFrame = whiteView.frame
        
//        updateUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(28), y: kFitWidth(160)+statusBarHeight, width: kFitWidth(320), height: kFitWidth(470)))
        vi.backgroundColor = .white
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var labelOne : UILabel = {
        let lab = UILabel()
        lab.text = "-"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = UIFont().DDInFontMedium(fontSize: 28)
        
        return lab
    }()
    lazy var labelTwo : UILabel = {
        let lab = UILabel()
        lab.text = "卡路里 (千卡)"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var goalImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "question_goal_selected")
        
        return img
    }()
    lazy var carVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: kFitWidth(0), y: kFitWidth(114), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "碳水化合物"
        if QuestinonaireMsgModel.shared.surveytype == "part" {
            vm.textField.isEnabled = false
        }
        vm.numberChangeBlock = {(number)in
            self.carNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var proteinVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(182), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "蛋白质"
        if QuestinonaireMsgModel.shared.surveytype == "part" {
            vm.textField.isEnabled = false
        }
        vm.numberChangeBlock = {(number)in
            self.proteinNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var fatVm : QuestionCustomItemVM = {
        let vm = QuestionCustomItemVM.init(frame: CGRect.init(x: 0, y: kFitWidth(250), width: kFitWidth(320), height: 0))
        vm.titleLabel.text = "脂肪"
        if QuestinonaireMsgModel.shared.surveytype == "part" {
            vm.textField.isEnabled = false
        }
        vm.numberChangeBlock = {(number)in
            self.fatNumber = Int(number) ?? 0
            self.calculateNumber()
        }
        return vm
    }()
    lazy var nextBtn : UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: kFitWidth(20), y: kFitWidth(346), width: kFitWidth(281), height: kFitWidth(48))
        btn.setTitle("保存营养目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_BG_THEME, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var cancelButton : FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
}


extension MainSaveNutrationAlertVM{
    func showView() {
        self.isHidden = false
        whiteView.alpha = 0
        self.alpha = 0
        
        carVm.textField.isEnabled = true
        proteinVm.textField.isEnabled = true
        fatVm.textField.isEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.carVm.textField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.whiteView.alpha = 1
        }
        UIView.animate(withDuration: 0.4, delay: 0.1,options: .curveLinear) {
            self.alpha = 1
        }
    }
    
    @objc func hiddenView() {
        NotificationCenter.default.removeObserver(self)
        self.carVm.textField.resignFirstResponder()
        self.proteinVm.textField.resignFirstResponder()
        self.fatVm.textField.resignFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0,options: .curveLinear) {
            self.alpha = 0
        }
        UIView.animate(withDuration: 0.3, delay: 0.2,options: .curveLinear) {
            self.whiteView.alpha = 0
        }completion: { c in
            self.isHidden = true
        }
    }
    
    @objc func nothingToDo() {
        self.carVm.textField.resignFirstResponder()
        self.proteinVm.textField.resignFirstResponder()
        self.fatVm.textField.resignFirstResponder()
    }
    func clearText() {
        self.carVm.textField.text = ""
        self.proteinVm.textField.text = ""
        self.fatVm.textField.text = ""
        labelOne.text = "-"
        carNumber = 0
        proteinNumber = 0
        fatNumber = 0
    }
    func calculateNumber() {
        if self.carNumber == 0 && self.fatNumber == 0 && self.fatNumber == 0{
            labelOne.text = "-"
            labelOne.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
            return
        }
        //((protein + carbohydrate) * 4) + (fat * 9);
        let number = (proteinNumber + carNumber) * 4 + fatNumber * 9
        labelOne.text = "\(number)"
        labelOne.textColor = .COLOR_GRAY_BLACK_85
    }
    @objc func nextAction(){
        if carVm.textField.text?.count == 0 {
            MCToast.mc_text("请输入碳水化合物数值",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        
        if Int(carVm.textField.text ?? "0") ?? 0 >= 0 && Int(carVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("碳水化合物目标数值范围 0 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if Int(proteinVm.textField.text ?? "0") ?? 0 >= 1 && Int(proteinVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("蛋白质目标数值范围 1 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        if Int(fatVm.textField.text ?? "0") ?? 0 >= 1 && Int(fatVm.textField.text ?? "0") ?? 0 <= 4999 {
            
        }else{
            MCToast.mc_text("脂肪目标数值范围 1 ~ 4999 g",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        QuestinonaireMsgModel.shared.carbohydrates = carVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.protein = proteinVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.fats = fatVm.textField.text ?? "0"
        QuestinonaireMsgModel.shared.calories = labelOne.text ?? "0"
        
        if self.saveBlock != nil{
            self.saveBlock!()
        }
        self.hiddenView()
    }
}

extension MainSaveNutrationAlertVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(labelOne)
        whiteView.addSubview(labelTwo)
        whiteView.addSubview(goalImgView)
        whiteView.addSubview(carVm)
        whiteView.addSubview(proteinVm)
        whiteView.addSubview(fatVm)
        
        whiteView.addSubview(nextBtn)
        whiteView.addSubview(cancelButton)
        
        whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        setConstrait()
    }
    
    func setConstrait(){
        labelOne.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(24))
            make.height.equalTo(kFitWidth(24))
        }
        labelTwo.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(62))
        }
        goalImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-20))
            make.top.equalTo(kFitWidth(24))
            make.width.height.equalTo(kFitWidth(48))
        }
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(nextBtn)
            make.width.equalTo(kFitWidth(60))
            make.top.equalTo(nextBtn.snp.bottom).offset(kFitWidth(12))
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
    func updateUI(msgDict:NSDictionary) {
//        let msgString = UserDefaults.getString(forKey: .nutritionDefault) ?? ""
//        if msgString.count > 0 {
//            let msgDict = WHUtils.getDictionaryFromJSONString(jsonString: msgString)
        
        self.carNumber = Int(msgDict.doubleValueForKey(key: "carbohydrateden").rounded())
        self.proteinNumber = Int(msgDict.doubleValueForKey(key: "proteinden").rounded())
        self.fatNumber = Int(msgDict.doubleValueForKey(key: "fatden").rounded())
        
        labelOne.text = msgDict.stringValueForKey(key: "caloriesden")
        carVm.textField.text = "\(self.carNumber)"
        proteinVm.textField.text = "\(self.proteinNumber)"
        fatVm.textField.text = "\(self.fatNumber)"
        labelOne.textColor = .COLOR_GRAY_BLACK_85
            
            
        
//        }
    }
}

extension MainSaveNutrationAlertVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if view.frame.origin.y == 0 {
//                view.frame.origin.y -= keyboardSize.height
//            }
            UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
                self.whiteView.frame = CGRect.init(x: self.whiteViewFrame.origin.x, y: SCREEN_HEIGHT-keyboardSize.height-self.whiteViewFrame.height+kFitWidth(20), width: self.whiteViewFrame.width, height: self.whiteViewFrame.height)
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
//        if view.frame.origin.y != 0 {
//            view.frame.origin.y = 0
//        }
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.whiteView.frame = self.whiteViewFrame
        }
    }

}
