//
//  FoodsCreateFastRemarkVM.swift
//  lns
//
//  Created by Elavatine on 2024/9/28.
//

import Foundation
import UIKit

class FoodsCreateFastRemarkVM: UIView {
    
    let selfHeight = kFitWidth(100)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
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
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "备注"
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        return lab
    }()
    lazy var textBgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_LIGHT_GREY
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var textField: ChineseTextField = {
        let text = ChineseTextField()
        text.placeholder = "简单描述本次添加的食物（可选）"
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        text.textNumber = 50
        
        
        return text
    }()
}

extension FoodsCreateFastRemarkVM{
    func initUI()  {
        addSubview(titleLabel)
        addSubview(textBgView)
        textBgView.addSubview(textField)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(8))
        }
        textBgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(8))
            make.height.equalTo(kFitWidth(34))
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(kFitWidth(-8))
        }
    }
}

extension FoodsCreateFastRemarkVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        
        if textField.text?.count ?? 0 >= 150{
            return false
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
            let cursorPostion = textField.offset(from: textField.endOfDocument,
                                                 to: textField.selectedTextRange!.end)
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9\\u0020\\u4E00-\\u9FA5]"
            //替换后的字符串（过滤调非中文字符）
            var str = textField.text ?? ""//!.pregReplace(pattern: pattern, with: "")
            //限制文字长度不能超过20个
            if str.count > 25 {
                str = String(str.prefix(25))
            }
            textField.text = str
             
            //让光标停留在正确位置
            let targetPostion = textField.position(from: textField.endOfDocument,
                                                   offset: cursorPostion)!
            textField.selectedTextRange = textField.textRange(from: targetPostion,
                                                              to: targetPostion)
            return
        }
    }
}
