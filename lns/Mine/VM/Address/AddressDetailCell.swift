//
//  AddressDetailCell.swift
//  lns
//
//  Created by Elavatine on 2025/9/11.
//


class AddressDetailCell: UITableViewCell {
    
    var textNumber = 11
    /// 文本变更回调
    var onTextChanged: ((String) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        initUI()
        //监听textField内容改变通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.greetingTextFieldChanged),
                                               name:NSNotification.Name(rawValue:"UITextFieldTextDidChangeNotification"),
                                               object: self.textField)
    }
    lazy var leftTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var idcLabel: UILabel = {
        let lab = UILabel()
        lab.text = "+86"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        
        return lab
    }()
    lazy var textField: ChineseTextField = {
        let text = ChineseTextField()
        text.textColor = .COLOR_TEXT_TITLE_0f1214
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.returnKeyType = .done
        text.textContentType = nil
        text.textNumber = 50
        
        text.delegate = self
        
        return text
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_BG_F5
        
        return vi
    }()
}

extension AddressDetailCell{
    func updateUI(type:String) {
        if type == "name"{
            textNumber = 15
            leftTitleLabel.text = "收件人"
            textField.placeholder = "姓名"
            textField.keyboardType = .default
            idcLabel.isHidden = true
            updateTextLeftGap(gap: kFitWidth(88))
        }else if type == "phone"{
            textNumber = 11
            leftTitleLabel.text = "手机号码"
            textField.placeholder = "请输入"
            textField.keyboardType = .numberPad
            idcLabel.isHidden = false
            updateTextLeftGap(gap: kFitWidth(120))
            
        }
    }
}

extension AddressDetailCell{
    func initUI() {
        contentView.addSubview(leftTitleLabel)
        contentView.addSubview(idcLabel)
        contentView.addSubview(textField)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        leftTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-15))
            make.height.equalTo(kFitWidth(21))
        }
        lineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        idcLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(88))
            make.centerY.lessThanOrEqualToSuperview()
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(88))
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(51))
            make.right.equalTo(kFitWidth(-16))
        }
    }
    func updateTextLeftGap(gap:CGFloat) {
        textField.snp.remakeConstraints { make in
            make.left.equalTo(gap)
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(51))
            make.right.equalTo(kFitWidth(-16))
        }
    }
}

extension AddressDetailCell:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return true
        }
        if textField.textInputMode?.primaryLanguage == "emoji"{
            return false
        }
        
        if textField.text?.count ?? 0 >= textNumber{
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
            onTextChanged?(str)
             
            //让光标停留在正确位置
            let targetPostion = textField.position(from: textField.endOfDocument,
                                                   offset: cursorPostion)!
            textField.selectedTextRange = textField.textRange(from: targetPostion,
                                                              to: targetPostion)
            return
        }
    }
}
