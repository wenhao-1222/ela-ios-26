//
//  CompactWindow.swift
//  lns
//
//  Created by Elavatine on 2025/3/27.
//

// MARK: - CompactWindow
class CompactWindow: UIWindow {
    override var traitCollection: UITraitCollection {
        let currentTraits = super.traitCollection
        // 合并当前 Trait 并覆盖 horizontalSizeClass
        return UITraitCollection(traitsFrom: [
            currentTraits,
            UITraitCollection(horizontalSizeClass: .compact)
        ])
    }
}
