//
//  FoodsCreateCaloriVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

class FoodsCreateCaloriVM: UIView {
    
    let selfHeight = kFitWidth(54)
    
    var unit = "kcal"//kcal   kj
    var numberChangeBlock:((String)->())?
    var unitChangeBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var numberLabel : NumericTextField = {
        let lab = NumericTextField()
//        lab.text = "-"
        lab.placeholder = "-"
        lab.delegate = self
        lab.keyboardType = .numberPad
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.textContentType = nil
//        lab.isEnabled = false
        
        return lab
    }()
    lazy var numberTapView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
//        vi.isUserInteractionEnabled = false
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(numberTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "热量（千卡）"
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        return lab
    }()
//    lazy var kjLabel: UILabel = {
//        let lab = UILabel()
//        lab.font = .systemFont(ofSize: 16, weight: .medium)
//        lab.textColor = .COLOR_GRAY_BLACK_45
//        
//        return lab
//    }()
    lazy var changeUnitButton: UIButton = {
//        let btn = GJVerButton.init(frame: CGRect.init(x: 0, y: 0, width: kFitWidth(120), height: selfHeight-WHUtils().getBottomSafeAreaHeight()))
        let btn = UIButton()
        btn.setTitleColor(.THEME, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        btn.backgroundColor = .clear
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.setImage(UIImage.init(named: "circle_change_icon"), for: .normal)
        btn.addTarget(self, action: #selector(changeUnitAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var kcalUnitLabel: UILabel = {
        let lab = UILabel()
        lab.text = "千卡"
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()
    lazy var kjUnitLabel: UILabel = {
        let lab = UILabel()
        lab.text = "千焦"
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()
    lazy var unitTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        let tap = FeedBackTapGestureRecognizer.init(target: self, action: #selector(changeUnitAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
}

extension FoodsCreateCaloriVM{
    @objc func numberTapAction() {
        numberLabel.becomeFirstResponder()
    }
    @objc func changeUnitAction() {
        if self.unit == "kcal"{
            self.unit = "kj"
            kjUnitLabel.text = "千卡"
        }else{
            self.unit = "kcal"
            kjUnitLabel.text = "千焦"
        }
        self.refreshTipsLabel()
        let num = numberLabel.text
        let numFloat = num?.floatValue ?? 0
        
        if numFloat == 0{
            numberLabel.text = ""
            self.unitChangeBlock?()
            return
        }
        
        if self.unit == "kj"{
            let kjNum = numFloat * 4.18585
            numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(kjNum.rounded())") ?? "0")"
        }else{
            let kcalNum = numFloat / 4.18585
            numberLabel.text = "\(WHUtils.convertStringToStringNoDigit("\(kcalNum.rounded())") ?? "0")"
        }
        self.unitChangeBlock?()
    }
    func refreshTipsLabel() {
        let attr = NSMutableAttributedString(string: "热量（")
        let unitAttr = NSMutableAttributedString(string: "\(self.unit == "kcal" ? "千卡" : "千焦")")
        let rightAttr = NSMutableAttributedString(string: "）")
        
        unitAttr.yy_color = .THEME
        attr.append(unitAttr)
        attr.append(rightAttr)
        
        tipsLabel.attributedText = attr
    }
    func hiddenUnitChange() {
        changeUnitButton.isHidden = true
        kcalUnitLabel.isHidden = true
        kjUnitLabel.isHidden = true
        unitTapView.isHidden = true
        tipsLabel.text = "热量（千卡）"
    }
}

extension FoodsCreateCaloriVM{
    func initUI() {
        addSubview(numberLabel)
        addSubview(tipsLabel)
//        addSubview(kjLabel)
//        addSubview(kcalUnitLabel)
        addSubview(changeUnitButton)
        addSubview(kjUnitLabel)
        addSubview(numberTapView)
        addSubview(unitTapView)
        
        setConstrait()
        refreshTipsLabel()
        
//        changeUnitButton.setTitle("切换单位", for: .normal)
//        changeUnitButton.setImage(UIImage.init(named: "circle_change_icon"), for: .normal)
//        changeUnitButton.imagePosition(style: .right, spacing: kFitWidth(3))
    }
    func setConstrait() {
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(5))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-5))
        }
//        kjLabel.snp.makeConstraints { make in
//            make.left.equalTo(tipsLabel.snp.right).offset(kFitWidth(10))
//            make.centerY.lessThanOrEqualToSuperview()
//        }
        numberTapView.snp.makeConstraints { make in
            make.left.top.height.equalToSuperview()
            make.right.equalTo(tipsLabel)
//            make.width.equalTo(kFitWidth(120))
        }
//        kcalUnitLabel.snp.makeConstraints { make in
//            make.left.equalTo(tipsLabel.snp.right).offset(kFitWidth(5))
//            make.centerY.lessThanOrEqualTo(tipsLabel)
//        }
        changeUnitButton.snp.makeConstraints { make in
            make.left.equalTo(tipsLabel.snp.right).offset(kFitWidth(3))
            make.centerY.lessThanOrEqualTo(tipsLabel)
//            make.width.equalTo(kFitWidth(34))
//            make.height.equalTo(kFitWidth(30))
//            make.bottom.equalTo(kFitWidth(-5))
        }
        kjUnitLabel.snp.makeConstraints { make in
            make.left.equalTo(changeUnitButton.snp.right).offset(kFitWidth(3))
            make.centerY.lessThanOrEqualTo(tipsLabel)
        }
        unitTapView.snp.makeConstraints { make in
            make.left.equalTo(tipsLabel)
            make.right.equalTo(kjUnitLabel).offset(kFitWidth(10))
            make.bottom.equalToSuperview()
            make.top.equalTo(tipsLabel)//.offset(kFitWidth(-10))
        }
    }
}

extension FoodsCreateCaloriVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text ?? ""
        if string == ""{
            if self.numberChangeBlock != nil{
                if textString.count > 0 {
                    self.numberChangeBlock!("\(textString.mc_clipFromPrefix(to: textString.count-1))")
//                    self.calculateJKNumber(num: "\(textString.mc_clipFromPrefix(to: textString.count-1))")
                }else{
                    self.numberChangeBlock!("")
//                    self.calculateJKNumber(num:"")
                }
            }
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if textString.count >= 5 {
            return false
        }
        if string == "0" && textString == "0"{
            return false
        }
        if self.numberChangeBlock != nil{
            self.numberChangeBlock!("\(textField.text ?? "")\(string)")
        }
//        self.calculateJKNumber(num:"\(textField.text ?? "")\(string)")
        
        return true
    }
}
