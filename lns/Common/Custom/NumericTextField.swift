//
//  NumericTextField.swift
//  lns
//
//  Created by LNS2 on 2024/5/30.
//

import Foundation
import UIKit

class NumericTextField : UITextField {
    var shouldLimitFoodQuantityInput = false
    var maximumFoodQuantityValue: Double = 9999.999
    var maximumFoodQuantityFractionDigits = 3
    
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
            let allowedCharacterSet = CharacterSet(charactersIn: shouldLimitFoodQuantityInput ? ".,0123456789" : ".0123456789")
            
            //使用字符集分割字符串，移除不在字符中的字符
            let filteredString = pasteboardString.components(separatedBy: allowedCharacterSet.inverted).joined()
                                                
            if let _ = Float(filteredString), !filteredString.isEmpty {
                                
                if let selectedRange = self.selectedTextRange {
                    if shouldLimitFoodQuantityInput {
                        let location = offset(from: beginningOfDocument, to: selectedRange.start)
                        let length = offset(from: selectedRange.start, to: selectedRange.end)
                        let range = NSRange(location: location, length: length)
                        guard Self.shouldAllowFoodQuantityChange(currentText: text ?? "",
                                                                  range: range,
                                                                  replacementString: filteredString,
                                                                  maximumValue: maximumFoodQuantityValue,
                                                                  maximumFractionDigits: maximumFoodQuantityFractionDigits) else {
                            return
                        }
                    }
                    
                    self.replace(selectedRange, withText: filteredString)
                    
                }
            }
        }
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

extension NumericTextField {
    static func shouldAllowFoodQuantityChange(currentText: String,
                                              range: NSRange,
                                              replacementString string: String,
                                              maximumValue: Double = 9999.999,
                                              maximumFractionDigits: Int = 3) -> Bool {
        guard let textRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        return isValidFoodQuantityText(updatedText,
                                       maximumValue: maximumValue,
                                       maximumFractionDigits: maximumFractionDigits)
    }

    static func isValidFoodQuantityText(_ text: String,
                                        maximumValue: Double = 9999.999,
                                        maximumFractionDigits: Int = 3) -> Bool {
        guard text.isEmpty == false else { return true }

        let allowedCharacters = CharacterSet(charactersIn: ".,0123456789")
        let characterSet = CharacterSet(charactersIn: text)
        guard allowedCharacters.isSuperset(of: characterSet) else { return false }

        let normalizedText = text.replacingOccurrences(of: ",", with: ".")
        guard normalizedText.filter({ $0 == "." }).count <= 1 else { return false }

        let parts = normalizedText.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2 else { return false }

        let integerPart = String(parts.first ?? "")
        guard integerPart.count <= 4 else { return false }

        if parts.count == 2 {
            let decimalPart = String(parts[1])
            guard decimalPart.count <= maximumFractionDigits else { return false }
        }

        if normalizedText == "." {
            return false
        }

        let numberText = normalizedText.hasPrefix(".") ? "0\(normalizedText)" : normalizedText
        guard let value = Double(numberText) else { return false }
        return value <= maximumValue
    }
}

extension NumericTextField : UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if(string.isEmpty) {
            return true
        }

        if shouldLimitFoodQuantityInput {
            return Self.shouldAllowFoodQuantityChange(currentText: textField.text ?? "",
                                                      range: range,
                                                      replacementString: string,
                                                      maximumValue: maximumFoodQuantityValue,
                                                      maximumFractionDigits: maximumFoodQuantityFractionDigits)
        }
        
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: ".0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
