//
//  NaturalStatNaviTimeVM.swift
//  lns
//
//  Created by LNS2 on 2024/9/11.
//

import Foundation

class NaturalStatNaviTimeVM: UIView {
    
    let selfHeight = kFitWidth(40)
    
    required init?(coder: NSCoder) {
        fatalError("required init?(coder: NSCoder) failed")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
//        self.isHidden = true
        
        initUI()
    }
    lazy var timeLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_45
        lab.font = .systemFont(ofSize: 12, weight: .medium)
        lab.textAlignment = .center
        
        return lab
    }()
}

extension NaturalStatNaviTimeVM{
    func initUI() {
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.center.lessThanOrEqualToSuperview()
        }
    }
}
