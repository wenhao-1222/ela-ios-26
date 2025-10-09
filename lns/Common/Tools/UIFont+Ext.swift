//
//  UIFont+Ext.swift
//  ttjx
//
//  Created by 文 on 2021/7/28.
//  Copyright © 2021 ttjx. All rights reserved.
//

import Foundation
import UIKit


extension UIFont {
    //自定义字体  PangMenZhengDao
    public static func pmzd_font(_ font : CGFloat) -> UIFont {
        
        return UIFont.init(name: "PangMenZhengDao", size: font) ?? UIFont.systemFont(ofSize: font)
    }
    
    public static func mc_boldFont(_ font : CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: font)
    }
    
}

extension UIFont {
    public static let MEDIUM_16           = UIFont.systemFont(ofSize: 16, weight: .medium)
    public static let REGULAY_16           = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    
}
