//
//  PlanDetailDayMealsFoodsVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/12.
//

import Foundation
import UIKit

class PlanDetailDayMealsFoodsVM: UIView {
    
    let selfHeight = kFitWidth(56)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var nameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 3
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
        
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
}

extension PlanDetailDayMealsFoodsVM{
    func updateUI(dict:NSDictionary) {
        nameLabel.text = dict["fname"]as? String ?? ""
//        detailLabel.text = "\(Int(dict["weight"]as? Double ?? 0.0))克，\(dict["calories"]as? Int ?? 0)千卡"
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            detailLabel.text = "\(WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "calories")) ?? "0")千卡"
        }else{
            detailLabel.text = "\(dict.stringValueForKey(key: "qty"))\(dict["spec"]as? String ?? "g")，\(WHUtils.convertStringToStringNoDigit(dict.stringValueForKey(key: "calories")) ?? "0")千卡"
        }
        let detailWidth = WHUtils().getWidthOfString(string: detailLabel.text ?? "", font: .systemFont(ofSize: 14, weight: .regular), height: kFitWidth(16))
        nameLabel.snp.remakeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo(SCREEN_WIDHT-detailWidth-kFitWidth(50))
        }
    }
}

extension PlanDetailDayMealsFoodsVM{
    func initUI() {
        addSubview(nameLabel)
        addSubview(detailLabel)
        addSubview(lineView)
        
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
    }
}
