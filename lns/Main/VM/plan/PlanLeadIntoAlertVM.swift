//
//  PlanLeadIntoAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit
import MCToast
import IQKeyboardManagerSwift

class PlanLeadIntoAlertVM: UIView {
    
    var controller = WHBaseViewVC()
    var whiteViewFrame = CGRect()
    
    var leadBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = .clear//WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenAlertVm))
//        self.addGestureRecognizer(tap)
//        IQKeyboardManager.shared.enableAutoToolbar = false
        self.whiteViewFrame = CGRect.init(x: kFitWidth(28), y: SCREEN_HEIGHT*0.5-kFitWidth(145), width: SCREEN_WIDHT-kFitWidth(56), height: kFitWidth(290))
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenAlertVm))
        v.addGestureRecognizer(tap)
        return v
    }()
    lazy var whiteView : UIView = {
//        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(28), y: kFitWidth(160)+statusBarHeight, width: kFitWidth(320), height: kFitWidth(290)))
        let vi = UIView.init(frame: self.whiteViewFrame)
        vi.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 1)
        vi.alpha = 0
        vi.layer.cornerRadius = kFitWidth(8)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(nothingToDo))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.9)
        lab.font = .systemFont(ofSize: 18, weight: .semibold)
        lab.text = "导入计划"
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.6)
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.text = "输入分享码即可导入计划"
        
        return lab
    }()
    lazy var textField: UITextField = {
        let text = UITextField()
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 16, weight: .regular)
        text.textAlignment = .center
        text.delegate = self
        text.backgroundColor = WHColor_16(colorStr: "F3F3F3")
        text.layer.cornerRadius = kFitWidth(6)
        text.clipsToBounds = true
        text.placeholder = "输入五位数分享码"
        text.keyboardType = .asciiCapable
        text.returnKeyType = .done
        text.textContentType = nil
        
        return text
    }()
    lazy var confirmButton : UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = kFitWidth(4)
        btn.clipsToBounds = true
        btn.setTitle("确认导入该计划", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var cancelButton : UIButton = {
        let btn = UIButton()
        btn.setTitle("暂不导入", for: .normal)
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        
        btn.addTarget(self, action: #selector(hiddenAlertVm), for: .touchUpInside)
        
        return btn
    }()
}

extension PlanLeadIntoAlertVM{
    @objc func showAlertVM() {
        self.isHidden = false
        bgView.alpha = 0
        bgView.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.textField.becomeFirstResponder()
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut){
            self.whiteView.alpha = 1
            self.bgView.alpha = 0.25
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        }completion: { _ in
            self.bgView.isUserInteractionEnabled = true
        }
    }
    @objc func hiddenAlertVm() {
        self.textField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut){
            self.whiteView.alpha = 0
//            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
            self.bgView.alpha = 0
        }completion: { t in
            self.isHidden = true
        }
    }
    @objc func nothingToDo(){
        self.textField.resignFirstResponder()
    }
    @objc func confirmAction(){
        if self.textField.text?.count != 5 {
            MCToast.mc_text("请输入5位数的分享码",offset: kFitWidth(100)+SCREEN_HEIGHT*0.5,respond: .allow)
            return
        }
        self.sendLeadIntoPlanRequest()
    }
}

extension PlanLeadIntoAlertVM{
    func initUI() {
        addSubview(bgView)
        addSubview(whiteView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(tipsLabel)
        whiteView.addSubview(textField)
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(cancelButton)
        
        setConstrait()
    }
    func setConstrait() {
//        whiteView.snp.makeConstraints { make in
//            make.center.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(320))
//            make.height.equalTo(kFitWidth(290))
//        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(24))
            make.centerX.lessThanOrEqualToSuperview()
            make.height.equalTo(kFitWidth(26))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(58))
            make.height.equalTo(kFitWidth(24))
        }
        textField.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(106))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(96))
            make.height.equalTo(kFitWidth(48))
        }
        confirmButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(178))
            make.height.equalTo(kFitWidth(48))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(96))
        }
        cancelButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.height.equalTo(confirmButton)
            make.top.equalTo(kFitWidth(234))
        }
    }
}

extension PlanLeadIntoAlertVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        
        if WHBaseViewVC().isMatchPattern("[^A-Za-z0-9]", string) == true{
            return false
        }
        if textField.text?.count ?? 0 >= 5 {
            return false
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
    }
}

extension PlanLeadIntoAlertVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
                self.whiteView.frame = CGRect.init(x: self.whiteViewFrame.origin.x, y: SCREEN_HEIGHT-self.whiteViewFrame.height-keyboardSize.size.height, width: self.whiteViewFrame.width, height: self.whiteViewFrame.height)
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.whiteView.frame = self.whiteViewFrame
        }
    }
}

extension PlanLeadIntoAlertVM{
    func sendLeadIntoPlanRequest() {
        MCToast.mc_loading(text: "计划导入中...")
        let uId = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: UserInfoModel.shared.uId)
        let code = textField.text ?? ""
        let shareCode = try? AESEncyptUtil.encrypt_AES_CBC(encryptText: code)
        WHNetworkUtil.shareManager().GET(urlString: "\(URL_plan_leadinto)?uid=\(uId ?? "")&psharecode=\(shareCode ?? "")", vc: self.controller) { responseObject in
            self.hiddenAlertVm()
            self.textField.text =  ""
            if self.leadBlock != nil{
                self.leadBlock!()
            }
        }
    }
}
