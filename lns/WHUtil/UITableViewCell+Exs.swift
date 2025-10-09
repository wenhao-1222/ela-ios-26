//
//  UITableViewCell+Exs.swift
//  lns
//
//  Created by Elavatine on 2025/4/23.
//

import SkeletonView

extension UITableViewCell{
    func showAnimatedSkeleton() {
        self.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .COLOR_LIGHT_GREY), animation: nil)
    }
    
    func hideSkeleton() {
        self.hideSkeleton(reloadDataAfter: false, transition: .crossDissolve(0.25))
    }
}
