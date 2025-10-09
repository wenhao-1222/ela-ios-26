//
//  WelcomeProtocalVM.swift
//  lns
//
//  Created by LNS2 on 2024/3/27.
//

import Foundation
import UIKit

class WelcomeProtocalVM: UIView {
    
    let selfHeight = kFitWidth(140)
    override init(frame:CGRect){
        super.init(frame: CGRect.init(x: 0, y: frame.origin.y, width: SCREEN_WIDHT, height: selfHeight))
        self.backgroundColor = .black
        self.isUserInteractionEnabled = true
        
        initUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WelcomeProtocalVM{
    func initUI() {
        
    }
}

