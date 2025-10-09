//
//  FriendListSearchVM.swift
//  lns
//
//  Created by Elavatine on 2025/6/30.
//


import Foundation
import UIKit

class FriendListSearchVM: UIView {
    
    var selfHeight = kFitWidth(36)
    let maxLength = 5
    
    var searchBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        //监听textField内容改变通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.greetingTextFieldChanged),
                                               name:NSNotification.Name(rawValue:"UITextFieldTextDidChangeNotification"),
                                               object: self.textField)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        return vi
    }()
    lazy var searchImgView : FeedBackUIImageView = {
        let img = FeedBackUIImageView()
        img.setImgLocal(imgName: "main_search_icon")
        img.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(searchTapAction))
        img.addGestureRecognizer(tap)
        
        return img
    }()
    lazy var textField : ChineseTextField = {
        let text = ChineseTextField()
        text.placeholder = "请输入好友ID"
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.returnKeyType = .search
        text.clearButtonMode = .always
        text.keyboardType = .asciiCapable
        text.delegate = self
        text.textContentType = nil
        text.textNumber = maxLength
        
        return text
    }()
}

extension FriendListSearchVM{
    @objc func searchTapAction(){
        if self.searchBlock != nil{
            self.searchBlock!()
        }
        self.textField.resignFirstResponder()
    }
}

extension FriendListSearchVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(searchImgView)
        bgView.addSubview(textField)
        
        setConstrait()
    }
    func setConstrait(){
        bgView.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(36))
        }
        searchImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(16))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(47))
            make.top.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-16))
        }
    }
}

extension FriendListSearchVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var textString = textField.text ?? ""
        
        if string == ""{
            if textString.count == 1{
                self.searchBlock?()
//                textField.text = ""
//                if self.searchBlock != nil{
//                    self.searchBlock!()
//                }
//                return false
            }
            return true
        }
        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
//        if range.length > 0 {
//            let firstStr = textString.mc_clipFromPrefix(to: range.location)
//            let endStr = textString.mc_cutToSuffix(from: range.location+range.length)
//            textField.text = "\(firstStr)\(string)\(endStr)"
//            
//            if textField.text ?? "" == ""{
//                if self.searchBlock != nil{
//                    self.searchBlock!()
//                }
//                return true
//            }else{
//                return false
//            }
//        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapAction()
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.textField.text = ""
        if self.searchBlock != nil{
            self.searchBlock!()
        }
        return true
    }
    //textField内容改变通知响应
    @objc func greetingTextFieldChanged(obj: Notification) {
//        DLLog(message: "greetingTextFieldChanged")
        //非markedText才继续往下处理
        guard let _: UITextRange = textField.markedTextRange else{
            //当前光标的位置（后面会对其做修改）
            let cursorPostion = textField.offset(from: textField.endOfDocument,
                                                 to: textField.selectedTextRange!.end)
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9]"//"[^A-Za-z0-9\\u0020\\u4E00-\\u9FA5]"
            var str = self.textField.text!.pregReplace(pattern: pattern, with: "")
            if str.count > maxLength {
                str = String(str.prefix(maxLength))
            }
            self.textField.text = str
             
            //让光标停留在正确位置
            let targetPostion = textField.position(from: textField.endOfDocument,
                                                   offset: cursorPostion)!
            textField.selectedTextRange = textField.textRange(from: targetPostion,
                                                              to: targetPostion)
            return
        }
    }
}
