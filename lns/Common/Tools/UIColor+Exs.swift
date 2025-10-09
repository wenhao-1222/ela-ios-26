//
//  UIColor+Exs.swift
//  ttjx
//
//  Created by 文 on 2019/8/28.
//  Copyright © 2019 ttjx. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    public static let COLOR_TEXT_TITLE_0f1214           = UIColor(named: "color_text_0f1214")!
    public static let COLOR_TEXT_TITLE_0f1214_50        = UIColor(named: "color_text_0f1214_50")!
    public static let COLOR_TEXT_TITLE_0f1214_10        = UIColor(named: "color_text_0f1214_10")!
    public static let COLOR_TEXT_TITLE_0f1214_05        = UIColor(named: "color_text_0f1214_05")!
    public static let COLOR_TEXT_TITLE_0f1214_06        = UIColor(named: "color_text_0f1214_06")!
    public static let COLOR_TEXT_TITLE_0f1214_03        = UIColor(named: "color_text_0f1214_03")!
    public static let COLOR_TEXT_TITLE_0f1214_20        = UIColor(named: "color_text_0f1214_20")!
    public static let COLOR_TEXT_TITLE_0f1214_25        = UIColor(named: "color_text_0f1214_25")!
    public static let COLOR_TEXT_TITLE_0f1214_30        = UIColor(named: "color_text_0f1214_30")!
    public static let COLOR_TEXT_TITLE_0f1214_35        = UIColor(named: "color_text_0f1214_35")!
    public static let COLOR_TEXT_TITLE_0f1214_60        = UIColor(named: "color_text_0f1214_60")!
    
    public static let COLOR_BG_WHITE                    = UIColor(named: "color_bg_white")!
    public static let COLOR_BG_BLACK                    = UIColor(named: "color_bg_black")!
    public static let COLOR_BG_F5                       = UIColor(named: "color_bg_f5")!
    public static let COLOR_BG_F2                       = UIColor(named: "color_bg_f2")!
    
    
}

extension UIColor {
    
    public static let THEME                  = WHColor_16(colorStr: "007AFF")
    
    //按钮按压时
    public static let COLOR_HIGHTLIGHT_GRAY       = WHColorWithAlpha(colorStr: "8B8B8B", alpha: 0.85)
    //按钮按压时
    public static let COLOR_BUTTON_HIGHLIGHT_GRAY       = WHColorWithAlpha(colorStr: "000000", alpha: 0.85)
    //按钮高亮状态  背景色    normal时为浅灰色
    public static let COLOR_BUTTON_HIGHLIGHT_BG_GRAY_LIGHT       = WHColorWithAlpha(colorStr: "000000", alpha: 0.1)
    //按钮高亮状态  背景色   normal时为主题色
    public static let COLOR_BUTTON_HIGHLIGHT_BG_THEME   = WHColor_16(colorStr: "409BFF")
    //按钮禁用状态   背景色  normal时为主题色
    public static let COLOR_BUTTON_DISABLE_BG_THEME   = WHColor_16(colorStr: "8DC3FF")
    //按钮高亮状态  背景色   normal时为主题色的浅色
    public static let COLOR_BUTTON_HIGHLIGHT_BG_THEME_LIGHT   = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.3)
    
    public static let COLOR_BUTTON_HIGHLIGHT_BG_THEME_10   = WHColorWithAlpha(colorStr: "007AFF", alpha: 0.1)
    //按钮高亮状态   文字颜色 normal时为 黑色  0.85透明度
    public static let COLOR_BUTTON_HIGHLIGHT_TEXT_85_LIGHT   = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
    
    //热量
    public static let COLOR_CALORI     = WHColor_16(colorStr: "007AFF")
    //碳水化合物
    public static let COLOR_CARBOHYDRATE     = WHColor_16(colorStr: "7137BF")
    public static let COLOR_CARBOHYDRATE_20     = WHColorWithAlpha(colorStr: "7137BF", alpha: 0.2)
    public static let COLOR_CARBOHYDRATE_FILL    = WHColor_RGB(r: 62, g: 36, b: 101)
    //蛋白质
    public static let COLOR_PROTEIN          = WHColor_16(colorStr: "F5BA18")
    public static let COLOR_PROTEIN_20     = WHColorWithAlpha(colorStr: "F5BA18", alpha: 0.2)
    public static let COLOR_PROTEIN_FILL          = WHColor_RGB(r: 135, g: 102, b: 13)
    //脂肪
    public static let COLOR_FAT              = WHColor_16(colorStr: "E37318")
    public static let COLOR_FAT_20     = WHColorWithAlpha(colorStr: "E37318", alpha: 0.2)
    public static let COLOR_FAT_FILL              = WHColor_RGB(r: 116, g: 66, b: 25)
    //运动
    public static let COLOR_SPORT              = WHColor_16(colorStr: "FF9500")
    //胸围
    public static let COLOR_DIMENSION_XIONG              = WHColor_16(colorStr: "C43695")
    //腰围
    public static let COLOR_DIMENSION_YAO              = WHColor_16(colorStr: "FFDB25")
//    public static let COLOR_DIMENSION_YAO              = WHColor_16(colorStr: "F5BA18")
    //臀围
    public static let COLOR_DIMENSION_TUN              = WHColor_16(colorStr: "3897FF")
//    public static let COLOR_DIMENSION_TUN              = WHColor_16(colorStr: "029CD4")
    //臂围
    public static let COLOR_DIMENSION_BI              = WHColor_16(colorStr: "C43695")
//    public static let COLOR_DIMENSION_BI              = WHColor_16(colorStr: "C43695")
    //体重
    public static let COLOR_DIMENSION_WEIGHT              = WHColor_16(colorStr: "00B853")
//    public static let COLOR_DIMENSION_WEIGHT              = WHColor_16(colorStr: "008858")
    
    public static let COLOR_TEXT_GREY        = WHColor_16(colorStr: "8B8B8B")
    public static let COLOR_LIGHT_GREY       = WHColor_16(colorStr: "f5f5f5")
    public static let COLOR_LINE_GREY        = WHColor_16(colorStr: "dadada")
    public static let COLOR_GRAY_FA          = WHColor_16(colorStr: "FAFAFA")
    public static let COLOR_GRAY_F6       = WHColor_16(colorStr: "F6F6F6")
    public static let COLOR_GRAY_E2          = WHColor_16(colorStr: "E2E2E2")
    public static let COLOR_GRAY_E8          = WHColor_16(colorStr: "E8E8E8")
    public static let COLOR_GRAY_BE          = WHColor_16(colorStr: "BEBEBE")
    
    public static let COLOR_GRAY_BLACK_85    = WHColorWithAlpha(colorStr: "000000", alpha: 0.85)
    public static let COLOR_GRAY_BLACK_65    = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
    public static let COLOR_GRAY_BLACK_45    = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
    public static let COLOR_GRAY_BLACK_25    = WHColorWithAlpha(colorStr: "000000", alpha: 0.25)
    public static let COLOR_GRAY_BLACK_10    = WHColorWithAlpha(colorStr: "000000", alpha: 0.1)
    
    public static let COLOR_GRAY_F4F5F7      = WHColor_16(colorStr: "F4F5F7")
    public static let COLOR_GRAY_F7F8FA      = WHColor_16(colorStr: "F7F8FA")
    public static let COLOR_GRAY_808080      = WHColor_16(colorStr: "808080")
    public static let COLOR_GRAY_C4C4C4      = WHColor_16(colorStr: "C4C4C4")
    public static let COLOR_GRAY_D6D6D6      = WHColor_16(colorStr: "D6D6D6")
    
    public static let COLOR_TIPS              = WHColor_16(colorStr: "FF8725")
    
    public static var COLOR_RANDOM           = WHColor_ARC()// WHColor_RGB(r: (CGFloat(arc4random() % 256)), g: (CGFloat(arc4random() % 256)), b: (CGFloat(arc4random() % 256)))

    class var randomColor:UIColor{
        get{
            let red  = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue  = CGFloat(arc4random()%256)/255.0
            
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }

    // 获取当前系统是否启用了深色模式
    static var isDarkModeEnabled: Bool {
        if #available(iOS 13.0, *) {
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark
        } else {
            return false // 在iOS 13之前的版本中，默认不启用深色模式
        }
    }
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

//MARK: 深色模式适配颜色
extension UIColor{
    public static let THEME_BG_DARK = UIColor { (traitCollection: UITraitCollection) -> UIColor in
//        DLLog(message: "\(traitCollection)")
        print("traitCollection:\(traitCollection.userInterfaceStyle)")
        if traitCollection.userInterfaceStyle == .dark {
            return WHColor_RGB(r: 28, g: 28, b: 54)
        } else {
            return .THEME
        }
    }
}

extension UIColor{
    public static let WIDGET_COLOR_GRAY_BLACK_85 = WHColorWithAlpha(colorStr: "000000", alpha: 0.85)
    
    public static let WIDGET_COLOR_GRAY_BLACK_65 = WHColorWithAlpha(colorStr: "000000", alpha: 0.65)
    public static let WIDGET_COLOR_GRAY_BLACK_45 = WHColorWithAlpha(colorStr: "000000", alpha: 0.45)
    
    public static let WIDGET_COLOR_GRAY_BLACK_01 = WHColorWithAlpha(colorStr: "000000", alpha: 0.01)
    public static let WIDGET_COLOR_GRAY_BLACK_04 = WHColorWithAlpha(colorStr: "000000", alpha: 0.04)
    
    public static let WIDGET_COLOR_GRAY_BLACK_06 = WHColorWithAlpha(colorStr: "000000", alpha: 0.06)
    public static let WIDGET_COLOR_SPORT = WHColorWithAlpha(colorStr: "FF9500", alpha: 1.0)
    
}

//随机色
public func WHColor_ARC() -> UIColor {
    let r = (CGFloat(arc4random() % 256))
    let g = (CGFloat(arc4random() % 256))
    let b = (CGFloat(arc4random() % 256))
    if #available(iOS 10.0, *) {
        return UIColor(displayP3Red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    } else {
        // Fallback on earlier versions
        return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    }
}

public func WHColorWithAlpha(colorStr:String , alpha:CGFloat)->UIColor{
    var color = UIColor.red
    var cStr : String = colorStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
    if cStr.hasPrefix("#") {
        let index = cStr.index(after: cStr.startIndex)
        cStr = String(cStr.prefix(upTo: index))
    }
    
    if cStr.count != 6 {
        return UIColor.black
    }
    //两种不同截取字符串的方法
    let rIndex = cStr.index(cStr.startIndex, offsetBy: 2)
    let rStr = String(cStr.prefix(upTo: rIndex))
    
    let gRange = cStr.index(cStr.startIndex, offsetBy: 2) ..< cStr.index(cStr.startIndex, offsetBy: 4)
    let gStr = cStr[gRange]
    
    let bIndex = cStr.index(cStr.endIndex, offsetBy: -2)
    let bStr = cStr.suffix(from: bIndex)
    
    color = UIColor.init(red: CGFloat(Float(changeToInt(numStr: rStr)) / 255), green: CGFloat(Float(changeToInt(numStr: String(gStr))) / 255), blue: CGFloat(Float(changeToInt(numStr: String(bStr))) / 255), alpha: alpha)
    
    return color
}

public func WHColor_TextBlack()->UIColor{
    return WHColor_16(colorStr: "#333333")
}

public func WHColor_LineGray()->UIColor{
    return WHColor_RGB(r: 202, g: 202, b: 202)
}

//MARK: -RGB颜色
public func WHColor_RGB(r: CGFloat,g: CGFloat,b: CGFloat) -> UIColor {
    if #available(iOS 10.0, *) {
        return UIColor(displayP3Red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    } else {
        // Fallback on earlier versions
        return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    }
}
//MARK: -16进制颜色
public func WHColor_16(colorStr:String) -> UIColor {
    
    var color = UIColor.red
    var cStr : String = colorStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
    if cStr.hasPrefix("#") {
        let index = cStr.index(after: cStr.startIndex)
        cStr = String(cStr.prefix(upTo: index))
    }
    
    if cStr.count != 6 {
        return UIColor.black
    }
    //两种不同截取字符串的方法
    let rIndex = cStr.index(cStr.startIndex, offsetBy: 2)
    let rStr = String(cStr.prefix(upTo: rIndex))
    
    let gRange = cStr.index(cStr.startIndex, offsetBy: 2) ..< cStr.index(cStr.startIndex, offsetBy: 4)
    let gStr = cStr[gRange]
    
    let bIndex = cStr.index(cStr.endIndex, offsetBy: -2)
    let bStr = cStr.suffix(from: bIndex)
    
    color = UIColor.init(red: CGFloat(Float(changeToInt(numStr: rStr)) / 255), green: CGFloat(Float(changeToInt(numStr: String(gStr))) / 255), blue: CGFloat(Float(changeToInt(numStr: String(bStr))) / 255), alpha: 1)
    
    return color
}
/// 支持格式：
/// - #RGB         (3位，不含透明度)
/// - #RGBA        (4位，含透明度)
/// - #RRGGBB     (6位，不含透明度)
/// - #RRGGBBAA   (8位，含透明度，**最后两位为 alpha**)
/// 也支持 "0x" 前缀或无前缀，大小写均可；无效输入返回 .black
public func WHColorHex(_ hex: String) -> UIColor {
    // 1) 预处理：去空白、去前缀
    var cStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                  .replacingOccurrences(of: "_", with: "")
                  .uppercased()
    if cStr.hasPrefix("#") { cStr.removeFirst() }
    if cStr.hasPrefix("0X") { cStr.removeFirst(2) }

    // 2) 将 3/4 位简写展开为 6/8 位
    switch cStr.count {
    case 3: // RGB -> RRGGBB
        let r = cStr[cStr.startIndex]
        let g = cStr[cStr.index(cStr.startIndex, offsetBy: 1)]
        let b = cStr[cStr.index(cStr.startIndex, offsetBy: 2)]
        cStr = "\(r)\(r)\(g)\(g)\(b)\(b)"
    case 4: // RGBA -> RRGGBBAA
        let r = cStr[cStr.startIndex]
        let g = cStr[cStr.index(cStr.startIndex, offsetBy: 1)]
        let b = cStr[cStr.index(cStr.startIndex, offsetBy: 2)]
        let a = cStr[cStr.index(cStr.startIndex, offsetBy: 3)]
        cStr = "\(r)\(r)\(g)\(g)\(b)\(b)\(a)\(a)"
    case 6, 8:
        break // 已是完整长度
    default:
        return .black
    }

    // 3) 解析 6/8 位十六进制
    let scanner = Scanner(string: cStr)
    var value: UInt64 = 0
    guard scanner.scanHexInt64(&value) else { return .black }

    let r, g, b, a: CGFloat
    if cStr.count == 6 {
        r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        g = CGFloat((value & 0x00FF00) >> 8)  / 255.0
        b = CGFloat( value & 0x0000FF)        / 255.0
        a = 1.0
    } else { // 8 位：RRGGBBAA（最后两位为 alpha）
        r = CGFloat((value & 0xFF000000) >> 24) / 255.0
        g = CGFloat((value & 0x00FF0000) >> 16) / 255.0
        b = CGFloat((value & 0x0000FF00) >> 8)  / 255.0
        a = CGFloat( value & 0x000000FF)        / 255.0
    }
    return UIColor(red: r, green: g, blue: b, alpha: a)
}
private func changeToInt(numStr:String) -> Int {
    
    let str = numStr.uppercased()
    var sum = 0
    for i in str.utf8 {
        //0-9 从48开始
        sum = sum * 16 + Int(i) - 48
        if i >= 65 {
            //A~Z 从65开始，但初始值为10
            sum -= 7
        }
    }
    return sum
}
