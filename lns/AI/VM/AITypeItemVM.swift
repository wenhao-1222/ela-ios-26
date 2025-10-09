//
//  AITypeItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/6.
//


class AITypeItemVM: FeedBackView {
    
    var selfHeight = kFitWidth(35)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.height
        self.layer.cornerRadius = selfHeight*0.5
        self.clipsToBounds = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var iconImgView: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
}

extension AITypeItemVM{
    @objc func tapAction() {
        self.tapBlock?()
    }
    func updateUI(isSelect:Bool,isFoods:Bool) {
        if isFoods{
            iconImgView.image = isSelect ? UIImage.init(named: "ai_type_foods_icon") : UIImage.init(named: "ai_type_foods_normal_icon")
        }else{
            iconImgView.image = isSelect ? UIImage.init(named: "ai_type_ingredient_icon") : UIImage.init(named: "ai_type_ingredient_normal_icon")
        }
        self.backgroundColor = isSelect ? .white : .clear
        titleLab.textColor = isSelect ? .THEME : .black
    }
}


extension AITypeItemVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(titleLab)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(50))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitHeight(30))
        }
        titleLab.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(iconImgView.snp.right)
        }
    }
}
