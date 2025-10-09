//
//  UILabel+WHExs.swift
//  lns
//
//  Created by LNS2 on 2024/3/28.
//

import Foundation


extension UILabel{
    ///设置行距
    func setLineSpace(lineSpcae:CGFloat,textString:String)  {
        // 创建NSMutableParagraphStyle来设置行高
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpcae // 设置额外的行高
         
        // 创建NSAttributedString并应用行高
        let attributedString = NSMutableAttributedString(string: "\(textString)")
        let range = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
         
        // 应用NSAttributedString到UILabel
        self.attributedText = attributedString
        self.sizeToFit() // 自动计算高度，包括行高
    }
    func setLineSpace(lineSpcae:CGFloat,textString:String,lineHeight:CGFloat)  {
        // 创建NSMutableParagraphStyle来设置行高
        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = lineSpcae // 设置额外的行高
        paragraphStyle.lineHeightMultiple = lineHeight
         
        // 创建NSAttributedString并应用行高
        let attributedString = NSMutableAttributedString(string: "\(textString)")
        let range = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
//        attributedString.yy_minimumLineHeight = lineHeight
        // 应用NSAttributedString到UILabel
        self.attributedText = attributedString
        self.sizeToFit() // 自动计算高度，包括行高
    }
    ///对富文本设置行高
    func setLineHeight(attr:NSAttributedString? = nil,textString:String? = nil,lineHeight:CGFloat)  {
        let fontLineHeight = self.font.lineHeight
        let baselineOffset = (lineHeight - fontLineHeight) / 2
        
        // 创建NSMutableParagraphStyle来设置行高
        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [
           .paragraphStyle: paragraphStyle,
           .font: self.font as Any,
           .foregroundColor: self.textColor as Any,
           .baselineOffset: baselineOffset
       ]

//       self.attributedText = NSAttributedString(string: text, attributes: attributes)
        
         
        // 创建NSAttributedString并应用行高
        var attributedString = NSMutableAttributedString()
        if attr != nil{
            attributedString = NSMutableAttributedString(attributedString: attr!)
        }else if textString != nil{
            attributedString = NSMutableAttributedString(string: "\(textString ?? "")")
        }
        
        let range = NSMakeRange(0, attributedString.length)
//        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        attributedString.setAttributes(attributes, range: range)
        
        self.attributedText = attributedString
        self.sizeToFit() // 自动计算高度，包括行高
    }
    /// 设置字间距（kern）
    /// - Parameters:
    ///   - spacing: 字符间距（单位：point）
    ///   - text: 可选传入文本，不传则使用当前文本
    func setCharacterSpacing(_ spacing: CGFloat, text: String? = nil) {
        let labelText = text ?? self.text ?? ""
        let attributedString = NSMutableAttributedString(string: labelText)
        // 设置除最后一个字符外的字间距
        let range = NSRange(location: 0, length: max(0, labelText.count - 1))
        attributedString.addAttribute(.kern, value: spacing, range: range)
        self.attributedText = attributedString
    }
}
