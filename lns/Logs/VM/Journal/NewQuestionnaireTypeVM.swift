//
//  NewQuestionnaireTypeVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/9.
//

import Foundation
import UIKit

class NewQuestionnaireTypeVM: UIView {
    
    var isShow = false
    var backBlock:(()->())?
    var choiceBlock:((Bool)->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: SCREEN_WIDHT, y: frame.origin.y, width: SCREEN_WIDHT, height: SCREEN_HEIGHT-frame.origin.y))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "back_arrow_highlight"), for: .highlighted)
        btn.setImage(UIImage(named: "back_arrow"), for: .normal)
        
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        btn.isHidden = true
        
        return btn
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "您是否需要饮食计划？"
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var yesButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("是", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(36)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(yesAction), for: .touchUpInside)
        
        return btn
    }()
    lazy var noButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("否，我只需要营养目标", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.layer.cornerRadius = kFitWidth(36)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(noAction), for: .touchUpInside)
        return btn
    }()
}

extension NewQuestionnaireTypeVM{
    @objc func backAction() {
        if self.backBlock != nil{
            self.backBlock!()
        }
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveLinear) {
            self.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: SCREEN_HEIGHT*0.5)
        }
    }
    @objc func yesAction() {
        if self.choiceBlock != nil{
            self.choiceBlock!(true)
        }
//        UIView.animate(withDuration: 0.2, delay: 0,options: .curveLinear) {
//            self.alpha = 0
//        }completion: { t in
//            self.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: SCREEN_HEIGHT*0.5)
//            self.alpha = 1
//        }
    }
    @objc func noAction() {
        if self.choiceBlock != nil{
            self.choiceBlock!(false)
        }
//        UIView.animate(withDuration: 0.2, delay: 0,options: .curveLinear) {
//            self.alpha = 0
//        }completion: { t in
//            self.center = CGPoint.init(x: SCREEN_WIDHT*1.5, y: SCREEN_HEIGHT*0.5)
//            self.alpha = 1
//        }
    }
    
}

extension NewQuestionnaireTypeVM{
    func initUI() {
        addSubview(backButton)
        addSubview(tipsLabel)
        addSubview(yesButton)
        addSubview(noButton)
        
        setConstrait()
    }
    func setConstrait(){
        backButton.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(0))
            make.top.equalTo(statusBarHeight)
            make.width.height.equalTo(kFitWidth(44))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(60))
        }
        yesButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(100))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(72))
        }
        noButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(yesButton.snp.bottom).offset(kFitWidth(20))
            make.width.equalTo(SCREEN_WIDHT-kFitWidth(32))
            make.height.equalTo(kFitWidth(72))
        }
    }
}
