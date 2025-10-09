//
//  FoodsMergeAddFoodsVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/19.
//


class FoodsMergeAddFoodsVM: UIView {
    
    let selfHeight = kFitWidth(24)
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: kFitWidth(78), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var addButton: GJVerButton = {
        let btn = GJVerButton()
        btn.layer.borderColor = UIColor.THEME.cgColor
        btn.layer.borderWidth = kFitWidth(1)
        btn.layer.cornerRadius = kFitWidth(18)
        btn.setTitle("添加食材", for: .normal)
        btn.setTitleColor(.COLOR_GRAY_BLACK_85, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.setImage(UIImage(named: "foods_merge_add_icon"), for: .normal)
        
        btn.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        
        return btn
    }()
}

extension FoodsMergeAddFoodsVM{
    @objc func tapAction() {
        self.tapBlock?()
    }
}

extension FoodsMergeAddFoodsVM{
    func initUI() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(4))
            make.width.equalTo(kFitWidth(290))
            make.height.equalTo(kFitWidth(36))
        }
        addButton.imagePosition(style: .left, spacing: kFitWidth(2))
    }
}

extension FoodsMergeAddFoodsVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
