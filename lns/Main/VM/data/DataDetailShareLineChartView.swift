//
//  DataDetailShareLineChartView.swift
//  lns
//
//  Created by LNS2 on 2024/4/19.
//

import Foundation
import UIKit

class DataDetailShareLineChartView: UIView {
    
    let selfWidth = kFitWidth(100)
    let selfHeight = kFitWidth(24)
    
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: frame.origin.x, y: frame.origin.y, width: kFitWidth(100), height: selfHeight))
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DataDetailShareLineChartView{
    func initUI() {
        let context = UIGraphicsGetCurrentContext()
    }
}
