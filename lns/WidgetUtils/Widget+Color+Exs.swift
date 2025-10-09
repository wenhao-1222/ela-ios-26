//
//  Widget+Color+Exs.swift
//  lns
//
//  Created by LNS2 on 2024/8/27.
//

import Foundation
import SwiftUI

extension Color{
    
    static var isDarkModeEnabled: Bool {
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }
    
    public static let TEXT_BLACK_85 = isDarkModeEnabled ? Color.white.opacity(0.85) : Color.black.opacity(0.85)
    
    
    
}


