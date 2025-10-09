//
//  PlanListTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation

class PlanListTableViewCell: FeedBackTableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        
        
        initUI()
    }
    lazy var nameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        lab.numberOfLines = 1

        return lab
    }()
    lazy var ingLabel : UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .THEME
        lab.layer.cornerRadius = kFitWidth(2)
        lab.clipsToBounds = true
        lab.text = "进行中"
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .center
        lab.adjustsFontSizeToFitWidth = true
        lab.isHidden = true
        
        return lab
    }()
    lazy var planDaysLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 1
        
        return lab
    }()
    lazy var timeLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var arrowImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_arrow_gray")
        img.alpha = 0
        
        return img
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
}

extension PlanListTableViewCell{
    func updateUI(dict:NSDictionary) {
        if dict.stringValueForKey(key: "pname").isEmpty {
            nameLabel.text = nil
            timeLabel.text = nil
            planDaysLabel.text = nil
            arrowImgView.alpha = 0
            
            // 需要骨架的子视图：显示骨架（从左向右 Shimmer + 渐入）
            let cfg = SkeletonConfig(baseColorLight: .COLOR_LIGHT_GREY,
                                     highlightColorLight: .COLOR_GRAY_E2,
                                     cornerRadius: kFitWidth(4),
                                     shimmerWidth: 0.22,
                                     shimmerDuration: 1.15)
            
            [timeLabel, nameLabel,planDaysLabel].forEach { $0.showSkeleton(cfg) }
            return
        }
        // 3) 最后统一把骨架优雅淡出 + 内容淡入
        [timeLabel, nameLabel,planDaysLabel].forEach { $0.hideSkeletonWithCrossfade() }
        
        arrowImgView.alpha = 0
        
        UIView.animate(withDuration: 0.15, animations: {
            self.arrowImgView.alpha = 1
        })
        
        var nameString = dict["pname"]as? String ?? ""
        
        if nameString.count > 18 {
            nameString = nameString.mc_clipFromPrefix(to: 16)
            nameLabel.text = "\(nameString)..."
        }else{
            nameLabel.text = "\(nameString)"
        }
        
        planDaysLabel.text = "计划周期 \(dict["pdays"]as? Int ?? 0)天"
        if (dict["ctime"]as? String ?? "").count > 10 {
            timeLabel.text = (dict["ctime"]as? String ?? "").mc_clipFromPrefix(to: 10)
        }else{
            timeLabel.text = (dict["ctime"]as? String ?? "")
        }
        
        if dict["state"]as? Int ?? 0 == 0{
            ingLabel.isHidden = true
        }else{
            ingLabel.isHidden = false
        }
        
        nameLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-61))
        }
        planDaysLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-40))
        }
        timeLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-12))
        }
    }
}

extension PlanListTableViewCell{
    func initUI(){
        contentView.addSubview(nameLabel)
        contentView.addSubview(ingLabel)
        contentView.addSubview(planDaysLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(arrowImgView)
        contentView.addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.width.equalTo(kFitWidth(260))
            make.bottom.equalTo(kFitWidth(-61))
            make.height.equalTo(kFitWidth(18))
        }
        ingLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(kFitWidth(8))
            make.width.equalTo(kFitWidth(44))
            make.height.equalTo(kFitWidth(18))
            make.centerY.lessThanOrEqualTo(nameLabel)
        }
        planDaysLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-40))
            make.width.equalTo(kFitWidth(120))
            make.height.equalTo(kFitWidth(18))
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-12))
            make.width.equalTo(kFitWidth(100))
            make.height.equalTo(kFitWidth(18))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-18))
            make.bottom.equalTo(kFitWidth(-36))
            make.width.height.equalTo(kFitWidth(20))
        }
        lineView.snp.makeConstraints { make in
            make.left.bottom.width.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
    }
}
