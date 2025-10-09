//
//  CustomRefreshHeader.swift
//  lns
//
//  Created by Elavatine on 2025/1/19.
//

import MJRefresh
import UIKit

class CustomRefreshHeader: MJRefreshNormalHeader {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 隐藏默认的文字标签
        self.lastUpdatedTimeLabel?.isHidden = true
        self.stateLabel?.isHidden = true
//        self.arrowView?.isHidden = true
        self.loadingView?.style = .medium
//        self.loadingView?.color = .THEME
        
        setOnlyLoadingView()
        
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
