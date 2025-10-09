//
//  ForumCommentTextVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/11.
//


class ForumCommentTextVM: UIView {
    
    var selfHeight = kFitWidth(36)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.05)
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(18)
        self.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var editIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "logs_pen_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var placeHolderLabel: UILabel = {
        let lab = UILabel()
        lab.text = "说点什么..."
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var textField: UITextField = {
        let text = UITextField()
        
//        let image = UIImage(named: "logs_pen_icon")!
//        let attachment = NSTextAttachment()
//        attachment.image = image
//        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .medium).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
//        let attachmentString = NSMutableAttributedString(attachment: attachment)
//        
//        let string = NSMutableAttributedString(string: "说点什么...")
//        string.yy_color = .COLOR_GRAY_BLACK_45
//        string.yy_font = .systemFont(ofSize: 14, weight: .medium)
//        attachmentString.append(string)
//        text.attributedPlaceholder = attachmentString
        
        return text
    }()
}

extension ForumCommentTextVM{
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    func setDisableStatus() {
        self.isUserInteractionEnabled = false
//        self.placeHolderLabel.text = "作者已关闭评论"
        self.setPlaceHolder(placeString: "已关闭评论")
    }
    func setPlaceHolder(placeString:String) {
        let image = UIImage(named: "logs_pen_icon")!
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (UIFont.systemFont(ofSize: 16, weight: .medium).capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        
        let string = NSMutableAttributedString(string: placeString)
        string.yy_color = .COLOR_GRAY_BLACK_45
        string.yy_font = .systemFont(ofSize: 14, weight: .medium)
        attachmentString.append(string)
        textField.attributedPlaceholder = attachmentString
    }
}

extension ForumCommentTextVM{
    func initUI() {
        addSubview(textField)
        
        setConstrait()
        setPlaceHolder(placeString: "说点什么...")
    }
    func setConstrait() {
        textField.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(8))
            make.top.height.equalToSuperview()
            make.right.equalTo(kFitWidth(-8))
        }
    }
}
