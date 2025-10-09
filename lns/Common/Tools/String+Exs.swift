//
//  String+Exs.swift
//  ttjx
//
//  Created by 文 on 2019/11/18.
//  Copyright © 2019 ttjx. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit

extension String {
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
            
        }
        return ""
        
    }
    
    func isLetterWithDigital() ->Bool{
//        let numberRegex:NSPredicate=NSPredicate(format:"SELF MATCHES %@","^.*[0-9]+.*$")
//        let letterRegex:NSPredicate=NSPredicate(format:"SELF MATCHES %@","^.*[A-Za-z]+.*$")
//        if numberRegex.evaluate(with: self) && letterRegex.evaluate(with: self){
        let regex:NSPredicate=NSPredicate(format:"SELF MATCHES %@","^[a-zA-Z0-9]+$")
        if regex.evaluate(with: self){
           return true
        }else{
            return false
        }
    }
    
    func judgeIncludeChineseWord() -> Bool {
        for (_, value) in self.enumerated() {

            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        
        return false
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
            
        }
        return hexString
        
    }
//    func attributedText(text: String, keywords: [String], font: UIFont, ignoreCase: Bool = true) -> NSAttributedString {
//        let attributedString = NSMutableAttributedString(string: text)
//        let baseText = ignoreCase ? text.lowercased() : text
//        
//        for keyword in keywords {
//            let searchKeyword = ignoreCase ? keyword.lowercased() : keyword
//            var searchRange = baseText.startIndex..<baseText.endIndex
//
//            while let range = baseText.range(of: searchKeyword, options: [], range: searchRange) {
//                let nsRange = NSRange(range, in: text)
//                attributedString.addAttribute(.font, value: font, range: nsRange)
//                searchRange = range.upperBound..<baseText.endIndex
//            }
//        }
//
//        return attributedString
//    }
    func attributedText(text: String, keywords: [String], font: UIFont,color:UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        for keyword in keywords {
            let range = (text as NSString).range(of: keyword)
            if range.location != NSNotFound {
                attributedString.addAttribute(.font, value: font, range: range)
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        
        return attributedString
    }
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    func htmlToString(_ htmlString: String) -> String {
        do {
            let attrText = try NSMutableAttributedString(data: (htmlString).data(using: String.Encoding.utf8, allowLossyConversion: true)!,
                                                         options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                                                                   NSAttributedString.DocumentReadingOptionKey.characterEncoding:String.Encoding.utf8.rawValue],
                                                         documentAttributes: nil)
            return attrText.string
        } catch let error as NSError {
            return "HTML 序列转义失败: \(error)"
        }
    }
    var isBlank : Bool{
        return allSatisfy({$0.isWhitespace})
    }
}

extension Optional where Wrapped == String{
    var isBlank : Bool{
        return self?.isBlank ?? true
    }
}

//MARK: 类型转换
extension String {
    
    /**
     * 字符串 转 Int
     */
    public var intValue: Int {
        let str = self
        return Int(str) ?? 0
    }
    
    /**
     * 字符串 转 Float
     */
    public var floatValue: Float {
//        let str = self
        let str = self.replacingOccurrences(of: ",", with: ".")
        return Float(str) ?? 0
    }
    
    /**
     * 字符串 转 Double
     */
    public var doubleValue: Double {
//        let str = self
        let str = self.replacingOccurrences(of: ",", with: ".")
        return Double(str) ?? 0
    }
    
    /**
     * 字符串 转 Number
     */
    public var numberValue: NSNumber {
        let str = self
        let value = Int(str) ?? 0
        return NSNumber.init(value: value)
    }
    //MARK:- 字符串转时间戳
   func timeStrChangeTotimeInterval(_ dateFormat:String? = "yyyy-MM-dd") -> String {
       if self.isEmpty {
           return ""
       }
       let format = DateFormatter.init()
       format.dateStyle = .medium
       format.timeStyle = .short
       if dateFormat == nil {
           format.dateFormat = "yyyy-MM-dd"
       }else{
           format.dateFormat = dateFormat
       }
       let date = format.date(from: self)
       return String(date!.timeIntervalSince1970)
   }
}



extension String {
    
    /**
     * 判断是否电话号码 11位并且首位是1
     */
    public func mc_isPhoneNumber() -> Bool {
        if self.count != 11 { return false }
        if self.first != "1" { return false }
        return true
    }

    
    /**
     * 校验密码强度
     * 必须包含字母和数字，长度必须大于等于6
     */
    public func mc_isPassword() -> Bool {
        
        if self.count <= 5 {
            return false
        }
        
        let numberRegex:NSPredicate = NSPredicate(format:"SELF MATCHES %@","^.*[0-9]+.*$")
        let letterRegex:NSPredicate = NSPredicate(format:"SELF MATCHES %@","^.*[A-Za-z]+.*$")
        if numberRegex.evaluate(with: self) && letterRegex.evaluate(with: self) {
            return true
        } else {
            return false
        }
    }
    
}




extension String {
    
    /**
     * 计算字符串的高度
     */
    public func mc_getHeight(font: CGFloat, width: CGFloat) -> CGFloat {
        return mc_getHeight(font: UIFont.systemFont(ofSize: font), width: width)
    }
    
    public func mc_getHeight(font: UIFont, width: CGFloat) -> CGFloat {
        let statusLabelText: NSString = self as NSString
        let size = CGSize.init(width: width, height: 9000)
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context: nil).size
        return strSize.height
    }
    
    /**
     * 计算字符串的宽度
     */
    public func mc_getWidth(font: CGFloat, height: CGFloat) -> CGFloat {
        return mc_getWidth(font: UIFont.systemFont(ofSize: font), height: height)
    }
    public func mc_getWidth(font:UIFont,height:CGFloat) -> CGFloat {
        let statusLabelText: NSString = self as NSString
        let size = CGSize.init(width: 9999, height: height)
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context: nil).size
        return strSize.width
    }
    
    
    /**
     * 截取指定的区间
     */
    public func mc_clip(range: (location: Int, length: Int)) -> String {
        
        if range.location + range.length > self.count {
            return self
        }
        let locationIndex = self.index(startIndex, offsetBy: range.location)
        let range = locationIndex..<self.index(locationIndex, offsetBy: range.length)
        return String(self[range])
    }
    
    
    /**
     * 字符串的截取 从头截取到指定index
     */
    public func mc_clipFromPrefix(to index: Int) -> String {
        
        if self.count <= index {
            return self
        } else {
            let index = self.index(self.startIndex, offsetBy: index)
            let str = self.prefix(upTo: index)
            return String(str)
        }
    }
    /**
     * 字符串的截取 从指定位置截取到尾部
     */
    public func mc_cutToSuffix(from index: Int) -> String {
        // 如果 index 为负数，max(0, index) 会变成 0；如果 index 大于 count，dropFirst 会返回空串
       let safeIndex = Swift.max(0, index)
       return String(self.dropFirst(safeIndex))
//        if self.count < index {
//            return self
//        }else if self.count == index {
//            return ""
//        } else {
//            let selfIndex = self.index(self.startIndex, offsetBy: index)
//            let str = self.suffix(from: selfIndex)
//            return String(str)
//        }
    }
}

extension String {
    
    /**
     * 设置文本的颜色
     */
    public func mc_setMutableColor(_ color: UIColor,range: NSRange) -> NSAttributedString {
        let attributedString = NSMutableAttributedString.init(string: self)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return attributedString
    }
    /**
     * 设置文本的字体大小
     */
    public func mc_setMutableFont(_ font: CGFloat, range: NSRange) -> NSAttributedString {
        let attributedString = NSMutableAttributedString.init(string: self)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: font), range: range)
        return attributedString
    }
    
    /**
     * 设置文本的字体大小和颜色
     */
    public func mc_setMutableFontAndColor(font: CGFloat,
                                          fontRange: NSRange,
                                          color: UIColor,
                                          colorRange: NSRange)
        -> NSAttributedString {
            let attributedString = NSMutableAttributedString.init(string: self)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: colorRange)
            
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: font), range: fontRange)
            return attributedString
    }
    
    /**
     * 设置删除线 NSStrikethroughStyleAttributeName
     */
    public func mc_setDeleteLine() -> NSAttributedString {
        let range = NSMakeRange(0, self.count)
        let attributedString = NSMutableAttributedString.init(string: self)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
        return attributedString
    }
    
    /**
     * 同时设置设置删除线和字体大小
     */
    public func mc_setMutableFontAndDeleteLine(_ font: CGFloat,range: NSRange) -> NSAttributedString {
        let attributedString = NSMutableAttributedString.init(string: self)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
        
        let deleTeRange = NSMakeRange(0, self.count)
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: deleTeRange)
        
        return attributedString
    }
    
    /**
     * 设置文本的行间距
     */
    public func mc_setLineSpace(lineSpace: CGFloat) -> NSAttributedString {
        let text = self
        if text.contains("\r\n"){
            let attrResult = NSMutableAttributedString()
            let textArray: [Substring] = text.split(separator: "\r\n")
            
            for i in 0..<textArray.count{
                let string = ((i == textArray.count - 1)  ? "\(textArray[i])" : "\(textArray[i])\n")
                let attr = self.clipStringForSetLineSpace(string: string, lineSpace: lineSpace)
                attrResult.append(attr)
            }
            return attrResult
        }else{
            let attributedString = NSMutableAttributedString.init(string: self)
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.lineSpacing = lineSpace
            let range = NSRange.init(location: 0, length: self.count)
            DLLog(message: "mc_setLineSpace:\(self.count)")
            DLLog(message: "mc_setLineSpace:\(self)")
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle:paragraphStyle], range: range)
            
            return attributedString
        }
    }
    
    func clipStringForSetLineSpace(string:String,lineSpace: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString.init(string: string)
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.lineSpacing = lineSpace
        let range = NSRange.init(location: 0, length: string.count)
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle:paragraphStyle], range: range)
        
        return attributedString
    }
    
    /**
     * 设置图文详情
     */
    public func mc_setTextAttachment(image: UIImage, imageFrame: CGRect) -> NSMutableAttributedString {
        
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        let nameStr : NSAttributedString = NSAttributedString(string: " " + self, attributes: nil)
        
        let attachment = NSTextAttachment.init()
        attachment.image = image
        attachment.bounds = imageFrame
        
        attributedStrM.append(NSAttributedString(attachment: attachment))
        attributedStrM.append(nameStr)
        return attributedStrM
    }
}

extension String{
/// 判断是不是Emoji
    ///
    /// - Returns: true false
    func containsEmoji()->Bool{
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F,
                 0x1F300...0x1F5FF,
                 0x1F680...0x1F6FF,
                 0x2600...0x26FF,
                 0x2700...0x27BF,
                 0xFE00...0xFE0F:
                return true
            default:
                continue
            }
        }
        
        let controlCharacters = CharacterSet.controlCharacters
        let emojiCharacters = CharacterSet.symbols
        
        return self.rangeOfCharacter(from: controlCharacters.union(emojiCharacters)) != nil
    }
    
    //使用正则表达式替换
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }

/// 判断是不是Emoji
    ///
    /// - Returns: true false
    func hasEmoji()->Bool {
        let pattern = "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    func isChineseNumberAscii()->Bool {
        let pattern = "[^A-Za-z0-9\\u0020\\u4E00-\\u9FA5]"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    func isChineseNumberAsciiSymbols()->Bool {
        let pattern = "[A-Za-z0-9\\u0020\\u4E00-\\u9FA5.<>《》()（）\\x22]"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    /// 在每个字符之间插入 WORD JOINER，保证整段不可拆分换行（适用于中文）
    func noBreakChunk() -> String {
        let wj = "\u{2060}" // WORD JOINER
        return self.map { String($0) }.joined(separator: wj)
    }
    //笔画
    func isStrokes()->Bool {
        let pattern = "[^\\u31C0-\\u31EF]"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    //无空格
    func isChineseNumberAsciiNoWhiteSpace()->Bool {
        let pattern = "[^A-Za-z0-9\\u4E00-\\u9FA5]"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
/// 判断是不是九宫格
    ///
    /// - Returns: true false
    func isNineKeyBoard()->Bool{
        let other : NSString = "➋➌➍➎➏➐➑➒"
        let len = self.count
        for i in 0 ..< len {
            if !(other.range(of: self).location != NSNotFound) {
                return false
            }
        }

        return true
    }
    func isNumber() -> Bool {
        return Double(self) != nil
    }

    /// 然后是去除字符串中的表情
    ///
    /// - Parameter text: text
    func disable_emoji(text : NSString)->String{
        do {
            let regex = try NSRegularExpression(pattern: "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]", options: NSRegularExpression.Options.caseInsensitive)

            let modifiedString = regex.stringByReplacingMatches(in: text as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, text.length), withTemplate: "")
//            DLLog(message: "modifiedString:\(modifiedString)")
            return modifiedString
        } catch {
            print(error)
        }
        return ""
    }
}
