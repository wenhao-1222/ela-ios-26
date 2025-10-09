//
//  LineHeightLabel.swift
//  lns
//
//  Created by Elavatine on 2025/6/25.
//
import UIKit

class LineHeightLabel: UILabel {

    /// 自定义行高。若为 nil，则默认为 font.lineHeight * 1.5
    var customLineHeight: CGFloat?

    /// 字符间距。默认为 nil，不额外设置
    var letterSpacing: CGFloat?

    /// 内容内边距
    var textInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }

    // MARK: - 处理 Text 和 AttributedText

    override var text: String? {
        didSet {
            applyLineHeight(to: text)
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            applyLineHeight(to: attributedText)
        }
    }

    override var font: UIFont! {
        didSet {
            // 更新样式
            if let t = text {
                applyLineHeight(to: t)
            } else if let a = attributedText {
                applyLineHeight(to: a)
            }
        }
    }

    // MARK: - 样式处理

    private func applyLineHeight(to text: String?) {
        guard let text = text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = calculatedLineSpacing()

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font ?? UIFont.systemFont(ofSize: 17),
            .paragraphStyle: paragraphStyle
        ]

        if let spacing = letterSpacing {
            attributes[.kern] = spacing
        }

        let attrString = NSAttributedString(string: text, attributes: attributes)
        super.attributedText = attrString
    }

    private func applyLineHeight(to attrString: NSAttributedString?) {
        guard let attrString = attrString else { return }

        let mutableAttr = NSMutableAttributedString(attributedString: attrString)
        let fullRange = NSRange(location: 0, length: mutableAttr.length)

        mutableAttr.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
            let paragraph = (attributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            paragraph.lineSpacing = calculatedLineSpacing()
            paragraph.alignment = textAlignment

            mutableAttr.addAttribute(.paragraphStyle, value: paragraph, range: range)

            if let spacing = letterSpacing {
                mutableAttr.addAttribute(.kern, value: spacing, range: range)
            }
        }

        super.attributedText = mutableAttr
    }

    private func calculatedLineSpacing() -> CGFloat {
        let baseLineHeight = font?.lineHeight ?? UIFont.systemFont(ofSize: 17).lineHeight
        let targetLineHeight = customLineHeight ?? baseLineHeight * 1.5
        return max(0, targetLineHeight - baseLineHeight)
    }

    // MARK: - 内边距处理

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let insetSize = CGSize(width: size.width - textInsets.left - textInsets.right,
                               height: size.height - textInsets.top - textInsets.bottom)
        let fittingSize = super.sizeThatFits(insetSize)
        return CGSize(width: fittingSize.width + textInsets.left + textInsets.right,
                      height: fittingSize.height + textInsets.top + textInsets.bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        preferredMaxLayoutWidth = bounds.width - textInsets.left - textInsets.right
    }
}

/*
 ///示例
 let label = LineHeightLabel()
 label.font = UIFont.systemFont(ofSize: 16)
 label.customLineHeight = 30
 label.letterSpacing = 1.2
 label.textInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
 label.numberOfLines = 0
 label.text = "这是一个带行距、内边距、字符间距的 UILabel"

 设置富文本：
 let attrString = NSMutableAttributedString(string: "富文本测试", attributes: [
     .foregroundColor: UIColor.red,
     .font: UIFont.boldSystemFont(ofSize: 16)
 ])
 label.attributedText = attrString  // 会自动添加行距/字符间距

 */
