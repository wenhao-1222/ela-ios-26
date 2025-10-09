//
//  InviteCodeAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/11.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class InviteCodeAlertVM: UIView {
    
    var whiteViewHeight = kFitWidth(374)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(16)
    var whiteViewOriginY = kFitWidth(0)
    
    var confirmBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        
        initUI()
        whiteViewOriginY = SCREEN_HEIGHT - whiteViewHeight + kFitWidth(16)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenLoginView))
        self.addGestureRecognizer(tap)
        
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView : UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(16)
        vi.clipsToBounds = true
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        // 创建下拉手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        // 将手势识别器添加到view
        vi.addGestureRecognizer(panGestureRecognizer)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(endEditAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var topLineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "D9D9D9")
        vi.layer.cornerRadius = kFitWidth(2)
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "邀请码"
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "如果您没有邀请码可以选择跳过"
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var inviteCodeTextField : UITextField = {
        let text = UITextField()
        text.placeholder = "请输入邀请码"
        text.textAlignment = .center
        text.font = .systemFont(ofSize: 18, weight: .medium)
        text.textColor = .COLOR_GRAY_BLACK_85
        text.keyboardType = .asciiCapable
        text.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        text.layer.cornerRadius = kFitWidth(8)
        text.clipsToBounds = true
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        
        return text
    }()
    lazy var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .THEME
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = kFitWidth(8)
        btn.clipsToBounds = true
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.backgroundColor = .white
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        btn.addTarget(self, action: #selector(hiddenLoginView), for: .touchUpInside)
        
        return btn
    }()
    lazy var topCloseTapView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        vi.isHidden = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hiddenLoginView))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
}

extension InviteCodeAlertVM{
    @objc func endEditAction(){
        self.inviteCodeTextField.resignFirstResponder()
    }
    @objc func confirmAction(){
        if self.confirmBlock != nil{
            self.confirmBlock!(self.inviteCodeTextField.text ?? "")
        }
        self.hiddenLoginView()
    }
     @objc func showLoginView() {
         self.isHidden = false
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//         self.inviteCodeTextField.becomeFirstResponder()
         UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
//             self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
//             self.whiteView.frame = CGRect.init(x: 0, y: self.whiteViewOriginY, width: SCREEN_WIDHT, height: self.whiteViewHeight)
             self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: self.whiteViewOriginY+self.whiteViewHeight*0.5)
             self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
         }completion: { t in
//             self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
         }
    }
    @objc func hiddenLoginView() {
        self.inviteCodeTextField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5+kFitWidth(16))
            self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
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
                DLLog(message: "translation.y:\(translation.y)")
                if translation.y < 0 && view.frame.minY <= self.whiteViewOriginY{
                    return
                }
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
                gesture.setTranslation(.zero, in: view)
                
            case .ended:
                if view.frame.minY - self.whiteViewOriginY >= kFitWidth(20){
                    self.hiddenLoginView()
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
}

extension InviteCodeAlertVM{
    func initUI() {
        addSubview(whiteView)
        addSubview(topCloseTapView)
        
        whiteView.addSubview(topLineView)
        whiteView.addSubview(titleLabel)
        whiteView.addSubview(tipsLabel)
        whiteView.addSubview(inviteCodeTextField)
        whiteView.addSubview(confirmButton)
        whiteView.addSubview(cancelButton)
        
        setConstrait()
    }
    func setConstrait()  {
        whiteView.snp.makeConstraints { make in
            make.left.width.equalToSuperview()
            make.height.equalTo(whiteViewHeight)
            make.bottom.equalTo(kFitWidth(16)+SCREEN_HEIGHT)
        }
        topCloseTapView.snp.makeConstraints { make in
            make.left.top.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT-whiteViewHeight+kFitWidth(40))
        }
        topLineView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(18))
            make.width.equalTo(kFitWidth(43))
            make.height.equalTo(kFitWidth(4))
            make.centerX.lessThanOrEqualToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(60))
            make.centerX.lessThanOrEqualToSuperview()
        }
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(108))
            make.centerX.lessThanOrEqualToSuperview()
        }
        inviteCodeTextField.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(166))
            make.width.equalTo(kFitWidth(343))
            make.height.equalTo(kFitWidth(56))
        }
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(inviteCodeTextField.snp.bottom).offset(kFitWidth(20))
            make.width.height.equalTo(inviteCodeTextField)
            make.centerX.lessThanOrEqualToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(confirmButton.snp.bottom).offset(kFitWidth(20))
            make.width.height.equalTo(inviteCodeTextField)
            make.centerX.lessThanOrEqualToSuperview()
        }
    }
}

extension InviteCodeAlertVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if string == " "{
            return false
        }
        if range.length > 0 {
            return true
        }
        if textField.text?.count ?? 0 >= 8{
            return false
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.confirmAction()
        return true
    }
}

extension InviteCodeAlertVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            DLLog(message: "keyboardSize:\(keyboardSize)")
//            DLLog(message: "\(SCREEN_HEIGHT)")
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-self.whiteViewHeight*0.5+kFitWidth(16))
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.whiteView.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-kFitWidth(32))
        }completion: { t in
            self.hiddenLoginView()
        }
    }
}
