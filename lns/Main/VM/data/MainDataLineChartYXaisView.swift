//
//  MainDataLineChartYXaisView.swift
//  lns
//
//  Created by LNS2 on 2024/6/11.
//

import Foundation
import UIKit

class MainDataLineChartYXaisView: UIView {
    
    var labelGap = kFitWidth(40)
    var selfHeight = kFitWidth(0)
    var minYXAisValue = 0;
    var maxYXAisValue = 0;
    var yXaisValueGap = 0;
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.selfHeight = frame.size.height
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainDataLineChartYXaisView{
    func setData(min:Int,max:Int,gap:Int) {
        for vi in self.subviews {
            vi.removeFromSuperview()
        }
        
        self.minYXAisValue = min
        self.maxYXAisValue = max
        self.yXaisValueGap = gap
        
        drawLabel(value: max)
    }
    func drawLabel(value:Int) {
        let index = (maxYXAisValue - value)/yXaisValueGap
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: labelGap*CGFloat(index)-kFitWidth(7), width: kFitWidth(38), height: kFitWidth(14)))
        label.textColor = .COLOR_GRAY_BLACK_65
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "\(value)"
        label.textAlignment = .right
        addSubview(label)
        
        if value > minYXAisValue{
            self.drawLabel(value: value-yXaisValueGap)
        }
    }
}

