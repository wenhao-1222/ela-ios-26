//
//  AICoachBreathingOrbPalette.swift
//  lns
//
//  Created by Codex on 2026/3/19.
//

import UIKit

enum AICoachBreathingOrbPalette {
    static let pageBackground = UIColor.clear
    static let pageGlow = UIColor.clear
    static let haloStroke = UIColor(red: 0.72, green: 0.84, blue: 1.0, alpha: 0.16)
    static let haloGlow = UIColor(red: 0.36, green: 0.52, blue: 1.0, alpha: 1.0)

    static let deepBlue = UIColor(red: 0.05, green: 0.15, blue: 1.0, alpha: 1.0)
    static let electricBlue = UIColor(red: 0.12, green: 0.39, blue: 1.0, alpha: 1.0)
    static let blue = UIColor(red: 0.27, green: 0.53, blue: 1.0, alpha: 1.0)
    static let aqua = UIColor(red: 0.48, green: 0.95, blue: 1.0, alpha: 1.0)
    static let cyan = UIColor(red: 0.66, green: 0.98, blue: 1.0, alpha: 1.0)
    static let indigo = UIColor(red: 0.30, green: 0.26, blue: 1.0, alpha: 1.0)
    static let violet = UIColor(red: 0.67, green: 0.45, blue: 1.0, alpha: 1.0)

    static let coreLight = UIColor(red: 0.80, green: 0.99, blue: 1.0, alpha: 1.0)
    static let coreLavender = UIColor(red: 0.79, green: 0.76, blue: 1.0, alpha: 1.0)
    static let coreShadow = UIColor(red: 0.36, green: 0.34, blue: 0.96, alpha: 1.0)
    static let rimGlow = UIColor(red: 0.74, green: 0.99, blue: 1.0, alpha: 0.98)
}

extension UIColor {
    static func orbInterpolate(from start: UIColor, to end: UIColor, amount: CGFloat) -> UIColor {
        let progress = max(0, min(1, amount))

        var sRed: CGFloat = 0
        var sGreen: CGFloat = 0
        var sBlue: CGFloat = 0
        var sAlpha: CGFloat = 0
        start.getRed(&sRed, green: &sGreen, blue: &sBlue, alpha: &sAlpha)

        var eRed: CGFloat = 0
        var eGreen: CGFloat = 0
        var eBlue: CGFloat = 0
        var eAlpha: CGFloat = 0
        end.getRed(&eRed, green: &eGreen, blue: &eBlue, alpha: &eAlpha)

        return UIColor(
            red: sRed + (eRed - sRed) * progress,
            green: sGreen + (eGreen - sGreen) * progress,
            blue: sBlue + (eBlue - sBlue) * progress,
            alpha: sAlpha + (eAlpha - sAlpha) * progress
        )
    }
}
