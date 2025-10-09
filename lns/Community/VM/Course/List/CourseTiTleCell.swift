//
//  CourseTiTleCell.swift
//  lns
//
//  Created by Elavatine on 2025/4/14.
//


class CourseTiTleCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .COLOR_BG_F5
        self.selectionStyle = .none
        
        initUI()
    }
    lazy var bgView: GradientView = {
        let vi = GradientView()
        vi.isUserInteractionEnabled = true
        
        return vi
    }()
    lazy var titleLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 21, weight: .semibold)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var detailLab: LineHeightLabel = {
        let lab = LineHeightLabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var priceLab: UILabel = {
        let lab = UILabel()
        lab.text = "¥"
        lab.isHidden = true
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 12, weight: .semibold)
        
        return lab
    }()
    lazy var priceLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .THEME
        lab.font = .systemFont(ofSize: 19, weight: .semibold)
        lab.isHidden = true
        
        return lab
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .COLOR_GRAY_E2
        
        return vi
    }()
}

extension CourseTiTleCell{
    func updateUI(dict:NSDictionary,isPaid:Bool=true) {
        titleLab.text = dict.stringValueForKey(key: "detailTitle")
        detailLab.text = dict.stringValueForKey(key: "detailSubtitle")
        
        priceLab.isHidden = true
        priceLabel.isHidden = true
        
        if dict.doubleValueForKey(key: "price") > 0 && isPaid == false && UserInfoModel.shared.abTestModel.tutorial_briefing_price_hidden == .B{
            priceLab.isHidden = false
            priceLabel.isHidden = false
            priceLabel.text = WHUtils.convertStringToString("\(dict.doubleValueForKey(key: "price"))")
            
            titleLab.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.top.equalToSuperview()
                make.right.equalTo(priceLab.snp.left).offset(kFitWidth(-16))
            }
        }
    }
}

extension CourseTiTleCell{
    func initUI() {
        contentView.addSubview(bgView)
        contentView.addSubview(titleLab)
        contentView.addSubview(detailLab)
        contentView.addSubview(priceLab)
        contentView.addSubview(priceLabel)
//        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview()
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
            make.right.equalTo(kFitWidth(-100))
//            make.right.equalTo(kFitWidth(-16))
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.bottom.equalTo(kFitWidth(-4))
            make.top.equalTo(titleLab.snp.bottom).offset(kFitWidth(8))
        }
        priceLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualTo(titleLab)
        }
        priceLab.snp.makeConstraints { make in
            make.right.equalTo(priceLabel.snp.left).offset(kFitWidth(-7))
            make.centerY.lessThanOrEqualTo(priceLabel)
        }
//        lineView.snp.makeConstraints { make in
//            make.left.right.equalTo(titleLab)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(kFitWidth(1))
//        }
    }
}
