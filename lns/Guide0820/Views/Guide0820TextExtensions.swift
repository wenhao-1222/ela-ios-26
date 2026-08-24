//
//  Guide0820TextExtensions.swift
//  lns
//
//  Created by Codex on 2026/8/24.
//

import UIKit

extension UILabel {
    /// 给当前 label 文本设置行间距。
    /// - Parameter spacing: 需要设置的行间距。
    func guide0820SetLineSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = spacing
        attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font as Any,
                .foregroundColor: textColor as Any,
                .paragraphStyle: paragraphStyle
            ]
        )
    }

    /// 给当前 label 文本设置固定行高。
    /// - Parameter lineHeight: 需要设置的行高。
    func guide0820SetLineHeight(_ lineHeight: CGFloat) {
        guard let text = text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font as Any,
                .foregroundColor: textColor as Any,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}

extension NSMutableAttributedString {
    /// 给指定文本添加链接属性。
    /// - Parameters:
    ///   - text: 需要命中的文本。
    ///   - urlString: 链接地址。
    func guide0820AddLink(_ text: String, urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let range = (string as NSString).range(of: text)
        guard range.location != NSNotFound else { return }
        addAttributes([
            .foregroundColor: UIColor.THEME,
            .link: url
        ], range: range)
    }
}
