//
//  UIFont+Exs.swift
//  lns
//
//  Created by LNS2 on 2024/4/7.
//

import Foundation

extension UIFont{
    @objc func DDInFontMedium(fontSize:CGFloat) -> UIFont {
        if let customFont = UIFont(name: "D-DIN-PRO-Medium", size: fontSize) {
            return customFont
        } else {
            print("Custom font not found")
        }
        return .systemFont(ofSize: fontSize, weight: .medium)
    }
    func DDInFontSemiBold(fontSize:CGFloat) -> UIFont {
        if let customFont = UIFont(name: "D-DIN-PRO-SemiBold", size: fontSize) {
            return customFont
        } else {
            print("Custom font not found")
        }
        return .systemFont(ofSize: fontSize, weight: .semibold)
    }
    func DDInFontBold(fontSize:CGFloat) -> UIFont {
        if let customFont = UIFont(name: "D-DIN-PRO-Bold", size: fontSize) {
            return customFont
        } else {
            print("Custom font not found")
        }
        return .systemFont(ofSize: fontSize, weight: .bold)
    }
    
    func DDInFontExtraBold(fontSize:CGFloat) -> UIFont {
        if let customFont = UIFont(name: "D-DIN-PRO-ExtraBold", size: fontSize) {
            return customFont
        } else {
            print("Custom font not found")
        }
        return .systemFont(ofSize: fontSize, weight: .bold)
    }
    func DDInFontHeavy(fontSize:CGFloat) -> UIFont {
        if let customFont = UIFont(name: "D-DIN-PRO-Heavy", size: fontSize) {
            return customFont
        } else {
            print("Custom font not found")
        }
        return .systemFont(ofSize: fontSize, weight: .heavy)
    }
    func DDInFontRegular(fontSize:CGFloat) -> UIFont {
        if let customFont = UIFont(name: "D-DIN-PRO-Regular", size: fontSize) {
            return customFont
        } else {
            print("Custom font not found")
        }
        return .systemFont(ofSize: fontSize, weight: .regular)
    }
}
