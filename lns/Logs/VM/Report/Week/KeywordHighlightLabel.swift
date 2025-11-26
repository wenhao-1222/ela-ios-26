final class KeywordHighlightLabel: UILabel {

    struct HighlightConfig {
        var font: UIFont
        var textColor: UIColor
        var underlineColor: UIColor
        var underlineThickness: CGFloat
    }

    var config = HighlightConfig(
        font: .systemFont(ofSize: 16, weight: .semibold),
        textColor: .COLOR_BG_BLACK,
        underlineColor: .THEME,
        underlineThickness: kFitWidth(4)
    )

    var textInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
            invalidateIntrinsicContentSize()
        }
    }

    private var keywordRanges: [NSRange] = []

    func setText(_ text: String,
                 keywords: [String],
                 lineSpacing: CGFloat = 8) {

        let para = NSMutableParagraphStyle()
        para.lineSpacing = lineSpacing

        let baseFont = self.font ?? UIFont.systemFont(ofSize: 14)
        let baseColor = self.textColor ?? .COLOR_BG_BLACK

        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: baseFont,
            .foregroundColor: baseColor,
            .paragraphStyle: para
        ])

        keywordRanges.removeAll()

        for kw in keywords where !kw.isEmpty {
            for r in ranges(of: kw, in: text) {
                attr.addAttributes([
                    .font : config.font,
                    .foregroundColor : config.textColor
                ], range: r)
                keywordRanges.append(r)
            }
        }

        attributedText = attr
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }

    override var intrinsicContentSize: CGSize {
        guard let attrText = attributedText else {
            return super.intrinsicContentSize
        }

        let size = CGSize(
            width: preferredMaxLayoutWidth - textInsets.left - textInsets.right,
            height: .greatestFiniteMagnitude
        )
        let rect = attrText.boundingRect(with: size,
                                         options: [.usesLineFragmentOrigin, .usesFontLeading],
                                         context: nil)
        return CGSize(
            width: ceil(rect.width) + textInsets.left + textInsets.right,
            height: ceil(rect.height) + textInsets.top + textInsets.bottom
        )
    }
    override func draw(_ rect: CGRect) {
        guard let attrText = attributedText,
              let ctx = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            return
        }

        // 1. 文本容器 & 布局
        let padded = rect.inset(by: textInsets)
        let container = NSTextContainer(size: padded.size)
        container.maximumNumberOfLines = numberOfLines
        container.lineFragmentPadding = 0

        let lm = NSLayoutManager()
        let ts = NSTextStorage(attributedString: attrText)
        ts.addLayoutManager(lm)
        lm.addTextContainer(container)
        lm.ensureLayout(for: container)

        ctx.saveGState()
        ctx.translateBy(x: padded.minX, y: padded.minY)
        ctx.setStrokeColor(config.underlineColor.cgColor)
        ctx.setLineWidth(config.underlineThickness)

        // 2. 字体指标
        let ctFont = CTFontCreateWithName(config.font.fontName as CFString,
                                          config.font.pointSize, nil)
        let ascent   = CTFontGetAscent(ctFont)
        let descent  = CTFontGetDescent(ctFont)
        let extraGap = config.underlineThickness * 0.75

        // 3. 针对每个关键词范围，收集并合并 segments
        for charRange in keywordRanges {
            // 3.1 整段字符 -> glyphRange
            let glyphRange = lm.glyphRange(
                forCharacterRange: charRange,
                actualCharacterRange: nil
            )
            // 用来累积每个连续段：[(lineY, startX, endX)]
            var segments: [(lineY: CGFloat, startX: CGFloat, endX: CGFloat)] = []

            // 3.2 遍历所有 glyph
            for glyphIndex in glyphRange.location ..< glyphRange.location + glyphRange.length {
                let singleGR = NSRange(location: glyphIndex, length: 1)
                let glyphRect = lm.boundingRect(forGlyphRange: singleGR, in: container)
                // 跳过无宽度的 glyph（空白、控制字符等）
                guard glyphRect.width > 0.1 else { continue }

                let y0 = glyphRect.origin.y
                let x0 = glyphRect.minX
                let x1 = glyphRect.maxX

                // 3.3 看看能否合并到最后一个 segment
                if var last = segments.last,
                   abs(last.lineY - y0) < 1.0,         // 同一行（阈值1pt）
                   x0 <= last.endX + 1.0               // 紧邻或略有重叠
                {
                    // 扩展尾端
                    last.endX = max(last.endX, x1)
                    segments[segments.count - 1] = last
                } else {
                    // 新开一段
                    segments.append((lineY: y0, startX: x0, endX: x1))
                }
            }

            // 4. 绘制合并后的每段下划线
            for seg in segments {
                let baselineY  = seg.lineY + CGFloat(ascent)
                let underlineY = baselineY + CGFloat(descent) + extraGap

                ctx.move(to: CGPoint(x: seg.startX, y: underlineY))
                ctx.addLine(to: CGPoint(x: seg.endX,   y: underlineY))
                ctx.strokePath()
            }
        }

        ctx.restoreGState()
        super.drawText(in: padded)
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        var textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        textRect.origin.x -= textInsets.left
        textRect.origin.y -= textInsets.top
        textRect.size.width += (textInsets.left + textInsets.right)
        textRect.size.height += (textInsets.top + textInsets.bottom)
        return textRect
    }

    private var lastSize: CGSize = .zero
    override func layoutSubviews() {
        super.layoutSubviews()
        numberOfLines = 0
        let width = bounds.width
        if preferredMaxLayoutWidth != width {
            preferredMaxLayoutWidth = width
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    private func ranges(of kw: String, in full: String) -> [NSRange] {
        var result: [NSRange] = []
        let ns = full as NSString
        var search = NSRange(location: 0, length: ns.length)
        while true {
            let r = ns.range(of: kw, options: [], range: search)
            guard r.location != NSNotFound else { break }
            result.append(r)
            search = NSRange(location: r.upperBound,
                             length: ns.length - r.upperBound)
        }
        return result
    }
}
