//
//  UILabel+Exs.swift
//  ttjx
//
//  Created by 文 on 2022/10/12.
//  Copyright © 2022 ttjx. All rights reserved.
//

import Foundation
import UIKit


extension UILabel{
    //计算label的行数
    func getRealLabelTextLines() -> Int {
        guard let labelText = text else {
            return 0
        }
        //计算理论上显示所有文字需要的尺寸
        let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelTextSize = (labelText as NSString)
            .boundingRect(with: rect, options: .usesFontLeading,attributes: [NSAttributedString.Key.font: self.font!], context: nil)
        //计算理论上需要的行数
        let labelTextLines = Int(ceil(CGFloat(labelTextSize.height) / self.font.lineHeight))
        return labelTextLines
    }
    /// “｜”分隔展示：段内不拆，行首不出现“｜”，行尾不出现“｜”
    func setTagText(_ text: String) {
        let normalized = text.replacingOccurrences(of: "|", with: "｜")

        // 切分并清理
        let chunks = normalized
            .components(separatedBy: "｜")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !chunks.isEmpty else {
            self.text = nil
            return
        }

        // 分隔符：WORD JOINER + "｜" + 普通空格
        // 断行只会发生在这个“普通空格”处，故不会行首/行尾是“｜”
        let sep = "\u{2060}｜ "

        // 段内加 WORD JOINER，保证整体性
        let protected = chunks.map { $0.noBreakChunk() }
        let result = protected.joined(separator: sep)

        self.text = result
    }
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copyText) {
            return true
        }
        return false
    }
    @objc private func copyText() {
        UIPasteboard.general.string = self.text
    }
}
