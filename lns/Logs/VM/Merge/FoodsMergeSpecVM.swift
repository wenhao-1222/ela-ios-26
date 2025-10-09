//
//  FoodsMergeSpecVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/14.
//


import Foundation
import UIKit

class FoodsMergeSpecVM: UIView {
    
    let selfHeight = kFitWidth(52)
    var specName = "份"
    
    var numberInput = false
    
    var specBlock:(()->())?
    
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
    lazy var numberTextField: NumericTextField = {
        let text = NumericTextField()
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

extension FoodsMergeSpecVM{
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
            if specName == "克" || specName == "g" || specName == "ml" || specName == "毫升"{
                numberTextField.placeholder = "100"
                numberTextField.text = "100"
            }else{
                numberTextField.placeholder = "1"
                numberTextField.text = "1"
            }
        }
    }
    func updateButtonForAi() {
        specButton.setTitle("\(specName)", for: .normal)
        specButton.setImage(UIImage(named: "create_plan_arrow_down"), for: .normal)
        specButton.imagePosition(style: .right, spacing: kFitWidth(2))
    }
}
extension FoodsMergeSpecVM{
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
            make.top.equalTo(kFitWidth(19))
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

extension FoodsMergeSpecVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        // 检查输入的字符是否是数字
        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        if allowedCharacters.isSuperset(of: characterSet) == false{
            return false
        }
        if textField.text?.count ?? 0 >= 4 {
            return false
        }
        numberInput = true
        return true
    }
}
