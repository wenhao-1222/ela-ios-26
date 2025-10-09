//
//  FoodsSearchVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/25.
//

import Foundation
import UIKit

class FoodsSearchVM: UIView {
    
    let selfHeight = kFitWidth(44)
    var inputBlock:(()->())?
    var inputSearchBlock:(()->())?
    var searchBlock:(()->())?
    var searchHistoryBlock:(()->())?
    
    //点击搜索按钮
    var searchKeyTapBlock:(()->())?
    
    var lastKeyword = ""
    private var isProcessingText = false // 防止递归
    private var isComposing = false // 记录输入法组合状态
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: statusBarHeight, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backArrowButton : GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setImage(UIImage(named: "back_arrow"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        return btn
    }()
    lazy var searchBgView: UIView = {
        let vi = UIView.init(frame: CGRect.init(x: kFitWidth(45), y: kFitWidth(4), width: kFitWidth(314), height: kFitWidth(36)))
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        vi.layer.cornerRadius = kFitWidth(18)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var searchIconImg : UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(12), y: kFitWidth(10), width: kFitWidth(16), height: kFitWidth(16)))
        img.setImgLocal(imgName: "main_search_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var textField : ChineseTextField = {
        let text = ChineseTextField.init(frame: CGRect.init(x: kFitWidth(36), y: 0, width: kFitWidth(260), height: kFitWidth(36)))
        text.placeholder = "请输入想要搜索的食物"
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.clearButtonMode = .whileEditing
        text.textContentType = nil
        text.textNumber = 50
        
        text.returnKeyType = .search
        text.delegate = self
//        text.startCountdown()
        
        return text
    }()
}

extension FoodsSearchVM{
    @objc func searchTapAction(){
        if self.searchBlock != nil{
            self.searchBlock!()
        }
        self.textField.resignFirstResponder()
    }
    func updateUIForGuide(isGuide:Bool) {
        if isGuide{
            self.backgroundColor = .clear
            self.textField.becomeFirstResponder()
            self.searchBgView.backgroundColor = .white
            self.backArrowButton.isUserInteractionEnabled = false
        }else{
            self.backgroundColor = .white
            self.searchBgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
            self.backArrowButton.isUserInteractionEnabled = true
        }
    }
}

extension FoodsSearchVM{
    func initUI() {
        addSubview(backArrowButton)
        addSubview(searchBgView)
        searchBgView.addSubview(searchIconImg)
        searchBgView.addSubview(textField)
        
        setConstrait()
    }
    func setConstrait() {
        backArrowButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(3))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(42))
        }
    }
}

extension FoodsSearchVM:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DLLog(message: "文字变化：textFieldShouldReturn")
        self.searchTapAction()
        self.textField.resignFirstResponder()
        
        if self.searchKeyTapBlock != nil{
            self.searchKeyTapBlock!()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if self.searchBlock != nil{
            self.searchBlock!()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DLLog(message: "文字变化：\(string)")
        if string == "，" || string == "," || string == "。" || string == "？" || string == "！"{
            return false
        }
        if self.inputBlock != nil{
            self.inputBlock!()
        }
        return true
    }
    @objc func keyboardWillHide(notification: NSNotification) {
//        self.searchTapAction()
    }
    @objc func textChanged(){
//        DLLog(message: "文字变化：textChanged  --- \(textField.text)")
        guard !isProcessingText else { return }
        isProcessingText = true
        
        // 输入法组合中，直接返回并记录状态
        if textField.markedTextRange != nil {
            isComposing = true
            isProcessingText = false
            return
        }

        // 组合刚结束但还未插入字符，忽略本次空回调
        if isComposing && (textField.text?.isEmpty ?? true) {
            isComposing = false
            isProcessingText = false
            return
        }

        isComposing = false
        DLLog(message: "文字变化：textChanged  --- \(textField.text)")

        if textField.text?.isEmpty == true{
            self.searchBlock?()
        }else{
//            guard textField.markedTextRange == nil else {
//                // 输入法正在组合文本（如中文拼音），不处理
//                isProcessingText = false
//                return
//            }
            
            // 记录原始光标位置
            guard let selectedRange = textField.selectedTextRange else {
                isProcessingText = false
                return
            }
            let originalOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            
            // 允许字母、数字、汉字、空格及特定标点
            let pattern = "[^A-Za-z0-9\\u4E00-\\u9FA5 ']"
            var filteredText = textField.text!.pregReplace(pattern: pattern, with: "")
            
            // 限制长度
            if filteredText.count > 50 {
                filteredText = String(filteredText.prefix(50))
            }
            
            // 更新文本
            textField.text = filteredText
            searchHistoryBlock?()
            
            // 修复光标位置
            let newLength = filteredText.count
            let targetOffset = min(originalOffset, newLength)
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: targetOffset) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            
            if filteredText.isEmpty {
//                searchBlock?()
            }
        }
        isProcessingText = false
    }
}
