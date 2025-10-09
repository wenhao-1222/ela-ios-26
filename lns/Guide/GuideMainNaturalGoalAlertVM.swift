//
//  GuideMainNaturalGoalAlertVM.swift
//  lns
//
//  Created by LNS2 on 2024/7/1.
//

import Foundation
import UIKit

class GuideMainNaturalGoalAlertVM: UIView {
    
    let originY = kFitWidth(56) + statusBarHeight + 44
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: SCREEN_HEIGHT))
        self.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(doneClick))
        self.addGestureRecognizer(tap)
        
        let is_guide = UserDefaults.standard.value(forKey: guide_main_natural) as? String ?? ""
        
        if is_guide.count > 0 || Date().judgeMin(firstTime: UserInfoModel.shared.registDate, secondTime: "2025-02-01",formatter: "yyyy-MM-dd"){
            self.isHidden = true
        }
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var goalVm : MainTopGoalVM = {
        let vm = MainTopGoalVM.init(frame: CGRect.init(x: kFitWidth(32), y: originY + kFitWidth(76), width: 0, height: 0))
        
        return vm
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = ""
        
        var titleAttr = NSMutableAttributedString(string: "")
        let step1 = NSMutableAttributedString(string: "设置营养目标/碳水循环")
        
//        titleAttr = WHUtils().createAttributedStringWithImage(image: UIImage(named: "main_edit_icon")!, text: "点击")
        
        titleAttr = WHUtils().createAttributedStringWithImage(image: UIImage(named: "main_pencil_icon")!, text: "点击")
        
        titleAttr.yy_font = .systemFont(ofSize: 14)
        step1.yy_font = .systemFont(ofSize: 14)
        
        titleAttr.yy_color = .white
        step1.yy_color = .white
        
        titleAttr.append(step1)
        lab.attributedText = titleAttr
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        
        return lab
    }()
    lazy var comfirmButton: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: kFitWidth(16), y: SCREEN_HEIGHT-WHUtils().getBottomSafeAreaHeight()-kFitWidth(60), width: kFitWidth(343), height: kFitWidth(48)))
//        btn.backgroundColor = .clear
//        btn.layer.borderColor = UIColor.white.cgColor
//        btn.layer.borderWidth = kFitWidth(1)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.setBackgroundImage(createImageWithColor(color: .THEME), for: .normal)
//        btn.setBackgroundImage(createImageWithColor(color: WHColorWithAlpha(colorStr: "007AFF", alpha: 0.7)), for: .highlighted)
        
        btn.enablePressEffect()
        btn.addTarget(self, action: #selector(doneClick), for: .touchUpInside)
        
        return btn
    }()
    lazy var bottomeTipsLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: SCREEN_HEIGHT-WHUtils().getTabbarHeight()-kFitWidth(40), width: SCREEN_WIDHT, height: kFitWidth(20)))
        lab.text = "点击任意位置可关闭"
        lab.textColor = WHColorWithAlpha(colorStr: "FFFFFF", alpha: 0.5)
        lab.font = .systemFont(ofSize: 10)
        lab.textAlignment = .center
        return lab
    }()
}

extension GuideMainNaturalGoalAlertVM{
    @objc func doneClick() {
        self.isHidden = true
        
        UserDefaults.standard.setValue("1", forKey: guide_main_natural)
    }
}
extension GuideMainNaturalGoalAlertVM{
    func initUI() {
        addSubview(goalVm)
        addSubview(tipsLabel)
        
        addSubview(bottomeTipsLabel)
//        addSubview(comfirmButton)
        
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(140))
            make.top.equalTo(goalVm.snp.bottom).offset(kFitWidth(5))
            make.right.equalTo(kFitWidth(-20))
        }
    }
}
 
