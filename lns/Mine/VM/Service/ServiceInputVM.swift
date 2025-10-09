//
//  ServiceInputVM.swift
//  lns
//
//  Created by LNS2 on 2024/6/12.
//

import Foundation
import IQKeyboardManagerSwift

class ServiceInputVM: UIView {
    
    let selfHeight = kFitWidth(64)+WHUtils().getBottomSafeAreaHeight()
    
    var imgChoiceBlock:(()->())?
    var textSendBlock:(()->())?
    var textDidInputBlock:((CGFloat)->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-selfHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        initUI()
        
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    lazy var whiteView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: kFitWidth(64)))
        vi.backgroundColor = .white
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var textBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(12), y: kFitWidth(8), width: SCREEN_WIDHT-kFitWidth(60)-kFitWidth(22), height: kFitWidth(48)))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.layer.cornerRadius = kFitWidth(24)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var textView: UITextView = {
        let text = UITextView.init(frame: CGRect.init(x: kFitWidth(8), y: kFitWidth(4), width: SCREEN_WIDHT-kFitWidth(60)-kFitWidth(38), height: kFitWidth(40)))
//        let text = UITextView()
        text.backgroundColor = .clear
        text.delegate = self
        text.returnKeyType = .send
        return text
    }()
    lazy var addBgView: UIButton = {
        let img = UIButton.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(12)-kFitWidth(48), y: kFitWidth(8), width: kFitWidth(48), height: kFitWidth(48)))
        img.setImage(UIImage(named: "service_add_bg"), for: .normal)
        img.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "000000", alpha: 0.02)), for: .highlighted)
//        img.layer.cornerRadius = kFitWidth(8)
//        img.clipsToBounds = true
        
        img.addTarget(self, action: #selector(imgTapAction), for: .touchUpInside)
        
        return img
    }()
    lazy var timeLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: kFitWidth(-15), width: SCREEN_WIDHT, height: kFitWidth(15)))
        lab.text = "客服工作时间：9:00 ~ 18:00（工作日）"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.2)
        lab.backgroundColor = .white
        lab.font = .systemFont(ofSize: 8, weight: .regular)
        lab.textAlignment = .center
        lab.isHidden = true
        
        return lab
    }()
}

extension ServiceInputVM{
    @objc func imgTapAction() {
        if self.imgChoiceBlock != nil{
            self.imgChoiceBlock!()
        }
    }
}
extension ServiceInputVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(textBgView)
        textBgView.addSubview(textView)
        whiteView.addSubview(addBgView)
        whiteView.addSubview(timeLabel)
        
//        textView.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(8))
//            make.right.equalTo(kFitWidth(-8))
//            make.centerY.lessThanOrEqualToSuperview()
//        }
    }
}

extension ServiceInputVM{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.textDidInputBlock != nil{
                self.textDidInputBlock!(keyboardSize.origin.y)
            }
            UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
                self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: keyboardSize.origin.y-kFitWidth(32))
            }completion: { t in
                
            }
        }
    }
     
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.textDidInputBlock != nil{
            self.textDidInputBlock!(0)
        }
        UIView.animate(withDuration: 0.7, delay: 0,options: .curveLinear) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT-kFitWidth(32))
        }completion: { t in
            
        }
    }
}

extension ServiceInputVM:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == ""{
            return true
        }
        if text == "\n"{
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                if self.textSendBlock != nil{
                    self.textSendBlock!()
                }
//                self.textView.resignFirstResponder()
            }
            return false
        }
        
        if text.isNineKeyBoard() {
            return true
        }else{
            if text.hasEmoji(){
                return false
            }
//            if text.hasEmoji() || text.containsEmoji() {
//                return false
//            }
        }

        if textView.textInputMode?.primaryLanguage == "emoji" || !((textView.textInputMode?.primaryLanguage) != nil){
            return false
        }
        if textView.text.count >= 400{
            return false
        }
        
        return true
    }
}
