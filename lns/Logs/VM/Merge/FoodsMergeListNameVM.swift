//
//  FoodsMergeListNameVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/14.
//


class FoodsMergeListNameVM: UIView {
    
    let selfHeight = kFitWidth(60)
    
    var addFoodsBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .COLOR_GRAY_F7F8FA
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.text = "食材列表"
        lab.font = .systemFont(ofSize: 14, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        return lab
    }()
    lazy var addFoodsButton: GJVerButtonNoneFeedBack = {
        let btn = GJVerButtonNoneFeedBack()
        btn.setTitle("添加食材", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.setImage(UIImage.init(named: "foods_merge_add_icon_white"), for: .normal)
        btn.layer.borderColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.3).cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.layer.cornerRadius = kFitWidth(12)
        btn.clipsToBounds = true
        btn.enablePressEffect()
        
        btn.addTarget(self, action: #selector(addFoodsAction), for: .touchUpInside)
        
        return btn
    }()
}

extension FoodsMergeListNameVM{
    @objc func addFoodsAction()  {
        self.addFoodsBlock?()
    }
}

extension FoodsMergeListNameVM{
    func initUI() {
        addSubview(whiteView)
        whiteView.addSubview(nameLabel)
        whiteView.addSubview(addFoodsButton)
        
        setConstrait()
    }
    func setConstrait() {
        whiteView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.top.equalTo(kFitWidth(12))
        }
        nameLabel.snp.makeConstraints { make in
            make.left.top.equalTo(kFitWidth(16))
        }
        addFoodsButton.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(84))
            make.height.equalTo(kFitWidth(24))
        }
    }
}
