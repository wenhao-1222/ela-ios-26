//
//  NaturalPieChartLegendITemVM.swift
//  lns
//
//  Created by LNS2 on 2024/4/26.
//

import Foundation
import UIKit

class NaturalPieChartLegendITemVM: UIView {
    
    let selfHeight = kFitWidth(30)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(125), height: selfHeight))
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var circleView: UIView = {
        let vi = UIView()
        vi.layer.cornerRadius = kFitWidth(4)
        vi.clipsToBounds = true
        
        return vi
    }()
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .COLOR_GRAY_BLACK_85
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        
        return lab
    }()
    lazy var detailsLabel: UILabel = {
        let lab = UILabel()
        lab.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
        lab.font = .systemFont(ofSize: 12, weight: .regular)
        lab.adjustsFontSizeToFitWidth = true
        lab.text = "0%（0千卡）"
        return lab
    }()
}

extension NaturalPieChartLegendITemVM{
    func initUI() {
        addSubview(circleView)
        addSubview(titleLabel)
        addSubview(detailsLabel)
        
        setConstrait()
    }
    func setConstrait() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalToSuperview()
        }
        circleView.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(0))
            make.centerY.lessThanOrEqualTo(titleLabel)
            make.width.height.equalTo(kFitWidth(8))
        }
        detailsLabel.snp.makeConstraints { make in
            make.left.equalTo(kFitWidth(12))
            make.top.equalTo(kFitWidth(16))
            make.right.equalToSuperview()
        }
    }
}
