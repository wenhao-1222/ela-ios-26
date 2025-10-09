//
//  PublishPollFootVM.swift
//  lns
//
//  Created by Elavatine on 2024/12/18.
//


class PublishPollFootVM: UIView {
    
    var selfHeight = kFitWidth(40)//kFitWidth(80)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sport_add_icon")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        let attr = NSMutableAttributedString(string: "添加选项")
        let attr2 = NSMutableAttributedString(string: "（最多20项）")
        attr2.yy_color = .COLOR_GRAY_BLACK_45
        attr2.yy_font = .systemFont(ofSize: 12, weight: .regular)
        attr.append(attr2)
        lab.attributedText = attr
        
        return lab
    }()
}

extension PublishPollFootVM{
    @objc func tapAction() {
        self.backgroundColor = .white
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension PublishPollFootVM{
    func initUI() {
        addSubview(imgView)
        addSubview(numberLabel)
        
        setConstrait()
    }
    func setConstrait() {
        imgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(26))
        }
        numberLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(imgView)
        }
    }
}

extension PublishPollFootVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .white
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .white
    }
}
