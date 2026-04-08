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
    /// 按倍数设置行高，适合需要跟随字体变化统一调整文案行高的场景
    func setLineHeightMultiple(attr: NSAttributedString? = nil, textString: String? = nil, lineHeightMultiple: CGFloat) {
        let sourceAttributedText = attr ?? self.attributedText
        let sourceText = textString ?? self.text ?? sourceAttributedText?.string ?? ""
        guard sourceText.isEmpty == false else { return }

        let attributedString: NSMutableAttributedString
        if let sourceAttributedText {
            attributedString = NSMutableAttributedString(attributedString: sourceAttributedText)
        } else {
            attributedString = NSMutableAttributedString(string: sourceText, attributes: [
                .font: self.font as Any,
                .foregroundColor: self.textColor as Any
            ])
        }

        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttributes(in: range, options: []) { attributes, subRange, _ in
            let paragraphStyle = (attributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
            paragraphStyle.alignment = self.textAlignment
            paragraphStyle.lineBreakMode = self.lineBreakMode
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: subRange)

            if attributes[.font] == nil, let font = self.font {
                attributedString.addAttribute(.font, value: font, range: subRange)
            }
            if attributes[.foregroundColor] == nil, let textColor = self.textColor {
                attributedString.addAttribute(.foregroundColor, value: textColor, range: subRange)
            }
        }

        self.attributedText = attributedString
        self.sizeToFit()
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
