//
//  PublishContentCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/6.
//



class PublishContentCell: UITableViewCell {
    
    var heightChangeBlock:((String)->())?
    
    var maxHeight = kFitWidth(200)
    var contentHeight = kFitWidth(100)
    
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
        text.font = .systemFont(ofSize: 16, weight: .regular)
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
        lab.text = "添加正文"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
}

extension PublishContentCell{
    func initUI() {
        contentView.addSubview(remarkTextField)
        contentView.addSubview(placeHoldLabel)
//        remarkTextField.frame = CGRect.init(x: kFitWidth(16), y: kFitWidth(10), width: kFitWidth(343), height: kFitWidth(60))
        remarkTextField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
//            make.right.equalTo(kFitWidth(-16))
            make.width.equalTo(kFitWidth(343))
            make.height.greaterThanOrEqualTo(kFitWidth(60))
            make.top.equalTo(kFitWidth(10))
            make.bottom.equalTo(kFitWidth(-10))
        }
        placeHoldLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.top.equalTo(remarkTextField).offset(kFitWidth(8))
//            make.bottom.equalTo(kFitWidth(-50))
//            make.centerY.lessThanOrEqualTo(remarkTextField)
        }
    }
    func updateContentString(content:String){
        remarkTextField.text = content
        placeHoldLabel.isHidden = remarkTextField.text.count > 0 ? true : false
    }
}

extension PublishContentCell:UITextViewDelegate{
    // 当文本改变时，动态调整高度
    func textViewDidChange(_ textView: UITextView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        // 计算文本高度
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var textViewHeight = max(newSize.height, kFitWidth(80))
        
        if textViewHeight >= maxHeight{
            textViewHeight = maxHeight
        }
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: textViewHeight)
//        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: max(newSize.height, kFitWidth(80)))
        
        placeHoldLabel.isHidden = textView.text.count > 0 ? true : false
        
        if self.heightChangeBlock != nil{
            self.heightChangeBlock!(textView.text)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            self.remarkTextField.resignFirstResponder()
        }
        
        return true
    }
}
