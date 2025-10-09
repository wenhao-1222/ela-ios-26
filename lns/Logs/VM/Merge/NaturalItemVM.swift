//
//  FoodsMergeFoodsAlertVm.swift
//  lns
//
//  Created by Elavatine on 2025/3/18.
//


class NaturalItemVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(100), height: kFitHeight(20)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var circleVi: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(2.5)
        vi.clipsToBounds = true
        return vi
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    func initUI() {
        addSubview(circleVi)
        addSubview(contentLabel)
        
        setConstrait()
    }
    func setConstrait() {
        circleVi.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(18))
            make.width.height.equalTo(kFitWidth(5))
            make.centerY.lessThanOrEqualToSuperview()
        }
        contentLabel.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualToSuperview()
            make.left.equalTo(kFitWidth(28))
            make.right.equalTo(kFitWidth(-2))
        }
    }
}
