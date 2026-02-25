//
//  DietPlanCreateItemVM.swift
//  lns
//
//  Created by LNS2 on 2026/2/24.
//


class DietPlanCreateItemVM: UIView {
    
    let selfHeight = kFitWidth(84)
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_CARD_BG_WHITE
        vi.layer.cornerRadius = kFitWidth(12)
        vi.layer.borderColor = UIColor.clear.cgColor
        vi.layer.borderWidth = kFitWidth(2)
        vi.clipsToBounds = true
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var titleLabel: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.numberOfLines = 1
        lab.textAlignment = .left
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 18, weight: .medium)
        
        return lab
    }()
    lazy var selectImgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        return img
    }()
    //question_foods_normal_icon
    //circle_today_select_icon
}

extension DietPlanCreateItemVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(selectImgView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(itemTapAction))
        bgView.addGestureRecognizer(tap)
        
        setConstrait()
//        updateUI(title: "", isSelected: false)
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(45))
            make.right.equalTo(kFitWidth(-45))
            make.top.equalTo(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-6))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.right.equalTo(selectImgView.snp.left).offset(kFitWidth(-12))
            make.centerY.equalToSuperview()
        }
        selectImgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(kFitWidth(-16))
            make.width.height.equalTo(kFitWidth(24))
        }
    }
    
    @objc func itemTapAction() {
        tapBlock?()
    }
    
    func updateUI(title:String,isSelected:Bool) {
        titleLabel.text = title
        selectImgView.setCheckState(isSelected,
                              checkedImageName: "circle_today_select_icon",
                              uncheckedImageName: "question_foods_normal_icon")
        if isSelected {
            bgView.layer.borderColor = UIColor.THEME.cgColor
        } else {
            bgView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
