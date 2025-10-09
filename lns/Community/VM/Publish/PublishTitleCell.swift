//
//  PublishTitleCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/6.
//


class PublishTitleCell: UITableViewCell {
    
    var heightChangeBlock:((String)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var remarkTextField: UITextView = {
        let text = UITextView()
        
        text.textColor = .COLOR_GRAY_BLACK_85
        text.font = .systemFont(ofSize: 18, weight: .medium)
        text.delegate = self
        text.returnKeyType = .done
        text.textContentType = nil
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.textContainer.lineBreakMode = .byWordWrapping
//        text.text = "添加标题"
//        text.textNumber = 120
//        text.placeholder = "这里输入您的注释说明"
        
        return text
    }()
    lazy var placeHoldLabel: UILabel = {
        let lab = UILabel()//.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(14), width: kFitWidth(200), height: kFitWidth(20)))
        lab.text = "添加标题"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
}

extension PublishTitleCell{
    func initUI() {
        contentView.addSubview(remarkTextField)
        contentView.addSubview(placeHoldLabel)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        remarkTextField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(343))
            make.height.greaterThanOrEqualTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(0))
        }
        placeHoldLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.centerY.lessThanOrEqualTo(remarkTextField)
        }
        lineView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
    func updateContentString(content:String){
        remarkTextField.text = content
        placeHoldLabel.isHidden = remarkTextField.text.count > 0 ? true : false
    }
}

extension PublishTitleCell:UITextViewDelegate{
    // 当文本改变时，动态调整高度
    func textViewDidChange(_ textView: UITextView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        // 计算文本高度
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
//        let currentText = textView.text ?? ""
//        if currentText.count > 30 {
//            textView.text = String(currentText.prefix(30))
//        }
        
        placeHoldLabel.isHidden = textView.text.count > 0 ? true : false
        
        if self.heightChangeBlock != nil{
            self.heightChangeBlock!(textView.text)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //        self.setNeedsLayout()
        //        self.layoutIfNeeded()
        if text == "\n"{
            self.remarkTextField.resignFirstResponder()
        }else if text == ""{//   换行   "\r\r"
            return true
        }
        // 计算文本高度
//        let fixedWidth = textView.frame.size.width
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
//        if textView.text.count >= 50 {//} textView.numberOfLines() > 3{
//            return false
//        }
        
        //非markedText才继续往下处理
        guard let _: UITextRange = textView.markedTextRange else{
            if textView.text.count >= 30{
                return false
            }
            
            return true
        }
        return true
    }
}
