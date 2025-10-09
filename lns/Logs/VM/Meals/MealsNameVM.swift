//
//  MealsNameVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/24.
//

import Foundation
import UIKit

class MealsNameVM: UIView {
    
    var selfHeight = kFitWidth(90)
    var controller = WHBaseViewVC()
    
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
    lazy var iconImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_pen_icon")
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.text = "食谱/餐食名称"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var textField : ChineseTextField = {
        let text = ChineseTextField()
        text.placeholder = "食谱/餐食名称15字以内"
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.textColor = .COLOR_GRAY_BLACK_85
        text.returnKeyType = .search
        text.delegate = self
        text.textContentType = nil
        text.textNumber = 50
        
        return text
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return vi
    }()
}

extension MealsNameVM{
    func initUI(){
        addSubview(iconImgView)
        addSubview(titleLab)
        addSubview(textField)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(kFitWidth(21))
            make.width.height.equalTo(kFitWidth(11))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.centerY.lessThanOrEqualTo(iconImgView)
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(titleLab.snp.bottom)
            make.bottom.equalToSuperview()
            make.right.equalTo(kFitWidth(-20))
        }
        lineView.snp.makeConstraints { make in
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension MealsNameVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        
        if textField.text?.count ?? 0 >= 50{
            return false
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
    }
    //textField内容改变通知响应
    @objc func greetingTextFieldChanged(obj: Notification) {
        DLLog(message: "greetingTextFieldChanged")
        //非markedText才继续往下处理
        guard let _: UITextRange = textField.markedTextRange else{
            //当前光标的位置（后面会对其做修改）
            let cursorPostion = textField.offset(from: textField.endOfDocument,
                                                 to: textField.selectedTextRange!.end)
            //判断非中文非字母非数字的正则表达式
            let pattern = "[^A-Za-z0-9\\u0020\\u4E00-\\u9FA5]"
            var str = self.textField.text!.pregReplace(pattern: pattern, with: "")
            if str.count > 50 {
                str = String(str.prefix(50))
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
