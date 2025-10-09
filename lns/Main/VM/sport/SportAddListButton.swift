//
//  SportAddListButton.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//


class SportAddListButton: FeedBackView {
    
    let selfHeight = kFitWidth(44)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT-kFitWidth(66), y: statusBarHeight, width: kFitWidth(66), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        lab.text = "已添加"
        return lab
    }()
    lazy var numberLabel: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = WHColor_16(colorStr: "D54941")
        lab.layer.cornerRadius = kFitWidth(8)
        lab.clipsToBounds = true
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        lab.textColor = .white
        
        return lab
    }()
}

extension SportAddListButton{
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
    func updateUI(number:String) {
        if number.intValue > 0 {
            numberLabel.isHidden = false
            numberLabel.text = number
        }else{
            numberLabel.isHidden = true
        }
    }
}
extension SportAddListButton{
    func initUI() {
        addSubview(contentLabel)
        addSubview(numberLabel)
        
        setConstrait()
        updateUI(number: "")
    }
    func setConstrait() {
        contentLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
        numberLabel.snp.makeConstraints { make in
            make.right.equalTo(contentLabel).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualTo(contentLabel.snp.top)
            make.width.height.equalTo(kFitWidth(16))
        }
    }
}
