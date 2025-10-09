//
//  Untitled.swift
//  lns
//
//  Created by Elavatine on 2025/7/4.
//

import UIKit

/// A transparent container that allows touches outside the popup view to pass
/// through while providing a callback to dismiss the popup.
class ActionPopupBackgroundView: UIView {
    weak var popupView: UIView?
    var outsideTapHandler: (() -> Void)?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let popup = popupView, popup.frame.contains(point) {
            return popup.hitTest(convert(point, to: popup), with: event)
        }
        outsideTapHandler?()
        return nil
    }
}
