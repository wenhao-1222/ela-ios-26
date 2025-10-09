//
//  JournalShareTableViewCell.swift
//  lns
//
//  Created by Elavatine on 2025/5/6.
//


class JournalShareTableViewCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        initUI()
    }
    lazy var whiteView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        
        return vi
    }()
    lazy var bgView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .white
        return vi
    }()
    lazy var foodsNameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    
    lazy var qtyLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214_50
        lab.font = .systemFont(ofSize: 13, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .right
        
        return lab
    }()
}

extension JournalShareTableViewCell{
    func updateUI(dict:NSDictionary) {
        foodsNameLabel.text = dict.stringValueForKey(key: "fname")
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            qtyLabel.text = "\(WHUtils.convertStringToString("\(dict["calories"]as? Double ?? Double(dict["calories"]as? String ?? "0") ?? 0)") ?? "0")千卡"
            if dict.stringValueForKey(key: "ctype") == "3"{
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "remark"))"
            }else if dict.stringValueForKey(key: "remark").count > 0 {
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
            }
        }else{
            let spec = dict.stringValueForKey(key: "spec").count > 0 ? dict.stringValueForKey(key: "spec") : "g"
            qtyLabel.text = "\(dict.stringValueForKey(key: "qty"))\(spec)"
        }
    }
}

extension JournalShareTableViewCell{
    func initUI() {
        contentView.addSubview(whiteView)
        whiteView.addSubview(bgView)
        contentView.addSubview(foodsNameLabel)
        contentView.addSubview(qtyLabel)
        
        whiteView.layer.shouldRasterize = true
        whiteView.layer.rasterizationScale = UIScreen.main.scale
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.top.equalTo(kFitWidth(-2))
            make.bottom.equalTo(kFitWidth(2))
            make.width.equalToSuperview()
        }
        whiteView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(kFitWidth(42))
            make.right.equalTo(kFitWidth(-42))
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(62))
            make.right.equalTo(kFitWidth(-140))
            make.top.equalTo(kFitWidth(6))
            make.bottom.equalTo(kFitWidth(-6))
        }
        qtyLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-62))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(68))
        }
    }
}
