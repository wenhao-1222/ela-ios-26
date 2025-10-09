//
//  ChineseTextField.swift
//  lns
//
//  Created by LNS2 on 2024/7/3.
//

import Foundation


class ChineseTextField : UITextField {
    
    var timer: Timer?
    var textNumber = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //监听textField内容改变通知
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.greetingTextFieldChanged),
//                                               name:NSNotification.Name(rawValue:"UITextFieldTextDidChangeNotification"),
//                                               object: self)
    }
}

extension ChineseTextField{
    func startCountdown() {
        //一般倒计时是操作UI，使用主队列
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            // 定时器执行的操作
            DLLog(message: "startCountdown:\(self.text ?? "")")
            var string = self.text ?? ""
            DLLog(message: "startCountdown:::\(string)")
            string = string.disable_emoji(text: string as NSString)
            if string.count > self.textNumber {
                string = String(string.prefix(self.textNumber))
            }
            
            self.text = string
        }
    }
    func disableTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    //textField内容改变通知响应
    @objc func greetingTextFieldChanged(obj: Notification) {
        //非markedText才继续往下处理
        guard let _: UITextRange = self.markedTextRange else{
            //当前光标的位置（后面会对其做修改）
            let cursorPostion = self.offset(from: self.endOfDocument,
                                                 to: self.selectedTextRange!.end)
            
            DLLog(message: "greetingTextFieldChanged:\(obj)")
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9\\u4E00-\\u9FA5]"
//            非中文：[^\\u4E00-\\u9FA5]
//            非英文：[^A-Za-z]
//            非数字：[^0-9]
//            句号：\\u3002
//            非中文或英文：[^A-Za-z\\u4E00-\\u9FA5]
//            非英文或数字：[^A-Za-z0-9]
            //替换后的字符串（过滤调非中文字符）
            var str = self.text!.pregReplace(pattern: pattern, with: "")
            if str.count > textNumber {
                str = String(str.prefix(textNumber))
            }
            self.text = str
             
            //让光标停留在正确位置
            let targetPostion = self.position(from: self.endOfDocument,
                                                   offset: cursorPostion)!
            self.selectedTextRange = self.textRange(from: targetPostion,
                                                              to: targetPostion)
            return
        }
    }
}
