//
//  SportListHeadVM.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//


class SportListHeadVM: UIView {
    
    let selfHeight = kFitWidth(56)
    
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: kFitWidth(100), y: WHUtils().getNavigationBarHeight(), width: kFitWidth(275), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
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
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 16, weight: .bold)
        return lab
    }()
    lazy var nameBottomView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.18)
        return vi
    }()
    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "sport_add_icon"), for: .normal)
        btn.isHidden = true
        return btn
    }()
    lazy var tipsButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "tips_gray_icon"), for: .normal)
        
        return btn
    }()
}

extension SportListHeadVM{
    func updateUI(model:SportCatogaryModel) {
        iconImgView.setImgUrl(urlString: model.icon)
        nameLabel.text = model.name
        
        if model.name.contains("自定义"){
            addButton.isHidden = false
            tipsButton.isHidden = true
        }else{
            addButton.isHidden = true
            tipsButton.isHidden = false
        }
    }
}
extension SportListHeadVM{
    func initUI() {
        addSubview(iconImgView)
        addSubview(nameBottomView)
        addSubview(nameLabel)
        addSubview(addButton)
        addSubview(tipsButton)
        
        setConstrait()
    }
    func setConstrait() {
        iconImgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(kFitWidth(16))
            make.width.height.equalTo(kFitWidth(24))
        }
        nameBottomView.snp.makeConstraints { make in
            make.left.width.bottom.equalTo(nameLabel)
            make.height.equalTo(kFitWidth(8))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(48))
            make.top.equalTo(kFitWidth(18))
        }
        addButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(nameLabel)
            make.right.equalTo(kFitWidth(-12))
            make.width.height.equalTo(kFitWidth(24))
        }
        tipsButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(nameLabel)
            make.right.equalTo(kFitWidth(-6))
            make.width.height.equalTo(kFitWidth(36))
        }
    }
}
