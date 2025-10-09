//
//  PublishPollItemVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/12.
//


class PublishPollItemVM: UIView {
    
    var selfHeight = kFitWidth(30)//kFitWidth(80)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(8), width: kFitWidth(64), height: kFitWidth(64)))
        img.layer.cornerRadius = kFitWidth(8)
        img.clipsToBounds = true
        img.isHidden = true
        img.isUserInteractionEnabled = true
        img.backgroundColor = .COLOR_GRAY_BLACK_25
        
        return img
    }()
    lazy var textField : UITextField = {
        let text = UITextField()
        text.placeholder = ""
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 16, weight: .medium)
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        
        return text
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
}

extension PublishPollItemVM{
    func initUI() {
        addSubview(imgView)
        addSubview(textField)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-16))
        }
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.height.equalTo(kFitWidth(1))
        }
    }
}

extension PublishPollItemVM:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        guard let _: UITextRange = textField.markedTextRange else{
            if textField.text?.count ?? 0 >= 14{
                return false
            }
            
            return true
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
    }
}
