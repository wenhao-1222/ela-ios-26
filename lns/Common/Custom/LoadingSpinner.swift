//
//  LoadingSpinner.swift
//  lns
//
//  Created by Elavatine on 2025/4/28.
//

import UIKit
 
class LoadingSpinner: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
 
    private func setup() {
        activityIndicator.center = center
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
 
    func startAnimating() {
        activityIndicator.startAnimating()
    }
 
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
