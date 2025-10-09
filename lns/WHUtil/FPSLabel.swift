//
//  FPSLabel.swift
//  lns
//
//  Created by Elavatine on 2025/5/7.
//

import UIKit

class FPSLabel: UILabel {

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        textColor = .white
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        textAlignment = .center
        layer.cornerRadius = 5
        layer.masksToBounds = true

        displayLink = CADisplayLink(target: self, selector: #selector(tick(link:)))
        displayLink?.add(to: .main, forMode: .common)
    }

    deinit {
        displayLink?.invalidate()
    }

    @objc private func tick(link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let delta = link.timestamp - lastTimestamp
        if delta >= 1 {
            let fps = Int(round(Double(frameCount) / delta))
            text = "FPS: \(fps)"

            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}

class FPSMonitorManager {
    static let shared = FPSMonitorManager()
    private var label: FPSLabel?

    func show(in window: UIWindow) {
        if label == nil {
            label = FPSLabel(frame: CGRect(x: 50, y: 50, width: 80, height: 30))
            window.addSubview(label!)
        }
    }

    func hide() {
        label?.removeFromSuperview()
        label = nil
    }
}
