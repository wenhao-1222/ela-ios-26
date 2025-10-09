//
//  PaddingLabel.swift
//  lns
//
//  Created by Elavatine on 2025/7/2.
//

class PaddingLabel: UILabel {
    var contentInsets = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7)

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: contentInsets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInsets.left + contentInsets.right,
                      height: size.height + contentInsets.top + contentInsets.bottom)
    }
}
