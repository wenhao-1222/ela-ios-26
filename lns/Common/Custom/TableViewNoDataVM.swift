//
//  TableViewNoDataVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/11.
//

import Foundation
import UIKit

class TableViewNoDataVM: UIView {
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: kFitWidth(100), width: frame.size.width, height: kFitWidth(50)))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var noDataLabel : UILabel = {
        let lab = UILabel()
        lab.text = "- 暂无数据 -"
        lab.textColor = .COLOR_TEXT_TITLE_0f1214
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        lab.textAlignment = .center
        
        return lab
    }()
    lazy var tipsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        
        let attr = NSMutableAttributedString(string: "请点击")
        let searc = NSMutableAttributedString(string: "搜索")
        
        searc.yy_font = .systemFont(ofSize: 14, weight: .semibold)
        attr.append(searc)
        
        lab.isHidden = true
        lab.attributedText = attr
        
        return lab
    }()
}

extension TableViewNoDataVM{
    func initUI() {
        addSubview(noDataLabel)
        addSubview(tipsLabel)
        
        setConstrait()
    }
    func setConstrait() {
        noDataLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(kFitWidth(5))
        }
        tipsLabel.snp.makeConstraints { make in
            make.centerX.lessThanOrEqualToSuperview()
            make.top.equalTo(noDataLabel.snp.bottom).offset(kFitWidth(4))
        }
    }
}
