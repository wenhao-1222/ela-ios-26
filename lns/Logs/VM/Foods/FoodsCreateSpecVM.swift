//
//  FoodsCreateSpecVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/20.
//

import Foundation
import UIKit

class FoodsCreateSpecVM: UIView {
    
    let selfHeight = kFitWidth(69)
    var specName = "克"
    
    var numberInput = false
    
    var specBlock:(()->())?
    var perNumBlock:(()->())?
    var numberChangeBlock:((String)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var leftTitleLab: UILabel = {
        let lab = UILabel()
        lab.text = "营养素信息"
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var numberTextField: UITextField = {
        let text = UITextField()
        text.placeholder = "100"
        text.text = "100"
        text.textColor = .THEME
        text.font = .systemFont(ofSize: 14, weight: .medium)
        text.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        text.layer.cornerRadius = kFitWidth(4)
        text.clipsToBounds = true
        text.textAlignment = .center
        text.keyboardType = .numberPad
        text.delegate = self
        text.textContentType = nil
        
        return text
    }()
    lazy var numberTapView: UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .clear
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(textFieldInputAction))
        vi.addGestureRecognizer(tap)
        
        return vi
    }()
    lazy var numerLeftLab: UILabel = {
        let lab = UILabel()
        lab.text = "每"
        lab.textColor = WHColor_16(colorStr: "8C8C8C")
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var specButton: GJVerButton = {
        let btn = GJVerButton()
        btn.setTitle("\(specName)", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        btn.setTitleColor(.COLOR_HIGHTLIGHT_GRAY, for: .highlighted)
        
        btn.addTarget(self, action: #selector(specButtonTapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension FoodsCreateSpecVM{
    @objc func specButtonTapAction() {
        self.numberTextField.resignFirstResponder()
        if self.specBlock != nil{
            self.specBlock!()
        }
    }
    @objc func textFieldInputAction(){
        self.numberTextField.becomeFirstResponder()
    }
    func updateButton() {
        specButton.setTitle("\(specName)", for: .normal)
        specButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        specButton.imagePosition(style: .right, spacing: kFitWidth(2))
        
        if numberInput == false{
            numberTextField.delegate = nil
            if specName == "克" || specName == "g" || specName == "ml" || specName == "毫升"{
                numberTextField.placeholder = "100"
                numberTextField.text = "100"
            }else{
                numberTextField.placeholder = "1"
                numberTextField.text = "1"
            }
            numberTextField.delegate = self
        }
    }
    func updateButtonForAi() {
        specButton.setTitle("\(specName)", for: .normal)
        specButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        specButton.imagePosition(style: .right, spacing: kFitWidth(2))
    }
}
extension FoodsCreateSpecVM{
    func initUI() {
        addSubview(leftTitleLab)
        addSubview(numberTextField)
        addSubview(numerLeftLab)
        addSubview(specButton)
        addSubview(numberTapView)
        
        setConstrait()
        updateButton()
    }
    func setConstrait() {
        leftTitleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalTo(kFitWidth(40))
        }
        numberTextField.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-58))
            make.width.equalTo(kFitWidth(40))
            make.height.equalTo(kFitWidth(22))
            make.centerY.lessThanOrEqualTo(leftTitleLab)
        }
        numerLeftLab.snp.makeConstraints { make in
            make.right.equalTo(numberTextField.snp.left).offset(kFitWidth(-12))
            make.centerY.lessThanOrEqualTo(leftTitleLab)
        }
        specButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(leftTitleLab)
            make.left.equalTo(numberTextField.snp.right).offset(kFitWidth(5))
            make.height.equalTo(kFitWidth(24))
            make.right.equalTo(kFitWidth(-5))
        }
        numberTapView.snp.makeConstraints { make in
            make.left.equalTo(numerLeftLab)
            make.right.equalTo(numberTextField.snp.right).offset(kFitWidth(5))
            make.top.height.equalToSuperview()
        }
    }
}

extension FoodsCreateSpecVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return false
        }
        DLLog(message: "numberChangeBlock: shouldChangeCharactersIn \(string)")

        // 构建修改后的文本内容
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)

        // 判断是否为纯数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) && string != "" {
            return false
        }

        // 限制最多3位数字
        if updatedText.count > 3 {
            return false
        }

        // 回调
        numberInput = true
        numberChangeBlock?(updatedText.replacingOccurrences(of: ",", with: "."))

        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.perNumBlock?()
        return true
    }
}
