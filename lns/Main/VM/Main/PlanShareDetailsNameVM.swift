//
//  PlanShareDetailsNameVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/16.
//

import Foundation
import UIKit

class PlanShareDetailsNameVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = WHColor_16(colorStr: "001E40")
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = kFitWidth(14)
        self.clipsToBounds = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var headImgView : UIImageView = {
        let img = UIImageView.init(frame: CGRect.init(x: kFitWidth(4), y: kFitWidth(4), width: kFitWidth(20), height: kFitWidth(20)))
        img.layer.cornerRadius = kFitWidth(10)
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.setImgLocal(imgName: "avatar_default")
        
        return img
    }()
    lazy var nameLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .white
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "给你分享了一个饮食计划"
        lab.textAlignment = .left
        
        return lab
    }()
}

extension PlanShareDetailsNameVM{
    func refreshUI(name:String,avatar:String) {
        if avatar == ""{
            
        }else{
            headImgView.setImgUrl(urlString: avatar)
        }
        let nameStr = "\(name)"
//        if nameStr.count > 7 {
//            nameLabel.text = "\(nameStr.mc_clipFromPrefix(to: 7))..."
//        }else{
//            nameLabel.text = nameStr
//        }
        nameLabel.text = nameStr
        nameLabel.sizeToFit()
        
        if nameLabel.frame.width > kFitWidth(96){
            nameLabel.snp.remakeConstraints { make in
                make.left.equalTo(kFitWidth(32))
                make.top.height.equalToSuperview()
                make.width.equalTo(kFitWidth(96))
            }
        }
    }
}
extension PlanShareDetailsNameVM{
    func initUI(){
        addSubview(headImgView)
        addSubview(nameLabel)
        addSubview(tipsLabel)
        
        setConstrait()
    }
    func setConstrait() {
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.height.equalToSuperview()
//            make.right.equalTo(tipsLabel.snp.left).offset(kFitWidth(-4))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(kFitWidth(4))
            make.top.height.equalToSuperview()
//            make.right.equalTo(kFitWidth(-5))
        }
    }
}
