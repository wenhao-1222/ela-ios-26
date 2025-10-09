//
//  FoodsCreateNameVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

class FoodsCreateNameVM: UIView {
    
    let selfHeight = kFitWidth(82)
    var numberChangeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
        //监听textField内容改变通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.greetingTextFieldChanged),
                                               name:NSNotification.Name(rawValue:"UITextFieldTextDidChangeNotification"),
                                               object: self.textField)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.text = "食物名称"
        
        return lab
    }()
    lazy var textField : ChineseTextField = {
        let text = ChineseTextField()
        
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        text.textNumber = 50
        
        return text
    }()
    
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
}

extension FoodsCreateNameVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(lineView)
        
        // 使用方法
        let image = UIImage(named: "logs_pen_icon")!
        let attributedString = createAttributedStringWithImage(image: image, text: "如：水果沙拉，健身餐")
        textField.attributedPlaceholder = attributedString
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(12))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(41))
            make.height.equalTo(kFitWidth(26))
            make.right.equalTo(kFitWidth(-20))
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(1))
        }
    }
    
    func createAttributedStringWithImage(image: UIImage, text: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .regular).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSMutableAttributedString(attachment: attachment)
     
        let string = NSMutableAttributedString(string: text)
        string.yy_font = .systemFont(ofSize: 16, weight: .regular)
        string.yy_color = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        attachmentString.append(string)
        
//        string.insert(attachmentString, at: 0)
     
        return attachmentString
    }
}

extension FoodsCreateNameVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            if self.numberChangeBlock != nil{
                let text = textField.text ?? ""
                if text.count > 0 {
                    self.numberChangeBlock!("\(text.mc_clipFromPrefix(to: text.count-1))")
                }
            }
            return true
        }
        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        
        if textField.text?.count ?? 0 >= 150{
            return false
        }
        if self.numberChangeBlock != nil{
            self.numberChangeBlock!("\(textField.text ?? "")\(string)")
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
    }
    //textField内容改变通知响应
    @objc func greetingTextFieldChanged(obj: Notification) {
        //非markedText才继续往下处理
        guard let _: UITextRange = textField.markedTextRange else{
            //当前光标的位置（后面会对其做修改）
            guard let selectedRange = textField.selectedTextRange else { return }
            let cursorPosition = textField.offset(from: textField.endOfDocument, to: selectedRange.end)
//            let cursorPostion = textField.offset(from: textField.endOfDocument,
//                                                 to: textField.selectedTextRange?.end)
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9\\u0020\\u4E00-\\u9FA5]"//判断非中文非字母非数字的正则表达式
            guard let text = textField.text else { return }
            var str = text.pregReplace(pattern: pattern, with: "")
            
//            var str = self.textField.text!.pregReplace(pattern: pattern, with: "")
            if str.count > 30 {
                str = String(str.prefix(30))
            }
            self.textField.text = str
             
            if let targetPosition = textField.position(from: textField.endOfDocument, offset: cursorPosition) {
//                textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
                textField.selectedTextRange = textField.textRange(from: targetPosition,
                                                                  to: targetPosition)
            }
            
            //让光标停留在正确位置
//            let targetPostion = textField.position(from: textField.endOfDocument,
//                                                   offset: cursorPosition)
//            textField.selectedTextRange = textField.textRange(from: targetPostion,
//                                                              to: targetPostion)
            return
        }
    }
}
