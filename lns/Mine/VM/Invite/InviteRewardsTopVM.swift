//
//  InviteRewardsTopVM.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//

import Foundation

class InviteRewardsTopVM: UIView {
    
    let selfHeight = kFitWidth(276)
    var withDrawBlock:(()->())?
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: WHUtils().getNavigationBarHeight(), width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var moneyLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 32, weight: .medium)
        lab.text = "￥0.00"
        
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "余额 (满10元即可提现)"
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var withDrawButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("提现", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        btn.isEnabled = false
        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .highlighted)
//        btn.setBackgroundImage(createImageWithColor(color: .COLOR_BUTTON_HIGHLIGHT_BG_THEME), for: .disabled)
        btn.layer.cornerRadius = kFitWidth(24)
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(withDrawAction), for: .touchUpInside)
        return btn
    }()
    lazy var lineVerView: UIView = {
        let vi = UIView()
        vi.backgroundColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
        return vi
    }()
    lazy var inviteNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        lab.text = "0"
        return lab
    }()
    lazy var inviteNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "已邀请"
        return lab
    }()
    
    lazy var remainNumLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 20, weight: .medium)
        lab.text = "0"
        return lab
    }()
    lazy var remainNumLab: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.text = "剩余名额"
        return lab
    }()
}

extension InviteRewardsTopVM{
    func refreshUI(dict:NSDictionary) {
        let withdrawalLimits = dict.doubleValueForKey(key: "withdrawalLimits")/100
        moneyLabel.text = "¥ \(dict.stringValueForKey(key: "money"))"
        tipsLabel.text = "余额 (满\(withdrawalLimits))元即可提现)"
        inviteNumLabel.text = dict.stringValueForKey(key: "invited")
        remainNumLabel.text = dict.stringValueForKey(key: "remaining")
        
//        let withdrawalLimits = withdrawalLimits
        let money = dict.doubleValueForKey(key: "money")
        if money < withdrawalLimits{
            withDrawButton.isEnabled = false
            withDrawButton.backgroundColor = .COLOR_BUTTON_DISABLE_BG_THEME
        }else{
            withDrawButton.isEnabled = true
            withDrawButton.backgroundColor = .THEME
        }
    }
    @objc func withDrawAction() {
        if self.withDrawBlock != nil{
            self.withDrawBlock!()
        }
    }
}

extension InviteRewardsTopVM{
    func initUI() {
        addSubview(moneyLabel)
        addSubview(tipsLabel)
        addSubview(withDrawButton)
        addSubview(lineVerView)
        addSubview(inviteNumLab)
        addSubview(inviteNumLabel)
        addSubview(remainNumLab)
        addSubview(remainNumLabel)
        
        setConstrait()
    }
    func setConstrait() {
        moneyLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(40))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(moneyLabel.snp.bottom).offset(kFitWidth(12))
        }
        withDrawButton.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(200))
            make.height.equalTo(kFitWidth(48))
            make.top.equalTo(kFitWidth(116))
        }
        lineVerView.snp.makeConstraints { make in
            make.bottom.equalTo(kFitWidth(-18))
            make.centerX.lessThanOrEqualToSuperview()
            make.width.equalTo(kFitWidth(1))
            make.height.equalTo(kFitWidth(44))
        }
        inviteNumLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(93.5))
            make.bottom.equalTo(kFitWidth(-20))
        }
        inviteNumLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(inviteNumLab)
            make.bottom.equalTo(kFitWidth(-40))
        }
        remainNumLab.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(kFitWidth(93.5)+kFitWidth(188))
            make.centerY.lessThanOrEqualTo(inviteNumLab)
        }
        remainNumLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualTo(remainNumLab)
            make.centerY.lessThanOrEqualTo(inviteNumLabel)
        }
    }
}

