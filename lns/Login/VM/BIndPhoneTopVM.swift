//
//  BIndPhoneTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/3.
//

import Foundation
import UIKit

class BIndPhoneTopVM: UIView {
    
    let selfHeight = kFitWidth(120)
    
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 24, weight: .medium)
        lab.textColor = WHColor_16(colorStr: "242424")
        lab.text = "绑定手机号码"
        
        return lab
    }()
    lazy var tipsLabel : UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.textColor = .COLOR_GRAY_BLACK_65
        lab.numberOfLines = 0
        lab.lineBreakMode = .byWordWrapping
        lab.text = "绑定的手机号可以用来登录，若账号丢失或出现异常可通过绑定手机号找回"
        
        return lab
    }()
}

extension BIndPhoneTopVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(tipsLabel)
        
        setConstrait()
    }
    func setConstrait() {
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(35))
        }
        tipsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(32))
            make.top.equalTo(kFitWidth(70))
            make.right.equalTo(kFitWidth(-32))
        }
    }
}
