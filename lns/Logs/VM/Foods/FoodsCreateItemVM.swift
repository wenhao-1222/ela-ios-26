//
//  FoodsCreateItemVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

class FoodsCreateItemVM: UIView {
    
    let selfHeight = kFitWidth(56)
    var numberChangeBlock:((String)->())?
    
    var maxLength = 2
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_BG_WHITE
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var textField: NumericTextField = {
        let text = NumericTextField()
        text.keyboardType = .decimalPad
        text.placeholder = "请输入数值"
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.textAlignment = .right
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        
        return text
    }()
    lazy var unitLab : UILabel = {
        let lab = UILabel()
        lab.text = "g"
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LINE_F0//WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
}

extension FoodsCreateItemVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(unitLab)
        addSubview(lineView)
        
        
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.isSecureTextEntry = false
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        unitLab.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-34))
            make.top.height.equalToSuperview()
            make.left.equalTo(kFitWidth(100))
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension FoodsCreateItemVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let textRange = Range(range, in: currentText) else {
            return false
        }
        if string.isEmpty {
            let updatedText = currentText.replacingCharacters(in: textRange, with: "")
            numberChangeBlock?(updatedText.replacingOccurrences(of: ",", with: "."))
            return true
        }
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return false
        }
        let prospectiveText = currentText.replacingCharacters(in: textRange, with: string)

        if prospectiveText.first == "." || prospectiveText.first == "," {
            return false
        }
        let separatorCount = prospectiveText.filter { $0 == "." || $0 == "," }.count
        if separatorCount > 1 {
            return false
        }
        if let separatorIndex = prospectiveText.firstIndex(where: { $0 == "." || $0 == "," }) {
            let decimalPart = prospectiveText[prospectiveText.index(after: separatorIndex)...]
            if decimalPart.count > 1 {
                return false
            }
        }
        let integerPart = prospectiveText.split(omittingEmptySubsequences: false, whereSeparator: { $0 == "." || $0 == "," }).first.map(String.init) ?? ""
        if maxLength > 0 && integerPart.count > maxLength {
            return false
        }
        let normalizedText = prospectiveText.replacingOccurrences(of: ",", with: ".")
        if let value = Float(normalizedText), value > 999.9 {
            return false
        }
        numberChangeBlock?(normalizedText)
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
    }
}
