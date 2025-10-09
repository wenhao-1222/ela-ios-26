//
//  MainDataLineChartLegentView.swift
//  lns
//
//  Created by LNS2 on 2024/6/11.
//

import Foundation
import UIKit

class MainDataLineChartLegentView: UIView {
    
    var labelGap = kFitWidth(20)
    let colors = [UIColor.COLOR_DIMENSION_YAO,
                  UIColor.COLOR_DIMENSION_TUN,
                  UIColor.COLOR_DIMENSION_BI]
    let labels = ["腰围",
                  "臀围",
                  "手臂"]
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainDataLineChartLegentView{
    func initUI() {
//        for vi in self.subviews{
//            vi.removeFromSuperview()
//        }
        
        var originX = kFitWidth(0)
        
        for i in 0..<colors.count{
            let circleView = UIView()
            addSubview(circleView)
            circleView.backgroundColor = colors[i]
            circleView.clipsToBounds = true
            circleView.layer.cornerRadius = kFitWidth(5)
            
            let label = UILabel()
            label.textColor = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.text = labels[i]
            addSubview(label)
            
            circleView.snp.makeConstraints { make in
                make.centerY.lessThanOrEqualToSuperview()
                make.width.height.equalTo(kFitWidth(10))
                make.left.equalTo(originX)
            }
            originX = originX+kFitWidth(14)
            label.snp.makeConstraints { make in
                make.centerY.lessThanOrEqualToSuperview()
                make.left.equalTo(originX)
            }
            originX = originX + kFitWidth(44)
        }
    }
}
