//
//  FPSMonitor.swift
//  lns
//
//  Created by Elavatine on 2025/5/7.
//

import UIKit

class FPSMonitor {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0

    var onUpdate: ((Int) -> Void)? // 回调，返回当前 FPS

    func startMonitoring() {
        stopMonitoring() // 避免重复添加

        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
        frameCount = 0
    }

    @objc private func tick(link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let delta = link.timestamp - lastTimestamp
        if delta >= 1.0 {
            let fps = Int(round(Double(frameCount) / delta))
            onUpdate?(fps)

            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
