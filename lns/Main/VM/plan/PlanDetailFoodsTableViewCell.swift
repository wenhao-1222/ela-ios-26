//
//  PlanDetailFoodsTableViewCell.swift
//  lns
//
//  Created by LNS2 on 2024/8/12.
//

import Foundation

class PlanDetailFoodsTableViewCell: FeedBackTableViewCell {
    
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
        lab.font = .systemFont(ofSize: 14, weight: .regular)
//        lab.numberOfLines = 2
//        lab.lineBreakMode = .byWordWrapping
//        lab.adjustsFontSizeToFitWidth = true
        
        return lab
    }()
    lazy var detailLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        return lab
    }()
    lazy var lineView : UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        
        return vi
    }()
    lazy var arrowImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_arrow_gray")
        img.isHidden = true
        
        return img
    }()
}

extension PlanDetailFoodsTableViewCell{
    func updateUI(dict:NSDictionary) {
        nameLabel.text = dict["fname"]as? String ?? ""
//        detailLabel.text = "\(Int(dict["weight"]as? Double ?? 0.0))克，\(dict["calories"]as? Int ?? 0)千卡"
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            detailLabel.text = "\(WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "calories")) ?? "0")千卡"
//            if dict.stringValueForKey(key: "remark").count > 0{
//                nameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
//            }
            if dict.stringValueForKey(key: "ctype") == "3"{
                nameLabel.text = "\(dict.stringValueForKey(key: "remark"))"
            }else if dict.stringValueForKey(key: "remark").count > 0 {
                nameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
            }
        }else{
            detailLabel.text = "\(dict.stringValueForKey(key: "qty"))\(dict["spec"]as? String ?? "g")，\(WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "calories")) ?? "0")千卡"
        }
        let detailWidth = WHUtils().getWidthOfString(string: detailLabel.text ?? "", font: .systemFont(ofSize: 14, weight: .regular), height: kFitWidth(16))
        nameLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-detailWidth-kFitWidth(55))
        }
    }
    func updateUIForNoFoods() {
        nameLabel.text = "请添加食物"
        detailLabel.text = ""
        arrowImgView.isHidden = true
    }
}

extension PlanDetailFoodsTableViewCell{
    func initUI() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(arrowImgView)
        
        setConstrait()
    }
    func setConstrait() {
        detailLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-16))
            make.centerY.lessThanOrEqualToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.right.equalTo(detailLabel.snp.left).offset(kFitWidth(-20))
        }
        lineView.snp.makeConstraints { make in
            make.left.width.bottom.equalToSuperview()
            make.height.equalTo(kFitWidth(1))
        }
        arrowImgView.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-18))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(20))
        }
    }
    func updateConstrait(isUpdate:Bool) {
        if isUpdate{
            arrowImgView.isHidden = false
            detailLabel.snp.remakeConstraints { make in
                make.right.equalTo(arrowImgView.snp.left).offset(kFitWidth(-5))
                make.centerY.lessThanOrEqualToSuperview()
            }
            nameLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.centerY.lessThanOrEqualToSuperview()
                make.right.equalTo(detailLabel.snp.left).offset(kFitWidth(-20))
            }
        }else{
            arrowImgView.isHidden = true
            detailLabel.snp.remakeConstraints { make in
                make.right.equalTo(kFitWidth(-16))
                make.centerY.lessThanOrEqualToSuperview()
            }
            nameLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(16))
                make.centerY.lessThanOrEqualToSuperview()
                make.right.equalTo(detailLabel.snp.left).offset(kFitWidth(-20))
            }
        }
    }
}
