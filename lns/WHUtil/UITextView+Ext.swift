//
//  UITextView+Ext.swift
//  lns
//
//  Created by Elavatine on 2024/12/6.
//

extension UITextView{
    func numberOfLines() -> Int {
        guard let font = self.font else { return 0 }
        let lineHeight = font.lineHeight
        let contentHeight = self.contentSize.height
        return Int(contentHeight / lineHeight)
    }
    
}
