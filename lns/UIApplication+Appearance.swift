//
//  UIApplication+Appearance.swift
//  lns
//
//  Created by LNS2 on 2025/11/25.
//

import UIKit

extension UIApplication {
    func applyInterfaceStyle(_ style: UIUserInterfaceStyle) {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}
