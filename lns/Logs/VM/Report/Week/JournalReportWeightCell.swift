//
//  JournalReportWeightCell.swift
//  lns
//
//  Created by Elavatine on 2025/6/13.
//

class JournalReportWeightCell: UITableViewCell {
    
    let whiteViewWidth = SCREEN_WIDHT-kFitWidth(32)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.isSkeletonable = true
        contentView.isSkeletonable = true
        initUI()
    }
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        vi.isSkeletonable = true
        
        return vi
    }()
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(3)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.text = "体重变化"
        lab.font = .systemFont(ofSize: 16, weight: .semibold)
        lab.adjustsFontSizeToFitWidth = true
        lab.isSkeletonable = true
        
        return lab
    }()
    lazy var changeIconImgView: UIImageView = {
        let img = UIImageView()
        
        return img
    }()
    lazy var changeNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        return lab
    }()
}

extension JournalReportWeightCell{
    func updateUI(dict:NSDictionary) {
        if dict.stringValueForKey(key: "sign").count > 0 {
            if dict.stringValueForKey(key: "sign") == "+"{
                changeIconImgView.setImgLocal(imgName: "report_weight_up_icon")
            }else{
                changeIconImgView.setImgLocal(imgName: "report_weight_down_icon")
            }
            
            var num = (dict.doubleValueForKey(key: "diff") * UserInfoModel.shared.weightCoefficient)
            num = String(format: "%.1f",(num * 10).rounded()/10).doubleValue
            
            var attr = NSMutableAttributedString(string: "\(WHUtils.convertStringToStringOneDigit("\(num)") ?? "0") ")
            var attr1 = NSMutableAttributedString(string: " 公斤")
            if UserInfoModel.shared.weightUnit == 2{
                attr1 = NSMutableAttributedString(string: " 斤")
            }else if UserInfoModel.shared.weightUnit == 3{
                attr1 = NSMutableAttributedString(string: " 磅")
            }
            attr.yy_font = .systemFont(ofSize: 18, weight: .semibold)
            attr1.yy_font = .systemFont(ofSize: 12, weight: .regular)
            
            attr.append(attr1)
            changeNumLabel.attributedText = attr
        }
    }
}
extension JournalReportWeightCell{
    func initUI() {
        contentView.addSubview(bgView)
        contentView.addSubview(circleView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(changeIconImgView)
        bgView.addSubview(changeNumLabel)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.right.equalTo(kFitWidth(-16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(90))
            make.bottom.equalToSuperview()
        }
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(27))
            make.width.height.equalTo(kFitWidth(6))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(29))
            make.centerY.lessThanOrEqualTo(circleView)
        }
        changeIconImgView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(9))
            make.width.height.equalTo(kFitWidth(20))
        }
        changeNumLabel.snp.makeConstraints { make in
            make.left.equalTo(changeIconImgView.snp.right).offset(kFitWidth(1))
            make.centerY.lessThanOrEqualTo(changeIconImgView)
        }
    }
}
