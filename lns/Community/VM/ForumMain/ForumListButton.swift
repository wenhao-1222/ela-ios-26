//
//  ForumListButton.swift
//  lns
//
//  Created by Elavatine on 2025/2/5.
//


class ForumListButton : UIView{
    
    let selfWidth = kFitWidth(64)
    let selfHeight = kFitWidth(28)
    
    var tapBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: selfWidth, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
}

extension ForumListButton{
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension ForumListButton{
    func initUI() {
        addSubview(iconImgView)
        addSubview(contentLab)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(18))
        }
        contentLab.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(kFitWidth(4))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalToSuperview()
        }
    }
}
