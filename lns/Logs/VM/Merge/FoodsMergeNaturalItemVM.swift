//
//  FoodsMergeNaturalItemVM.swift
//  lns
//
//  Created by Elavatine on 2025/3/14.
//


class FoodsMergeNaturalItemVM: UIView {
    
    let selfHeight = kFitWidth(27)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(170), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var legenView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(3.5)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var itemTitleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        return lab
    }()
    lazy var weightLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "0g"
        return lab
    }()
}

extension FoodsMergeNaturalItemVM{
    func initUI() {
        addSubview(legenView)
        addSubview(itemTitleLabel)
        addSubview(weightLabel)
        
        setConstrait()
    }
    func setConstrait() {
        legenView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(0))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(10))
        }
        itemTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        weightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}
