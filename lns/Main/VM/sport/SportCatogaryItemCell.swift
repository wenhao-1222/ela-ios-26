//
//  SportCatogaryItemCell.swift
//  lns
//
//  Created by Elavatine on 2024/11/22.
//


class SportCatogaryItemCell: UITableViewCell {
    
    var tapBlock:(()->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        initUI()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .clear
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var nameLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .bold)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var metsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
        return vi
    }()
}

extension SportCatogaryItemCell{
    func updateUI(model:SportCatogaryItemModel) {
        nameLabel.text = model.name
        if model.met.doubleValue > 0 {
            metsLabel.text = "\(model.met) METs"
        }else{
            if model.durationLast.doubleValue > 0 {
                metsLabel.text = "\(Int(model.caloriesLast.doubleValue.rounded()))千卡 / \(model.durationLast)分钟"
            }else{
                metsLabel.text = "\(Int(model.calories.doubleValue.rounded()))千卡 / \(Int(model.minute.doubleValue.rounded()))分钟"
            }
        }
        
        self.backgroundColor = .clear
    }
    
    @objc func tapAction() {
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension SportCatogaryItemCell{
    func initUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(metsLabel)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.centerY.lessThanOrEqualTo(kFitWidth(18))
//            make.right.equalTo(kFitWidth(-20))
            make.width.equalTo(kFitWidth(243))
        }
        metsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(20))
            make.top.equalTo(nameLabel.snp.bottom).offset(kFitWidth(5))
//            make.bottom.equalTo(kFitWidth(-10))
        }
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
            make.width.equalTo(kFitWidth(243))
        }
    }
}

extension SportCatogaryItemCell{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        TouchGenerator.shared.touchGenerator()
        self.backgroundColor = .WIDGET_COLOR_GRAY_BLACK_06
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .clear
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = .clear
    }
}
