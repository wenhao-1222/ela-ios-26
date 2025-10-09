//
//  AutoSizingTextView.swift
//  lns
//
//  Created by LNS2 on 2024/7/24.
//

import Foundation

class AutoSizingTextView: UITextView, UITextViewDelegate {
 
    // 初始化时设置默认高度
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.delegate = self
        self.isScrollEnabled = false
//        self.isEditable = false
        self.translatesAutoresizingMaskIntoConstraints = false
//        self.adjustsFontForContentSizeCategory = true // 可选，根据字体大小偏好调整文本视图的字体
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.isScrollEnabled = false
//        self.isEditable = false
    }
 
    // 当文本改变时，动态调整高度
    func textViewDidChange(_ textView: UITextView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        // 计算文本高度
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
}
