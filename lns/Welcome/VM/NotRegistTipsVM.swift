//
//  NotRegistTipsVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/2.
//

import Foundation
import UIKit

class NotRegistTipsVM: UIView {
    
    var whiteViewHeight = kFitWidth(473)+WHUtils().getBottomSafeAreaHeight()+kFitWidth(16)
    var hiddenBlock:(()->())?
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColor_16(colorStr: "FAFAFA")
        self.alpha = 0
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.text = "很遗憾\n我们未能匹配到您的账号信息"
        lab.textAlignment = .center
        lab.numberOfLines = 2
        lab.lineBreakMode = .byWordWrapping
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.text = "请设置营养目标后再尝试登录"
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_85
        
        return lab
    }()
    lazy var gotItBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("好 的", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .THEME
        btn.layer.cornerRadius = kFitWidth(24)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.85), for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
        btn.clipsToBounds = true
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(hiddenView), for: .touchUpInside)
        
        return btn
    }()
    
}

extension NotRegistTipsVM{
    @objc func showView() {
        self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*0.5)
        UIView.animate(withDuration: 0.4, delay: 0,options: .curveLinear) {
            self.alpha = 1
        }
   }
   @objc func hiddenView() {
       UIView.animate(withDuration: 0.4, delay: 0,options: .curveLinear) {
           self.alpha = 0
       }completion: { t in
           self.center = CGPoint.init(x: SCREEN_WIDHT*0.5, y: SCREEN_HEIGHT*1.5)
       }
       if self.hiddenBlock != nil{
           self.hiddenBlock!()
       }
  }
}

extension NotRegistTipsVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsLabel)
        addSubview(gotItBtn)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(301))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(kFitWidth(20))
        }
        gotItBtn.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(tipsLabel.snp.bottom).offset(kFitWidth(60))
        }
    }
}
