//
//  ForumLoadingFooter.swift
//  lns
//  纯loading 的footerView
//  Created by Elavatine on 2025/9/28.
//

import MJRefresh


final class ForumLoadingFooter: MJRefreshBackNormalFooter {
    override func prepare() {
        super.prepare()
        stateLabel?.isHidden = true
        arrowView?.isHidden = true
        loadingView?.hidesWhenStopped = false
        loadingView?.startAnimating()
    }

    override func placeSubviews() {
        super.placeSubviews()
        arrowView?.isHidden = true
        loadingView?.center = CGPoint(x: mj_w * 0.5, y: mj_h * 0.5)
    }

    override var state: MJRefreshState {
        didSet {
            arrowView?.isHidden = true
            switch state {
            case .noMoreData:
                loadingView?.stopAnimating()
                loadingView?.isHidden = true
            default:
                loadingView?.isHidden = false
                loadingView?.startAnimating()
            }
        }
    }
}
