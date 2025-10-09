//
//  CancelAccountHelpVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/14.
//

import Foundation
import UIKit

class CancelAccountHelpVM: UIView {
    
    let selfHeight = kFitWidth(154)
    
    required init?(coder: NSCoder) {
        fatalError("CancelAccountItemVM  required init?(coder: NSCoder)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    lazy var titleLabel: UILabel = {
        let lab = UILabel()
        lab.text = "您是否需要："
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 16, weight: .medium)
        
        return lab
    }()
    lazy var resetButton: FeedBackButton = {
        let btn = FeedBackButton.init(frame: CGRect.init(x: kFitWidth(16), y: kFitWidth(22), width: kFitWidth(140), height: kFitWidth(44)))
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitle("·重置日志列表", for: .normal)
        btn.titleLabel?.textAlignment = .left
        
        return btn
    }()
    lazy var resetGoalButton: FeedBackButton = {
        let btn = FeedBackButton.init(frame: CGRect.init(x: self.resetButton.frame.origin.x, y: self.resetButton.frame.maxY, width: self.resetButton.frame.size.width, height: self.resetButton.frame.size.height))
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitle("·重新获取目标", for: .normal)
        btn.titleLabel?.textAlignment = .left
        
        return btn
    }()
    lazy var getGoalButton: FeedBackButton = {
        let btn = FeedBackButton.init(frame: CGRect.init(x: self.resetButton.frame.origin.x, y: self.resetGoalButton.frame.maxY, width: self.resetButton.frame.size.width, height: self.resetButton.frame.size.height))
        btn.setTitleColor(.THEME, for: .normal)
        btn.setTitleColor(.COLOR_BUTTON_HIGHLIGHT_GRAY, for: .highlighted)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.setTitle("·手动填写目标", for: .normal)
        btn.titleLabel?.textAlignment = .left
        
        return btn
    }()
}

extension CancelAccountHelpVM{
    func initUI() {
        addSubview(titleLabel)
        addSubview(resetButton)
        addSubview(resetGoalButton)
        addSubview(getGoalButton)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(16))
            make.top.equalToSuperview()
            make.height.equalTo(kFitWidth(22))
        }
    }
}
