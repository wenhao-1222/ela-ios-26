
import UIKit

class VerifyCodeSingleView: UILabel{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.COLOR_GRAY_BLACK_85.cgColor
        self.layer.borderWidth = kFitWidth(1)
        self.layer.cornerRadius = kFitWidth(8)
        self.clipsToBounds = true
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        self.textColor = .COLOR_GRAY_BLACK_85
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
}

public class MHVerifyCodeView: UIStackView, UITextFieldDelegate {
    
    var verifyCodes: [VerifyCodeSingleView]!
    var inputBlock:(()->())?
    
    /**验证码字体*/
    public var font: UIFont = UIFont.systemFont(ofSize: 18, weight: .medium) {
        didSet{
            for verifyCode in self.verifyCodes{
                verifyCode.font = font
            }
        }
    }
    
    /**验证码数量*/
    public var verifyCount: Int? {
        didSet{
            for _ in Range(0...(verifyCount ?? 4) - 1) {
                let singleView = VerifyCodeSingleView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                verifyCodes.append(singleView)
                self.addArrangedSubview(singleView)
            }
        }
    }
    public var bgColor:UIColor?{
        didSet{
            for singleView in verifyCodes{
                singleView.backgroundColor = bgColor
            }
        }
    }
    public var borderColor:UIColor?{
        didSet{
            for singleView in verifyCodes{
                singleView.layer.borderColor = borderColor?.cgColor
            }
        }
    }
    
    
    /**验证码输入完成后的回调闭包，返回参数为验证码*/
    var completeHandler: ((_ verifyCode: String) -> Void)!
    
    //隐藏的输入框
    lazy var hideTextField: NumericTextField = {
        let textfield = NumericTextField()
        self.addSubview(textfield)
        textfield.isHidden = true
        textfield.keyboardType = .numberPad
        textfield.delegate = self
        return textfield
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
        self.distribution = .fillEqually
        verifyCodes = []
        verifyCount = 4
    }
    
    /**
     - parameter complete: 验证完成回调闭包，返回参数为验证码
     */
    public convenience init(complete: @escaping (_ verifyCode: String) -> Void) {
        self.init()
        setCompleteHandler(complete: complete)
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**设置验证码输入完成后的回调闭包*/
    public func setCompleteHandler(complete: @escaping (_ verifyCode: String) -> Void) {
        self.completeHandler = complete
    }
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.count ?? 0 < verifyCount ?? 4{
            if self.inputBlock != nil{
                self.inputBlock!()
            }
        }
        
        guard textField.text!.count <= (verifyCount ?? 4) else {
            textField.text = String(textField.text!.prefix(4))
            return
        }
        
        var index = 0
        for char in textField.text! {
            verifyCodes[index].text = String(char)
            index += 1
        }
        guard index < (verifyCount ?? 4) else {
            
            self.endEditing(true)
            
            if let complete = self.completeHandler {
                complete(textField.text!)
            }
            return
        }
        for i in Range(index...(verifyCount ?? 4) - 1) {
            verifyCodes[i].text = ""
        }
        
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        TouchGenerator.shared.touchGenerator()
        hideTextField.becomeFirstResponder()
    }
    //清除已输入的数字
    public func clearNumber(){
        hideTextField.text = ""
        for i in Range(0...(verifyCount ?? 4) - 1) {
            verifyCodes[i].text = ""
        }
    }
}
