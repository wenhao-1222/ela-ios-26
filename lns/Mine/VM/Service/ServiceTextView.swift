//
//  ServiceTextView.swift
//  lns
//
//  Created by LNS2 on 2024/5/16.
//

import Foundation
import UIKit

class ServiceTextView : UIView{
    
    var limitCount = 200
    var inputBlock:((String)->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: kFitWidth(200)))
        
        initUI()
    }
    lazy var textView: UITextView = {
        let text = UITextView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(17), width: kFitWidth(343), height: kFitWidth(150)))
        text.delegate = self
        text.textColor = .COLOR_GRAY_BLACK_85
        text.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.02)
        text.font = .systemFont(ofSize: 16, weight: .regular)
        text.returnKeyType = .done
        return text
    }()
    lazy var placeholderLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 16, weight: .regular)
        lab.text = "输入您遇到的问题"
        return lab
    }()
    lazy var limitCountLabel: UILabel = {
        let lab = UILabel()
        return lab
    }()
}

extension ServiceTextView{
    func initUI() {
        addSubview(textView)
        addSubview(placeholderLabel)
        addSubview(limitCountLabel)
        
        updateCountLabel(num: "0")
        
        setConstrait()
    }
    func setConstrait() {
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(textView).offset(kFitWidth(4))
            make.top.equalTo(textView).offset(kFitWidth(8))
            make.right.equalTo(kFitWidth(-28))
        }
        limitCountLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(171))
        }
    }
    func updateCountLabel(num:String) {
        let numAttr = NSMutableAttributedString(string: "\(num)")
        let totalAttr = NSMutableAttributedString(string: "/\(limitCount)")
        
        numAttr.yy_font = .systemFont(ofSize: 14, weight: .regular)
        numAttr.yy_color = .COLOR_GRAY_BLACK_85
        totalAttr.yy_font = .systemFont(ofSize: 12, weight: .regular)
        totalAttr.yy_color = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        numAttr.append(totalAttr)
        limitCountLabel.attributedText = numAttr
        
        self.placeholderLabel.isHidden = (num == "0" ? false : true)
    }
}

extension ServiceTextView : UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > limitCount {
            // 获得已输出字数与正输入字母数
            let selectRange = textView.markedTextRange
            
            // 获取高亮部分 － 如果有联想词则解包成功
            if let selectRange = selectRange {
                let position =  textView.position(from: (selectRange.start), offset: 0)
                if (position != nil) {
                    return
                }
            }
            
            let textContent = textView.text ?? ""
            let textNum = textContent.count
            
            // 截取
            if textNum > limitCount && limitCount > 0 {
                textView.text = string_prefix(index: limitCount, text: textContent)
            }
        }
//        self.limitCountLabel.text =  "\(textView.text.count)/\(limitCount)"
        updateCountLabel(num: "\(textView.text.count)")
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        self.placeholderLabel.isHidden = true
        return true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            self.placeholderLabel.isHidden = false
//        } else {
//            self.placeholderLabel.isHidden = true
//        }
        if self.inputBlock != nil{
            self.inputBlock!(textView.text ?? "")
        }
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return true
        }
        
        if text.isNineKeyBoard() {
            return true
        }else{
            if text.hasEmoji() || text.containsEmoji() {
                return false
            }
        }

        if textView.textInputMode?.primaryLanguage == "emoji" || !((textView.textInputMode?.primaryLanguage) != nil){
            return false
        }
        return true
    }
    
    // 字符串的截取 从头截取到指定index
    private func string_prefix(index:Int,text:String) -> String {
        if text.count <= index {
            return text
        } else {
            let index = text.index(text.startIndex, offsetBy: index)
            let str = text.prefix(upTo: index)
            return String(str)
        }
    }
}
