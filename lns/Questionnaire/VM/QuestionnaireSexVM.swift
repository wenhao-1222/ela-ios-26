//
//  QuestionnaireSexVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation
import UIKit

class QuestionnaireSexVM: UIView {
    
    var manTapBlock:(()->())?
    var femanTapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var sexLabel: UILabel = {
        let lab = UILabel()
        lab.text = "您的性别是？"
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var sexManButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        btn.layer.cornerRadius = kFitWidth(40)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
        btn.addTarget(self, action: #selector(manTapAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var sexManIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sex_icon_man_normal")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var sexManLabel : UILabel = {
        let lab = UILabel()
        lab.text = "男"
        lab.textColor = WHColor_16(colorStr: "595959")
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    lazy var sexFeManButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        btn.layer.cornerRadius = kFitWidth(40)
        btn.clipsToBounds = true
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT), for: .highlighted)
        
        btn.addTarget(self, action: #selector(femanTapAction), for: .touchUpInside)
        return btn
    }()
    lazy var sexFeManIcon: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "sex_icon_feman_normal")
        img.isUserInteractionEnabled = true
        
        return img
    }()
    lazy var sexFeManLabel : UILabel = {
        let lab = UILabel()
        lab.text = "女"
        lab.textColor = WHColor_16(colorStr: "595959")
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        
        return lab
    }()
    
//    lazy var sexManButton : GJVerButton = {
//        let btn = GJVerButton()
//        btn.setTitle("男", for: .normal)
//        btn.setImage(UIImage.init(named: "sex_icon_man_normal"), for: .normal)
//        btn.setTitleColor(.white, for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.back
//        btn.backgroundColor = .COLOR_GRAY_BLACK_85
//        btn.layer.cornerRadius = kFitWidth(8)
//        btn.clipsToBounds = true
//        btn.addTarget(self, action: #selector(femanTapAction), for: .touchUpInside)
//        
//        return btn
//    }()
//    lazy var sexFeManButton : GJVerButton = {
//        let btn = GJVerButton()
//        btn.setTitle("女", for: .normal)
//        btn.setImage(UIImage.init(named: "sex_icon_feman_normal"), for: .normal)
//        btn.setTitleColor(.white, for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//        btn.backgroundColor = .COLOR_GRAY_BLACK_85
//        btn.layer.cornerRadius = kFitWidth(8)
//        btn.clipsToBounds = true
//        btn.addTarget(self, action: #selector(femanTapAction), for: .touchUpInside)
//        
//        return btn
//    }()
}

extension QuestionnaireSexVM{
    @objc func manTapAction(){
        if QuestinonaireMsgModel.shared.sex == "2"{
            QuestinonaireMsgModel.shared.clearMsg()
        }
        QuestinonaireMsgModel.shared.sex = "1"
        
        sexManButton.backgroundColor = .THEME
        sexManIcon.setImgLocal(imgName: "sex_icon_man")//sex_icon_man_normal
        sexManLabel.textColor = .white
        
        sexFeManButton.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        sexFeManIcon.setImgLocal(imgName: "sex_icon_feman_normal")//sex_icon_feman_normal
        sexFeManLabel.textColor = WHColor_16(colorStr: "595959")
        
        if self.manTapBlock != nil{
            self.manTapBlock!()
        }
    }
    @objc func femanTapAction(){
        if QuestinonaireMsgModel.shared.sex == "1"{
            QuestinonaireMsgModel.shared.clearMsg()
        }
        QuestinonaireMsgModel.shared.sex = "2"
        
        sexManButton.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
        sexManIcon.setImgLocal(imgName: "sex_icon_man_normal")//
        sexManLabel.textColor = WHColor_16(colorStr: "595959")
        
        sexFeManButton.backgroundColor = WHColor_16(colorStr: "FE5A7D")
        sexFeManIcon.setImgLocal(imgName: "sex_icon_feman")//sex_icon_feman_normal
        sexFeManLabel.textColor = .white
        
        if self.femanTapBlock != nil{
            self.femanTapBlock!()
        }
    }
}

extension QuestionnaireSexVM{
    func initUI() {
        addSubview(sexLabel)
        addSubview(sexManButton)
        sexManButton.addSubview(sexManIcon)
        sexManButton.addSubview(sexManLabel)
        addSubview(sexFeManButton)
        sexFeManButton.addSubview(sexFeManIcon)
        sexFeManButton.addSubview(sexFeManLabel)
    
        setConstrait()
    }
    
    func setConstrait() {
        sexLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
            make.height.equalTo(kFitWidth(72))
        }
        sexManButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(232))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(80))
        }
        sexManIcon.snp.makeConstraints { make in
            make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5-kFitWidth(26))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        sexManLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(177))
            make.left.equalTo(sexManIcon.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualToSuperview()
        }
        sexFeManButton.snp.makeConstraints { make in
            make.width.height.equalTo(sexManButton)
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(sexManButton.snp.bottom).offset(kFitWidth(20))
        }
        sexFeManIcon.snp.makeConstraints { make in
            make.left.equalTo((SCREEN_WIDHT-kFitWidth(32))*0.5-kFitWidth(26))
            make.centerY.lessThanOrEqualToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        sexFeManLabel.snp.makeConstraints { make in
//            make.left.equalTo(kFitWidth(177))
            make.left.equalTo(sexFeManIcon.snp.right).offset(kFitWidth(8))
            make.centerY.lessThanOrEqualToSuperview()
        }
    }
}

