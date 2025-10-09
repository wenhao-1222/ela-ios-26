//
//  PlanCreateSynDaysVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/17.
//

import Foundation
import UIKit

class PlanCreateSynDaysVM: UIView {
    
    var days = ""
    var isSelect = false
    
    var selectContentColor = UIColor.COLOR_TEXT_TITLE_0f1214
    var selectBgColor = UIColor.THEME
    var tapBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        self.isHidden = true
        self.layer.cornerRadius = kFitWidth(8)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tap)
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("PlanCreateSynDaysVM init(coder:) has not been implemented")
    }
    lazy var bgView : UIView = {
        let vi = UIView()
        vi.isUserInteractionEnabled = true
        vi.backgroundColor = .COLOR_BG_F5
        vi.layer.cornerRadius = kFitWidth(8)
        vi.clipsToBounds = true
        vi.layer.borderColor = UIColor.clear.cgColor
        vi.layer.borderWidth = kFitWidth(1)
        
        return vi
    }()
    lazy var contentLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var selecImgView: UIImageView = {
        let img = UIImageView()
        img.setImgLocal(imgName: "create_plan_syn_select")
        img.isUserInteractionEnabled = true
        img.isHidden = true
        return img
    }()
}


extension PlanCreateSynDaysVM{
    func setSelectStatus(select:Bool) {
        self.isSelect = select
        if isSelect == true{
            selecImgView.isHidden = false
            contentLabel.textColor = selectContentColor
            bgView.layer.borderColor = UIColor.THEME.cgColor
        }else{
            selecImgView.isHidden = true
            contentLabel.textColor = .COLOR_TEXT_TITLE_0f1214
            bgView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func setEnableStatus(isEnable:Bool) {
        if isEnable || self.contentLabel.text == "休"{
            self.isUserInteractionEnabled = true
            self.contentLabel.textColor = .COLOR_TEXT_TITLE_0f1214
        }else{
            self.isUserInteractionEnabled = false
            self.contentLabel.textColor = .COLOR_TEXT_TITLE_0f1214_20
        }
    }
}

extension PlanCreateSynDaysVM{
    func initUI() {
        addSubview(bgView)
        bgView.addSubview(contentLabel)
        bgView.addSubview(selecImgView)
        
        setConstrait()
    }
    func setConstrait() {
        bgView.snp.makeConstraints { make in
            make.left.top.width.height.equalToSuperview()
        }
        selecImgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(kFitWidth(24))
        }
        contentLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
    }
}


extension PlanCreateSynDaysVM{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        bgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.08)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        bgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
    }
   @objc func tapAction() {
       playClickAnimation()
       bgView.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
       
       isSelect = !isSelect
       if isSelect == true{
           selecImgView.isHidden = false
           contentLabel.textColor = selectContentColor
           bgView.layer.borderColor = selectBgColor.cgColor
       }else{
           selecImgView.isHidden = true
           contentLabel.textColor = .COLOR_TEXT_TITLE_0f1214
           bgView.layer.borderColor = UIColor.clear.cgColor
       }
       if self.tapBlock != nil{
           self.tapBlock!()
       }
    }
    private func playClickAnimation() {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.bgView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.bgView.transform = .identity
            }
        }, completion: nil)
    }
}
