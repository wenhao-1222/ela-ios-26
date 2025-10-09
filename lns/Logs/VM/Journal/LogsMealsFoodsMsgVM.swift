//
//  LogsMealsFoodsMsgVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/22.
//

import Foundation
import UIKit

class LogsMealsFoodsMsgVM: UIView {
    
    let selfHeight = kFitWidth(40)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: kFitWidth(359), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var foodsNameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.adjustsFontSizeToFitWidth = true
        lab.isUserInteractionEnabled = true
        
        return lab
    }()
    lazy var rightDetailLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textAlignment = .right
        lab.isUserInteractionEnabled = true
        return lab
    }()
    lazy var arrowImgView : UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "plan_arrow_gray")
        img.isUserInteractionEnabled = true
        
        return img
    }()
}

extension LogsMealsFoodsMsgVM{
    func updateUI(dict:NSDictionary) {
        foodsNameLabel.text = dict["fname"]as? String ?? ""
        rightDetailLabel.text = "\(WHUtils.convertStringToString("\(dict["weight"]as? Double ?? 0)") ?? "")g，\(dict["calories"]as? Int ?? 0)千卡"
        
    }
}
extension LogsMealsFoodsMsgVM{
    func initUI() {
        addSubview(foodsNameLabel)
        addSubview(rightDetailLabel)
        addSubview(arrowImgView)
        
        setConstrait()
    }
    func setConstrait() {
        rightDetailLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-40))
            make.top.height.equalToSuperview()
        }
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.height.equalToSuperview()
            make.right.equalTo(rightDetailLabel.snp.left).offset(kFitWidth(-10))
        }
    }
}
