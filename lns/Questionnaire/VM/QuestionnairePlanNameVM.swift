//
//  QuestionnairePlanNameVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/1.
//

import Foundation
import UIKit
import MCToast

class QuestionnairePlanNameVM: UIView {
    
    var showTipsBlock:(()->())?
    var submitBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bottomView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .white
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "您的计划名称是？"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tipsButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("如何查看并使用计划？", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        btn.addTarget(self, action: #selector(showTipsAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var nameTextField : ChineseTextField = {
        let text = ChineseTextField()
        text.layer.cornerRadius = kFitWidth(8)
        text.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        text.placeholder = "请输入计划名称"
        text.textAlignment = .center
        text.font = .systemFont(ofSize: 20, weight: .medium)
        text.textColor = .COLOR_GRAY_BLACK_85
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        text.textNumber = 50
        
        return text
    }()
    lazy var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("开始体验", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
}

extension QuestionnairePlanNameVM{
    @objc func showTipsAction() {
        self.nameTextField.resignFirstResponder()
        if self.showTipsBlock != nil{
            self.showTipsBlock!()
        }
    }
    @objc func confirmAction(){
        QuestinonaireMsgModel.shared.name = (nameTextField.text ?? "").disable_emoji(text: (nameTextField.text ?? "")as NSString)
        if QuestinonaireMsgModel.shared.name.count < 1 {
            MCToast.mc_text("请输入您的计划名称")
            return
        }
        if QuestinonaireMsgModel.shared.name.count > 15 {
            MCToast.mc_text("计划名称不能超过15个字")
            return
        }
        if self.submitBlock != nil{
            self.submitBlock!()
        }
    }
}
extension QuestionnairePlanNameVM{
    func initUI() {
        addSubview(bottomView)
        bottomView.addSubview(titleLabel)
        bottomView.addSubview(tipsButton)
        bottomView.addSubview(nameTextField)
        bottomView.addSubview(confirmBtn)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(160))
            make.centerX.lessThanOrEqualToSuperview()
        }
        tipsButton.snp.makeConstraints { make in
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(208))
            make.centerX.lessThanOrEqualToSuperview()
        }
        nameTextField.snp.makeConstraints { make in
            make.width.equalTo(kFitWidth(343))
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(286))
            make.height.equalTo(kFitWidth(72))
        }
        confirmBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(398)+WHUtils().getNavigationBarHeight())
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(48))
        }
    }
    func refreshUI(isShowKeyboard:Bool) {
        let topGap = isShowKeyboard ? kFitWidth(-200) : kFitWidth(0)
        
        let titleLabelFrame = titleLabel.frame
        let tipsButtonFrame = tipsButton.frame
        let nameTextFieldFrame = nameTextField.frame
        let confirmBtnFrame = confirmBtn.frame
        
        UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseInOut) {
            self.titleLabel.frame = CGRect.init(x: titleLabelFrame.origin.x,
                                                y: WHUtils().getNavigationBarHeight()+kFitWidth(160)+topGap,
                                                width: titleLabelFrame.width,
                                                height: titleLabelFrame.height)
            self.tipsButton.frame = CGRect.init(x: tipsButtonFrame.origin.x,
                                                y: WHUtils().getNavigationBarHeight()+kFitWidth(208)+topGap,
                                                width: tipsButtonFrame.width,
                                                height: tipsButtonFrame.height)
            self.nameTextField.frame = CGRect.init(x: nameTextFieldFrame.origin.x,
                                                y: WHUtils().getNavigationBarHeight()+kFitWidth(286)+topGap,
                                                width: nameTextFieldFrame.width,
                                                height: nameTextFieldFrame.height)
            self.confirmBtn.frame = CGRect.init(x: confirmBtnFrame.origin.x,
                                                y: WHUtils().getNavigationBarHeight()+kFitWidth(398)+topGap,
                                                width: confirmBtnFrame.width,
                                                height: confirmBtnFrame.height)
        }
        
//        titleLabel.snp.remakeConstraints { make in
//            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(160)+topGap)
//            make.centerX.lessThanOrEqualToSuperview()
//        }
//        tipsButton.snp.remakeConstraints { make in
//            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(208)+topGap)
//            make.centerX.lessThanOrEqualToSuperview()
//        }
//        nameTextField.snp.remakeConstraints { make in
//            make.width.equalTo(kFitWidth(343))
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(WHUtils().getNavigationBarHeight()+kFitWidth(286)+topGap)
//            make.height.equalTo(kFitWidth(72))
//        }
//        confirmBtn.snp.remakeConstraints { make in
//            make.centerX.lessThanOrEqualToSuperview()
//            make.top.equalTo(kFitWidth(398)+WHUtils().getNavigationBarHeight()+topGap)
//            make.width.equalTo(kFitWidth(200))
//            make.height.equalTo(kFitWidth(48))
//        }
    }
}

extension QuestionnairePlanNameVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        if string.isNineKeyBoard() {
            return true
        }else{
            if string.hasEmoji() || string.containsEmoji() || string.isChineseNumberAscii() {
                return false
            }
        }

        if textField.textInputMode?.primaryLanguage == "emoji" || !((textField.textInputMode?.primaryLanguage) != nil){
            return false
        }
        if range.length > 0 {
            return true
        }
        if textField.text?.count ?? 0 > 30 {
            return false
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
    }
}

extension QuestionnairePlanNameVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.refreshUI(isShowKeyboard: true)
           
//            UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
//                self.bottomView.frame = CGRect.init(x:0, y: -keyboardSize.height+SCREEN_HEIGHT-(kFitWidth(450)+WHUtils().getNavigationBarHeight()), width: SCREEN_HEIGHT, height:SCREEN_HEIGHT)
//            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
//        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
//            self.bottomView.frame = CGRect.init(x:0, y: 0, width: SCREEN_HEIGHT, height:SCREEN_HEIGHT)
//        }
        self.refreshUI(isShowKeyboard: false)
    }
}
