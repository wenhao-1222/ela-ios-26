//
//  ElaExpandedTapButton.swift
//  lns
//  扩大点击范围
//  Created by LNS2 on 2026/3/9.
//

class ElaExpandedTapButton: UIButton {
    /// Negative values expand the tappable area without changing layout size.
    var hitTestEdgeInsets: UIEdgeInsets = .init(top: -12, left: -12, bottom: -12, right: -12)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.inset(by: hitTestEdgeInsets).contains(point)
    }
}
