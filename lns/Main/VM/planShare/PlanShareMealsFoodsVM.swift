//
//  PlanShareMealsFoodsVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit

class PlanShareMealsFoodsVM: UIView {
    
    var selfWidth = kFitWidth(0)
    let selfHeight = kFitWidth(24)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: frame.size.width, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.selfWidth = frame.size.width
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var foodsNameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.7
        
        return lab
    }()
    lazy var foodsWeightLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .right
        
        return lab
    }()
}

extension PlanShareMealsFoodsVM{
    func updateUI(dict:NSDictionary) {
        foodsNameLabel.text = dict["fname"]as? String ?? ""
        
//        foodsWeightLabel.text = "\(dict["weight"]as? Int ?? 0)g"
        
        if dict["fname"]as? String ?? "" == "快速添加"{
            foodsWeightLabel.text = "\(WHUtils.convertStringToString("\(dict["calories"]as? Double ?? Double(dict["calories"]as? String ?? "0") ?? 0)") ?? "0")千卡"
//            if dict.stringValueForKey(key: "remark").count > 0 {
//                foodsNameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
//            }
            
            if dict.stringValueForKey(key: "ctype") == "3"{
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "remark"))"
            }else if dict.stringValueForKey(key: "remark").count > 0 {
                foodsNameLabel.text = "\(dict.stringValueForKey(key: "fname"))(\(dict.stringValueForKey(key: "remark")))"
            }
        }else{
//            foodsWeightLabel.text = "\(dict["qty"]as? Int ?? 0)\(dict["spec"]as? String ?? "")"
            let spec = dict.stringValueForKey(key: "spec").count > 0 ? dict.stringValueForKey(key: "spec") : "g"
            foodsWeightLabel.text = "\(dict.stringValueForKey(key: "qty"))\(spec)"
            //本地选择的食物
//            if (dict["specName"]as? String ?? "").count > 0 {
//                foodsWeightLabel.text = "\(WHUtils.convertStringToString("\(dict["specNum"]as? String ?? "0.0")") ?? "0")\(dict["specName"]as? String ?? "g")"
//            }else if (dict["qty"]as? Int ?? 0) > 0{
//                foodsWeightLabel.text = "\(WHUtils.convertStringToString("\(dict["qty"]as? Double ?? 0)") ?? "0")\(dict["spec"]as? String ?? "g")"
//            }else{
//                foodsWeightLabel.text = "\(WHUtils.convertStringToString("\(dict["weight"]as? Double ?? 0)") ?? "0")\(dict["spec"]as? String ?? "g")"
//            }
        }
    }
}
extension PlanShareMealsFoodsVM{
    func initUI() {
        addSubview(foodsNameLabel)
        addSubview(foodsWeightLabel)
    
        setConstrait()
    }
    
    func setConstrait() {
        foodsNameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(36))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo((self.selfWidth - kFitWidth(72))*0.7)
        }
        foodsWeightLabel.snp.makeConstraints { make in
            make.right.equalTo(kFitWidth(-36))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.equalTo((self.selfWidth - kFitWidth(72))*0.3)
        }
    }
}

