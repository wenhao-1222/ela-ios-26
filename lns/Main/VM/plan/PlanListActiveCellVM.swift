//
//  PlanListActiveCellVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/8.
//

import Foundation
import UIKit

class PlanListActiveCellVM: FeedBackView {
    
    let selfHeight = kFitWidth(92)
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var nameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
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
        
        return img
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColor_16(colorStr: "F0F0F0")
        return vi
    }()
}

extension PlanListActiveCellVM{
    func updateUI(dict:NSDictionary) {
        var nameString = dict["pname"]as? String ?? ""
        
        if nameString.count > 14 {
            nameString = nameString.mc_clipFromPrefix(to: 12)
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
//        timeLabel.text = (dict["ctime"]as? String ?? "").mc_clipFromPrefix(to: 10)
        
        if dict["state"]as? Int ?? 0 == 0{
            ingLabel.isHidden = true
        }else{
            ingLabel.isHidden = false
        }
    }
    @objc func tapAction(){
        if self.tapBlock != nil{
            self.tapBlock!()
        }
    }
}

extension PlanListActiveCellVM{
    func initUI(){
        addSubview(nameLabel)
        addSubview(ingLabel)
        addSubview(planDaysLabel)
        addSubview(timeLabel)
        addSubview(arrowImgView)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-61))
            
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
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-12))
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
