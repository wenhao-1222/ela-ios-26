//
//  InviteRewardsRuleAlertTitleVm.swift
//  lns
//
//  Created by LNS2 on 2024/5/21.
//

import Foundation

class InviteRewardsRuleAlertTitleVm: UIView {
    
    let selfHeight = kFitWidth(16)
    
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        initUI()
    }
    lazy var leftLineView: UIView = {
        let vi = UIView()
        vi.backgroundColor = .THEME
        vi.layer.cornerRadius = kFitWidth(2)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
}

extension InviteRewardsRuleAlertTitleVm{
    func initUI() {
        addSubview(leftLineView)
        addSubview(titleLabel)
        
        setConstrait()
    }
    func setConstrait() {
        leftLineView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.height.equalToSuperview()
            make.width.equalTo(kFitWidth(4))
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(28))
            make.top.height.equalToSuperview()
        }
    }
}
