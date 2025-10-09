//
//  MJRefreshHeader+Exs.swift
//  lns
//
//  Created by Elavatine on 2025/5/7.
//
import MJRefresh

extension MJRefreshHeader {
    /// 直接进入刷新状态，不带下拉动画
    func beginRefreshingWithoutAnimation() {
        guard state != .refreshing else { return }

        self.state = .refreshing
        self.scrollView?.setContentOffset(CGPoint(x: 0, y: -self.mj_h), animated: false)
        self.executeRefreshingCallback()
    }
    
}
