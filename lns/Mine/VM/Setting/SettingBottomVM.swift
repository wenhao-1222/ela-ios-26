//
//  SettingBottomVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/14.
//

import Foundation
import UIKit

class SettingBottomVM: UIView {
    
    let selfHeight = kFitWidth(100)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var cancelAccountButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("注销账号", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.25), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        return btn
    }()
    lazy var lineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return vi
    }()
    lazy var loginOutButton: FeedBackButton = {
        let btn = FeedBackButton()
        btn.setTitle("退出登录", for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.45), for: .normal)
        btn.setTitleColor(WHColorWithAlpha(colorStr: "000000", alpha: 0.25), for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        
        return btn
    }()
}

extension SettingBottomVM{
    func initUI() {
        addSubview(cancelAccountButton)
        addSubview(loginOutButton)
        addSubview(lineView)
        
        setConstrait()
    }
    func setConstrait() {
        lineView.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(16))
            make.bottom.equalTo(kFitWidth(-12))
        }
        cancelAccountButton.snp.makeConstraints { make in
            make.centerY.lessThanOrEqualTo(lineView)
            make.right.equalTo(lineView.snp.left)
            make.width.equalTo(kFitWidth(96))
            make.height.equalTo(lineView)
        }
        loginOutButton.snp.makeConstraints { make in
            make.width.height.equalTo(cancelAccountButton)
            make.centerY.lessThanOrEqualTo(lineView)
            make.left.equalTo(lineView.snp.right)
        }
    }
}
