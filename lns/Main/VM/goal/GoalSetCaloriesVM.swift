//
//  GoalSetCaloriesVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/31.
//

import Foundation
import UIKit

class GoalSetCaloriesVM: UIView {
    
    let selfHeight = kFitWidth(70)
    
    var numberChangeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT-kFitWidth(32), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var numberLabel : NumericTextField = {
        let lab = NumericTextField()
        lab.placeholder = "-"
        lab.delegate = self
        lab.keyboardType = .numberPad
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.textContentType = nil
        lab.isEnabled = false
        return lab
    }()
    lazy var unitLabel: UILabel = {
        let lab = UILabel()
        lab.text = "卡路里（千卡）"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var numberTapView: FeedBackView = {
        let vi = FeedBackView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(numberTapAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
}

extension GoalSetCaloriesVM{
    func changeType(type:String) {
        if type == "g"{
            self.numberLabel.isEnabled = false
            self.numberLabel.textColor = .COLOR_GRAY_BLACK_65
            self.numberTapView.isUserInteractionEnabled = false
        }else{
            self.numberLabel.isEnabled = true
            self.numberLabel.textColor = .THEME
            self.numberTapView.isUserInteractionEnabled = true
        }
        
    }
    @objc func numberTapAction(){
        numberLabel.becomeFirstResponder()
    }
}

extension GoalSetCaloriesVM{
    func initUI() {
        addSubview(numberLabel)
        addSubview(unitLabel)
        addSubview(lineView)
        addSubview(numberTapView)
        
        setConstrait()
    }
    func setConstrait() {
        numberLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(12))
        }
        unitLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(46))
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
//            make.width.equalTo(kFitWidth(288))
            make.width.equalTo(SCREEN_WIDHT - kFitWidth(95))
            make.height.equalTo(kFitWidth(1))
        }
        numberTapView.snp.makeConstraints { make in
            make.center.lessThanOrEqualTo(numberLabel)
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(40))
        }
    }
    
    func updateConstraitForAlert() {
        unitLabel.snp.remakeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(40))
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension GoalSetCaloriesVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text ?? ""
        if string == ""{
            if self.numberChangeBlock != nil{
                if textString.count > 0 {
                    self.numberChangeBlock!("\(textString.mc_clipFromPrefix(to: textString.count-1))")
                }else{
                    self.numberChangeBlock!("")
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
        
        return true
    }
}
