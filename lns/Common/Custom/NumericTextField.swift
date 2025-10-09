//
//  NumericTextField.swift
//  lns
//
//  Created by LNS2 on 2024/5/30.
//

import Foundation
import UIKit

class NumericTextField : UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textContentType = nil
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.isSecureTextEntry = false
        self.delegate = self
    }
    
    override func paste(_ sender: Any?) {
        
        if let pasteboardString = UIPasteboard.general.string {
                        
            //创建一个字符集包含数字和小数点
            let allowedCharacterSet = CharacterSet(charactersIn: ".0123456789")
            
            //使用字符集分割字符串，移除不在字符中的字符
            let filteredString = pasteboardString.components(separatedBy: allowedCharacterSet.inverted).joined()
                                                
            if let _ = Float(filteredString), !filteredString.isEmpty {
                                
                if let selectedRange = self.selectedTextRange {
                    
                    self.replace(selectedRange, withText: filteredString)
                    
                }
            }
        }
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

extension NumericTextField : UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if(string.isEmpty) {
            return true
        }
        
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: ".0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
}

