//
//  TutorialDataListCell.swift
//  lns
//
//  Created by Elavatine on 2024/12/24.
//


class TutorialDataListCell: UITableViewCell {
    
    var tapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white//WHColor_16(colorStr: "1C1C1C")
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04//WHColor_16(colorStr: "2C2C2C")
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        vi.addGestureRecognizer(tap)
        return vi
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85//.white
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45//WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
}

extension TutorialDataListCell{
    func updateUI(model:ForumTutorialModel) {
        titleLab.text = model.title
        contentLab.text = model.subTitle
    }
    func setPlayState(isPlaying:Bool) {
        if isPlaying{
//            bgView.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.15)
            titleLab.textColor = .THEME
//            contentLab.textColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.45)
            let stri = titleLab.text ?? ""
            let attr = NSMutableAttributedString(string: "\(stri)  ")
            
            let attachment = NSTextAttachment()
            let image = UIImage.init(named: "tutorial_playing_icon")!
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: 0, width: kFitWidth(14), height: kFitWidth(14))
            let attachmentString = NSMutableAttributedString(attachment: attachment)
            
            attr.append(attachmentString)
            titleLab.attributedText = attr
        }else{
//            bgView.backgroundColor = WHColor_16(colorStr: "2C2C2C")
            titleLab.textColor = .COLOR_GRAY_BLACK_85
//            contentLab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.45)
        }
    }
    @objc func tapAction(){
        bgView.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension TutorialDataListCell{
    func initUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(titleLab)
        bgView.addSubview(contentLab)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalTo(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-6))
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(8))
            make.right.equalTo(kFitWidth(-12))
        }
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.right.equalTo(kFitWidth(-12))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
            make.bottom.equalTo(kFitWidth(-8))
        }
    }
}

extension TutorialDataListCell{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = .COLOR_GRAY_BLACK_25
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        bgView.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_04
//    }
}
